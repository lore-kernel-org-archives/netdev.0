From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch] fix suspend/resume on b44
Date: Wed, 21 Sep 2005 23:13:32 +0200
Message-ID: <20050921211332.GA2194@elf.ucw.cz>
References: <20050920132811.GA4563@elf.ucw.cz> <20050920162635.565e4b46.akpm@osdl.org> <20050921102054.GE25297@atrey.karlin.mff.cuni.cz> <20050921033653.05c448df.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, hmacht@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050921033653.05c448df.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> > > > diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> > > > --- a/drivers/net/b44.c
> > > > +++ b/drivers/net/b44.c
> > > > @@ -1930,6 +1930,8 @@ static int b44_suspend(struct pci_dev *p
> > > >  	b44_free_rings(bp);
> > > >  
> > > >  	spin_unlock_irq(&bp->lock);
> > > > +
> > > > +	free_irq(dev->irq, dev);
> > > >  	pci_disable_device(pdev);
> > > >  	return 0;
> > > >  }
> > > > @@ -1946,6 +1948,9 @@ static int b44_resume(struct pci_dev *pd
> > > >  	if (!netif_running(dev))
> > > >  		return 0;
> > > >  
> > > > +	if (request_irq(dev->irq, b44_interrupt, SA_SHIRQ, dev->name, dev))
> > > > +		printk(KERN_ERR PFX "%s: request_irq failed\n", dev->name);
> > > > +
> > > >  	spin_lock_irq(&bp->lock);
> > > >  
> > > >  	b44_init_rings(bp);
> > > > 
> > > 
> > > Why does it hang on suspend/resume?
> > > 
> > > This came up a while back and iirc we decided that adding free_irq() to
> > > every ->suspend() handler in the world was the wrong thing to do.  Do I
> > > misremember?
> > 
> > No, you remember right, but b44 needed that free_irq/request_irq even
> > because those ACPI changes. I'm not exactly sure why, something went
> > very wrong otherwise.
> 
> Well I guess we should work out what went wrong ;)
> 
> What are the symptoms?  Screaming interrupt?  Can't immediately see why. 
> Does the screaming interrupt detetor trigger and disable the IRQ Line?

No, it seems like BUG() triggers in
b44. https://bugzilla.novell.com/show_bug.cgi?id=116088 is for
basically 2.6.13 kernel (but it was in something as old as 2.6.5,
too).



Setting machine into suspend to disk with loaded module b44. While
resuming,
kernel oopses and machine freezes after reloading data from
swap. Image will be
appended.

If this can not be fixed in time, we could add this module to
UNLOAD_MODULES_BEFORE_SUSPEND in powersave configuratiion.

								Pavel

-- 
if you have sharp zaurus hardware you don't need... you know my address
