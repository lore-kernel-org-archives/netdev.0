From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 04/05] ipv6: RFC4214 Support
Date: Thu, 08 Nov 2007 03:36:50 +0900 (JST)
Message-ID: <20071108.033650.113099372.yoshfuji@linux-ipv6.org>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38807 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbXKGSgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 13:36:44 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com> (at Tue, 6 Nov 2007 17:16:11 -0800), "Templin, Fred L" <Fred.L.Templin@boeing.com> says:

> @@ -154,6 +155,14 @@ static struct ip_tunnel * ipip6_tunnel_l
>  	struct net_device *dev;
>  	char name[IFNAMSIZ];
>  
> +#if defined(CONFIG_IPV6_ISATAP)
> +	/* ISATAP (RFC4214) - router address in daddr */
> +	if (!strncmp(parms->name, "isatap", 6)) {
> +		parms->i_key = parms->iph.daddr;
> +		parms->iph.daddr = remote = 0;
> +	}
> +#endif
> +
>  	for (tp = __ipip6_bucket(parms); (t = *tp) != NULL; tp =
> &t->next) {
>  		if (local == t->parms.iph.saddr && remote ==
> t->parms.iph.daddr)
>  			return t;

I do not think it is a good idea to change the behavior based on
the interface name.

> @@ -182,6 +191,11 @@ static struct ip_tunnel * ipip6_tunnel_l
>  	dev->init = ipip6_tunnel_init;
>  	nt->parms = *parms;
>  
> +#if defined(CONFIG_IPV6_ISATAP)
> +	if (!strncmp(dev->name, "isatap", 6))
> +		dev->priv_flags |= IFF_ISATAP;
> +#endif
> +

ditto.

> +		    if (!(ipv6_addr_is_isatap(addr6)) ||
> +			(addr6->s6_addr32[3] != iph->saddr)) {
> +drop:
> +			tunnel->stat.rx_errors++;

you can unlock here.

> +			dst_release(dst);
> +			kfree_skb(skb);
> +			read_unlock(&ipip6_lock);
> +			return 0;
> +		    }
> +		    dst_release(dst);
> +		}
> +accept:
> +#endif

--yoshfuji
