From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Thu, 08 Feb 2007 07:26:20 +0900 (JST)
Message-ID: <20070208.072620.63000777.yoshfuji@linux-ipv6.org>
References: <20070206200915.GC10707@hmsreliant.homelinux.net>
	<45C8EF75.6070506@hp.com>
	<20070207205503.GB20804@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54175 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161461AbXBGWY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 17:24:56 -0500
In-Reply-To: <20070207205503.GB20804@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070207205503.GB20804@hmsreliant.homelinux.net> (at Wed, 7 Feb 2007 15:55:03 -0500), Neil Horman <nhorman@tuxdriver.com> says:

> @@ -559,7 +562,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
>  		return;
>  
>  	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
> -	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
> +	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr); 
>  	if (send_llinfo)
>  		len += ndisc_opt_addr_space(dev);
>  

trailing space

> @@ -637,7 +660,7 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
>  		return;
>  
>  	len = sizeof(struct icmp6hdr);
> -	if (dev->addr_len)
> +	if (dev->addr_len && send_sllao)
>  		len += ndisc_opt_addr_space(dev);
>  
>          skb = sock_alloc_send_skb(sk,

if (send_sllao)

> @@ -664,7 +687,7 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
>  
>  	opt = (u8*) (hdr + 1);
>  
> -	if (dev->addr_len)
> +	if (dev->addr_len && send_sllao)
>  		ndisc_fill_addr_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
>  				       dev->addr_len, dev->type);
>  

ditto.

--yoshfuji
