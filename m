From: Richard Zhao <linuxzsc@gmail.com>
Subject: [PATCH 3/3] smsc911x: add flag SMSC911X_USE_INTERPHY
Date: Tue, 24 Mar 2009 14:47:25 +0800
Message-ID: <4e090d470903232347g2b6e91a7o385af2e66f05a936@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, kernel@pengutronix.de
To: steve.glendinning@smsc.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:29653 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582AbZCXGr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 02:47:26 -0400
Received: by wa-out-1112.google.com with SMTP id j5so1704302wah.21
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 23:47:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mx31pdk board don't have external PHY, but it wrongly pull up MDIO.
So, add flag SMSC911X_USE_INTERPHY to force using internal PHY.

Signed-off-by: Richard Zhao <linuxzsc@gmail.com>

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index d1590ac..60f7b74 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -831,10 +831,12 @@ static int __devinit smsc911x_mii_init(struct
platform_device *pdev,
 	case 0x01150000:
 	case 0x117A0000:
 	case 0x115A0000:
-		/* External PHY supported, try to autodetect */
-		if (smsc911x_phy_initialise_external(pdata) < 0) {
-			SMSC_TRACE(HW, "No external PHY detected, "
-				"using internal PHY");
+		if (!(pdata->config & SMSC911X_USE_INTERPHY)) {
+			/* External PHY supported, try to autodetect */
+			if (smsc911x_phy_initialise_external(pdata) < 0) {
+				SMSC_TRACE(HW, "No external PHY detected, "
+					"using internal PHY");
+			}
 		}
 		break;
 	default:
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 1cbf031..42b088d 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -43,5 +43,6 @@ struct smsc911x_platform_config {
 /* Constants for flags */
 #define SMSC911X_USE_16BIT 			(BIT(0))
 #define SMSC911X_USE_32BIT 			(BIT(1))
+#define SMSC911X_USE_INTERPHY 			(BIT(2))

 #endif /* __LINUX_SMSC911X_H__ */
-- 
1.5.6.3
