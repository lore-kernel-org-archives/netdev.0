From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: (usagi-core 15040) [PATCH] IPv6: Protect proxied addresses
 against DAD
Date: Wed, 20 Aug 2003 20:43:04 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820.204304.07033882.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0308201423500.541-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0308201423500.541-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0308201423500.541-200000@rhea.tcs.hut.fi> (at Wed, 20 Aug 2003 14:40:14 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> --- linux-2.5.OLD/net/ipv6/ndisc.c	2003-08-20 14:10:16.000000000 +0300
> +++ linux-2.5/net/ipv6/ndisc.c	2003-08-20 14:10:30.000000000 +0300
> @@ -861,7 +861,8 @@
>  		struct inet6_dev *in6_dev = in6_dev_get(dev);
>  
>  		if (in6_dev && in6_dev->cnf.forwarding &&
> -		    (addr_type & IPV6_ADDR_UNICAST) &&
> +		    (addr_type & IPV6_ADDR_UNICAST ||
> +		     addr_type == IPV6_ADDR_ANY) &&
>  		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0)) {
>  			int inc = ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
>  

I believe we don't need this chunk.

--ypshfuj 
