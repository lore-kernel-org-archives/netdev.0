From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] [Rev2] MPC5121 FEC support
Date: Tue, 17 Jun 2008 21:46:20 +0200
Message-ID: <20080617194620.GA13147@uranus.ravnborg.org>
References: <1213729717-26688-1-git-send-email-jrigby@freescale.com> <20080617192237.GA12961@uranus.ravnborg.org> <48581113.4060101@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Rigby <jrigby@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:53467 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbYFQTph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 15:45:37 -0400
Content-Disposition: inline
In-Reply-To: <48581113.4060101@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 02:31:31PM -0500, Scott Wood wrote:
> Sam Ravnborg wrote:
> >>+	data = of_get_property(ofdev->node, "fsl,align-tx-packets", &len);
> >>+	if (data && len == 4)
> >>+		fpi->align_tx_packets = *data;
> >>+
> >Where did "4" come from. USe a define with a desriptive name.
> 
> It's sizeof(u32), i.e. one device tree cell.  This is fairly normal.
Not fpr me at least - but I just review the patch out of context.
If it is sizeof(u32) why not write so?

> 
> >> 	fpi->rx_ring = 32;
> >> 	fpi->tx_ring = 32;
> >Same for "32"
> >> 	fpi->rx_copybreak = 240;
> >Same for "240".
> 
> They're arbitrary tuning parameters.  How is a #define any more 
> descriptive than the field name?
So it is clear they are tuneing parameters.


> 
> Besides, that's pre-existing, and has nothing to do with this patch.
>
OK.
 
> >>--- a/drivers/net/fs_enet/fs_enet.h
> >>+++ b/drivers/net/fs_enet/fs_enet.h
> >>@@ -10,12 +10,17 @@
> >> 
> >> #include <linux/fs_enet_pd.h>
> >> #include <asm/fs_pd.h>
> >>+#ifdef CONFIG_FS_ENET_MPC5121_FEC
> >>+#include "fec_mpc5121.h"
> >>+#endif
> >
> >Which is this include ifdeffed - looks like some wrong concept.
> 
> This has already been discussed.  There are two similar but different 
> ethernet controllers that are being targeted, and the chips they are a 
> part of (8xx and 512x) are already mutually exclusive with respect to 
> multiplatform kernels due to core differences.
OK - had not seen it (or forgot).

> 
> >The amount of ifdef introduced looks bad..
> 
> Yes, it's bad -- but it's a matter of which is the lesser evil, a few 
> ifdefs or large amounts of mostly duplicated code.
> 
> >And try to run the patch through scripts/checkpatch.pl
> >And try to split it up a bit.
> 
> Other than the fec_t thing, I don't see any needed splitting...
It was only the fec_t => struct fec change I had in mind.

	Sam
