From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/13] tg3: Disable GPHY autopowerdown
Date: Fri, 09 Nov 2007 16:38:54 -0800
Message-ID: <1194655134.5745.269.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3328 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429AbXKJAjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New CPMU devices contend with the GPHY for power management.  The GPHY
autopowerdown feature is enabled by default in the PHY and thus needs to
be disabled after every PHY reset.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 25e57d8..b5c4799 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1117,6 +1117,12 @@ static int tg3_phy_reset(struct tg3 *tp)
 			udelay(40);
 			tw32_f(TG3_CPMU_LSPD_1000MB_CLK, val);
 		}
+
+		/* Disable GPHY autopowerdown. */
+		tg3_writephy(tp, MII_TG3_MISC_SHDW,
+			     MII_TG3_MISC_SHDW_WREN |
+			     MII_TG3_MISC_SHDW_APD_SEL |
+			     MII_TG3_MISC_SHDW_APD_WKTM_84MS);
 	}
 
 out:
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f715b35..5b799ff 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1715,6 +1715,12 @@
 #define MII_TG3_ISTAT			0x1a /* IRQ status register */
 #define MII_TG3_IMASK			0x1b /* IRQ mask register */
 
+#define MII_TG3_MISC_SHDW		0x1c
+#define MII_TG3_MISC_SHDW_WREN		0x8000
+#define MII_TG3_MISC_SHDW_APD_SEL	0x2800
+
+#define MII_TG3_MISC_SHDW_APD_WKTM_84MS	0x0001
+
 /* ISTAT/IMASK event bits */
 #define MII_TG3_INT_LINKCHG		0x0002
 #define MII_TG3_INT_SPEEDCHG		0x0004


