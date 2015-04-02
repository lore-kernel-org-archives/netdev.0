From: sfeldma@gmail.com
Subject: [PATCH net-next v3 07/26] switchdev: add port vlan obj
Date: Thu,  2 Apr 2015 01:09:53 -0700
Message-ID: <1427962212-18411-8-git-send-email-sfeldma@gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34142 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077AbbDBIJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:09:30 -0400
Received: by pdbni2 with SMTP id ni2so82129558pdb.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:09:29 -0700 (PDT)
In-Reply-To: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
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
index d4e5478..2128037 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -40,11 +40,19 @@ struct fib_info;
 
 enum swdev_obj_id {
 	SWDEV_OBJ_UNDEFINED,
+	SWDEV_OBJ_PORT_VLAN,
 };
 
 struct swdev_obj {
 	enum swdev_obj_id id;
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
