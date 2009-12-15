From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 3/4] fec: add support for Freescale i.MX25 PDK (3DS)
Date: Tue, 15 Dec 2009 08:08:45 +0200
Message-ID: <20091215060844.GA18290@jasper.tkos.co.il>
References: <cover.1260785451.git.baruch@tkos.co.il>
 <fb518184b206ec2727deda111cc5364134ace69a.1260785451.git.baruch@tkos.co.il>
 <4B26E61F.7030709@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sascha Hauer <kernel@pengutronix.de>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:36171 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808AbZLOGJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 01:09:28 -0500
Content-Disposition: inline
In-Reply-To: <4B26E61F.7030709@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

On Tue, Dec 15, 2009 at 11:27:59AM +1000, Greg Ungerer wrote:
> Hi Baruch,
> 
> Baruch Siach wrote:
> >The i.MX25 PDK uses RMII to communicate with its PHY. This patch adds the
> >necessary bits to make the i.MX25 talk RMII.
> >
> >Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> >---

[snip]

> >+	/* re-enable the gasket */
> >+	writel(2, fep->hwp + FEC_MIIGSK_ENR);
>                              ^^^^^^^^^^^^^^
> 
> This will not compile for some CPU types that use this driver.
> 

[snip]

> >--- a/drivers/net/fec.h
> >+++ b/drivers/net/fec.h
> >@@ -43,6 +43,8 @@
> > #define FEC_R_DES_START		0x180 /* Receive descriptor ring */
> > #define FEC_X_DES_START		0x184 /* Transmit descriptor ring */
> > #define FEC_R_BUFF_SIZE		0x188 /* Maximum receive buff size */
> >+#define FEC_MIIGSK_CFGR		0x300 /* MIIGSK Configuration reg */
> >+#define FEC_MIIGSK_ENR		0x308 /* MIIGSK Enable reg */
> 
> These are defined in a conditional section for certain CPU types.
> There is no definitions for the other "#else" section here.

So, should I put a bogus #define in the other #else section, or put the 
FEC_MIIGSK_* code in an #ifdef section? I guess the latter is the way to go.

baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
