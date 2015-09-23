From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 04/10] switchdev: add switchdev_trans_ph_prepare/commit helpers
Date: Wed, 23 Sep 2015 09:57:52 +0200
Message-ID: <1442995078-10491-5-git-send-email-jiri@resnulli.us>
References: <1442995078-10491-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35163 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbbIWH6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 03:58:08 -0400
Received: by wicge5 with SMTP id ge5so194879539wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 00:58:07 -0700 (PDT)
In-Reply-To: <1442995078-10491-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add helpers which should be used int attr_set/obj_add switchdev ops to
check the phase of transaction.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 368a642..f84ecf4 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -35,6 +35,16 @@ struct switchdev_trans {
 	enum switchdev_trans_ph ph;
 };
 
+static inline bool switchdev_trans_ph_prepare(struct switchdev_trans *trans)
+{
+	return trans && trans->ph == SWITCHDEV_TRANS_PREPARE;
+}
+
+static inline bool switchdev_trans_ph_commit(struct switchdev_trans *trans)
+{
+	return trans && trans->ph == SWITCHDEV_TRANS_COMMIT;
+}
+
 enum switchdev_attr_id {
 	SWITCHDEV_ATTR_UNDEFINED,
 	SWITCHDEV_ATTR_PORT_PARENT_ID,
-- 
1.9.3
