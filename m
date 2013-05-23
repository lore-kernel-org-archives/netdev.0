From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: fix kernel panic with icmp_dest_unreach
Date: Thu, 23 May 2013 10:11:28 -0700
Message-ID: <1369329088.3301.390.camel@edumazet-glaptop>
References: <D2CA09D3-A93C-48CF-A23B-DC1B76D66818@rcs-rds.ro>
	 <1369170063.3301.251.camel@edumazet-glaptop> <519C839E.1000309@rcs-rds.ro>
	  <1369222666.3301.304.camel@edumazet-glaptop> <519CB0D3.8000406@rcs-rds.ro>
	 <1369230739.3301.334.camel@edumazet-glaptop> <519CE6F0.3040703@rcs-rds.ro>
	 <519DD7A4.9090801@rcs-rds.ro> <1369324409.3301.382.camel@edumazet-glaptop>
	 <7233D50E-0C6D-44B3-9B61-98C8998C3BDD@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Petre <daniel.petre@rcs-rds.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35582 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757813Ab3EWRLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 13:11:30 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq12so3233004pab.12
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 10:11:30 -0700 (PDT)
In-Reply-To: <7233D50E-0C6D-44B3-9B61-98C8998C3BDD@rcs-rds.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 19:59 +0300, Daniel Petre wrote:
> On May 23, 2013, at 6:53 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Thu, 2013-05-23 at 11:47 +0300, Daniel Petre wrote:
> > 
> >> 
> >> Hello again Eric,
> >> we applied the little patch from:
> >> http://lkml.indiana.edu/hypermail/linux/kernel/1007.0/00961.html
> >> we have flapped the link few times and everything recovered smooth.
> >> 
> > 
> > Thats a very good catch, now we have to fix the bug at the right place.
> > 
> 
> Hey Eric,
> maybe this could work?
> 
> --- linux-3.8.13/net/ipv4/ip_gre.c.orig	2013-05-23 19:54:58.317798942 +0300
> +++ linux-3.8.13/net/ipv4/ip_gre.c	2013-05-23 19:56:30.290029424 +0300
> @@ -882,7 +882,7 @@ static netdev_tx_t ipgre_tunnel_xmit(str
>  		if (time_before(jiffies,
>  				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
>  			tunnel->err_count--;
> -
> +			memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>  			dst_link_failure(skb);
>  		} else
>  			tunnel->err_count = 0;
> 

Not exactly, please try the patch I sent.

Thanks !
