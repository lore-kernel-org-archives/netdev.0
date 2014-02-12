From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 04/10] net: phy: add genphy_aneg_done()
Date: Tue, 11 Feb 2014 17:27:36 -0800
Message-ID: <1392168462-18888-5-git-send-email-f.fainelli@gmail.com>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:60332 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbaBLB2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:28:31 -0500
In-Reply-To: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing PHY drivers to potentially override their
auto-negotiation done callback, move the contents of phy_aneg_done() to
genphy_aneg_done() since that function really is the generic
implementation based on the BMSR_ANEGCOMPLETE status.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c        |  4 +---
 drivers/net/phy/phy_device.c | 16 ++++++++++++++++
 include/linux/phy.h          |  1 +
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 36fc6e1..db9c543 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -120,9 +120,7 @@ static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
  */
 static inline int phy_aneg_done(struct phy_device *phydev)
 {
-	int retval = phy_read(phydev, MII_BMSR);
-
-	return (retval < 0) ? retval : (retval & BMSR_ANEGCOMPLETE);
+	return genphy_aneg_done(phydev);
 }
 
 /* A structure for mapping a particular speed and duplex
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 82514e7..4e7db72 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -865,6 +865,22 @@ int genphy_config_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_config_aneg);
 
+/**
+ * genphy_aneg_done - return auto-negotiation status
+ * @phydev: target phy_device struct
+ *
+ * Description: Reads the status register and returns 0 either if
+ *   auto-negotiation is incomplete, or if there was an error.
+ *   Returns BMSR_ANEGCOMPLETE if auto-negotiation is done.
+ */
+int genphy_aneg_done(struct phy_device *phydev)
+{
+	int retval = phy_read(phydev, MII_BMSR);
+
+	return (retval < 0) ? retval : (retval & BMSR_ANEGCOMPLETE);
+}
+EXPORT_SYMBOL(genphy_aneg_done);
+
 static int gen10g_config_aneg(struct phy_device *phydev)
 {
 	return 0;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 565188c..c572842 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -612,6 +612,7 @@ static inline int phy_read_status(struct phy_device *phydev)
 int genphy_setup_forced(struct phy_device *phydev);
 int genphy_restart_aneg(struct phy_device *phydev);
 int genphy_config_aneg(struct phy_device *phydev);
+int genphy_aneg_done(struct phy_device *phydev);
 int genphy_update_link(struct phy_device *phydev);
 int genphy_read_status(struct phy_device *phydev);
 int genphy_suspend(struct phy_device *phydev);
-- 
1.8.3.2
