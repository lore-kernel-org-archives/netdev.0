From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 04/10] switchdev: add switchdev_trans_ph_prepare/commit helpers
Date: Thu, 24 Sep 2015 10:02:43 +0200
Message-ID: <1443081769-11193-5-git-send-email-jiri@resnulli.us>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35565 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbbIXIC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 04:02:58 -0400
Received: by wicge5 with SMTP id ge5so240206692wic.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 01:02:56 -0700 (PDT)
In-Reply-To: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
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
