From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Warn if device doesn't have
 enough PCI bandwidth
Date: Mon, 6 Jan 2014 21:15:55 +0000
Message-ID: <1389042955.9947.110.camel@bwh-desktop.uk.level5networks.com>
References: <1388863024-8718-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64005 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756342AbaAFVQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:16:00 -0500
In-Reply-To: <1388863024-8718-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-04 at 21:17 +0200, Amir Vadai wrote:
> From: Eyal Perry <eyalpe@mellanox.com>
> 
> Check if the device get enough bandwidth from the entire PCI chain to satisfy
> its capabilities. This patch determines the PCIe device's bandwidth capabilities
> by reading its PCIe Link Capabilities registers and then call the
> pcie_get_minimum_link function to ensure that the adapter is hooked into a slot
> which is capable of providing the necessary bandwidth capabilities.
[...]

This is essentially another duplicate of what ixgbe and i40e are
doing...  (And the out-of-tree version of sfc does it too, but I never
felt that was ready for in-tree.)

We ought to have a generic PCI layer function that warns when a PCIe
device is running below maximum link width/speed.  Maybe even run it as
soon as the device is enumerated, so that a driver doesn't need to do
anything.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
