From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Wed, 28 Sep 2011 13:07:13 -0400
Message-ID: <20110928170713.GA16532@hmsreliant.think-freely.org>
References: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
 <1316477404.14749.256.camel@deadeye>
 <20110920185918.GX21309@gospo.rdu.redhat.com>
 <20110920202305.GC16323@hmsreliant.think-freely.org>
 <1317167146.2845.48.camel@bwh-desktop>
 <20110928110055.GA15340@hmsreliant.think-freely.org>
 <20110928081158.7273e9b4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	jeffrey t kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, Alexander H Duyck <alexander.h.duyck@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56792 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038Ab1I1RHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 13:07:32 -0400
Content-Disposition: inline
In-Reply-To: <20110928081158.7273e9b4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2011 at 08:11:58AM -0700, Stephen Hemminger wrote:
> On Wed, 28 Sep 2011 07:00:55 -0400
> Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > I was thinking of something along the lines of two more attributes in
> > /sys/class/net/<if>/queues:
> > napi_weight
> > irq
> > 
> > The former is the napi weight of a given napi instance associated with a queue,
> > while the latter is a symlink either to ../device/irq or ../device/msi_irqs/<n>/
> > (or perhaps to ../devices/msi_irqs/<n>/irq if we want more consistency).   This
> > lets us tune the napi weight of a queue and know what interrupt is associated
> > with it.  That seems fairly sane to me.
> 
> This breaks for the case of some corner case devices like multi-port Marvell boards.
> There can be a N to 1 or 1 to N relationship between NAPI and the device.
> 

I don't see that it has to explicitly _break_ anything.  If a multiqueue device
uses a single napi instance to handle all queues, we can still create a napi
weight attribute for each queue, and simply let the device driver tie all the
weight sysfs objects to the same napi instance.  It would be odd for certain,
but doable.  In fact, since we'd have to get the driver involved in the creation
of such a per-queue napi weight attribute (since the driver is the only thing
with any knoweldge about which queue maps to which napi instance), we might be
able to explicitly export this information by allowing a single queue to hold
the napi wieght, and allowing the other queues sysfs symlinks back to that
object.  

I'm just spitballing here on implementation, but I don't think the idea is
broken.
Neil
