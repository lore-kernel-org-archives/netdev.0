From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 00/13] Mellanox 100G mlx5 resiliency and xmit path fixes
Date: Thu, 30 Jun 2016 17:34:37 +0300
Message-ID: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37669 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932163AbcF3Oh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series provides two set of fixes to the mlx5 driver:
	- Resiliency fixes for reset flow and internal pci errors
	- xmit path fixes

Please consider queuing those patches for -stable (4.6).

Reset flow fixes for core driver:
	- Add more commands to the list of error simulated commands 
	  when pci errors occur
	- Avoid calling sleeping function by the health poll thread
	- Fix incorrect page count when in internal error
	- Fix timeout in wait vital for VFs
	- Deadlock fix and Timeout handling in commands interface

Reset flow and resiliency fixes for mlx5e netdev driver:
	- Handle RQ flush in error cases
	- Implement ndo_tx_timeout callback
	- Timeout if SQ doesn't flush during close
	- Log link state changes
	- Validate BW weight values of ETS

xmit path fixes:
	- Fix wrong fallback assumption in select queue callback
	- Account for all L2 headers when copying headers into inline segment

Thanks,
Saeed.

Daniel Jurgens (5):
  net/mlx5: Fix incorrect page count when in internal error
  net/mlx5: Fix wait_vital for VFs and remove fixed sleep
  net/mlx5e: Timeout if SQ doesn't flush during close
  net/mlx5e: Implement ndo_tx_timeout callback
  net/mlx5e: Handle RQ flush in error cases

Matthew Finlay (1):
  net/mlx5e: Copy all L2 headers into inline segment

Mohamad Haj Yahia (4):
  net/mlx5: Fix teardown errors that happen in pci error handler
  net/mlx5: Avoid calling sleeping function by the health poll thread
  net/mlx5: Fix potential deadlock in command mode change
  net/mlx5: Add timeout handle to commands with callback

Rana Shahout (2):
  net/mlx5e: Fix select queue callback
  net/mlx5e: Validate BW weight values of ETS

Shaker Daibes (1):
  net/mlx5e: Log link state changes

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 129 ++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  11 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  99 ++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  41 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  52 ++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  11 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  41 +++----
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  63 +++++++---
 include/linux/mlx5/driver.h                        |   1 +
 10 files changed, 335 insertions(+), 121 deletions(-)

-- 
2.8.0
