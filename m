From: sfeldma@gmail.com
Subject: [PATCH net-next v6 08/23] switchdev: add port vlan obj
Date: Sat,  9 May 2015 10:40:10 -0700
Message-ID: <1431193225-807-9-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35817 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbbEIRnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:25 -0400
Received: by pabtp1 with SMTP id tp1so75742467pab.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:24 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
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
