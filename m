From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 00/16 V2] Add new driver for RTL8723BE
Date: Fri, 28 Feb 2014 15:16:42 -0600
Message-ID: <1393622218-1455-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:64977 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbaB1VRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 16:17:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches modifies rtlwifi to incorporate a new driver for
the RTL8723BE wireless device. New variables are needed in the common
structs, and some routines that are common to rtl8723ae and rtl8723be
are moved into a common mini driver.

This driver is intended for the -next stream for 3.15.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
V2 - Apparently, my repo had some bit rot as the V1 set would not apply
     to a freshly pulled repo. That is fixed, and the code modified for
     the new API for ieee80211_is_robust_mgmt_frame().
V3 - Fix some duplicate global names when doing an allyesconfig.

Larry Finger (16):
  rtlwifi: btcoexist: Add headers for new mini driver
  rtlwifi: btcoexist: Add source for new mini driver - part 1
  rtlwifi: btcoexist: Add source for new mini driver - part 2
  rtlwifi: Prepare existing drivers for new driver
  rtlwifi: rtl8723ae: rtl8723-common: Create new driver for common code
  rtlwifi: rtl8723ae: rtl8723-common: Copy common firmware code
  rtlwifi: rtl8723ae: rtl8723-common: Copy common dynamic power
    management code
  rtlwifi: rtl8723be: Add files for new driver - part 1
  rtlwifi: rtl8723be: Add files for new driver - part 2
  rtlwifi: rtl8723be: Add files for new driver - part 3
  rtlwifi: rtl8723be: Add files for new driver - part 4
  rtlwifi: rtl8723be: Add files for new driver - part 5
  rtlwifi: rtl8723be: Add files for new driver - part 6
  rtlwifi: rtl8723be: Add files for new driver - part 7
  rtlwifi: rtl8723be: Add files for new driver - part 8
  rtlwifi: rtl8723be: Turn on building of new driver

 drivers/net/wireless/rtlwifi/Kconfig               |   27 +-
 drivers/net/wireless/rtlwifi/Makefile              |    3 +
 drivers/net/wireless/rtlwifi/btcoexist/Makefile    |    7 +
 .../net/wireless/rtlwifi/btcoexist/halbt_precomp.h |   87 +
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.c   | 3698 ++++++++++++++++++++
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.h   |  173 +
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  | 1011 ++++++
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  |  559 +++
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c   |  218 ++
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h   |   52 +
 drivers/net/wireless/rtlwifi/core.c                |   12 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    2 +-
 drivers/net/wireless/rtlwifi/pci.h                 |    4 +
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |   18 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h       |    5 -
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |   42 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |  260 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |   18 +-
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |    2 +
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |   36 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |  482 +--
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |   21 -
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |   13 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h       |    6 -
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile    |   20 +
 drivers/net/wireless/rtlwifi/rtl8723be/def.h       |  248 ++
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        | 1325 +++++++
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h        |  310 ++
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c        |  628 ++++
 drivers/net/wireless/rtlwifi/rtl8723be/fw.h        |  248 ++
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        | 2529 +++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/hw.h        |   64 +
 drivers/net/wireless/rtlwifi/rtl8723be/led.c       |  153 +
 drivers/net/wireless/rtlwifi/rtl8723be/led.h       |   35 +
 drivers/net/wireless/rtlwifi/rtl8723be/phy.c       | 2175 ++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/phy.h       |  217 ++
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c    |  106 +
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h    |  305 ++
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c |  140 +
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h |   95 +
 drivers/net/wireless/rtlwifi/rtl8723be/reg.h       | 2293 ++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/rf.c        |  504 +++
 drivers/net/wireless/rtlwifi/rtl8723be/rf.h        |   43 +
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |  385 ++
 drivers/net/wireless/rtlwifi/rtl8723be/sw.h        |   35 +
 drivers/net/wireless/rtlwifi/rtl8723be/table.c     |  572 +++
 drivers/net/wireless/rtlwifi/rtl8723be/table.h     |   43 +
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |  959 +++++
 drivers/net/wireless/rtlwifi/rtl8723be/trx.h       |  616 ++++
 drivers/net/wireless/rtlwifi/rtl8723com/Makefile   |    9 +
 .../net/wireless/rtlwifi/rtl8723com/dm_common.c    |   65 +
 .../net/wireless/rtlwifi/rtl8723com/dm_common.h    |   33 +
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |  329 ++
 .../net/wireless/rtlwifi/rtl8723com/fw_common.h    |  126 +
 drivers/net/wireless/rtlwifi/rtl8723com/main.c     |   33 +
 .../net/wireless/rtlwifi/rtl8723com/phy_common.c   |  434 +++
 .../net/wireless/rtlwifi/rtl8723com/phy_common.h   |   89 +
 drivers/net/wireless/rtlwifi/usb.c                 |    2 +-
 drivers/net/wireless/rtlwifi/wifi.h                |  309 +-
 71 files changed, 21378 insertions(+), 910 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbt_precomp.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/trx.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/dm_common.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/main.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/phy_common.h

-- 
1.8.4.5
