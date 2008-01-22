From: Jeff Garzik <jeff@garzik.org>
Subject: Re: RFC: igb: Intel 82575 gigabit ethernet driver (take #3)
Date: Tue, 22 Jan 2008 05:05:26 -0500
Message-ID: <4795BFE6.1080202@garzik.org>
References: <4786AB0C.6010202@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59906 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756899AbYAVKF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 05:05:29 -0500
In-Reply-To: <4786AB0C.6010202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> All,
> 
> here is the third version of the igb (82575) ethernet controller driver. This
> driver was previously posted 2007-07-13 and 2007-12-11. Many comments received
> were addressed:
> 
> - removed indirection wrappers in the same way as e1000e and ixgbe.
> - cleaned up largely against sparse, checkpatch
> - removed module parameters and moved functionality to ethtool ioctls
> - new NAPI API rewrites
> - by default the driver runs in multiqueue mode with 2 to 40 RX queues enabled.
> 
> and specifically in this version:
> 
> - register macro's were condensed for readability
> - fixed namespace collisions by renaming functions to igb_*
> 
> Since the driver is still too large (allthough the patch shrunk from 558k to 416k
> to 407k, almost 38% of its size) to post to this list I am attaching the bzipped
> patch here. You can get the same driver alternatively from here:
> 
> http://foo-projects.org/~sofar/0001-igb-PCI-Express-82575-Gigabit-Ethernet-driver.patch
> [407k]
> http://foo-projects.org/~sofar/0001-igb-PCI-Express-82575-Gigabit-Ethernet-driver.patch.bz2
> [74k]
> 
> or through git:
>     git://lost.foo-projects.org/~ahkok/git/linux-2.6 #igb
> 
> 
> There are several concerns still open for this driver:
> - hardware code is still a large API. we're expecting more hardware to be
> supported by this driver in the future. The API has already been scrubbed but we
> anticipate that the remaining hooks will be used in the future.
> - The register defines are still named "E1000_" as they are mostly identical to
> the e1000 chipsets (igb register space is a superset of most recent e1000 register
> sets).
> 
> 
> Please review,
> 
> 
> Cheers,
> 
> Auke
> 
> ---
> 
>>From 4ec9e52f44de0c1c41265c5f326b573643f24da7 Mon Sep 17 00:00:00 2001
> From: Auke Kok <auke-jan.h.kok@intel.com>
> Date: Thu, 10 Jan 2008 14:55:46 -0800
> Subject: [PATCH] igb: PCI-Express 82575 Gigabit Ethernet driver
> 
> We are pleased to announce a new Gigabit Ethernet product and its
> driver to the linux community. This product is the Intel(R) 82575
> Gigabit Ethernet adapter family. Physical adapters will be available
> to the public soon. These adapters come in 2- and 4-port versions
> (copper PHY) currently. Other variants will be available later.
> 
> The 82575 chipset supports significantly different features that
> warrant a new driver. The descriptor format is (just like the
> ixgbe driver) different. The device can use multiple MSI-X vectors
> and multiple queues for both send and receive. This allows us to
> optimize some of the driver code specifically as well compared to
> the e1000-supported devices.
> 
> This version of the igb driver no lnger uses fake netdevices and
> incorporates napi_struct members for each ring to do the multi-
> queue polling. multi-queue is enabled by default and the driver
> supports NAPI mode only.
> 
> All the namespace collisions should be gone in this version too. The
> register macro's have been condensed to improve readability.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
>  drivers/net/Kconfig             |   22 +
>  drivers/net/Makefile            |    1 +
>  drivers/net/igb/Makefile        |   37 +
>  drivers/net/igb/e1000_82575.c   | 1269 ++++++++++++
>  drivers/net/igb/e1000_82575.h   |  150 ++
>  drivers/net/igb/e1000_defines.h |  772 ++++++++
>  drivers/net/igb/e1000_hw.h      |  599 ++++++
>  drivers/net/igb/e1000_mac.c     | 1505 ++++++++++++++
>  drivers/net/igb/e1000_mac.h     |   98 +
>  drivers/net/igb/e1000_nvm.c     |  605 ++++++
>  drivers/net/igb/e1000_nvm.h     |   40 +
>  drivers/net/igb/e1000_phy.c     | 1807 +++++++++++++++++
>  drivers/net/igb/e1000_phy.h     |   98 +
>  drivers/net/igb/e1000_regs.h    |  270 +++
>  drivers/net/igb/igb.h           |  300 +++
>  drivers/net/igb/igb_ethtool.c   | 1927 ++++++++++++++++++
>  drivers/net/igb/igb_main.c      | 4138 +++++++++++++++++++++++++++++++++++++++
>  17 files changed, 13638 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/igb/Makefile
>  create mode 100644 drivers/net/igb/e1000_82575.c
>  create mode 100644 drivers/net/igb/e1000_82575.h
>  create mode 100644 drivers/net/igb/e1000_defines.h
>  create mode 100644 drivers/net/igb/e1000_hw.h
>  create mode 100644 drivers/net/igb/e1000_mac.c
>  create mode 100644 drivers/net/igb/e1000_mac.h
>  create mode 100644 drivers/net/igb/e1000_nvm.c
>  create mode 100644 drivers/net/igb/e1000_nvm.h
>  create mode 100644 drivers/net/igb/e1000_phy.c
>  create mode 100644 drivers/net/igb/e1000_phy.h
>  create mode 100644 drivers/net/igb/e1000_regs.h
>  create mode 100644 drivers/net/igb/igb.h
>  create mode 100644 drivers/net/igb/igb_ethtool.c
>  create mode 100644 drivers/net/igb/igb_main.c

applied


