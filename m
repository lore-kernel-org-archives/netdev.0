From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: [PATCH 1/3] Blackfin ethernet driver: on chip ethernet MAC
	controller driver
Date: Sun, 15 Jul 2007 21:55:39 +0800
Message-ID: <1184507739.6030.0.camel@roc-laptop>
References: <1184438993.3140.23.camel@roc-laptop>
	 <200707142138.36619.mb@bu3sch.de>
	 <8bd0f97a0707141249y2c90a59cs356aa3cef357f721@mail.gmail.com>
	 <200707142217.36361.mb@bu3sch.de>
	 <8bd0f97a0707141338q996f246p6abdc2f65efa5e7@mail.gmail.com>
	 <1184504661.5871.25.camel@localhost.localdomain>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier.adi@gmail.com>,
	Michael Buesch <mb@bu3sch.de>, bryan.wu@analog.com,
	Jeff Garzik <jeff@garzik.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:3990 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648AbXGONzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 09:55:47 -0400
In-Reply-To: <1184504661.5871.25.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-07-15 at 09:04 -0400, Dan Williams wrote:
> On Sat, 2007-07-14 at 16:38 -0400, Mike Frysinger wrote:
> > On 7/14/07, Michael Buesch <mb@bu3sch.de> wrote:
> > > On Saturday 14 July 2007 21:49:21 Mike Frysinger wrote:
> > > > On 7/14/07, Michael Buesch <mb@bu3sch.de> wrote:
> > > > > On Saturday 14 July 2007 20:49:53 Bryan Wu wrote:
> > > > > > +static int __init bf537mac_probe(struct net_device *dev)
> > > > > > +{
> > > > > > +     struct bf537mac_local *lp = netdev_priv(dev);
> > > > > > +     int retval;
> > > > > > +
> > > > > > +     /* Grab the MAC address in the MAC */
> > > > > > +     *(u32 *) (&(dev->dev_addr[0])) = bfin_read_EMAC_ADDRLO();
> > > > > > +     *(u16 *) (&(dev->dev_addr[4])) = (u16) bfin_read_EMAC_ADDRHI();
> > > > >
> > > > > Endianess broken.
> > > > >
> > > > > > +struct dma_config_reg {
> > > > > > +     unsigned short b_DMA_EN:1;  /* Bit 0 : DMA Enable */
> > > > > > +     unsigned short b_WNR:1;     /* Bit 1 : DMA Direction */
> > > > > > +     unsigned short b_WDSIZE:2;  /* Bit 2 & 3 : DMA Tranfer Word size */
> > > > > > +     unsigned short b_DMA2D:1;   /* Bit 4 : DMA Mode 2D or 1D */
> > > > > > +     unsigned short b_RESTART:1; /* Bit 5 : Retain the FIFO */
> > > > > > +     unsigned short b_DI_SEL:1;  /* Bit 6 : Data Interrupt Timing Select */
> > > > > > +     unsigned short b_DI_EN:1;   /* Bit 7 : Data Interrupt Enable */
> > > > > > +     unsigned short b_NDSIZE:4;  /* Bit 8 to 11 : Flex descriptor Size */
> > > > > > +     unsigned short b_FLOW:3;    /* Bit 12 to 14 : FLOW */
> > > > > > +};
> > > > >
> > > > > This is most likely not endianess safe.
> > > >
> > > > do we really need to care about this ?  this is a driver for a MAC
> > > > which can only be found on Blackfin processors and Blackfin itself is
> > > > only little endian.
> > >
> > > Well, this bitfield _might_ be OK (although I don't like bitfields
> > > at all), but the above pointer casting stuff should really use
> > > leXX_to_cpu. It's so easy to use and it is easier to read and
> > > maintain the code afterwards.
> > 
> > i think that's arguable ... i dont see how:
> > a = foo(b);
> > is easier to read than:
> > a = b;
> > but it is easy to use ... i guess my point was more along the lines of
> > wasting further time auditing a driver for endianness issues that will
> > never actually be an issue.
> 
> Sometimes by doing this you catch bugs you didn't see before.  It's a
> good thing to do generally.  Does sparse with endianness check show
> errors?  You may want to fix those.
> 
> Dan

Yes, I will add endianess protection as Michael and you mentioned.

Thanks
- Bryan Wu

> > -mike
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
