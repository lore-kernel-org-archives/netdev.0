From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Implement SIOCGIWNICKN
Date: Thu, 13 Jul 2006 17:56:16 +0100 (BST)
Message-ID: <20060713165616.3FFD78B3552@zog.reactivated.net>
Cc: kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:6670 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1030245AbWGMQ4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 12:56:16 -0400
To: linville@tuxdriver.com
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wireless.h discourages using SIOCGIWNAME to publish the driver name
which the interface belongs to. Use SIOCGIWNICKN instead.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

diff --git a/drivers/net/wireless/zd1211rw/zd_netdev.c b/drivers/net/wireless/zd1211rw/zd_netdev.c
index 9df232c..440ef24 100644
--- a/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ b/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -72,10 +72,18 @@ static int iw_get_name(struct net_device
 	               struct iw_request_info *info,
 		       union iwreq_data *req, char *extra)
 {
-	/* FIXME: check whether 802.11a will also supported, add also
-	 *        zd1211B, if we support it.
-	 */
-	strlcpy(req->name, "802.11g zd1211", IFNAMSIZ);
+	/* FIXME: check whether 802.11a will also supported */
+	strlcpy(req->name, "IEEE 802.11b/g", IFNAMSIZ);
+	return 0;
+}
+
+static int iw_get_nick(struct net_device *netdev,
+	               struct iw_request_info *info,
+		       union iwreq_data *req, char *extra)
+{
+	strcpy(extra, "zd1211");
+	req->data.length = strlen(extra) + 1;
+	req->data.flags = 1;
 	return 0;
 }
 
@@ -181,6 +189,7 @@ #define WX(x) [(x)-SIOCIWFIRST]
 
 static const iw_handler zd_standard_iw_handlers[] = {
 	WX(SIOCGIWNAME)		= iw_get_name,
+	WX(SIOCGIWNICKN)	= iw_get_nick,
 	WX(SIOCSIWFREQ)		= iw_set_freq,
 	WX(SIOCGIWFREQ)		= iw_get_freq,
 	WX(SIOCSIWMODE)		= iw_set_mode,
