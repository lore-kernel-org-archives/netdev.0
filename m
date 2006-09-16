From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.18-rc[67] crashes in TCP ack handling
Date: Sun, 17 Sep 2006 08:32:14 +0900
Message-ID: <20060917083214.45b5f61f@localhost.localdomain>
References: <20060916221948.GA12421@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51858 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964860AbWIPXcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2006 19:32:25 -0400
To: bert hubert <bert.hubert@netherlabs.nl>
In-Reply-To: <20060916221948.GA12421@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 17 Sep 2006 00:19:48 +0200
bert hubert <bert.hubert@netherlabs.nl> wrote:

> The bad news is that I haven't yet been able to capture traces. 
> Once every three days or so I get a crash of 2.6.18-rc[67] which
> *probably* end in tcp_ack(), but I don't have the exact dump.
> 
> My .config is indeed heavy on TCP congestion stuff:
> 
> $ zcat /proc/config.gz | grep -i tcp
> CONFIG_INET_TCP_DIAG=y
> CONFIG_TCP_CONG_ADVANCED=y
> # TCP congestion control
> CONFIG_TCP_CONG_BIC=y
> CONFIG_TCP_CONG_CUBIC=y
> CONFIG_TCP_CONG_WESTWOOD=y
> CONFIG_TCP_CONG_HTCP=y
> CONFIG_TCP_CONG_HSTCP=y
> CONFIG_TCP_CONG_HYBLA=y
> CONFIG_TCP_CONG_VEGAS=y
> CONFIG_TCP_CONG_SCALABLE=y
> CONFIG_TCP_CONG_LP=y
> CONFIG_TCP_CONG_VENO=y
> CONFIG_IP_VS_PROTO_TCP=y
> CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
> CONFIG_IP_NF_TARGET_TCPMSS=y
> # CONFIG_NET_TCPPROBE is not set
> # CONFIG_ISCSI_TCP is not set
> # CONFIG_NFSD_TCP is not set
> 
> However, I haven't specifically configured anything.
> $ dmesg | grep -i tcp 
> [   33.106317] TCP established hash table entries: 131072 (order: 8, 1048576
> bytes)
> [   33.107086] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
> [   33.107476] TCP: Hash tables configured (established 131072 bind 65536)
> [   33.107605] TCP reno registered
> [   40.985770] IPVS: Registered protocols (TCP, UDP, AH, ESP)
> [   41.105710] TCP bic registered
> [   41.105833] TCP cubic registered
> [   41.105957] TCP westwood registered
> [   41.106080] TCP highspeed registered
> [   41.106203] TCP hybla registered
> [   41.106328] TCP htcp registered
> [   41.106452] TCP vegas registered
> [   41.106574] TCP veno registered
> [   41.106698] TCP scalable registered
> [   41.106822] TCP lp registered
> 
> $ cat ipv4/tcp_congestion_control
> lp
> 
> I hope to follow up this message with the actual backtrace, but this is
> already an heads up. 
> 
> Sorry for not yet being able to be more specific.
> 
> 	bert

By building all the possiblities into the kernel, ie. not as modules
you get the last one registered. TCP LP is probably the worst one
to use, because it is designed for bulk low priority applications.
It also is one of the newest least tested.  Right now, I would rate
the choices as:
	Stable: reno, bic, htcp, westwood, cubic
	Testing: hybla, highspeed, scaleable, vegas
	Unstable: veno, lp

The stable ones seem to be reliable and have no known issues.
The testing group are only interesting for comparison, and need more
tuning. The unstable group, are new and need even more testing
for fairness and robustness.

Without a back trace, it will be hard to find the bug in TCP LP
