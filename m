From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: Re: [PATCH] gianfar: prevent fragmentation in DSA environments
Date: Fri, 19 Aug 2016 21:24:30 +0000
Message-ID: <AM5PR0401MB25618716FACFE3DA3A21D5F696160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <1471598174-16938-1-git-send-email-zefir.kurtisi@neratec.com>
 <20160819145900.GD7343@lunn.ch>
 <AM5PR0401MB2561CB4CA30BC13EBFFAD43796160@AM5PR0401MB2561.eurprd04.prod.outlook.com>,<20160819163944.GF22939@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "claudiu.manoil@freescale.com" <claudiu.manoil@freescale.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0043.outbound.protection.outlook.com ([104.47.2.43]:44311
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754388AbcHSVio (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 17:38:44 -0400
In-Reply-To: <20160819163944.GF22939@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,


From: Andrew Lunn <andrew@lunn.ch>
Sent: Friday, August 19, 2016 7:39 PM
To: Claudiu Manoil
Cc: Zefir Kurtisi; netdev@vger.kernel.org; claudiu.manoil@freescale.com
Subject: Re: [PATCH] gianfar: prevent fragmentation in DSA environments
=A0  =20
> >> -#define GFAR_RXB_SIZE 1536
> >> +/* prevent fragmenation by HW in DSA environments */
> >> +#define GFAR_RXB_SIZE (1536 + RXBUF_ALIGNMENT)
> >
> >Hi Zefir
> >
> >Using RXBUF_ALIGNMENT suggests this has something to do with
> >alignment, not extra headers.
> >
> >How about
> >
> >/* Prevent fragmenation by HW when using extra headers like DSA */
> >#define GFAR_RXB_SIZE (1536 + 8)
> >
>=20
> MRBL (Maximum receive buffer length) must be multiple of 64.
> Please consult de hardware documentation at least before prosing
> changes to the driver.
=A0
Hi Claudiu

Thanks for pointing this out. This makes RXBUF_ALIGNMENT even worse
for understabability, since you say multiples of 64 is important, not
alignment.

How about

/* Prevent fragmentation by HW when using extra headers like DSA,
while respecting the multiple of 64 requirement. */

#define GFAR_RXB_SIZE roundup(1536 + 8, 64)

[Claudiu]
Nice improvement.
But what's so special about 8?  I thought only 4 bytes were missing :)
At least 1536 is the default size of the MRBLR register, as specified
in the h/w ref manual.  Is there some recommended standard size
to accommodate most (if not all) headers, to refer to?


    =
