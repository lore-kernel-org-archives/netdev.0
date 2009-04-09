From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC PATCH v2 09/19] net: Add vbus_enet driver
Date: Thu, 9 Apr 2009 12:50:30 -0700
Message-ID: <20090409195030.GA3453@suse.de>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163128.32740.46975.stgit@dev.haskins.net> <20090409093710.10d63e39@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org,
	herber@gondor.apana.org.au, chrisw@sous-sol.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090409093710.10d63e39@s6510>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 09, 2009 at 09:37:10AM -0700, Stephen Hemminger wrote:
> > +static int tx_ringlen = 256;
> > +module_param(tx_ringlen, int, 0444);
> > +
> > +#undef PDEBUG             /* undef it, just in case */
> > +#ifdef VBUS_ENET_DEBUG
> > +#  define PDEBUG(fmt, args...) printk(KERN_DEBUG "vbus_enet: " fmt, ## args)
> > +#else
> > +#  define PDEBUG(fmt, args...) /* not debugging: nothing */
> > +#endif
> 
> Why reinvent pr_debug()?

Even more important, use dev_dbg() instead please, that uniquly
describes your device and driver together, which is what you need/want,
and it ties into the dynamic debug work, so you don't need a special
kernel config option.

thanks,

greg k-h
