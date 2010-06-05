From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Re: still having r8169 woes with XID 18000000
Date: Sat, 05 Jun 2010 11:13:21 +0200
Message-ID: <1275729201.5238.2.camel@edumazet-laptop>
References: <4C08ED47.1030800@iki.fi>
	 <20100604123641.ED8154CD45@orbit.nwl.cc> <4C08F953.1050800@iki.fi>
	 <20100604134351.7981F4CD45@orbit.nwl.cc> <4C09387F.1050403@iki.fi>
	 <4C09611B.2090805@iki.fi>  <4C09FF4B.4050601@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Phil Sutter <phil@nwl.cc>,
	=?ISO-8859-1?Q?fran=E7ois?= romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44106 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932555Ab0FEJN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:13:29 -0400
Received: by wyi11 with SMTP id 11so1384831wyi.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 02:13:27 -0700 (PDT)
In-Reply-To: <4C09FF4B.4050601@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 05 juin 2010 =C3=A0 10:39 +0300, Timo Ter=C3=A4s a =C3=A9crit=
 :

> Ok, I compared Realtek's and the in-tree driver. The only essential
> difference is that Realtek driver uses udelay(100) in mdio_write()'s
> busy polling loop where as the in-tree uses udelay(25). And that seem=
s
> to be the magic difference! Using udelay(100) fixes this!
>=20
> I'm guessing that the phy needs slight delay between consecutive
> mdio_write's even if it has advertised that the write has been
> completed. And yes, just adding a small delay in the end of mdio_writ=
e
> does seem to work too.
>=20
> Francois, you think the below patch is ok? Should I send it as proper=
ly
> formatted commit?
>=20
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 217e709..6db62bf 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -559,6 +559,7 @@ static void mdio_write(void __iomem *ioaddr,
>  			break;
>  		udelay(25);
>  	}
> +	udelay(25);
>  }
>=20
>  static int mdio_read(void __iomem *ioaddr, int reg_addr)
> --

Sure this deserves an official patch with all prereqs, but please add a
comment in mdio_write() why this extra udelay(25) is needed, especially
since you say of udelay(100) 'fixes the bug'.



