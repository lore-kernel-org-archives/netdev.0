From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] ip6tunnel: make rx/tx bytes counters consistent
Date: Sun, 20 Sep 2015 22:35:18 -0700 (PDT)
Message-ID: <20150920.223518.1988314641746373948.davem@davemloft.net>
References: <1442569661-5528-1-git-send-email-nicolas.dichtel@6wind.com>
	<1442569661-5528-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756001AbbIUFfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 01:35:19 -0400
In-Reply-To: <1442569661-5528-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 18 Sep 2015 11:47:41 +0200

> Like the previous patch, which fixes ipv4 tunnels, here is the ipv6 part.
> 
> Before the patch, the external ipv6 header + gre header were included on
> tx.
> 
> After the patch:
> $ ping -c1 192.168.6.121 ; ip -s l ls dev ip6gre1
> PING 192.168.6.121 (192.168.6.121) 56(84) bytes of data.
> 64 bytes from 192.168.6.121: icmp_req=1 ttl=64 time=1.92 ms
> 
> --- 192.168.6.121 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev = 1.923/1.923/1.923/0.000 ms
> 7: ip6gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1440 qdisc noqueue state UNKNOWN mode DEFAULT group default
>     link/gre6 20:01:06:60:30:08:c1:c3:00:00:00:00:00:00:01:23 peer 20:01:06:60:30:08:c1:c3:00:00:00:00:00:00:01:21
>     RX: bytes  packets  errors  dropped overrun mcast
>     84         1        0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     84         1        0       0       0       0
> $ ping -c1 192.168.1.121 ; ip -s l ls dev ip6tnl1
> PING 192.168.1.121 (192.168.1.121) 56(84) bytes of data.
> 64 bytes from 192.168.1.121: icmp_req=1 ttl=64 time=2.28 ms
> 
> --- 192.168.1.121 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev = 2.288/2.288/2.288/0.000 ms
> 8: ip6tnl1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1452 qdisc noqueue state UNKNOWN mode DEFAULT group default
>     link/tunnel6 2001:660:3008:c1c3::123 peer 2001:660:3008:c1c3::121
>     RX: bytes  packets  errors  dropped overrun mcast
>     84         1        0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     84         1        0       0       0       0
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
