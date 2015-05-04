From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] codel: fix maxpacket/mtu confusion
Date: Sun, 03 May 2015 22:18:10 -0400 (EDT)
Message-ID: <20150503.221810.908470058524978930.davem@davemloft.net>
References: <1430412040.3711.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nichols@pollere.com, vanj@google.com, dave.taht@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbbEDCSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 22:18:12 -0400
In-Reply-To: <1430412040.3711.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Apr 2015 09:40:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Under presence of TSO/GSO/GRO packets, codel at low rates can be quite
> useless. In following example, not a single packet was ever dropped,
> while average delay in codel queue is ~100 ms !
> 
> qdisc codel 0: parent 1:12 limit 16000p target 5.0ms interval 100.0ms 
>  Sent 134376498 bytes 88797 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 13626b 3p requeues 0 
>   count 0 lastcount 0 ldelay 96.9ms drop_next 0us
>   maxpacket 9084 ecn_mark 0 drop_overlimit 0
> 
> This comes from a confusion of what should be the minimal backlog. It is
> pretty clear it is not 64KB or whatever max GSO packet ever reached the
> qdisc.
> 
> codel intent was to use MTU of the device.
> 
> After the fix, we finally drop some packets, and rtt/cwnd of my single
> TCP flow are meeting our expectations.
> 
> qdisc codel 0: parent 1:12 limit 16000p target 5.0ms interval 100.0ms 
>  Sent 102798497 bytes 67912 pkt (dropped 1365, overlimits 0 requeues 0) 
>  backlog 6056b 3p requeues 0 
>   count 1 lastcount 1 ldelay 36.3ms drop_next 0us
>   maxpacket 10598 ecn_mark 0 drop_overlimit 0
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
