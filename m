From: sfeldma@gmail.com
Subject: [PATCH net-next v2 1/4] switchdev: add bridge attributes
Date: Wed,  7 Oct 2015 23:04:40 -0700
Message-ID: <1444284283-33601-2-git-send-email-sfeldma@gmail.com>
References: <1444284283-33601-1-git-send-email-sfeldma@gmail.com>
Cc: davem@davemloft.net, jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34135 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbbJHGBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 02:01:48 -0400
Received: by padhy16 with SMTP id hy16so44372675pad.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 23:01:48 -0700 (PDT)
In-Reply-To: <1444284283-33601-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Setting the stage to push bridge-level attributes down to port driver so
hardware can be programmed accordingly.  Bridge-level attribute example is
ageing_time.  This is a per-bridge attribute, not a per-bridge-port attr.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h      |    5 +++++
 include/uapi/linux/if_link.h |    2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 89266a3..8d92cd0 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -43,6 +43,7 @@ enum switchdev_attr_id {
 	SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 	SWITCHDEV_ATTR_ID_PORT_STP_STATE,
 	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
+	SWITCHDEV_ATTR_ID_BRIDGE,
 };
 
 struct switchdev_attr {
@@ -52,6 +53,10 @@ struct switchdev_attr {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
 		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
+		struct switchdev_attr_bridge {		/* BRIDGE */
+			enum ifla_br attr;
+			u32 val;
+		} bridge;
 	} u;
 };
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index e3b6217..30177b3 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -222,7 +222,7 @@ enum in6_addr_gen_mode {
 
 /* Bridge section */
 
-enum {
+enum ifla_br {
 	IFLA_BR_UNSPEC,
 	IFLA_BR_FORWARD_DELAY,
 	IFLA_BR_HELLO_TIME,
-- 
1.7.10.4
