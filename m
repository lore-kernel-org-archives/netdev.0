From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH] PCIe ASPM causes machine (HP Compaq 6735s) to
	sometimes freeze hard at boot at PCI initialization time
Date: Mon, 08 Dec 2008 09:32:42 +0800
Message-ID: <1228699962.13024.2.camel@sli10-desk.sh.intel.com>
References: <200811281328.55259.trenn@suse.de>
	 <200812051407.14419.trenn@suse.de>  <20081205182148.GA28192@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Renninger <trenn@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	Rafael Wysocki <rwysocki@suse.de>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Stable@kernel.org" <Stable@kernel.org>
To: Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39494 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753142AbYLHBcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2008 20:32:45 -0500
In-Reply-To: <20081205182148.GA28192@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-12-06 at 02:21 +0800, Matthew Garrett wrote:
> On Fri, Dec 05, 2008 at 02:07:13PM +0100, Thomas Renninger wrote:
> 
> > PCIE: Break out of endless loop waiting for PCI config bits to switch
> > 
> > Makes a Compaq 6735s boot reliably again which hang in the loop
> > on some boots.
> 
> Which device does it get stuck on?
> 
> > +	if (loop_count == 100) 
> > +		dev_printk (KERN_WARNING, &pdev->dev, "Could not configure ASPM\n");
> 
> "ASPM: Could not configure common clock\n"? ASPM should still work, 
> though with higher latency. It probably also needs to revert the 
> configuration changes.
Yep, Just undo the pci config writes of pcie_aspm_configure_common_clock should be fine to me.
Maybe an expiration time is ok here.
Does the device work after this?

Thanks,
Shaohua

