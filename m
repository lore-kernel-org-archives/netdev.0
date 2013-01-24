From: walter harms <wharms@bfs.de>
Subject: Re: [patch] ip6mr: limit IPv6 MRT_TABLE identifiers
Date: Thu, 24 Jan 2013 09:22:56 +0100
Message-ID: <5100EF60.1080409@bfs.de>
References: <20130124063834.GA5611@elgon.mountain>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:26015 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab3AXI3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 03:29:06 -0500
In-Reply-To: <20130124063834.GA5611@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 24.01.2013 07:38, schrieb Dan Carpenter:
> We did this for IPv4 in b49d3c1e1c "net: ipmr: limit MRT_TABLE
> identifiers" but we need to do it for IPv6 as well.  On IPv6 the name
> is "pim6reg" instead of "pimreg" so there is one less digit allowed.
> 
> The strcpy() is in ip6mr_reg_vif().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index acc3249..351ce98 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -1766,6 +1766,9 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
>  			return -EINVAL;
>  		if (get_user(v, (u32 __user *)optval))
>  			return -EFAULT;
> +		/* "pim6reg%u" should not exceed 16 bytes (IFNAMSIZ) */
> +		if (v != RT_TABLE_DEFAULT && v >= 100000000)
> +			return -EINVAL;
>  		if (sk == mrt->mroute6_sk)
>  			return -EBUSY;
>  
hi Dan,
that comment left me in a bit confused, i guess you men
  printf( "pim6reg%u",v) should not exceed IFNAMSIZ (16 bytes) ?
also the if is a bit strange, i assume that RT_TABLE_DEFAULT is const
so anything else is rejected than v==RT_TABLE_DEFAULT
(assuming that RT_TABLE_DEFAULT >= 100000000 ....)

re,
 wh


> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
