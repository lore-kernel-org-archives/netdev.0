From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/2 V2 NEXT] Replacement patches for [09/11] and [10/11]
Date: Sat, 27 Sep 2014 11:52:04 -0500
Message-ID: <1411836726-12699-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:57748 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaI0QwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 12:52:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit: c151aed6aa146e9587590051aba9da68b9370f9b, the zero-day kbuild
test robot  reported the following:

All error/warnings:

   drivers/net/wireless/rtlwifi/rtl8188ee/built-in.o: In function `rtl_hal_pwrseqcmdparsing':
>> (.text+0x163ab): multiple definition of `rtl_hal_pwrseqcmdparsing'
   drivers/net/wireless/rtlwifi/rtl8723ae/built-in.o:(.text+0x18bee): first defined here
   drivers/net/wireless/rtlwifi/rtl8188ee/built-in.o: In function `rtl92c_phy_ap_calibrate':
>> (.text+0x15323): multiple definition of `rtl92c_phy_ap_calibrate'
   drivers/net/wireless/rtlwifi/rtl8192c/built-in.o:(.text+0xa96b): first defined here

To improve bisectibility, please replace patches 9, 10, and 11 of the previous submission
with the two patches in this set. Number 11 had been merged with these two. The subjects
of the patches have not been changed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Larry Finger (2):
  rtlwifi: rtl8188ee: Update driver to match Realtek release of 06282014
  rtlwifi: rtl8821ae: Move driver from staging to regular tree

 drivers/net/wireless/rtlwifi/Kconfig               |   13 +-
 drivers/net/wireless/rtlwifi/Makefile              |    1 +
 drivers/net/wireless/rtlwifi/core.c                |   98 +
 drivers/net/wireless/rtlwifi/debug.h               |    1 +
 drivers/net/wireless/rtlwifi/pwrseqcmd.h           |   94 +
 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/def.h       |   66 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |  881 ++--
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h        |   23 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |  231 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.h        |   29 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        | 1259 ++---
 drivers/net/wireless/rtlwifi/rtl8188ee/led.c       |   49 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/led.h       |    4 -
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       | 2151 +++++----
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h       |   49 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c    |  102 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h    |  415 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c |  140 -
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h |   93 -
 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h       | 2936 ++++++------
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.c        |  282 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.h        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |   41 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.h        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/table.c     |    6 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/table.h     |   12 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |  444 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h       |   83 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h |   98 -
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |   16 +-
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c    |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/Makefile    |   19 +
 drivers/net/wireless/rtlwifi/rtl8821ae/def.h       |  450 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c        | 3019 ++++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h        |  356 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c        | 1889 ++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.h        |  351 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c        | 4215 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.h        |   70 +
 drivers/net/wireless/rtlwifi/rtl8821ae/led.c       |  237 +
 drivers/net/wireless/rtlwifi/rtl8821ae/led.h       |   37 +
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c       | 4855 ++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.h       |  259 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.c    |  182 +
 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.h    |  738 +++
 drivers/net/wireless/rtlwifi/rtl8821ae/reg.h       | 2464 ++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/rf.c        |  465 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/rf.h        |   43 +
 drivers/net/wireless/rtlwifi/rtl8821ae/sw.c        |  484 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/sw.h        |   34 +
 drivers/net/wireless/rtlwifi/rtl8821ae/table.c     | 4572 ++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/table.h     |   60 +
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c       | 1243 +++++
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.h       |  620 +++
 drivers/net/wireless/rtlwifi/wifi.h                |   98 +-
 61 files changed, 31815 insertions(+), 4586 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/pwrseqcmd.h
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/trx.h

-- 
1.8.4.5
