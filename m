From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH V2 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 13:58:04 +0100
Message-ID: <201601201358.04790.marex@denx.de>
References: <1452538083-7331-5-git-send-email-marex@denx.de> <569F63C4.4070708@pengutronix.de> <569F675D.1070903@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: "Marc Kleine-Budde" <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:49873 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347AbcATM6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 07:58:08 -0500
In-Reply-To: <569F675D.1070903@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, January 20, 2016 at 11:54:21 AM, Marc Kleine-Budde wrote:
> On 01/20/2016 11:39 AM, Marc Kleine-Budde wrote:
> >> +/* IFI CANFD private data structure */
> >> +struct ifi_canfd_priv {
> >> +	struct can_priv		can;	/* must be the first member */
> >> +	struct napi_struct	napi;
> >> +	struct net_device	*ndev;
> >> +	struct device		*device;
> > 
> > Nitpick: This variable is write only, correct? I can fix this while
> > applying the patch.
> > 
> >> +	void __iomem		*base;
> >> +};
> > 
> > Otherweise looks good.

It's write-only, yeah. What would you propose to change here ?

> Until compiling:
> > drivers/net/can/ifi_canfd/ifi_canfd.c:486:40: warning: cast truncates
> > bits from constant value (ffffffff7ffffffd becomes 7ffffffd)
> > drivers/net/can/ifi_canfd/ifi_canfd.c:640:9: warning: cast truncates
> > bits from constant value (ffffffff7fffffff becomes 7fffffff)
> > drivers/net/can/ifi_canfd/ifi_canfd.c:676:9: warning: cast truncates
> > bits from constant value (ffffffff7fffffff becomes 7fffffff)
> 
> target is ARMv5 with gcc version 4.9.2, compiled with C=2 using sparse
> v0.5.0.

It's again the BIT() macro :-/ Do you have any idea how to fix this please ?
Doing something like u32 foo = ~BIT(31); triggers this splat and I am running
out of ideas how to fix that.

Best regards,
Marek Vasut
