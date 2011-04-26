From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Tue, 26 Apr 2011 13:51:46 +1000
Message-ID: <20110426135146.c01f8395.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>,
	=?UTF-8?B?IkZyYW7Dp29pcyBSb21pZXUi?= <romieu@fr.zoreil.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

drivers/net/r8169.c: In function 'rtl8168e_1_hw_phy_config':
drivers/net/r8169.c:2578: error: too many arguments to function 'rtl_apply_firmware'
drivers/net/r8169.c:2578: error: void value not ignored as it ought to be
drivers/net/r8169.c: In function 'rtl8168e_2_hw_phy_config':
drivers/net/r8169.c:2586: error: too many arguments to function 'rtl_apply_firmware'
drivers/net/r8169.c:2586: error: void value not ignored as it ought to be

Caused by commit 953a12cc2889 ("r8169: don't request firmware when
there's no userspace") from the net-current tree interacting with commit
01dc7fec4025 ("net/r8169: support RTL8168E").

I applied the following fixup patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 26 Apr 2011 13:47:51 +1000
Subject: [PATCH] r8169: fix for rtl_apply_firmware API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/r8169.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3f93fc7..c3e264f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -190,7 +190,9 @@ static const struct rtl_firmware_info {
 	{ .mac_version = RTL_GIGA_MAC_VER_25, .fw_name = FIRMWARE_8168D_1 },
 	{ .mac_version = RTL_GIGA_MAC_VER_26, .fw_name = FIRMWARE_8168D_2 },
 	{ .mac_version = RTL_GIGA_MAC_VER_29, .fw_name = FIRMWARE_8105E_1 },
-	{ .mac_version = RTL_GIGA_MAC_VER_30, .fw_name = FIRMWARE_8105E_1 }
+	{ .mac_version = RTL_GIGA_MAC_VER_30, .fw_name = FIRMWARE_8105E_1 },
+	{ .mac_version = RTL_GIGA_MAC_VER_31, .fw_name = FIRMWARE_8168E_1 },
+	{ .mac_version = RTL_GIGA_MAC_VER_32, .fw_name = FIRMWARE_8168E_2 }
 };
 
 enum cfg_version {
@@ -2575,16 +2577,14 @@ static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8168e_1_hw_phy_config(struct rtl8169_private *tp)
 {
-	if (rtl_apply_firmware(tp, FIRMWARE_8168E_1) < 0)
-		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
+	rtl_apply_firmware(tp);
 
 	rtl8168e_hw_phy_config(tp);
 }
 
 static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 {
-	if (rtl_apply_firmware(tp, FIRMWARE_8168E_2) < 0)
-		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
+	rtl_apply_firmware(tp);
 
 	rtl8168e_hw_phy_config(tp);
 }
-- 
1.7.4.4


-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
