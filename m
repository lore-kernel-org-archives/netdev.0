From: sfeldma@gmail.com
Subject: [PATCH net-next v7 08/24] switchdev: add port vlan obj
Date: Sun, 10 May 2015 09:47:53 -0700
Message-ID: <1431276489-64199-9-git-send-email-sfeldma@gmail.com>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34813 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbbEJQrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 12:47:09 -0400
Received: by pdbqa5 with SMTP id qa5so125544958pdb.1
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 09:47:08 -0700 (PDT)
In-Reply-To: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

VLAN obj has flags (PVID and untagged) as well as start and end vid ranges.
The switchdev driver can optimize programing the device using the ranges.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
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
