From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Warn if device doesn't have
 enough PCI bandwidth
Date: Wed, 15 Jan 2014 23:33:53 +0000
Message-ID: <1389828833.11912.37.camel@bwh-desktop.uk.level5networks.com>
References: <1388863024-8718-1-git-send-email-amirv@mellanox.com>
	 <1389042955.9947.110.camel@bwh-desktop.uk.level5networks.com>
	 <1389827709.8362.14.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21750 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaAOXd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:33:58 -0500
In-Reply-To: <1389827709.8362.14.camel@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 23:15 +0000, Keller, Jacob E wrote:
> On Mon, 2014-01-06 at 21:15 +0000, Ben Hutchings wrote:
> > On Sat, 2014-01-04 at 21:17 +0200, Amir Vadai wrote:
> > > From: Eyal Perry <eyalpe@mellanox.com>
> > > 
> > > Check if the device get enough bandwidth from the entire PCI chain to satisfy
> > > its capabilities. This patch determines the PCIe device's bandwidth capabilities
> > > by reading its PCIe Link Capabilities registers and then call the
> > > pcie_get_minimum_link function to ensure that the adapter is hooked into a slot
> > > which is capable of providing the necessary bandwidth capabilities.
> > [...]
> > 
> > This is essentially another duplicate of what ixgbe and i40e are
> > doing...  (And the out-of-tree version of sfc does it too, but I never
> > felt that was ready for in-tree.)
> > 
> > We ought to have a generic PCI layer function that warns when a PCIe
> > device is running below maximum link width/speed.  Maybe even run it as
> > soon as the device is enumerated, so that a driver doesn't need to do
> > anything.
> > 
> > Ben.
> > 
> 
> Hi,
> 
> I was thinking about this again, was wondering a few things. Is this
> something you were already investigating?

No, I'm busy with other things.

> On an implementation note, how would this function know how much
> bandwidth a particular device (or function?) would require? I'm thinking
> of something along the lines of a driver essentially saying how much the
> devices it supports require?

I was thinking you could generically compare the link status with link
capabilities of the endpoint, i.e. actual versus maximum possible
bandwidth.

In some cases the link capabilities may be more than you really need.
For example, given a 10/40G controller capable of PCIe gen3 x8, on a
board that only has a single 10G port, you could put the board in a gen1
x8 slot and still have enough PCIe bandwidth to saturate the Ethernet
link.  However it will have higher latency compared to a gen3 x8 slot.
So I think the generic comparison would be OK as long as the log message
and severity is not too alarming.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
