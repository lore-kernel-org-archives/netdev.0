From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Wed, 2 Aug 2006 20:39:33 +0100
Message-ID: <OF9B6DF52E.7B28B6F4-ON802571BE.006AB3BD-802571BE.006BFCA5@smsc.com>
References: <20060801214055.GA27595@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir Balban <Bahadir.Balban@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:59659 "EHLO smsc.com")
	by vger.kernel.org with ESMTP id S932129AbWHBTj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 15:39:57 -0400
In-Reply-To: <20060801214055.GA27595@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

Thanks again for all your feedback.  I have implemented most of your 
suggestions, 

> >                              /* Enable phy clocks to the MAC */
> >                              hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
> >                              hwcfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
> >                              smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> >                              udelay(10);             /* Enough time 
for clocks to restart */
> 
> (back to my original question that I should have reworded in a different
> thread)
> 
> Does the platform guarantees that the register write has actually 
reached
> the real register when the udelay is issued ?

I think so, but maybe you can help me check.  The LAN911x device is always 
directly connected to a simple SRAM-like host bus, and smsc911x_reg_write 
is implemented using readl.  Does this implicitly guarantee it to be 
volatile?


> > 
> >              if (!pdata->software_irq_signal) {
> >                              printk(KERN_WARNING "%s: ISR failed 
signaling test (IRQ %d)\n",
> >                                     dev->name, dev->irq);
> >                              return -ENODEV;
> >              }
> >              SMSC_TRACE("IRQ handler passed test using IRQ %d", 
dev->irq);
> > 
> >              printk(KERN_INFO "%s: SMSC911x/921x identified at %#08lx, 
IRQ: %d\n",
> >                     dev->name, (unsigned long)pdata->ioaddr, 
dev->irq);
> > 
> >              spin_lock_irqsave(&pdata->phy_lock, flags);
> 
> flags useless: ->open() is issued in irq-enabled context.

How do you mean? I thought an irq-enabled context meant i DO have to 
disable irqs?


> >              unsigned long flags;
> > 
> >              SMSC_TRACE("ioctl cmd 0x%x", cmd);
> >              switch (cmd) {
> >              case SIOCGMIIPHY:
> >              case SIOCDEVPRIVATE:
> 
> The SIOCDEVPRIVATE can/should be removed.

I have removed these, they were only in as a quick fix because mii-tool 
here sends SIOCDEVPRIVATE instead of SIOCGMIIPHY.  I fixed my copy of 
mii-tool instead :o)

Best Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

