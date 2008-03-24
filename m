From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 8/8] New driver "sfc" for Solarstorm SFC4000 controller (try #8)
Date: Mon, 24 Mar 2008 10:34:40 +0000
Message-ID: <20080324103438.GA24160@solarflare.com>
References: <20080312012102.GB24160@solarflare.com> <20080312012629.GJ24160@solarflare.com> <20080324085202.GA4845@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53747 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753947AbYCXKfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 06:35:11 -0400
Content-Disposition: inline
In-Reply-To: <20080324085202.GA4845@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Hellwig wrote:
> > +++ b/drivers/net/sfc/Makefile
> > @@ -0,0 +1,23 @@
> > +
> > +# Final objects
> > +sfc_o = sfc.o
> > +
> > +# Constituent objects
> > +sfc_elements_o :=
> > +sfc_elements_o += efx.o
> > +sfc_elements_o += falcon.o
> > +sfc_elements_o += tx.o
> > +sfc_elements_o += rx.o
> > +sfc_elements_o += falcon_xmac.o
> > +sfc_elements_o += i2c-direct.o
> > +sfc_elements_o += ethtool.o
> > +sfc_elements_o += xfp_phy.o
> > +sfc_elements_o += mdio_10g.o
> > +sfc_elements_o += tenxpress.o
> > +sfc_elements_o += boards.o
> > +sfc_elements_o += sfe4001.o
> > +
> > +obj-$(CONFIG_SFC) += $(sfc_o)
> > +
> > +sfc-objs = $(sfc_elements_o)
> 
> Very strange makefile.  This should be:
> 
> sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \					   i2c-direct.o ethtool.o xfp_phy.o mdio_10g.o \
> 			   tenxpress.o boards.o sfe4001.o
> 
> obj-$(CONFIG_SFC)	+= sfc.o

The Makefile and all the source files are derived from an internal
version, processed to remove code that's not suitable for upstream.
But they're not strictly tracking that version any more, so we could
just write it the simple way.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
