From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2.6.11-rc2] wireless: Make Atmel driver use
	SET_NETDEV_DEV
Date: Tue, 01 Feb 2005 20:41:02 -0500
Message-ID: <1107308462.20243.1.camel@dcbw.boston.redhat.com>
References: <1107294126.17332.16.camel@dcbw.boston.redhat.com>
	 <42002E00.6000101@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, simon@thekelleys.org.uk
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42002E00.6000101@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

And both evolution and pine screw up the patches inline and break the
line at odd places...  at least, that's what I see...  you don't mind if
you have to do a little surgery here and there?

Dan

On Tue, 2005-02-01 at 20:33 -0500, Jeff Garzik wrote:
> Dan Williams wrote:
> > Make the Atmel wireless driver use SET_NETDEV_DEV to get the correct
> > entries in sysfs.  Seems like somebody meant to do this but it got lost.
> > atmel_cs.c was previously fixed to pass in the correct struct device *
> > via handle_to_dev() but the driver never actually used it.
> > 
> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> > 
> > --- a/drivers/net/wireless/atmel.c	2005-01-27 20:26:46.000000000 -0500
> > +++ b/drivers/net/wireless/atmel.c	2005-02-01 16:15:55.000000000 -0500
> > @@ -1579,6 +1579,8 @@
> >  	dev->irq = irq;
> >  	dev->base_addr = port;
> >  	
> > +	SET_NETDEV_DEV(dev, sys_dev);
> > +	
> >  	if ((rc = request_irq(dev->irq, service_interrupt, SA_SHIRQ, dev->name, dev))) {
> >  		printk(KERN_ERR "%s: register interrupt %d failed, rc %d\n", dev->name, irq, rc );
> >  		goto err_out_free;
> > 
> > 
> 
> Can you please resend all your patches with _just_ the patch inline, 
> rather than both inline and attached?
> 
> Your emails break my scripts, since the scripts try to apply both.
> 
> 	Jeff
> 
> 
> 
