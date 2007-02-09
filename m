From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: Network: convert network devices to use struct device instead
	of class_device
Date: Fri, 09 Feb 2007 09:22:02 +0100
Message-ID: <1171009322.10605.39.camel@pim.off.vrfy.org>
References: <200702080400.l1840lFd002314@hera.kernel.org>
	 <d120d5000702080929r7016de12k292add26a0a72291@mail.gmail.com>
	 <20070209005601.GE30794@kroah.com>  <200702082259.47685.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Dmitry Torokhov <dtor@insightbb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:53095 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946210AbXBIIWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 03:22:00 -0500
In-Reply-To: <200702082259.47685.dtor@insightbb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-02-08 at 22:59 -0500, Dmitry Torokhov wrote:
> On Thursday 08 February 2007 19:56, Greg KH wrote:
> > On Thu, Feb 08, 2007 at 12:29:12PM -0500, Dmitry Torokhov wrote:
> > > On 2/8/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > > >On Thu, 08 Feb 2007 07:43:18 -0500

> > > >> >     Network: convert network devices to use struct device instead of 
> > > >class_device
> > > >> >
> > > >> >     This lets the network core have the ability to handle 
> > > >suspend/resume
> > > >> >     issues, if it wants to.
> > > >
> > > >It fixes a non-problem. I would like to see the network core suspend/resume
> > > >proposal as well. Last time I examined doing network core suspend help,
> > > >the problem was that the physical device suspend was called before the
> > > >class device. It is not clear how this change would help.
> > > 
> > > If physical devices are registered before class devices then when
> > > suspending class devices are naturally suspended first. It is still
> > > not clear to me why we need to convert everythign to struct device, I
> > > believe I've shown (with patches) that it is possible to integrate
> > > struct class_device into PM framework and avoid reshuffling half of
> > > the kernel code.
> > 
> > I don't want to have two separate device trees in the kernel (well, one
> > big device tree and a bunch of little class_device trees.)  The code
> > duplication in the class_device code is just too much, and I get
> > questions all the time as to what the differences are.
> >
> 
> While duplication of code is a real concern my worry is constant fattening
> of struct device. For example most physical devices do not interface
> directly with userspace but every single one of them now has dev_t.
> Former class_devices do not need suspend/resume early framework either.
> And so on, and so forth.

The dev_t is a good example for the mess we try to fix here. Not having
a dev_t for "devices" lead to the creation of a lot of otherwise
completely useless "class devices" which are just a total pain to
interpret, and follow the events they create, from userspace.

Things like the scsi_device devices, usb_device devices, ... just exist,
because only this type of devices was allowed to pass information for
device nodes to userspace.

Thanks,
Kay

