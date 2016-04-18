From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rtl8xxxu: hide unused tables
Date: Mon, 18 Apr 2016 23:59:31 +0200
Message-ID: <1461016782-2640046-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Jakub Sitnicki <jsitnicki@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The references to some arrays in the rtl8xxxu driver were moved inside
of an #ifdef, but the symbols remain outside, resulting in build warnings:

rtl8xxxu/rtl8xxxu.c:1506:33: error: 'rtl8188ru_radioa_1t_highpa_table' defined but not used
rtl8xxxu/rtl8xxxu.c:1431:33: error: 'rtl8192cu_radioa_1t_init_table' defined but not used
rtl8xxxu/rtl8xxxu.c:1407:33: error: 'rtl8192cu_radiob_2t_init_table' defined but not used
rtl8xxxu/rtl8xxxu.c:1332:33: error: 'rtl8192cu_radioa_2t_init_table' defined but not used
rtl8xxxu/rtl8xxxu.c:239:35: error: 'rtl8192c_power_base' defined but not used
rtl8xxxu/rtl8xxxu.c:217:35: error: 'rtl8188r_power_base' defined but not used

This adds an extra #ifdef around them to shut up the warnings.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 2fc0b8e5a17d ("rtl8xxxu: Add TX power base values for gen1 parts")
Fixes: 4062b8ffec36 ("rtl8xxxu: Move PHY RF init into device specific functions")
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c
index 928ca56f751c..0ba84b5fe0d6 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c
@@ -214,6 +214,7 @@ static struct rtl8xxxu_reg8val rtl8192e_mac_init_table[] = {
 	{0xffff, 0xff},
 };
 
+#ifdef CONFIG_RTL8XXXU_UNTESTED
 static struct rtl8xxxu_power_base rtl8188r_power_base = {
 	.reg_0e00 = 0x06080808,
 	.reg_0e04 = 0x00040406,
@@ -257,6 +258,7 @@ static struct rtl8xxxu_power_base rtl8192c_power_base = {
 	.reg_084c = 0x0b0c0d0e,
 	.reg_0868 = 0x01030509,
 };
+#endif
 
 static struct rtl8xxxu_power_base rtl8723a_power_base = {
 	.reg_0e00 = 0x0a0c0c0c,
@@ -1329,6 +1331,7 @@ static struct rtl8xxxu_rfregval rtl8723bu_radioa_1t_init_table[] = {
 	{0xff, 0xffffffff}
 };
 
+#ifdef CONFIG_RTL8XXXU_UNTESTED
 static struct rtl8xxxu_rfregval rtl8192cu_radioa_2t_init_table[] = {
 	{0x00, 0x00030159}, {0x01, 0x00031284},
 	{0x02, 0x00098000}, {0x03, 0x00018c63},
@@ -1577,6 +1580,7 @@ static struct rtl8xxxu_rfregval rtl8188ru_radioa_1t_highpa_table[] = {
 	{0x00, 0x00030159},
 	{0xff, 0xffffffff}
 };
+#endif
 
 static struct rtl8xxxu_rfregval rtl8192eu_radioa_init_table[] = {
 	{0x7f, 0x00000082}, {0x81, 0x0003fc00},
-- 
2.7.0
