From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [Cbe-oss-dev] [PATCH 5/5] spidernet: revise link status logging
Date: Wed, 23 Jan 2008 14:55:57 +0100
Message-ID: <200801231455.57262.jens@de.ibm.com>
References: <20080111.154847.-494080281.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, netdev@vger.kernel.org
To: cbe-oss-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:32000 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbYAWN4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 08:56:03 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0NDu17E497926
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:56:01 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NDu1TO4923508
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:56:01 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0NDtvnx007057
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:55:58 GMT
In-Reply-To: <20080111.154847.-494080281.kouish@swc.toshiba.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 January 2008, Ishizaki Kou wrote:
> This patch revises the logging for link informations of spidernet.
>=20
>   - The link down message is too verbose because auto-negotiation tim=
eout
>     occurs periodically while an ethernet cable is not connected.=20
>   - We want to see the link result, and we think it should be display=
ed.=20
>=20
> Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

Acked-by: Jens Osterkamp <jens@de.ibm.com>

> ---
>=20
> Index: linux-powerpc-git/drivers/net/spider_net.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-powerpc-git.orig/drivers/net/spider_net.c
> +++ linux-powerpc-git/drivers/net/spider_net.c
> @@ -2045,7 +2045,8 @@ static void spider_net_link_phy(unsigned
>  	/* if link didn't come up after SPIDER_NET_ANEG_TIMEOUT tries, setu=
p phy again */
>  	if (card->aneg_count > SPIDER_NET_ANEG_TIMEOUT) {
>=20
> -		pr_info("%s: link is down trying to bring it up\n", card->netdev->=
name);
> +		pr_debug("%s: link is down trying to bring it up\n",
> +			 card->netdev->name);
>=20
>  		switch (card->medium) {
>  		case BCM54XX_COPPER:
> @@ -2096,9 +2097,10 @@ static void spider_net_link_phy(unsigned
>=20
>  	card->aneg_count =3D 0;
>=20
> -	pr_debug("Found %s with %i Mbps, %s-duplex %sautoneg.\n",
> -		phy->def->name, phy->speed, phy->duplex=3D=3D1 ? "Full" : "Half",
> -		phy->autoneg=3D=3D1 ? "" : "no ");
> +	pr_info("%s: link up, %i Mbps, %s-duplex %sautoneg.\n",
> +		card->netdev->name, phy->speed,
> +		phy->duplex =3D=3D 1 ? "Full" : "Half",
> +		phy->autoneg =3D=3D 1 ? "" : "no ");
>=20
>  	return;
>  }
> _______________________________________________
> cbe-oss-dev mailing list
> cbe-oss-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/cbe-oss-dev
>=20



--=20

Gru=DF,

Jens

IBM Deutschland Entwicklung GmbH
Vorsitzender des Aufsichtsrats: Martin Jetter
Gesch=E4ftsf=FChrung: Herbert Kircher=20
Sitz der Gesellschaft: B=F6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
