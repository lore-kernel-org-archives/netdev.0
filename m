From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 10/39] mv643xx_eth: clarify irq masking and unmasking
Date: Thu, 5 Jun 2008 22:36:05 +0200
Message-ID: <20080605203605.GD30083@xi.wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-11-git-send-email-buytenh@wantstofly.org> <20080605114406.GA3807@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:42721 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbYFEUgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 16:36:37 -0400
Content-Disposition: inline
In-Reply-To: <20080605114406.GA3807@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 05, 2008 at 04:44:06AM -0700, Dale Farnsworth wrote:

> > diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> > index bdb03f3..ffdd3fc 100644
> > --- a/drivers/net/mv643xx_eth.c
> > +++ b/drivers/net/mv643xx_eth.c
> > @@ -97,7 +97,14 @@ static char mv643xx_driver_version[] = "1.0";
> >  #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
> >  #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
> >  #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
> > +#define  INT_RX				0x00000804
> > +#define  INT_EXT			0x00000002
> >  #define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
> > +#define  INT_EXT_LINK			0x00100000
> > +#define  INT_EXT_PHY			0x00010000
> > +#define  INT_EXT_TX_ERROR_0		0x00000100
> > +#define  INT_EXT_TX_0			0x00000001
> > +#define  INT_EXT_TX			0x00000101
> 
> Oops, I missed this the first time.  You have an extra space in each
> of the above added defines.

Right, that's because they are possible values of that register,
instead of the definition of a new register.  A couple of existing
drivers follow this format (e.g. look at b44.h or tg3.h), and I kind
of like it, because it groups things logically together.

OK?
