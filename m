From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Sat, 6 Jun 2009 00:05:46 +0930
Message-ID: <200906060005.47127.rusty@rustcorp.com.au>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <200906051425.02924.rusty@rustcorp.com.au> <4A290800.1030803@novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A290800.1030803@novell.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 5 Jun 2009 09:26:48 pm Gregory Haskins wrote:
> Hi Rusty,
>
> Rusty Russell wrote:
> > On Fri, 5 Jun 2009 04:19:17 am Gregory Haskins wrote:
> >> Avi Kivity wrote:
> >>> Gregory Haskins wrote:
> >>> One idea is similar to signalfd() or eventfd()
> >>
> >> And thus the "kvm-eventfd" (irqfd/iosignalfd) interface project was
> >> born. ;)
> >
> > The lguest patch queue already has such an interface :)
>
> Cool!  Ultimately I think it will be easier if both lguest+kvm support
> the same eventfd notion so this is good you are already moving in the
> same direction.

Not really; lguest doesn't do PCI.

> > And I have a partially complete in-kernel virtio_pci patch with the same
> > trick.
>
> I thought lguest didn't use pci?  Or do you just mean that you have an
> in-kernel virtio-net for lguest?

No, this was for kvm.  Sorry for the confusion.

> Other than the potential rcu issues that Paul already addressed, looks
> good.  FWIW: this looks like what we are calling "iosignalfd" on the kvm
> land (unless I am misunderstanding).  Do you have the equivalent of
> "irqfd" going the other way?

Yes; lguest uses write() (offset indicates cpu #) rather than ioctls, but 
anyone can do the LHREQ_IRQ write to queue an interrupt for delivery.

So the threads just get the same /dev/lguest fd and it's simple.

Thanks!
Rusty.
