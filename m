From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH V2 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 15:25:42 +0100
Message-ID: <201601201525.42143.marex@denx.de>
References: <1452538083-7331-5-git-send-email-marex@denx.de> <201601201358.04790.marex@denx.de> <569F944A.4090201@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: "Marc Kleine-Budde" <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:37643 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932839AbcATO3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 09:29:50 -0500
In-Reply-To: <569F944A.4090201@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, January 20, 2016 at 03:06:02 PM, Marc Kleine-Budde wrote:
> On 01/20/2016 01:58 PM, Marek Vasut wrote:
> > On Wednesday, January 20, 2016 at 11:54:21 AM, Marc Kleine-Budde wrote:
> >> On 01/20/2016 11:39 AM, Marc Kleine-Budde wrote:
> >>>> +/* IFI CANFD private data structure */
> >>>> +struct ifi_canfd_priv {
> >>>> +	struct can_priv		can;	/* must be the first member */
> >>>> +	struct napi_struct	napi;
> >>>> +	struct net_device	*ndev;
> >>>> +	struct device		*device;
> >>> 
> >>> Nitpick: This variable is write only, correct? I can fix this while
> >>> applying the patch.
> >>> 
> >>>> +	void __iomem		*base;
> >>>> +};
> >>> 
> >>> Otherweise looks good.
> > 
> > It's write-only, yeah. What would you propose to change here ?
> 
> Remove it completely. :D

Erm, right. I see it now, thanks.

> >> Until compiling:
> >>> drivers/net/can/ifi_canfd/ifi_canfd.c:486:40: warning: cast truncates
> >>> bits from constant value (ffffffff7ffffffd becomes 7ffffffd)
> >>> drivers/net/can/ifi_canfd/ifi_canfd.c:640:9: warning: cast truncates
> >>> bits from constant value (ffffffff7fffffff becomes 7fffffff)
> >>> drivers/net/can/ifi_canfd/ifi_canfd.c:676:9: warning: cast truncates
> >>> bits from constant value (ffffffff7fffffff becomes 7fffffff)
> >> 
> >> target is ARMv5 with gcc version 4.9.2, compiled with C=2 using sparse
> >> v0.5.0.
> > 
> > It's again the BIT() macro :-/ Do you have any idea how to fix this
> > please ? Doing something like u32 foo = ~BIT(31); triggers this splat
> > and I am running out of ideas how to fix that.
> 
> -#define IFI_CANFD_INTERRUPT_SET_IRQ            BIT(31)
> +#define IFI_CANFD_INTERRUPT_SET_IRQ            ((u32)BIT(31))

I see, so adding u32 also here works. I'm starting to wonder if the BIT
macro is really that nice and if I shouldn't just use (1 << n) as usual.

> ...or change the bit to "30" :D

:-)

I will send V3 in a bit.

Best regards,
Marek Vasut
