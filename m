From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] phy: add suspend/resume into the PHY drivers
Date: Thu, 27 Nov 2008 14:57:19 +0100
Message-ID: <1227794239-19897-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:60773 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753337AbYK0N5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 08:57:41 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id ECC7BDAFA
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 13:57:36 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B105E4C27F
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 13:57:35 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

almost all physical device drivers should be able to support power management.
So this patch only adds the generic suspend/resume within them.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/broadcom.c   |   12 ++++++++++++
 drivers/net/phy/cicada.c     |    4 ++++
 drivers/net/phy/davicom.c    |    6 ++++++
 drivers/net/phy/icplus.c     |    2 ++
 drivers/net/phy/lxt.c        |    4 ++++
 drivers/net/phy/marvell.c    |   12 ++++++++++++
 drivers/net/phy/national.c   |    2 ++
 drivers/net/phy/phy_device.c |    2 ++
 drivers/net/phy/qsemi.c      |    2 ++
 drivers/net/phy/realtek.c    |    2 ++
 drivers/net/phy/smsc.c       |    9 +++++++++
 drivers/net/phy/vitesse.c    |    4 ++++
 12 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 4b4dc98..da0a11f 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -342,6 +342,8 @@ static struct phy_driver bcm5411_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE },
 };
 
@@ -356,6 +358,8 @@ static struct phy_driver bcm5421_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE },
 };
 
@@ -370,6 +374,8 @@ static struct phy_driver bcm5461_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE },
 };
 
@@ -384,6 +390,8 @@ static struct phy_driver bcm5464_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE },
 };
 
@@ -398,6 +406,8 @@ static struct phy_driver bcm5481_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE },
 };
 
@@ -412,6 +422,8 @@ static struct phy_driver bcm5482_driver = {
 	.read_status	= bcm5482_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE },
 };
 
diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index a1bd599..4a6b9eb 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -114,6 +114,8 @@ static struct phy_driver cis8201_driver = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
@@ -129,6 +131,8 @@ static struct phy_driver cis8204_driver = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index d926168..3e47ed6 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -158,6 +158,8 @@ static struct phy_driver dm9161e_driver = {
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
@@ -169,6 +171,8 @@ static struct phy_driver dm9161a_driver = {
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
@@ -182,6 +186,8 @@ static struct phy_driver dm9131_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index af3f1f2..5005fef 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -117,6 +117,8 @@ static struct phy_driver ip175c_driver = {
 	.config_init	= &ip175c_config_init,
 	.config_aneg	= &ip175c_config_aneg,
 	.read_status	= &ip175c_read_status,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 4cf3324..6170316 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -131,6 +131,8 @@ static struct phy_driver lxt970_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt970_ack_interrupt,
 	.config_intr	= lxt970_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
@@ -144,6 +146,8 @@ static struct phy_driver lxt971_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt971_ack_interrupt,
 	.config_intr	= lxt971_config_intr,
+	.suspend 	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index eb6411c..377241b 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -440,6 +440,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.suspend = genphy_suspend,
+		.resume	= genphy_resume,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -453,6 +455,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.suspend = genphy_suspend,
+		.resume	= genphy_resume,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -466,6 +470,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.suspend = genphy_suspend,
+		.resume	= genphy_resume,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -479,6 +485,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.suspend = genphy_suspend,
+		.resume	= genphy_resume,
 		.driver = {.owner = THIS_MODULE,},
 	},
 	{
@@ -492,6 +500,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.suspend = genphy_suspend,
+		.resume	= genphy_resume,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
@@ -505,6 +515,8 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.suspend = genphy_suspend,
+		.resume	= genphy_resume,
 		.driver = { .owner = THIS_MODULE },
 	},
 };
diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
index 6c636eb..e1e0de8 100644
--- a/drivers/net/phy/national.c
+++ b/drivers/net/phy/national.c
@@ -134,6 +134,8 @@ static struct phy_driver dp83865_driver = {
 	.read_status = genphy_read_status,
 	.ack_interrupt = ns_ack_interrupt,
 	.config_intr = ns_config_intr,
+	.suspend = genphy_suspend,
+	.resume	= genphy_resume,
 	.driver = {.owner = THIS_MODULE,}
 };
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index b51cebb..61a5e9b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -919,6 +919,8 @@ static struct phy_driver genphy_driver = {
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= {.owner= THIS_MODULE, },
 };
 
diff --git a/drivers/net/phy/qsemi.c b/drivers/net/phy/qsemi.c
index 23062d0..0a8cefb 100644
--- a/drivers/net/phy/qsemi.c
+++ b/drivers/net/phy/qsemi.c
@@ -123,6 +123,8 @@ static struct phy_driver qs6612_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= qs6612_ack_interrupt,
 	.config_intr	= qs6612_config_intr,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index a052a67..49238e2 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -59,6 +59,8 @@ static struct phy_driver rtl821x_driver = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &rtl821x_ack_interrupt,
 	.config_intr	= &rtl821x_config_intr,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 73baa7a..a1c2d97 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -81,6 +81,9 @@ static struct phy_driver lan83c185_driver = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
+
 	.driver		= { .owner = THIS_MODULE, }
 };
 
@@ -102,6 +105,9 @@ static struct phy_driver lan8187_driver = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
+
 	.driver		= { .owner = THIS_MODULE, }
 };
 
@@ -123,6 +129,9 @@ static struct phy_driver lan8700_driver = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
+
 	.driver		= { .owner = THIS_MODULE, }
 };
 
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index dd3b244..cd9f1ad 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -140,6 +140,8 @@ static struct phy_driver vsc8244_driver = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
@@ -167,6 +169,8 @@ static struct phy_driver vsc8221_driver = {
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
-- 
1.5.6.5

