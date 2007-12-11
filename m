From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 support for NFS server
Date: Wed, 12 Dec 2007 03:19:11 +0900 (JST)
Message-ID: <20071212.031911.115042677.yoshfuji@linux-ipv6.org>
References: <475D86C1.6070400@ext.bull.net>
	<475EBDB4.5020108@hp.com>
	<475ED028.2010109@ext.bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, neilb@suse.de, bfields@fieldses.org,
	netdev@vger.kernel.org, nfsv4@linux-nfs.org,
	yoshfuji@linux-ipv6.org
To: aurelien.charbon@ext.bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43514 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbXLKSSn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 13:18:43 -0500
In-Reply-To: <475ED028.2010109@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <475ED028.2010109@ext.bull.net> (at Tue, 11 Dec 2007 19:00:0=
8 +0100), Aur=E9lien Charbon <aurelien.charbon@ext.bull.net> says:

> --- linux-2.6.24-rc4/include/net/ipv6.h	2007-12-10 16:11:38.000000000=
 +0100
> +++ linux-2.6.24-rc4-IPv6-cache-based/include/net/ipv6.h	2007-12-11 1=
7:52:39.000000000 +0100
> @@ -400,6 +400,15 @@ static inline int ipv6_addr_v4mapped(con
>  		 a->s6_addr32[2] =3D=3D htonl(0x0000ffff));
>  }
> =20
> +static inline void ipv6_addr_set_v4mapped(const __be32 addr,
> +					  struct in6_addr *v4mapped)
> +{
> +	ipv6_addr_set(v4mapped,
> +			0, 0,
> +			__constant_htonl(0x0000FFFF),
> +			addr);
> +}
> +
>  /*
>   * find the first different bit between two addresses
>   * length of address must be a multiple of 32bits

Use htonl() here, not __constant_htonl().

--yoshfuji
