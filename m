From: Thomas Renninger <trenn@suse.de>
Subject: Re: [PATCH] PCIe ASPM causes machine (HP Compaq 6735s) to sometimes freeze hard at boot at PCI initialization time
Date: Mon, 8 Dec 2008 15:56:57 +0100
Message-ID: <200812081556.59070.trenn@suse.de>
References: <200811281328.55259.trenn@suse.de> <20081205182148.GA28192@srcf.ucam.org> <1228699962.13024.2.camel@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Matthew Garrett <mjg59@srcf.ucam.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	Rafael Wysocki <rwysocki@suse.de>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Stable@kernel.org" <Stable@kernel.org>
To: Shaohua Li <shaohua.li@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37603 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753270AbYLHO5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 09:57:03 -0500
In-Reply-To: <1228699962.13024.2.camel@sli10-desk.sh.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 December 2008 02:32:42 Shaohua Li wrote:
> On Sat, 2008-12-06 at 02:21 +0800, Matthew Garrett wrote:
> > On Fri, Dec 05, 2008 at 02:07:13PM +0100, Thomas Renninger wrote:
> > > PCIE: Break out of endless loop waiting for PCI config bits to switch
> > >
> > > Makes a Compaq 6735s boot reliably again which hang in the loop
> > > on some boots.
> >
> > Which device does it get stuck on?
> >
> > > +	if (loop_count == 100)
> > > +		dev_printk (KERN_WARNING, &pdev->dev, "Could not configure ASPM\n");
> >
> > "ASPM: Could not configure common clock\n"? ASPM should still work,
> > though with higher latency. It probably also needs to revert the
> > configuration changes.
>
> Yep, Just undo the pci config writes of pcie_aspm_configure_common_clock
> should be fine to me. Maybe an expiration time is ok here.
> Does the device work after this?

After not writing back the pci values as done with this patch?
Yes, I think it did.

It definitely does with this patch.

What about this one:

