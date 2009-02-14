From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 43/43] drivers/net/wireless/prism54: fix sparse warning: fix
	signedness
Date: Sat, 14 Feb 2009 22:50:45 +0100
Message-ID: <20090214215034.24377.54126.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:50319 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756043AbZBNVuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:50:50 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix sparse warning:
  drivers/net/wireless/prism54/isl_ioctl.c:2997:32: warning: incorrect type in argument 2 (different signedness)
  drivers/net/wireless/prism54/oid_mgt.c:712:42: warning: incorrect type in argument 2 (different signedness)

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wireless/prism54/isl_ioctl.c |    3 ++-
 drivers/net/wireless/prism54/oid_mgt.c   |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 57a150a..4c97c6a 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -2981,7 +2981,8 @@ prism54_set_spy(struct net_device *ndev,
 		union iwreq_data *uwrq, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	u32 u, oid = OID_INL_CONFIG;
+	u32 u;
+	enum oid_num_t oid = OID_INL_CONFIG;
 
 	down_write(&priv->mib_sem);
 	mgt_get(priv, OID_INL_CONFIG, &u);
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
index 57a4ac3..1187e61 100644
--- a/drivers/net/wireless/prism54/oid_mgt.c
+++ b/drivers/net/wireless/prism54/oid_mgt.c
@@ -698,7 +698,7 @@ int
 mgt_commit(islpci_private *priv)
 {
 	int rvalue;
-	u32 u;
+	enum oid_num_t u;
 
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;

