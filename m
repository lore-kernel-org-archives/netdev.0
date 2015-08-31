From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 1/2] airo: fix IW_AUTH_ALG_OPEN_SYSTEM
Date: Mon, 31 Aug 2015 21:19:53 +0200
Message-ID: <1441048794-31237-1-git-send-email-linux@rainbow-software.org>
Cc: Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle IW_AUTH_ALG_OPEN_SYSTEM in set_auth.
This allows wpa_supplicant (and thus NetworkManager) to work with open APs.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/wireless/airo.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index d0c97c2..2066a1f 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -6670,10 +6670,9 @@ static int airo_set_auth(struct net_device *dev,
 		break;
 
 	case IW_AUTH_80211_AUTH_ALG: {
-			/* FIXME: What about AUTH_OPEN?  This API seems to
-			 * disallow setting our auth to AUTH_OPEN.
-			 */
-			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
+			if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
+				local->config.authType = AUTH_OPEN;
+			} else if (param->value & IW_AUTH_ALG_SHARED_KEY) {
 				local->config.authType = AUTH_SHAREDKEY;
 			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
 				local->config.authType = AUTH_ENCRYPT;
-- 
Ondrej Zary
