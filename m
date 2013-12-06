From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: auto corking
Date: Fri, 06 Dec 2013 12:54:17 -0500 (EST)
Message-ID: <20131206.125417.1287943279062327392.davem@davemloft.net>
References: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758525Ab3LFRyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:54:21 -0500
In-Reply-To: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Dec 2013 22:36:05 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> With the introduction of TCP Small Queues, TSO auto sizing, and TCP
> pacing, we can implement Automatic Corking in the kernel, to help
> applications doing small write()/sendmsg() to TCP sockets.
> 
> Idea is to change tcp_push() to check if the current skb payload is
> under skb optimal size (a multiple of MSS bytes)
> 
> If under 'size_goal', and at least one packet is still in Qdisc or
> NIC TX queues, set the TCP Small Queue Throttled bit, so that the push
> will be delayed up to TX completion time.
> 
> This delay might allow the application to coalesce more bytes
> in the skb in following write()/sendmsg()/sendfile() system calls.
> 
> The exact duration of the delay is depending on the dynamics
> of the system, and might be zero if no packet for this flow
> is actually held in Qdisc or NIC TX ring.
> 
> Using FQ/pacing is a way to increase the probability of
> autocorking being triggered.
> 
> Add a new sysctl (/proc/sys/net/ipv4/tcp_autocorking) to control
> this feature and default it to 1 (enabled)
> 
> Add a new SNMP counter : nstat -a | grep TcpExtTCPAutoCorking
> This counter is incremented every time we detected skb was under used
> and its flush was deferred.
> 
> Tested:
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks fantastic, applied, thanks!
