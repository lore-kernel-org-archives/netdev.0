From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 2/2] drivers/net: Fix synchronize_irq() bugs,
	redundancies
Date: Mon, 21 Apr 2008 21:04:42 -0400
Message-ID: <1208826282.2748.1.camel@obelisk.thedillows.org>
References: <20080421233419.GA4923@havoc.gtf.org>
	 <20080421233537.GA5223@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:35596 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760906AbYDVBL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 21:11:26 -0400
In-Reply-To: <20080421233537.GA5223@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-04-21 at 19:35 -0400, Jeff Garzik wrote:
> free_irq() calls synchronize_irq() for you, so there is no need for
> drivers to manually do the same thing (again).  Thus, calls where
> sync-irq immediately precedes free-irq can be simplified.

> diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
> index 333961b..7d2a4c6 100644
> --- a/drivers/net/typhoon.c
> +++ b/drivers/net/typhoon.c
[...]
>  	/* Make sure there is no irq handler running on a different CPU. */
> -	typhoon_synchronize_irq(dev->irq);
>  	free_irq(dev->irq, dev);

Should probably kill the comment as well, since it was referring to the
synchronize_irq() call.

Acked-by: Dave Dillow <dave@thedillows.org>

