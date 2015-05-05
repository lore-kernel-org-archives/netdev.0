From: sfeldma@gmail.com
Subject: [PATCH net-next v5 07/21] switchdev: add port vlan obj
Date: Tue,  5 May 2015 10:34:43 -0700
Message-ID: <1430847297-15728-8-git-send-email-sfeldma@gmail.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32936 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965338AbbEEReI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 13:34:08 -0400
Received: by pacwv17 with SMTP id wv17so200256738pac.0
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 10:34:08 -0700 (PDT)
In-Reply-To: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

VLAN obj has flags (PVID and untagged) as well as start and end vid ranges.
The switchdev driver can optimize programing the device using the ranges.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 4f43300..e598c2d 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -43,11 +43,19 @@ struct fib_info;
 
 enum switchdev_obj_id {
 	SWITCHDEV_OBJ_UNDEFINED,
+	SWITCHDEV_OBJ_PORT_VLAN,
 };
 
 struct switchdev_obj {
 	enum switchdev_obj_id id;
 	enum switchdev_trans trans;
+	union {
+		struct switchdev_obj_vlan {			/* PORT_VLAN */
+			u16 flags;
+			u16 vid_start;
+			u16 vid_end;
+		} vlan;
+	};
 };
 
 /**
-- 
1.7.10.4
