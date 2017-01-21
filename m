From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 3/5] bridge: uapi: add per vlan tunnel info
Date: Fri, 20 Jan 2017 21:46:54 -0800
Message-ID: <1484977616-1541-4-git-send-email-roopa@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34755 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdAUFrF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 00:47:05 -0500
Received: by mail-pf0-f172.google.com with SMTP id e4so27428024pfg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 21:47:05 -0800 (PST)
In-Reply-To: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

New netlink api to associate tunnel info per vlan.
This is used by bridge driver to send tunnel metadata to
bridge ports in LWT tunnel dst metadata mode.

One example use for this is a vxlan bridging gateway or vtep
which maps vlans to vn-segments (or vnis). User can configure
per-vlan tunnel information which the bridge driver can use
to bridge vlan into the corresponding vn-segment.

This patch also introduces a bridge port flag IFLA_BRPORT_LWT_VLAN
to enable this feature on a tunnel bridge port. It is off by default.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h |   11 +++++++++++
 include/uapi/linux/if_link.h   |    1 +
 2 files changed, 12 insertions(+)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index ab92bca..a9e6244 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -118,6 +118,7 @@ enum {
 	IFLA_BRIDGE_FLAGS,
 	IFLA_BRIDGE_MODE,
 	IFLA_BRIDGE_VLAN_INFO,
+	IFLA_BRIDGE_VLAN_TUNNEL_INFO,
 	__IFLA_BRIDGE_MAX,
 };
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
@@ -134,6 +135,16 @@ struct bridge_vlan_info {
 	__u16 vid;
 };
 
+enum {
+	IFLA_BRIDGE_VLAN_TUNNEL_UNSPEC,
+	IFLA_BRIDGE_VLAN_TUNNEL_ID,
+	IFLA_BRIDGE_VLAN_TUNNEL_VID,
+	IFLA_BRIDGE_VLAN_TUNNEL_FLAGS,
+	__IFLA_BRIDGE_VLAN_TUNNEL_MAX,
+};
+
+#define IFLA_BRIDGE_VLAN_TUNNEL_MAX (__IFLA_BRIDGE_VLAN_TUNNEL_MAX - 1)
+
 struct bridge_vlan_xstats {
 	__u64 rx_bytes;
 	__u64 rx_packets;
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 184b16e..f0356b9 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -321,6 +321,7 @@ enum {
 	IFLA_BRPORT_MULTICAST_ROUTER,
 	IFLA_BRPORT_PAD,
 	IFLA_BRPORT_MCAST_FLOOD,
+	IFLA_BRPORT_LWT_VLAN,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
-- 
1.7.10.4
