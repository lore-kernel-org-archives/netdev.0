From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH V3 1/8] net: add limit for socket backlog
Date: Fri, 5 Mar 2010 10:00:25 -0300
Message-ID: <20100305130025.GC16539@ghostprotocols.net>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f185.google.com ([209.85.210.185]:54034 "EHLO
	mail-yx0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784Ab0CEN2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 08:28:37 -0500
Received: by yxe15 with SMTP id 15so2121228yxe.25
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 05:28:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Mar 05, 2010 at 12:01:40PM +0800, Zhu Yi escreveu:
> We got system OOM while running some UDP netperf testing on the loopback
> device. The case is multiple senders sent stream UDP packets to a single
> receiver via loopback on local host. Of course, the receiver is not able
> to handle all the packets in time. But we surprisingly found that these
> packets were not discarded due to the receiver's sk->sk_rcvbuf limit.
> Instead, they are kept queuing to sk->sk_backlog and finally ate up all
> the memory. We believe this is a secure hole that a none privileged user
> can crash the system.
> 
> The root cause for this problem is, when the receiver is doing
> __release_sock() (i.e. after userspace recv, kernel udp_recvmsg ->
> skb_free_datagram_locked -> release_sock), it moves skbs from backlog to
> sk_receive_queue with the softirq enabled. In the above case, multiple
> busy senders will almost make it an endless loop. The skbs in the
> backlog end up eat all the system memory.
> 
> The issue is not only for UDP. Any protocols using socket backlog is
> potentially affected. The patch adds limit for socket backlog so that
> the backlog size cannot be expanded endlessly.

>From visual inspection (no testing):

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo
