From: Ben Dooks <ben@fluff.org>
Subject: Re: [PATCH 00/24 for-2.6.25] DM9000 updates for 2.6.25
Date: Tue, 5 Feb 2008 01:44:18 +0000
Message-ID: <20080205014418.GD15407@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk> <20080204161940.2fc8ca14.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	jeff@garzik.org, daniel@caiaq.de, laurentp@cse-semaphore.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:59287 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753676AbYBEBol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 20:44:41 -0500
Content-Disposition: inline
In-Reply-To: <20080204161940.2fc8ca14.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 04, 2008 at 04:19:40PM -0800, Andrew Morton wrote:
> On Tue, 05 Feb 2008 00:01:59 +0000
> Ben Dooks <ben-linux@fluff.org> wrote:
> 
> > Subject: [PATCH 00/24 for-2.6.25] DM9000 updates for 2.6.25
> 
> Holy cow.
> 
> > This patch set is a series of updates for the DM9000
> > driver, to tidy-up some of the source, stop the accesses
> > to the PHY and EEPROM sitting and spinning with locks
> > held, and to add ethtool support.
> 
> Jeff, the immediate issue is that the driver doesn't compile on mips.  I
> have the below lameo fix for it, but it appears to be wrong.  Or at least
> suboptimal.
> 
> So if you're unprepared to chew on this lot (and 24 patches two weeks into the
> merge window is one hell of a chew) then we do need to get that
> regression fixed, at least.

To be fair, jeff has already acked most of these patches, this set is
a repost hopefully without the offending patches.
 
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> mips:
> 
> drivers/net/dm9000.c: In function `dm9000_open':
> drivers/net/dm9000.c:627: error: `IRQT_RISING' undeclared (first use in this function)
> drivers/net/dm9000.c:627: error: (Each undeclared identifier is reported only once
> drivers/net/dm9000.c:627: error: for each function it appears in.)
> 
> Cc: Daniel Mack <daniel@caiaq.de>
> Cc: Russell King <rmk@arm.linux.org.uk>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/dm9000.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff -puN drivers/net/dm9000.c~drivers-net-dm9000c-vague-probably-wrong-build-fix drivers/net/dm9000.c
> --- a/drivers/net/dm9000.c~drivers-net-dm9000c-vague-probably-wrong-build-fix
> +++ a/drivers/net/dm9000.c
> @@ -113,8 +113,10 @@
>  #define writesw	outsw
>  #define writesl	outsl
>  #define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQF_TRIGGER_HIGH)
> -#else
> +#elif defined(ARM)
>  #define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQT_RISING)
> +#else
> +#define DM9000_IRQ_FLAGS	(IRQF_SHARED)
>  #endif
>  
>  /*
> _
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
