From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] icmp: add a global rate limitation
Date: Tue, 23 Sep 2014 12:48:07 -0400 (EDT)
Message-ID: <20140923.124807.784868084262929714.davem@davemloft.net>
References: <1411137520.26859.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129AbaIWQsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 12:48:09 -0400
In-Reply-To: <1411137520.26859.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Sep 2014 07:38:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Current ICMP rate limiting uses inetpeer cache, which is an RBL tree
> protected by a lock, meaning that hosts can be stuck hard if all cpus
> want to check ICMP limits.
> 
> When say a DNS or NTP server process is restarted, inetpeer tree grows
> quick and machine comes to its knees.
> 
> iptables can not help because the bottleneck happens before ICMP
> messages are even cooked and sent.
> 
> This patch adds a new global limitation, using a token bucket filter,
> controlled by two new sysctl :
> 
> icmp_msgs_per_sec - INTEGER
>     Limit maximal number of ICMP packets sent per second from this host.
>     Only messages whose type matches icmp_ratemask are
>     controlled by this limit.
>     Default: 1000
> 
> icmp_msgs_burst - INTEGER
>     icmp_msgs_per_sec controls number of ICMP packets sent per second,
>     while icmp_msgs_burst controls the burst size of these packets.
>     Default: 50
> 
> Note that if we really want to send millions of ICMP messages per
> second, we might extend idea and infra added in commit 04ca6973f7c1a
> ("ip: make IP identifiers less predictable") :
> add a token bucket in the ip_idents hash and no longer rely on inetpeer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
