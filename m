From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8723au: Fix randconfig build errors
Date: Sat,  5 Apr 2014 22:48:59 -0500
Message-ID: <1396756139-26286-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes Sorensen <Jes.Sorensen@redhat.com>,
	kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:37551 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132AbaDFDtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2014 23:49:21 -0400
Received: by mail-oa0-f50.google.com with SMTP id i7so5205157oag.37
        for <netdev@vger.kernel.org>; Sat, 05 Apr 2014 20:49:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kbuild test robot got the following errors for i386-randconfig-c0-04060652:

ERROR: "wiphy_free" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "bridge_tunnel_header" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "ieee80211_frequency_to_channel" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "cfg80211_rx_mgmt" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "ieee80211_channel_to_frequency" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "cfg80211_mgmt_tx_status" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "rfc1042_header" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "__ieee80211_get_channel" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "wiphy_unregister" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "cfg80211_connect_result" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "cfg80211_michael_mic_failure" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "cfg80211_roamed" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "cfg80211_put_bss" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "wiphy_new" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "wiphy_register" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "cfg80211_inform_bss_width_frame" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "cfg80211_disconnected" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "ieee80211_amsdu_to_8023s" [drivers/staging/rtl8723au/r8723au.ko] undefined!
ERROR: "cfg80211_scan_done" [drivers/staging/rtl8723au/r8723au.ko] undefined!

All of these are fixed by forcing the selection of CFG80211 in Kconfig.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
Cc: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org
---
 drivers/staging/rtl8723au/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/rtl8723au/Kconfig b/drivers/staging/rtl8723au/Kconfig
index 7f19d15..78e8805 100644
--- a/drivers/staging/rtl8723au/Kconfig
+++ b/drivers/staging/rtl8723au/Kconfig
@@ -3,6 +3,7 @@ config R8723AU
 	depends on WLAN && USB
 	select WIRELESS_EXT
 	select WEXT_PRIV
+	select CFG80211
 	default n
 	---help---
 	This option adds the Realtek RTL8723AU USB device such as found in
-- 
1.8.1.4
