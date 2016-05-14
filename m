From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 2/2] Documentation: devictree: Add macb mdio bindings
Date: Sat, 14 May 2016 08:20:35 +0530
Message-ID: <CAFcVECJjHRYUmtN3Gha-zNz+4JvXRH-BY+eEumdboaREp1D4Ow@mail.gmail.com>
References: <1463131568-36948-1-git-send-email-harinik@xilinx.com>
	<1463131568-36948-2-git-send-email-harinik@xilinx.com>
	<20160513174300.GB7600@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Harini Katakam <harini.katakam@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, davem@davemloft.net,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	"michals@xilinx.com" <michals@xilinx.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:35786 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbcENCuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 22:50:37 -0400
In-Reply-To: <20160513174300.GB7600@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI Andrew,

On Fri, May 13, 2016 at 11:13 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> Hi Harini
>
> Is this backward compatible? Will devices using the old binding still
> work?

It isn't right now.
I will have to assign the bus read/write functions conditionally in order to
do that - I'll see if I can make it clean.

>
>   /* Disable RX and TX (XXX: Should we halt the transmission
>    * more gracefully?)
>     */
> -   macb_writel(bp, NCR, 0);
> +   ctrl = macb_readl(bp, NCR);
> +   ctrl &= ~(MACB_BIT(RE) | MACB_BIT(TE));
> +   macb_writel(bp, NCR, ctrl);
>
>         /* Clear the stats registers (XXX: Update stats first?) */
> -       macb_writel(bp, NCR, MACB_BIT(CLRSTAT));
> +       ctrl |= MACB_BIT(CLRSTAT);
> +       macb_writel(bp, NCR, ctrl);
>
>         /* Clear all status flags */
>         macb_writel(bp, TSR, -1);
>
> It is not clear to me what this part has to do with MDIO.
>

Sorry, I'll move this to a separate patch in my next version.
It is intended to write those registers without disturbing reserved bits.

Regards,
Harini
