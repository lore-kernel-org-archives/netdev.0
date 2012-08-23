From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] drivers/net: use is_zero_ether_addr() instead of memcmp()
Date: Thu, 23 Aug 2012 15:16:44 +0800
Message-ID: <CAPgLHd_L1=1zaq=NUAjr+3822WfR2gV-sMA2tzKowHEezPmvOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: j@w1.fi, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:44712 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755593Ab2HWHQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 03:16:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using is_zero_ether_addr() instead of directly use
memcmp() to determine if the ethernet address is all
zeros.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/hostap/hostap_info.c | 4 ++--
 drivers/net/wireless/hostap/hostap_main.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_info.c b/drivers/net/wireless/hostap/hostap_info.c
index 47932b2..970a48b 100644
--- a/drivers/net/wireless/hostap/hostap_info.c
+++ b/drivers/net/wireless/hostap/hostap_info.c
@@ -4,6 +4,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/export.h>
+#include <linux/etherdevice.h>
 #include "hostap_wlan.h"
 #include "hostap.h"
 #include "hostap_ap.h"
@@ -463,8 +464,7 @@ static void handle_info_queue_scanresults(local_info_t *local)
 		prism2_host_roaming(local);
 
 	if (local->host_roaming == 2 && local->iw_mode == IW_MODE_INFRA &&
-	    memcmp(local->preferred_ap, "\x00\x00\x00\x00\x00\x00",
-		   ETH_ALEN) != 0) {
+	    !is_zero_ether_addr(local->preferred_ap)) {
 		/*
 		 * Firmware seems to be getting into odd state in host_roaming
 		 * mode 2 when hostscan is used without join command, so try

diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 627bc12..15f0fad 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -1084,7 +1084,7 @@ int prism2_sta_deauth(local_info_t *local, u16 reason)
 	__le16 val = cpu_to_le16(reason);
 
 	if (local->iw_mode != IW_MODE_INFRA ||
-	    memcmp(local->bssid, "\x00\x00\x00\x00\x00\x00", ETH_ALEN) == 0 ||
+	    is_zero_ether_addr(local->bssid) ||
 	    memcmp(local->bssid, "\x44\x44\x44\x44\x44\x44", ETH_ALEN) == 0)
 		return 0;
 
