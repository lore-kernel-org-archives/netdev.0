From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next]r8169:Disable advertise full duplex on chip id RTL_GIGA_MAC_VER_09. Disable advertise full duplex on chip id RTL_GIGA_MAC_VER_09  wich support random full duplex.(very sad)  On branch master  Your branch is ahead of 'origin/master' by 18 commits.    (use "git push" to publish your local commits)
Date: Sat, 18 Jul 2015 13:03:58 +0300
Message-ID: <1437213838-29318-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------mine-boundary-string"
Cc: Corcodel Marian <corcodel.marian@gmail.com>,
	Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35744 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463AbbGRKES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 06:04:18 -0400
Received: by wibxm9 with SMTP id xm9so55754626wib.0
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 03:04:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------mine-boundary-string
Content-Type: text/plain; charset=UTF-8; format=fixed
Content-Transfer-Encoding: 8bit


 Changes to be committed:
	modified:   drivers/net/ethernet/realtek/r8169.c

Signed-off-by: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)


--------------mine-boundary-string
Content-Type: text/x-patch; name="0001-Committer-Corcodel-Marian-corcodel.marian-gmail.com.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="0001-Committer-Corcodel-Marian-corcodel.marian-gmail.com.patch"

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 714af89..a373679 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1918,12 +1918,23 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 		if (adv & ADVERTISED_10baseT_Half)
 			auto_nego |= ADVERTISE_10HALF;
-		if (adv & ADVERTISED_10baseT_Full)
-			auto_nego |= ADVERTISE_10FULL;
+		if (!tp->mac_version == RTL_GIGA_MAC_VER_09) {
+		 if (adv & ADVERTISED_10baseT_Full)
+			 auto_nego |= ADVERTISE_10FULL;
+		} else {
+		   netif_info(tp, link, dev,							   	     
+		             "PHY does not support 10Mbps full duplex\n");
+		  } 
 		if (adv & ADVERTISED_100baseT_Half)
 			auto_nego |= ADVERTISE_100HALF;
-		if (adv & ADVERTISED_100baseT_Full)
-			auto_nego |= ADVERTISE_100FULL;
+		if (!tp->mac_version == RTL_GIGA_MAC_VER_09) {
+		 if (adv & ADVERTISED_100baseT_Full)
+			 auto_nego |= ADVERTISE_100FULL;
+	        } else {
+		   netif_info(tp, link, dev,
+		             "PHY does not support 100Mbps full duplex\n");
+	          } 
+
 
 		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 

--------------mine-boundary-string--
