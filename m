From: sfeldma@gmail.com
Subject: [PATCH net-next v4 07/24] switchdev: add port vlan obj
Date: Sun, 12 Apr 2015 23:17:01 -0700
Message-ID: <1428905838-14920-8-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36106 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbbDMGQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:40 -0400
Received: by pdea3 with SMTP id a3so96430309pde.3
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:39 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

VLAN obj has flags (PVID and untagged) as well as start and end vid ranges.
The swdev driver can optimize programing the device using the ranges.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index f5f7733..d3cc8eb 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -45,12 +45,20 @@ struct fib_info;
 
 enum swdev_obj_id {
 	SWDEV_OBJ_UNDEFINED,
+	SWDEV_OBJ_PORT_VLAN,
 };
 
 struct swdev_obj {
 	enum swdev_obj_id id;
 	enum swdev_trans trans;
 	u32 flags;
+	union {
+		struct swdev_obj_vlan {			/* PORT_VLAN */
+			u16 flags;
+			u16 vid_start;
+			u16 vid_end;
+		} vlan;
+	};
 };
 
 /**
-- 
1.7.10.4
