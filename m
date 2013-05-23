From: Daniel Petre <daniel.petre@rcs-rds.ro>
Subject: Re: [PATCH] ip_gre: fix kernel panic with icmp_dest_unreach
Date: Thu, 23 May 2013 19:59:02 +0300
Message-ID: <7233D50E-0C6D-44B3-9B61-98C8998C3BDD@rcs-rds.ro>
References: <D2CA09D3-A93C-48CF-A23B-DC1B76D66818@rcs-rds.ro> <1369170063.3301.251.camel@edumazet-glaptop> <519C839E.1000309@rcs-rds.ro>  <1369222666.3301.304.camel@edumazet-glaptop> <519CB0D3.8000406@rcs-rds.ro> <1369230739.3301.334.camel@edumazet-glaptop> <519CE6F0.3040703@rcs-rds.ro> <519DD7A4.9090801@rcs-rds.ro> <1369324409.3301.382.camel@edumazet-glaptop>
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailproxy.rcs-rds.ro ([212.54.120.14]:36513 "EHLO
	mailproxy.rcs-rds.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756558Ab3EWQ7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 12:59:05 -0400
In-Reply-To: <1369324409.3301.382.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 23, 2013, at 6:53 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2013-05-23 at 11:47 +0300, Daniel Petre wrote:
> 
>> 
>> Hello again Eric,
>> we applied the little patch from:
>> http://lkml.indiana.edu/hypermail/linux/kernel/1007.0/00961.html
>> we have flapped the link few times and everything recovered smooth.
>> 
> 
> Thats a very good catch, now we have to fix the bug at the right place.
> 

Hey Eric,
maybe this could work?

--- linux-3.8.13/net/ipv4/ip_gre.c.orig	2013-05-23 19:54:58.317798942 +0300
+++ linux-3.8.13/net/ipv4/ip_gre.c	2013-05-23 19:56:30.290029424 +0300
@@ -882,7 +882,7 @@ static netdev_tx_t ipgre_tunnel_xmit(str
 		if (time_before(jiffies,
 				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
 			tunnel->err_count--;
-
+			memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 			dst_link_failure(skb);
 		} else
 			tunnel->err_count = 0;


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
