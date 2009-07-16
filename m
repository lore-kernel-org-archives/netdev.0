From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH 4/8] libertas: Use %pM conversion specifier
Date: Thu, 16 Jul 2009 10:56:57 +0200
Message-ID: <1247734617-20902-1-git-send-email-klto@zhaw.ch>
Cc: Tobias Klauser <klto@zhaw.ch>
To: dcbw@redhat.com, linville@tuxdriver.com, johannes@sipsolutions.net,
	proski@gnu.org, davem@davemloft.net,
	libertas-dev@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:59235 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753352AbZGPI47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 04:56:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM conversion specifier for printk instead of print_mac.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 drivers/net/wireless/libertas/assoc.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/libertas/assoc.c b/drivers/net/wireless/libertas/assoc.c
index b9b3741..a953647 100644
--- a/drivers/net/wireless/libertas/assoc.c
+++ b/drivers/net/wireless/libertas/assoc.c
@@ -129,7 +129,6 @@ static int lbs_set_authentication(struct lbs_private *priv, u8 bssid[6], u8 auth
 {
 	struct cmd_ds_802_11_authenticate cmd;
 	int ret = -1;
-	DECLARE_MAC_BUF(mac);
 
 	lbs_deb_enter(LBS_DEB_JOIN);
 
@@ -138,8 +137,7 @@ static int lbs_set_authentication(struct lbs_private *priv, u8 bssid[6], u8 auth
 
 	cmd.authtype = iw_auth_to_ieee_auth(auth);
 
-	lbs_deb_join("AUTH_CMD: BSSID %s, auth 0x%x\n",
-		print_mac(mac, bssid), cmd.authtype);
+	lbs_deb_join("AUTH_CMD: BSSID %pM, auth 0x%x\n", bssid, cmd.authtype);
 
 	ret = lbs_cmd_with_response(priv, CMD_802_11_AUTHENTICATE, &cmd);
 
@@ -342,8 +340,6 @@ static int lbs_associate(struct lbs_private *priv,
 
 	/* Firmware v9+ indicate authentication suites as a TLV */
 	if (priv->fwrelease >= 0x09000000) {
-		DECLARE_MAC_BUF(mac);
-
 		auth = (struct mrvl_ie_auth_type *) pos;
 		auth->header.type = cpu_to_le16(TLV_TYPE_AUTH_TYPE);
 		auth->header.len = cpu_to_le16(2);
@@ -351,8 +347,8 @@ static int lbs_associate(struct lbs_private *priv,
 		auth->auth = cpu_to_le16(tmpauth);
 		pos += sizeof(auth->header) + 2;
 
-		lbs_deb_join("AUTH_CMD: BSSID %s, auth 0x%x\n",
-			print_mac(mac, bss->bssid), priv->secinfo.auth_mode);
+		lbs_deb_join("AUTH_CMD: BSSID %pM, auth 0x%x\n",
+			bss->bssid, priv->secinfo.auth_mode);
 	}
 
 	/* WPA/WPA2 IEs */
-- 
1.6.0.4

