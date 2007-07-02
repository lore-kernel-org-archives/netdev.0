From: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Subject: RE: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI	Express adapters...
Date: Mon, 2 Jul 2007 15:56:23 -0700
Message-ID: <E35F4F4D7F6C9E4E826FEC1F86CEF58304193401@orsmsx412.amr.corp.intel.com>
References: <20070702140958.5ea6571a@freepuppy.localdomain.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jeff@garzik.org>, <netdev@vger.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	<arjan@linux.intel.com>, <akpm@linux-foundation.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2752 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756212AbXGBW4Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 18:56:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070702140958.5ea6571a@freepuppy.localdomain.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/2/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > Fake netdevs are needed for doing the multiple Rx queues in NAPI
mode.
> > We are thinking to solve in 2 ways. Having netdev pointer in ring
> > structure or having an array of netdev pointers in ixgbe_adatper
struct
> > which would be visible to all rings.
> 
> Wait until Davem & I separate NAPI from network device.
> The patch is close to ready for 2.6.24 when this driver will need to
show up.
> 
> Since I know Intel will be forced to backport this to older distro's.
You
> would be best to have a single receive queue version when you have to
make
> it work on the older code.

So far all our testing indicates we need multiple Rx queues to have
better CPU utilization number at 10Gig line rate. So I am thinking
adding the non-NAPI support to the driver (like other 10Gig drivers) and
restrict to single rx queue in case of NAPI. I already have the non-NAPI
version coded up and went through internal testing. I will add this in
the next submission. We will add the multiple Rx queues support in NAPI
mode once when "separate NAPI from network device" is done. Does this
sound ok?

> 
> You only need to store the name for when you are doing request_irq, so
> it can just be a stack temporary.
>

request_irq expects allocated memory not just stack temporary. I glanced
the kernel source.. There are precedents to the way we did.

linux-2.6/source/drivers/usb/core/hcd.c

1594         /* enable irqs just before we start the controller */
1595         if (hcd->driver->irq) {
1596                 snprintf(hcd->irq_descr, sizeof(hcd->irq_descr),
"%s:usb%d",
1597                                 hcd->driver->description,
hcd->self.busnum);
1598                 if ((retval = request_irq(irqnum, &usb_hcd_irq,
irqflags,
1599                                 hcd->irq_descr, hcd)) != 0) {
1600                         dev_err(hcd->self.controller,
1601                                         "request interrupt %d
failed\n", irqnum);
1602                         goto err_request_irq;
1603                 }

 
> Stephen Hemminger <shemminger@linux-foundation.org>

I appreciate the feedback.

Thanks,
Ayyappa
