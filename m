From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/7] Convert drivers to a common rtl_phy_scan_operation_backup() routine
Date: Thu, 26 Sep 2013 13:25:26 -0500
Message-ID: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:52081 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab3IZS0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 14:26:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several of the driver implement this routine using the same code. This set
of patches creates a common routine in driver rtlwifi, converts each of the
drivers to use the new routine, and then deletes the now unused old code.

These patches rely on two prerequisite patches:

[PATCH 11/11] rtlwifi: Remove extern from function prototypes by Joe Perches
TCH] rtlwifi: remove duplicate declarations and macros in headers by Catalin Iacob

None of these patches fix any bugs. They merely reduce the size of the source code,
thus they need no particular priority.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Larry Finger (7):
  rtlwifi: Implement a common rtl_phy_scan_operation_backup() routine
  rtlwifi: rtl8192cu: Convert to use new rtl_phy_scan_operation_backup()
    routine
  rtlwifi: rtl8192ce: Convert driver to use new
    rtl_phy_scan_operation_backup() routine
  rtlwifi: rtl8192c: Remove rtl8192c_phy_scan_operation_backup()
  rtlwifi: rtl8192ce: Convert driver to use new
    rtl_phy_scan_operation_backup() routine
  rtlwifi: rtl8723ae: Convert driver to use new
    rtl_phy_scan_operation_backup() routine
  rtlwifi: rtl8188ee: Convert driver to use new
    rtl_phy_scan_operation_backup() routine

 drivers/net/wireless/rtlwifi/base.c                | 29 +++++++++++++++++++++
 drivers/net/wireless/rtlwifi/base.h                |  1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       | 28 --------------------
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h       |  1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c | 30 ----------------------
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h |  2 --
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |  1 -
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       | 28 --------------------
 drivers/net/wireless/rtlwifi/rtl8192de/phy.h       |  1 -
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       | 29 ---------------------
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |  1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |  3 ++-
 16 files changed, 40 insertions(+), 126 deletions(-)

-- 
1.8.1.4
