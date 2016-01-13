From: Bjorn Helgaas <helgaas@kernel.org>
Subject: mlx4 fails ("go bit not cleared") without MSI
Date: Wed, 13 Jan 2016 16:08:43 -0600
Message-ID: <20160113220843.GA21544@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eugenia Emantayev <eugenia@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:40075 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755184AbcAMWIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2016 17:08:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eugenia,

Due to my own stupidity, I tried to use mlx4 without turning on
CONFIG_PCI_MSI=y.  The driver failed miserably:

  pci 0000:01:00.0: [15b3:1007] type 00 class 0x020000
  mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
  mlx4_core: Initializing 0000:01:00.0
  mlx4_core 0000:01:00.0: PCIe link speed is 8.0GT/s, device supports 8.0GT/s
  mlx4_core 0000:01:00.0: PCIe link width is x8, device supports x8
  mlx4_core 0000:01:00.0: command 0x23 timed out (go bit not cleared)
  mlx4_core 0000:01:00.0: device is going to be reset
  mlx4_core 0000:01:00.0: device was reset successfully
  mlx4_core 0000:01:00.0: Failed to initialize queue pair table, aborting
  mlx4_core: probe of 0000:01:00.0 failed with error -5

The lack of MSI was my own fault, but it took me a long time to figure it
out.

The fact that mlx4 has a "msi_x" module parameter makes me think that
mlx4 is *supposed* to work without MSI.  Would you consider either
fixing the non-MSI fallback path, or printing a warning when the
driver can't set up MSIs?

This is easy to reproduce; just turn off CONFIG_PCI_MSI or boot with
"pci=nomsi".

Bjorn
