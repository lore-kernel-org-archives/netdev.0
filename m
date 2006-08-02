From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Wed, 2 Aug 2006 23:07:11 +0200
Message-ID: <20060802210711.GA28282@electric-eye.fr.zoreil.com>
References: <20060801214055.GA27595@electric-eye.fr.zoreil.com> <OF9B6DF52E.7B28B6F4-ON802571BE.006AB3BD-802571BE.006BFCA5@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bahadir Balban <Bahadir.Balban@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32414 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932161AbWHBVKN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 17:10:13 -0400
To: Steve.Glendinning@smsc.com
Content-Disposition: inline
In-Reply-To: <OF9B6DF52E.7B28B6F4-ON802571BE.006AB3BD-802571BE.006BFCA5@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve.Glendinning@smsc.com <Steve.Glendinning@smsc.com> :
> Mezigues :
[...]
> > Does the platform guarantees that the register write has actually 
> reached
> > the real register when the udelay is issued ?
> 
> I think so, but maybe you can help me check.  The LAN911x device is always 
> directly connected to a simple SRAM-like host bus, and smsc911x_reg_write 
> is implemented using readl.  Does this implicitly guarantee it to be 
> volatile?

(s/readl/writel/)

It's probably safe if it's non-cached SRAM like but I strongly suggest to
read Documentation/DocBook/deviceiobook.tmpl. It explains better than me.

[...]
> > >              spin_lock_irqsave(&pdata->phy_lock, flags);
> > 
> > flags useless: ->open() is issued in irq-enabled context.
> 
> How do you mean? I thought an irq-enabled context meant i DO have to 
> disable irqs?

Yes but you can disable unconditionally and later enable unconditionnally
because you know that the irq are _always_ enabled before the lock (in
->open()).

'flags' saves the state. If the state is constant, you can either:
- s/spin_{lock_irqsave/unlock_irqrestore}/spin_{lock/unlock}_irq/
  (irq always on before the lock)
or:
- s/spin_{lock_irqsave/unlock_irqrestore}/spin_{lock/unlock}/
  (irq always off before the lock)

-- 
Ueimor
