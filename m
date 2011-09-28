From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Wed, 28 Sep 2011 07:00:55 -0400
Message-ID: <20110928110055.GA15340@hmsreliant.think-freely.org>
References: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
 <1316477404.14749.256.camel@deadeye>
 <20110920185918.GX21309@gospo.rdu.redhat.com>
 <20110920202305.GC16323@hmsreliant.think-freely.org>
 <1317167146.2845.48.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	jeffrey t kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, Alexander H Duyck <alexander.h.duyck@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37266 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417Ab1I1LBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 07:01:11 -0400
Content-Disposition: inline
In-Reply-To: <1317167146.2845.48.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2011 at 12:45:46AM +0100, Ben Hutchings wrote:
> On Tue, 2011-09-20 at 16:23 -0400, Neil Horman wrote:
> [...]
> > This is the work Andy is referring to for those interested:
> > http://marc.info/?l=linux-kernel&m=131644727521409&w=2
> > 
> > This version has Gregs Ack, and is waiting for an Ack from Jesse Barnes at the
> > moment.
> 
> While I think it's useful to be able to list all IRQs assigned to a PCI
> device, this doesn't tell us anything about the way they're associated
> with queues.
> 
I never claimed that it did.  This just lets us definitavely correlate msi irq
instances to pci devices, and their device class.  Preveously we were limited to
guessing what kind device an irq belonged to by doing hopeful string matches on
device names from proc/interrupts, something which was easily broken by a change
in driver naming practice, or an administrative device name change.

> > I think Andy's probably right, theres room here for expansion to create
> > a relationship between a given interrupt and a napi wieght.  I expect what would
> > be most direct would be adding a napi_weight attribute that was conditional on
> > the class of the pci device allocating the irqs (make it visible for class 0x200
> > devs, invisible for others).
> 
> That's a terrible idea; what has NAPI got to do with PCI devices?
> 
Nothing directly, but stop making up an implementation, and deciding based on
that the whole notion is stupid.  There are a few ways to do this, some of which
make sense.

I was thinking of something along the lines of two more attributes in
/sys/class/net/<if>/queues:
napi_weight
irq

The former is the napi weight of a given napi instance associated with a queue,
while the latter is a symlink either to ../device/irq or ../device/msi_irqs/<n>/
(or perhaps to ../devices/msi_irqs/<n>/irq if we want more consistency).   This
lets us tune the napi weight of a queue and know what interrupt is associated
with it.  That seems fairly sane to me.
Neil
