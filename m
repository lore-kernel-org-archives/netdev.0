From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] usbnet: Convert dev(dbg|err|warn|info) macros to
 netdev_<level>
Date: Sun, 14 Feb 2010 16:54:47 -0800
Message-ID: <1266195287.16721.953.camel@Joe-Laptop.home>
References: <20100212.123837.56526847.davem@davemloft.net>
	 <cover.1266187669.git.joe@perches.com>
	 <ec60c0152394dbca309a66072035b92342d8bf7b.1266187670.git.joe@perches.com>
	 <4B7892AA.7000305@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	David Brownell <david-b@pacbell.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7892AA.7000305@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-02-15 at 01:17 +0100, Tilman Schmidt wrote: 
> Am 15.02.2010 00:01 schrieb Joe Perches:
> > Some logging messages were in the form:
> > 	printk(KERN_<level> "msg %s%s%s%s\n",
> > 	       value == 1 ? "one" : "",
> > 	       value == 2 ? "two" : "",
> > 	       value == 3 ? "three" : "",
> > 	       value == 4 ? "four" : "unknown");
> > Converted to:
> > 	printk(KERN_<level> "msg %s\n",
> > 	       value == 1 ? "one" :
> > 	       value == 2 ? "two" :
> > 	       value == 3 ? "three" :
> > 	       value == 4 ? "four" : "unknown");
> [...]
> > diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
> > index aeb1ab0..aa078f3 100644
> > --- a/drivers/net/usb/net1080.c
> > +++ b/drivers/net/usb/net1080.c
> > @@ -205,23 +205,24 @@ static inline void nc_dump_usbctl(struct usbnet *dev, u16 usbctl)
> >  {
> >  	if (!netif_msg_link(dev))
> >  		return;
> > -	devdbg(dev, "net1080 %s-%s usbctl 0x%x:%s%s%s%s%s;"
> > -			" this%s%s;"
> > -			" other%s%s; r/o 0x%x",
> > -		dev->udev->bus->bus_name, dev->udev->devpath,
> > -		usbctl,
> > -		(usbctl & USBCTL_ENABLE_LANG) ? " lang" : "",
> > -		(usbctl & USBCTL_ENABLE_MFGR) ? " mfgr" : "",
> > -		(usbctl & USBCTL_ENABLE_PROD) ? " prod" : "",
> > -		(usbctl & USBCTL_ENABLE_SERIAL) ? " serial" : "",
> > -		(usbctl & USBCTL_ENABLE_DEFAULTS) ? " defaults" : "",
> > -
> > -		(usbctl & USBCTL_FLUSH_OTHER) ? " FLUSH" : "",
> > -		(usbctl & USBCTL_DISCONN_OTHER) ? " DIS" : "",
> > -		(usbctl & USBCTL_FLUSH_THIS) ? " FLUSH" : "",
> > -		(usbctl & USBCTL_DISCONN_THIS) ? " DIS" : "",
> > -		usbctl & ~USBCTL_WRITABLE_MASK
> > -		);
> > +	netdev_dbg(dev->net, "net1080 %s-%s usbctl 0x%x:%s;"
> > +		   " this%s;"
> > +		   " other%s; r/o 0x%x\n",
> > +		   dev->udev->bus->bus_name, dev->udev->devpath,
> > +		   usbctl,
> > +		   (usbctl & USBCTL_ENABLE_LANG) ? " lang" :
> > +		   (usbctl & USBCTL_ENABLE_MFGR) ? " mfgr" :
> > +		   (usbctl & USBCTL_ENABLE_PROD) ? " prod" :
> > +		   (usbctl & USBCTL_ENABLE_SERIAL) ? " serial" :
> > +		   (usbctl & USBCTL_ENABLE_DEFAULTS) ? " defaults" : "",
> > +
> > +		   (usbctl & USBCTL_FLUSH_OTHER) ? " FLUSH" :
> > +		   (usbctl & USBCTL_DISCONN_OTHER) ? " DIS" : "",
> > +
> > +		   (usbctl & USBCTL_FLUSH_THIS) ? " FLUSH" :
> > +		   (usbctl & USBCTL_DISCONN_THIS) ? " DIS" : "",
> > +
> > +		   usbctl & ~USBCTL_WRITABLE_MASK);
> >  }
> >  
> >  /*-------------------------------------------------------------------------*/
> 
> That doesn't look right. The original code concatenates all the strings
> corresponding to the set bits in usbctl. With your patch, it prints only
> the string corresponding to the first set bit it encounters within each
> group.

Hmm, right.  Stuffed that one up.  Thanks Tilman.

I'll resend in a bit after David Brownell or
someone else answers the inverted question below.

> Btw, is it intentional that the _OTHER values are printed after the
> label "this", and the _THIS values after the label "other"?

Thanks again, I saw that, but neglected to mention it.
David Brownell?  Do you know if that is inverted?

[]

> Same problem.

Right again.
