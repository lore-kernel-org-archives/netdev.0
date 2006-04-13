From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 18/18] ipw2200: Fix wpa_supplicant association problem
Date: Thu, 13 Apr 2006 17:21:13 +0800
Message-ID: <20060413092113.GA28829@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:36522 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S964857AbWDMJ2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:28:17 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new ipw2200 scan completion event feature will cause a potential event
race condition in wpa_supplicant. The patch fixes this problem by move the
ipw_disassociate() to the IW_AUTH_WPA_ENABLED event handling code.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

ea463b8df2999bc2814935df49aec5be42ad9912
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 1bccf7a..8da5b23 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -6346,8 +6346,6 @@ static void ipw_wpa_assoc_frame(struct i
 {
 	/* make sure WPA is enabled */
 	ipw_wpa_enable(priv, 1);
-
-	ipw_disassociate(priv);
 }
 
 static int ipw_set_rsn_capa(struct ipw_priv *priv,
@@ -6541,6 +6539,7 @@ static int ipw_wx_set_auth(struct net_de
 
 	case IW_AUTH_WPA_ENABLED:
 		ret = ipw_wpa_enable(priv, param->value);
+		ipw_disassociate(priv);
 		break;
 
 	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
-- 
1.2.6

