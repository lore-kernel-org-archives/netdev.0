From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: RFC: igb: Intel 82575 gigabit ethernet driver (take #2)
Date: Wed, 12 Dec 2007 09:18:58 -0800
Message-ID: <47601802.6080205@intel.com>
References: <475F107A.8080201@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8204 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbXLLRYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 12:24:25 -0500
In-Reply-To: <475F107A.8080201@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> All,
> 
> here is the second version of the igb (82575) ethernet controller driver. This
> driver was previously posted 2007-07-13. Many comments received were addressed:
> 
> - removed indirection wrappers in the same way as e1000e and ixgbe.
> - cleaned up largely against sparse, checkpatch
> - removed module parameters and moved functionality to ethtool ioctls
> - new NAPI API rewrites
> - by default the driver runs in multiqueue mode with 2 to 40 RX queues enabled.
> 
> Since the driver is still too large (allthough the patch shrunk from 558k to 416k,
> almost 34% of its size) to post to this list I am attaching the bzipped patch
> here. You can get the same driver alternatively from here:
> 
> http://foo-projects.org/~sofar/0001-igb-PCI-Express-82575-Gigabit-Ethernet-driver.patch
> [416k]
> http://foo-projects.org/~sofar/0001-igb-PCI-Express-82575-Gigabit-Ethernet-driver.patch.bz2
> [74k]
> 
> or through git:
>     git://lost.foo-projects.org/~ahkok/git/linux-2.6 #igb
> 
> 
> There are several concerns still open for this driver:
> - namespace collisions with e1000. Since there are cleanups planned for e1000
> since pci-e hardware is now moved to e1000e, this might resolve them.
> - hardware code is still a large API. we're expecting more hardware to be
> supported by this driver in the future and it's not certain which parts we need to
> keep or not.


unfortunately a last-minute effort of mine inserted a stray character. Please
re-download the patch files from http or through git to get the updated patch that
fixes this issue. The changes needed are below.

Cheers,

Auke


---
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index e57222a..1c13156 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -1555,7 +1555,7 @@ s32 e1000_get_phy_info_igp(struct e1000_hw *hw)
 		goto out;

 	ret_val = hw->phy.ops.read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS,
-			`		   &data);
+					   &data);
 	if (ret_val)
 		goto out;
