From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] pci_get_slot()
Date: Wed, 15 Oct 2003 12:34:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015193455.GA23727@kroah.com>
References: <20031015183213.GG16535@parcelfarce.linux.theplanet.co.uk> <20031015184104.GA22373@kroah.com> <20031015185053.GH16535@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, "David S. Miller" <davem@redhat.com>,
        Jeff Garzik <jgarzik@pobox.com>, linux-pci@atrey.karlin.mff.cuni.cz,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20031015185053.GH16535@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 15, 2003 at 07:50:53PM +0100, Matthew Wilcox wrote:
> On Wed, Oct 15, 2003 at 11:41:04AM -0700, Greg KH wrote:
> > The check of:
> > 	if (dev->bus->number == bus && dev->devfn == devfn)
> > in pci_find_slot() doesn't check for the domain?
> 
> No, it would also need to check pci_domain_nr(dev->bus) .. and it doesn't
> have anything to check it against as that information isn't passed into
> the function.

Ah, missed that.  I need to get myself a ppc64 box so I have to worry
about the pci domain stuff :)

> > Anyway, is there any other way you can fix this in the tg3 driver only
> > for right now?  I agree adding the pci function is "cleaner", but a bit
> > late for right now.
> 
> The only real way to do it is to inline pci_get_slot() into tg3.  Since I
> also have a need for it in sym2, that doesn't seem like a sensible idea.
> It would also be racy since it wouldn't take the pci_bus_lock.

Ok, fair enough.  I'll add it to my tree to be sent to Linus after 2.6.0
is out, if Jeff and David agree it's an ok tg3.c patch.

thanks,

greg k-h
