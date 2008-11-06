From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] ssb: Fix DMA-API compilation for non-PCI systems
Date: Thu, 6 Nov 2008 22:23:09 +0100
Message-ID: <200811062223.09400.mb@bu3sch.de>
References: <200811062149.21841.mb@bu3sch.de> <8bd0f97a0811061316u6b9a330dy279cb7dca679ab73@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>,
	"Mike Frysinger" <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:37708 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272AbYKFVXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 16:23:36 -0500
In-Reply-To: <8bd0f97a0811061316u6b9a330dy279cb7dca679ab73@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 November 2008 22:16:00 Mike Frysinger wrote:
> On Thu, Nov 6, 2008 at 15:49, Michael Buesch wrote:
> > --- wireless-testing.orig/include/linux/ssb/ssb.h       2008-08-01 17:26:05.000000000 +0200
> > +++ wireless-testing/include/linux/ssb/ssb.h    2008-11-06 21:45:37.000000000 +0100
> > @@ -427,12 +427,16 @@ static inline int ssb_dma_mapping_error(
> >  {
> >        switch (dev->bus->bustype) {
> >        case SSB_BUSTYPE_PCI:
> > +#ifdef CONFIG_SSB_PCIHOST
> >                return pci_dma_mapping_error(dev->bus->host_pci, addr);
> > +#endif
> > +               break;
> >        case SSB_BUSTYPE_SSB:
> >                return dma_mapping_error(dev->dev, addr);
> >        default:
> > -               __ssb_dma_not_implemented(dev);
> > +               break;
> >        }
> 
> all these functions now read:
> default: break;
> seems kind of pointless ... why not just drop that case completely

Because the compiler complains "not handled all cases...".
And yes, we do want to trigger __ssb_dma_not_implemented() for
these cases.

-- 
Greetings Michael.
