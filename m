From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Wed, 29 Oct 2008 13:50:02 -0700
Message-ID: <20081029205002.GI12879@ovro.caltech.edu>
References: <20081029202027.GH12879@ovro.caltech.edu> <20081029132506.55b93555@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:45213 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165AbYJ2UuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 16:50:04 -0400
Content-Disposition: inline
In-Reply-To: <20081029132506.55b93555@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 01:25:06PM -0700, Stephen Hemminger wrote:
> On Wed, 29 Oct 2008 13:20:27 -0700
> Ira Snyder <iws@ovro.caltech.edu> wrote:

Big snip...

> > diff --git a/drivers/net/pcinet.h b/drivers/net/pcinet.h
> > new file mode 100644
> > index 0000000..66d2cba
> > --- /dev/null
> > +++ b/drivers/net/pcinet.h
> > @@ -0,0 +1,75 @@
> > +/*
> > + * Shared Definitions for the PCINet / PCISerial drivers
> > + *
> > + * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
> > + *
> > + * Heavily inspired by the drivers/net/fs_enet driver
> > + *
> > + * This file is licensed under the terms of the GNU General Public License
> > + * version 2. This program is licensed "as is" without any warranty of any
> > + * kind, whether express or implied.
> > + */
> > +
> > +#ifndef PCINET_H
> > +#define PCINET_H
> > +
> > +#include <linux/kernel.h>
> > +#include <linux/if_ether.h>
> > +
> > +/* Ring and Frame size -- these must match between the drivers */
> > +#define PH_RING_SIZE	(64)
> > +#define PH_MAX_FRSIZE	(64 * 1024)
> > +#define PH_MAX_MTU	(PH_MAX_FRSIZE - ETH_HLEN)
> > +
> > +struct circ_buf_desc {
> > +	__le32 sc;
> > +	__le32 len;
> > +	__le32 addr;
> > +} __attribute__((__packed__));
> > +typedef struct circ_buf_desc cbd_t;
> 
> Don't use typedef. See chapter 5 of Documentation/CodingStyle
> 

I know about this. I was following the example set forth in
drivers/net/fs_enet. I tried to make this driver somewhat similar to
that driver, but I'm not against changing this to a struct everywhere.

> Do you really need packed here, sometime gcc generates much worse code
> on needlessly packed structures?

I'm pretty sure I do. I share this structure between both devices over
the PCI bus. This is where the physical addresses of the skb's go so
that the DMA controller can transfer them.

As an example, let's say I have a machine that places 32bit values on
64bit boundaries. AFAIK, the Freescale places 32bit values on 32bit
boundaries. Now the two of them disagree about where the fields of the
buffer descriptor are.

Of course, I may be wrong. :) Comments?

Thanks for the review,
Ira
