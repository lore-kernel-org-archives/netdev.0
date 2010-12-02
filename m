From: Ben Hutchings <bhutchings@solarflare.com>
Subject: sfc: Bug fixes and cleanup
Date: Thu, 02 Dec 2010 23:44:50 +0000
Message-ID: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12862 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758263Ab0LBXoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:44:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit c20ec76157747434652e721cdd4dccd8654ad370:

  forcedeth: Use netdev_dbg for printk(KERN_DEBUG (2010-11-29 11:44:56 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git for-davem

Various bug fixes and cleanup.  I'll post them all as replies to this
message.  Please pull.

Ben.

Ben Hutchings (15):
      sfc: Reduce log level for MCDI error response in efx_mcdi_rpc()
      sfc: Fix condition for no-op in set_phy_flash_cfg()
      sfc: Distinguish critical and non-critical over-temperature conditions
      sfc: Read-to-clear LM87 alarm/interrupt status at start of day
      sfc: Clear RXIN_SEL when soft-resetting QT2025C
      sfc: Remove broken automatic fallback for invalid Falcon chip/board config
      sfc: Expose Falcon BootROM config through MTD, not ethtool
      sfc: Remove unnecessary inclusion of various private header files
      sfc: Move SPI state to struct falcon_nic_data
      sfc: Move mdio_lock to struct falcon_nic_data
      sfc: Move Falcon global event handling to falcon.c
      sfc: Move xmac_poll_required into struct falcon_nic_data
      sfc: Update kernel-doc to match earlier move of Toeplitz hash key
      sfc: Use current MAC address, not NVRAM MAC address, for WoL filter
      sfc: Store MAC address from NVRAM in net_device::perm_addr

Steve Hodgson (2):
      sfc: Fix event based MCDI completion and MC REBOOT/CMDDONE ordering issue
      sfc: When waking a stopped tx_queue, only lock that tx_queue

 drivers/net/sfc/efx.c           |   14 +--
 drivers/net/sfc/ethtool.c       |   60 -------------
 drivers/net/sfc/falcon.c        |  183 +++++++++++++++++++++-----------------
 drivers/net/sfc/falcon_boards.c |  120 ++++++++++++++++++-------
 drivers/net/sfc/falcon_xmac.c   |   14 ++-
 drivers/net/sfc/mcdi.c          |    3 +-
 drivers/net/sfc/mcdi_phy.c      |    1 -
 drivers/net/sfc/mdio_10g.c      |    1 -
 drivers/net/sfc/mtd.c           |   98 ++++++++++++++-------
 drivers/net/sfc/net_driver.h    |   17 +---
 drivers/net/sfc/nic.c           |   48 +---------
 drivers/net/sfc/nic.h           |   12 +++-
 drivers/net/sfc/qt202x_phy.c    |    6 ++
 drivers/net/sfc/siena.c         |   10 +--
 drivers/net/sfc/spi.h           |    5 +
 drivers/net/sfc/tenxpress.c     |    2 -
 drivers/net/sfc/tx.c            |    8 ++-
 17 files changed, 309 insertions(+), 293 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

