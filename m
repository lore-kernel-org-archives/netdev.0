From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] [v3] spidernet : add improved phy support
Date: Mon, 12 Feb 2007 17:26:18 -0600
Message-ID: <20070212232618.GD923@austin.ibm.com>
References: <200702122135.34417.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, benh@kernel.crashing.org,
	James K Lewis <jim@jklewis.com>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jens Osterkamp <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:41081 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030487AbXBLX0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 18:26:50 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l1CNQBS9027280
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 18:26:11 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1CNQe8e539872
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 16:26:40 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1CNQda5001824
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 16:26:40 -0700
Content-Disposition: inline
In-Reply-To: <200702122135.34417.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Tested the patch, it works for me.  Thus I'll attach a pre-emptive 
Acked-by: Linas Vepstas <linas@austin.ibm.com>

However, some quibbbles, which I think would be nice to see fixed:

On Mon, Feb 12, 2007 at 09:35:34PM +0100, Jens Osterkamp wrote:
> 
> Index: linux-2.6.20/drivers/net/sungem_phy.c
> ===================================================================
> --- linux-2.6.20.orig/drivers/net/sungem_phy.c
> +++ linux-2.6.20/drivers/net/sungem_phy.c
>  
> +#define BCM5421_MODE_MASK	(1 << 5)

Customary practice is to have these in the heder file ... 

> +	mode = (phy_reg & BCM5421_MODE_MASK) >> 5;
> +
> +	if ( mode == BCM54XX_COPPER)

All this shifting makes the code hard to read and 
hard to verify for correctness.  Part of the problem 
seems to be that you are trying to re-cycle the 
BCM5421_COPPER and BCM5461_COPPER which are in 
different locations.

It would have been clearer to simply have

#define BCM5421_MODE_MASK  (1 << 5)
#define BCM5421_COPPER     0

if (phy_reg & BCM5421_MODE_MASK == BCM5421_COPPER)

> +	if ( (phy_reg & 0x0080) >> 7)

There is no need for the shift. The if statement is 
just as true (or false) with or without the shift.

> +#define BCM5461_FIBER_LINK	(1 << 2)
> +#define BCM5461_MODE_MASK	(3 << 1)
> +
> +	mode = (phy_reg & BCM5461_MODE_MASK ) >> 1;

More confusing shifting ....

> +enum {
> +	BCM54XX_COPPER,
> +	BCM54XX_FIBER,
> +	BCM54XX_GBIC,
> +	BCM54XX_SGMII,

Things that are being used for bitmak tests should probably
not be declared in an enum. For me, at least, there's a 
cognitive dissonance in doing things this way.

-- linas
