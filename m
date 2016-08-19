From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] gianfar: prevent fragmentation in DSA environments
Date: Fri, 19 Aug 2016 18:39:44 +0200
Message-ID: <20160819163944.GF22939@lunn.ch>
References: <1471598174-16938-1-git-send-email-zefir.kurtisi@neratec.com>
 <20160819145900.GD7343@lunn.ch>
 <AM5PR0401MB2561CB4CA30BC13EBFFAD43796160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "claudiu.manoil@freescale.com" <claudiu.manoil@freescale.com>
To: Claudiu Manoil <claudiu.manoil@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39249 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754215AbcHSRYa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 13:24:30 -0400
Content-Disposition: inline
In-Reply-To: <AM5PR0401MB2561CB4CA30BC13EBFFAD43796160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
> 
> MRBL (Maximum receive buffer length) must be multiple of 64.
> Please consult de hardware documentation at least before prosing
> changes to the driver.
 
Hi Claudiu

Thanks for pointing this out. This makes RXBUF_ALIGNMENT even worse
for understabability, since you say multiples of 64 is important, not
alignment.

How about

/* Prevent fragmentation by HW when using extra headers like DSA,
while respecting the multiple of 64 requirement. */

#define GFAR_RXB_SIZE roundup(1536 + 8, 64)

	Andrew
