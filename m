From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH 3/3] pch_gbe: Add MinnowBoard support
Date: Fri, 12 Jul 2013 22:46:21 -0700
Message-ID: <1373694381.3475.95.camel@envy.home>
References: <ce5dd365d05f8747d269aa74e0bb929935d9cdee.1373676797.git.dvhart@linux.intel.com>
	 <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
	 <20130713011731.GA17939@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130713011731.GA17939@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-12 at 18:17 -0700, Greg KH wrote:
> On Fri, Jul 12, 2013 at 05:58:07PM -0700, Darren Hart wrote:
> > The MinnowBoard uses an AR803x PHY with the PCH GBE which requires
> > special handling. Use the MinnowBoard PCI Subsystem ID to detect this
> > and add a pci_device_id.driver_data structure and functions to handle
> > platform setup.
> > 
> > The AR803x does not implement the RGMII 2ns TX clock delay in the trace
> > routing nor via strapping. Add a detection method for the board and the
> > PHY and enable the TX clock delay via the registers.
> > 
> > This PHY will hibernate without link for 10 seconds. Ensure the PHY is
> > awake for probe and then disable hibernation. A future improvement would
> > be to convert pch_gbe to using PHYLIB and making sure we can wake the
> > PHY at the necessary times rather than permanently disabling it.
> > 
> > Signed-off-by: Darren Hart <dvhart@linux.intel.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> > Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > Cc: netdev@vger.kernel.org
> > Cc: <stable@vger.kernel.org> # 3.8.x: 5829e9b mfd: lpc_sch: Accomodate partial
> > Cc: <stable@vger.kernel.org> # 3.8.x: 3cbf182 gpio-sch: Allow for more than 8
> > Cc: <stable@vger.kernel.org> # 3.8.x: 91bbe92: PCI: Add CircuitCo vendor ID
> > Cc: <stable@vger.kernel.org> # 3.8.x: bd79680: pch_gbe: remove inline keyword
> > Cc: <stable@vger.kernel.org> # 3.8.x: 453ca93: pch_gbe: convert pr_* to
> > Cc: <stable@vger.kernel.org> # 3.8.x: 29cc436: pch_gbe: use managed functions
> > Cc: <stable@vger.kernel.org> # 3.8.x
> > Cc: <stable@vger.kernel.org> # 3.10.x: 91bbe92: PCI: Add CircuitCo vendor ID
> > Cc: <stable@vger.kernel.org> # 3.10.x: bd79680: pch_gbe: remove inline keyword
> > Cc: <stable@vger.kernel.org> # 3.10.x: 453ca93: pch_gbe: convert pr_* to
> > Cc: <stable@vger.kernel.org> # 3.10.x: 29cc436: pch_gbe: use managed functions
> > Cc: <stable@vger.kernel.org> # 3.10.x
> > Signed-off-by: Darren Hart <dvhart@linux.intel.com>
> > ---
> >  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    | 15 ++++
> >  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 48 +++++++++++
> >  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 98 ++++++++++++++++++++++
> >  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  2 +
> >  4 files changed, 163 insertions(+)
> 
> This is _far_ more than just a simple "add a new device id" for a stable
> kernel update.   Please go read Documentation/stable_kernel_rules.txt
> again for why there's no way I can take this type of thing.
>
> You know better than this.

I do appreciate the documentation that is there, and I have read it
(several times). The first two for 3.8 should be acceptable. The three
pre-reqs from pch_gbe are very unfortunate, but Andy pushed his in
response to my initial patch and they were merged first, making things
unnecessarily complicated for stable. This left me with the option of
massaging the patch (easy enough to do - I did this first actually) or
including them as pre-reqs, and I opted for the latter after re-reading
the stable docs and various threads on -stable to try and figure out
what was preferable, and there you had agreed to take a 120 patch
series. I've also seen patches longer than the 100 line limit go in, so
despite the documentation, sometimes it's difficult to tell what is
preferred, and if I don't include stable initially, it takes a lot of
effort and time to get things in afterward. I don't intend this as a
criticism, just an explanation of how I arrived here.

What would you prefer I do with this? I can break up the patch into
infrastructure and then MinnowBoard specific bits (I didn't think the
infrastructure-only patches would be well received on netdev, but maybe
I'm wrong there). I could massage the patch around Andy's three pch_gbe
cleanups which indeed are not stable candidates on their own. Or I could
drop the idea of trying to get Ethernet working on the MinnowBoard
outside of vendor trees and the next upstream release (I'd rather not do
that).

Thanks,

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel
