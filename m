From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT] rtlwifi: btcoexist: Fix interference between rtl8723be and Bluetooth
Date: Mon, 11 May 2015 14:00:27 -0500
Message-ID: <1431370827-13324-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, Daniel Drake <drake@endlessm.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Shao Fu <shaofu@realtek.com>
To: kvalo@codeaurora.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:34833 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671AbbEKTAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 15:00:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Drake <drake@endlessm.com>

During usage of the new Bluetooth driver for Realtek devices, it was found
that BT scans were inhibited for the RTL8723BE when wireless was active. The
exact cause of this interference is not known yet, but a satisfactory work
around has been found that does not seem to have any visible side effects.

Signed-off-by: Daniel Drake <drake@endlessm.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Shao Fu <shaofu@realtek.com>
---
 drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c
index cefe269..f2b9d11 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c
@@ -1286,8 +1286,11 @@ static void btc8723b2ant_ps_tdma(struct btc_coexist *btcoexist, bool force_exec,
 						    0x12, 0xe1, 0x90);
 			break;
 		case 3:
-			btc8723b2ant_set_fw_ps_tdma(btcoexist, 0xe3, 0x1c,
-						    0x3, 0xf1, 0x90);
+			/* This call breaks BT when wireless is active -
+			 * comment it out for now until a better fix is found:
+			 * btc8723b2ant_set_fw_ps_tdma(btcoexist, 0xe3, 0x1c,
+			 *			    0x3, 0xf1, 0x90);
+			 */
 			break;
 		case 4:
 			btc8723b2ant_set_fw_ps_tdma(btcoexist, 0xe3, 0x10,
-- 
2.1.4
