From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] New driver "sfc" for Solarstorm SFC4000 controller
Date: Tue, 29 Jan 2008 16:22:02 +0000
Message-ID: <20080129162201.GC28089@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:56197 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932750AbYA2QWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 11:22:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resubmission of a new driver for Solarflare network controllers.

The driver supports several types of PHY (10Gbase-T, XFP, CX4) on six
different 10G and 1G boards.  It is accompanied by an MTD driver that
allows access to the flash/EEPROM.

NICs based on this controller are now available from SMC as part numbers
SMC10GPCIe-XFP and SMC10GPCIe-10BT.

FYI the previous thread was:
  http://marc.info/?l=linux-netdev&m=120067352032298&w=4

Things that have changed since the last patch:

 - Changed ethtool support to use the default ethtool implementations
   where possible
 - Removed unused MDIO functions
 - Combined struct efx_nic and struct efx_nic_port, since the driver
   now only supports 1-port configurations
 - Removed/combined redundant members of struct efx_nic
 - Moved some constant members of struct efx_nic into struct efx_nic_type
 - Moved the two steps of efx_nic::dma_mask initialisation together
 - Eliminated efx_nic::features and efx_nic_type::features; moved all
   feature flag setting into efx_init_netdev()
 - Fixed page-based RX buffer alignment for architectures with strict
   alignment
 - Replaced spinlocks with mutexes where possible
 - Merged efx_{init,fini}_debugfs_nic_symlink into
   efx_{init,fini}_debugfs_netdev
 - Renamed efx_{init,fini}_netdev and corrected comments to
   indicate that they only (un)register the net device
 - Added EFX_FTL - fatal in debug builds otherwise equivalent to EFX_ERR
 - Changed RX FIFO watermarks to more reasonable values
 - Fixed various corner cases in PHY reconfiguration
 - Changed NET_DEV_NAME() to use efx->name, making races with
   (un)registration harmless
 - Fixed repetition of PCI or net device name in log messages
 - Renamed falcon_nic_params structure to falcon_nic_data
 - Fixed spelling, capitalisation, grammar, punctuation, spacing
   in various comments and log messages

We believe this is ready to be merged now and would like to know if
there is anything remaining that we need to fix or improve.

The patch (against netdev-2.6) is at:
  https://support.solarflare.com/netdev/6/netdev-2.6-sfc-2.2.0056.patch

The new files may also be downloaded as a tarball:
  https://support.solarflare.com/netdev/6/netdev-2.6-sfc-2.2.0056.tgz

And for verification there is:
  https://support.solarflare.com/netdev/6/MD5SUMS

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
