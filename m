From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] New driver "sfc" for Solarstorm SFC4000 controller (try #7)
Date: Mon, 3 Mar 2008 18:56:24 +0000
Message-ID: <20080303185624.GC2988@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rutherford.zen.co.uk ([212.23.3.142]:52399 "EHLO
	rutherford.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbYCCS4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 13:56:30 -0500
Received: from [82.69.137.158] (helo=opal.uk.level5networks.com)
	by rutherford.zen.co.uk with esmtp (Exim 4.63)
	(envelope-from <bwh@solarflare.com>)
	id 1JWFps-0007oX-0Z
	for netdev@vger.kernel.org; Mon, 03 Mar 2008 18:56:28 +0000
Received: from achroite (achroite.uk.level5networks.com [10.17.20.50])
	by opal.uk.level5networks.com (8.12.8/8.12.8) with ESMTP id m23IuPMC023781
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 18:56:25 GMT
Received: from bwh by achroite with local (Exim 4.62)
	(envelope-from <bwh@solarflare.com>)
	id 1JWFpo-0002cD-RE
	for netdev@vger.kernel.org; Mon, 03 Mar 2008 18:56:24 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resubmission of a new driver for Solarflare network controllers.

The driver supports several types of PHY (10Gbase-T, XFP, CX4) on six
different 10G and 1G boards.  It is accompanied by an MTD driver that
allows access to the flash/EEPROM.

NICs based on this controller are now available from SMC as part numbers
SMC10GPCIe-XFP and SMC10GPCIe-10BT.

The previous thread was:
  http://marc.info/?l=linux-netdev&m=120162616808659&w=2

Some explanation of the driver structure was posted in:
  http://marc.info/?l=linux-netdev&m=119999015817920&w=2

Since the last patch we have made some bug fixes and minor improvements:

 - Fix MAC stats during TX drain
 - Fix skb leak on self-test failure
 - Add workaround for RX flush timeout
 - Recover from more TX errors
 - Allow more time for recovery of TXC43128 PHY between resets
 - Fix signed-ness mismatches
 - Improve robustness of efx_{start,stop}_{all,port}()
 - Correct some netif_tx_lock/unlock calls to _bh variants
 - Make probe fail if the NIC becomes disabled
 - Fix efx_dl_search_device_info() macro
 - Validate MAC address in efx_set_mac_address()
 - Test for failure of efx_init_debugfs_netdev()
 - Fix potential loss of promiscuous flag
 - Improve comments on locking requirements
 - Remove some redundant initialisation code
 - Remove unused alaska_blink() function
 - Add byte-order annotations and fix byte-order bugs
 - Use C99 __func__, not gcc's __FUNCTION__
 - Eliminate suspend lock as redundant with rtnl_lock
 - Move Falcon hardware parameters from efx_nic into the nic_data field
 - Make RX refill workqueue global as it should be per-CPU not per-NIC
 - Use net_device::stats instead of efx_nic::stats
 - Correct some comments
 - Define a PCI_EXP_DEVCTL_PAYLOAD_LBN constant instead of using ffs()
   since ffs() is not evaluated at compile-time
 - Make use of PCI_DEVICE() macro for efx_pci_table initialisation
 - Remove unnecessary indirection between efx_pci_table and
   struct efx_nic_type
 - Change MSI-X setup to allocate an MSI-X interrupt per package, not
   per core, by default
 - Rename *_max to *_lim in struct efx_dl_falcon_resources for clarity
 - Fix error handling in efx_change_mtu()
 - Do not reconfigure XGXS block after resetting XAUI block
 - Simplify multicast hash setting
 - Fix array size calculation in efx_multicast_hash

We believe this is ready to be merged now and would appreciate a
thorough review.

The patch (against netdev-2.6) is at:
  https://support.solarflare.com/netdev/7/netdev-2.6-sfc-2.2.0106.patch

The new files may also be downloaded as a tarball:
  https://support.solarflare.com/netdev/7/netdev-2.6-sfc-2.2.0106.tar.gz

And for verification there is:
  https://support.solarflare.com/netdev/7/MD5SUMS

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
