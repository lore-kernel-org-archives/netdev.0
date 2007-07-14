From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/3] Blackfin ethernet driver: on chip ethernet MAC controller driver
Date: Sat, 14 Jul 2007 22:17:35 +0200
Message-ID: <200707142217.36361.mb@bu3sch.de>
References: <1184438993.3140.23.camel@roc-laptop> <200707142138.36619.mb@bu3sch.de> <8bd0f97a0707141249y2c90a59cs356aa3cef357f721@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, "Jeff Garzik" <jeff@garzik.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44267
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655AbXGNUSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 16:18:53 -0400
In-Reply-To: <8bd0f97a0707141249y2c90a59cs356aa3cef357f721@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 14 July 2007 21:49:21 Mike Frysinger wrote:
> On 7/14/07, Michael Buesch <mb@bu3sch.de> wrote:
> > On Saturday 14 July 2007 20:49:53 Bryan Wu wrote:
> > > +static int __init bf537mac_probe(struct net_device *dev)
> > > +{
> > > +     struct bf537mac_local *lp = netdev_priv(dev);
> > > +     int retval;
> > > +
> > > +     /* Grab the MAC address in the MAC */
> > > +     *(u32 *) (&(dev->dev_addr[0])) = bfin_read_EMAC_ADDRLO();
> > > +     *(u16 *) (&(dev->dev_addr[4])) = (u16) bfin_read_EMAC_ADDRHI();
> >
> > Endianess broken.
> >
> > > +struct dma_config_reg {
> > > +     unsigned short b_DMA_EN:1;  /* Bit 0 : DMA Enable */
> > > +     unsigned short b_WNR:1;     /* Bit 1 : DMA Direction */
> > > +     unsigned short b_WDSIZE:2;  /* Bit 2 & 3 : DMA Tranfer Word size */
> > > +     unsigned short b_DMA2D:1;   /* Bit 4 : DMA Mode 2D or 1D */
> > > +     unsigned short b_RESTART:1; /* Bit 5 : Retain the FIFO */
> > > +     unsigned short b_DI_SEL:1;  /* Bit 6 : Data Interrupt Timing Select */
> > > +     unsigned short b_DI_EN:1;   /* Bit 7 : Data Interrupt Enable */
> > > +     unsigned short b_NDSIZE:4;  /* Bit 8 to 11 : Flex descriptor Size */
> > > +     unsigned short b_FLOW:3;    /* Bit 12 to 14 : FLOW */
> > > +};
> >
> > This is most likely not endianess safe.
> 
> do we really need to care about this ?  this is a driver for a MAC
> which can only be found on Blackfin processors and Blackfin itself is
> only little endian.

Well, this bitfield _might_ be OK (although I don't like bitfields
at all), but the above pointer casting stuff should really use
leXX_to_cpu. It's so easy to use and it is easier to read and
maintain the code afterwards.
If the bitfield stays, a comment must be added.

-- 
Greetings Michael.
