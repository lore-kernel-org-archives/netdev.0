From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: Network: convert network devices to use struct device instead of class_device
Date: Fri, 9 Feb 2007 10:28:28 -0500
Message-ID: <d120d5000702090728i51818b1xc1c0c0aa4b67a76c@mail.gmail.com>
References: <200702080400.l1840lFd002314@hera.kernel.org>
	 <d120d5000702080929r7016de12k292add26a0a72291@mail.gmail.com>
	 <20070209005601.GE30794@kroah.com>
	 <200702082259.47685.dtor@insightbb.com>
	 <1171009322.10605.39.camel@pim.off.vrfy.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Greg KH" <greg@kroah.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Kay Sievers" <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:10177 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946529AbXBIP23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 10:28:29 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1251123nfa
        for <netdev@vger.kernel.org>; Fri, 09 Feb 2007 07:28:28 -0800 (PST)
In-Reply-To: <1171009322.10605.39.camel@pim.off.vrfy.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/9/07, Kay Sievers <kay.sievers@vrfy.org> wrote:
> On Thu, 2007-02-08 at 22:59 -0500, Dmitry Torokhov wrote:
> > On Thursday 08 February 2007 19:56, Greg KH wrote:
> > > On Thu, Feb 08, 2007 at 12:29:12PM -0500, Dmitry Torokhov wrote:
> > > > On 2/8/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > > > >On Thu, 08 Feb 2007 07:43:18 -0500
>
> > > > >> >     Network: convert network devices to use struct device instead of
> > > > >class_device
> > > > >> >
> > > > >> >     This lets the network core have the ability to handle
> > > > >suspend/resume
> > > > >> >     issues, if it wants to.
> > > > >
> > > > >It fixes a non-problem. I would like to see the network core suspend/resume
> > > > >proposal as well. Last time I examined doing network core suspend help,
> > > > >the problem was that the physical device suspend was called before the
> > > > >class device. It is not clear how this change would help.
> > > >
> > > > If physical devices are registered before class devices then when
> > > > suspending class devices are naturally suspended first. It is still
> > > > not clear to me why we need to convert everythign to struct device, I
> > > > believe I've shown (with patches) that it is possible to integrate
> > > > struct class_device into PM framework and avoid reshuffling half of
> > > > the kernel code.
> > >
> > > I don't want to have two separate device trees in the kernel (well, one
> > > big device tree and a bunch of little class_device trees.)  The code
> > > duplication in the class_device code is just too much, and I get
> > > questions all the time as to what the differences are.
> > >
> >
> > While duplication of code is a real concern my worry is constant fattening
> > of struct device. For example most physical devices do not interface
> > directly with userspace but every single one of them now has dev_t.
> > Former class_devices do not need suspend/resume early framework either.
> > And so on, and so forth.
>
> The dev_t is a good example for the mess we try to fix here. Not having
> a dev_t for "devices" lead to the creation of a lot of otherwise
> completely useless "class devices" which are just a total pain to
> interpret, and follow the events they create, from userspace.
>
> Things like the scsi_device devices, usb_device devices, ... just exist,
> because only this type of devices was allowed to pass information for
> device nodes to userspace.
>

I admit I do not know scsi stack but I would expect that the only
things that need dev_t there would be sd, sr and sg interfaces. As
such they are separate entities and "deserve" their own structures no
mater what.

I can bet that number of real devices that need dev_t is smaller than
number of virtual devices that do not need full power management:

PCI cards, ACPI tree, etc, etc - hardware devices interfacing with
other parts of the kernel, not userspace directly.

NET, input, tty, etc - no need to suspend late/resume early

And, btw, having separate device and struct device does not prevent
exporting them as a unified sysfs tree and is in fact pretty easy to
do (I believe I posted patches to do that as well).

-- 
Dmitry
