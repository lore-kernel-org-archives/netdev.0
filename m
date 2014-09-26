From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/7 NEXT] More updates for the rtlwifi-family of drivers
Date: Fri, 26 Sep 2014 16:40:21 -0500
Message-ID: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:59270 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755964AbaIZVki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:40:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches, which is intended for the 3.18 stream, converts more of the
drivers to the 06/28/14 Realtek version, moves the driver for the RTL8192EE from
staging to the regular wireless tree, and fixes some bugs found in the parts that
have already been submitted.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (7):
  rtlwifi: rtl8188ee: rtl8821ae: Fix a queue locking problem
  rtlwifi: rtl8192ee: Move driver from staging to the regular tree
  rtlwifi: rtl8723ae: Update driver to match 06/28/14 Realtek version
  rtlwifi: rtl8723be: Update driver to match Realtek release of 06/28/14
  rtlwifi: rtl8192ce: rtl8192common: Update for latest version of
    Realtek drivers
  rtlwifi: rtl8188ee: rtl8192com: rtl8192cu: rtl8192ee: rtl8723ae:
    rtl87323be: rtl8821ae: Use common cmd_send_packet
  rtlwifi: rtl8188ee: rtl8723ae: rtl8821ae: Initialize some variables

 drivers/net/wireless/rtlwifi/Kconfig               |   14 +-
 drivers/net/wireless/rtlwifi/Makefile              |    1 +
 drivers/net/wireless/rtlwifi/core.c                |   31 +
 drivers/net/wireless/rtlwifi/core.h                |    1 +
 drivers/net/wireless/rtlwifi/efuse.c               |    4 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   24 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |   38 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |    3 +
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |  447 ++-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |   40 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |  815 ++---
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |   15 -
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |   64 -
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   16 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |    3 +
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |  107 -
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/def.h       |    3 -
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   17 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |    3 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192de/fw.h        |   12 -
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/Makefile    |   20 +
 drivers/net/wireless/rtlwifi/rtl8192ee/def.h       |  101 +
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.c        | 1263 ++++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.h        |  267 ++
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c        |  906 ++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.h        |  208 ++
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c        | 2569 ++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.h        |   62 +
 drivers/net/wireless/rtlwifi/rtl8192ee/led.c       |  145 +
 drivers/net/wireless/rtlwifi/rtl8192ee/led.h       |   34 +
 drivers/net/wireless/rtlwifi/rtl8192ee/phy.c       | 3219 ++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/phy.h       |  153 +
 drivers/net/wireless/rtlwifi/rtl8192ee/pwrseq.c    |  112 +
 drivers/net/wireless/rtlwifi/rtl8192ee/pwrseq.h    |  340 +++
 drivers/net/wireless/rtlwifi/rtl8192ee/reg.h       | 2231 ++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/rf.c        |  152 +
 drivers/net/wireless/rtlwifi/rtl8192ee/rf.h        |   36 +
 drivers/net/wireless/rtlwifi/rtl8192ee/sw.c        |  399 +++
 drivers/net/wireless/rtlwifi/rtl8192ee/sw.h        |   33 +
 drivers/net/wireless/rtlwifi/rtl8192ee/table.c     |  882 ++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/table.h     |   45 +
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c       | 1300 ++++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h       |  860 ++++++
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h       |  197 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |  422 ++-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |   50 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |  255 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |   54 +-
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |  414 ++-
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h    |   38 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   | 1232 ++++----
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h   |   66 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        | 1512 ++++-----
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.h        |   66 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c       |   54 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/led.h       |   13 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |  884 +++---
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |   67 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |   91 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h    |  543 ++--
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h       | 2718 +++++++++--------
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.c        |  261 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h        |   18 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |  222 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.h        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/table.c     |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/table.h     |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |  460 ++-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h       |  325 +-
 drivers/net/wireless/rtlwifi/rtl8723be/def.h       |  178 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        |  243 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c        |  194 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.h        |  200 +-
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        | 1319 ++++----
 drivers/net/wireless/rtlwifi/rtl8723be/hw.h        |    1 +
 drivers/net/wireless/rtlwifi/rtl8723be/led.c       |    6 +-
 drivers/net/wireless/rtlwifi/rtl8723be/phy.c       | 1783 +++++++----
 drivers/net/wireless/rtlwifi/rtl8723be/phy.h       |  110 +-
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h    |  131 +-
 drivers/net/wireless/rtlwifi/rtl8723be/reg.h       | 1135 +++----
 drivers/net/wireless/rtlwifi/rtl8723be/rf.c        |  144 +-
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |   42 +-
 drivers/net/wireless/rtlwifi/rtl8723be/table.c     | 1053 +++----
 drivers/net/wireless/rtlwifi/rtl8723be/table.h     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |  307 +-
 drivers/net/wireless/rtlwifi/rtl8723be/trx.h       |   34 +-
 .../net/wireless/rtlwifi/rtl8723com/dm_common.c    |   14 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |   90 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.h    |   59 +-
 .../net/wireless/rtlwifi/rtl8723com/phy_common.c   |   57 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c        |   40 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c        |    3 +
 drivers/net/wireless/rtlwifi/rtl8821ae/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/usb.c                 |    4 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   28 +-
 108 files changed, 25156 insertions(+), 9073 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h

-- 
1.8.4.5
