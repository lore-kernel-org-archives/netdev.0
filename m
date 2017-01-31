From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 3/5] bridge: uapi: add per vlan tunnel info
Date: Mon, 30 Jan 2017 21:57:13 -0800
Message-ID: <1485842235-32343-4-git-send-email-roopa@cumulusnetworks.com>
References: <1485842235-32343-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35367 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdAaF6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 00:58:49 -0500
Received: by mail-pf0-f175.google.com with SMTP id f144so100120782pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 21:57:26 -0800 (PST)
In-Reply-To: <1485842235-32343-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

New nested netlink attribute to associate tunnel info per vlan.
This is used by bridge driver to send tunnel metadata to
bridge ports in vlan tunnel mode. This patch also adds new per
port flag IFLA_BRPORT_VLAN_TUNNEL to enable vlan tunnel mode.
off by default.

One example use for this is a vxlan bridging gateway or vtep
which maps vlans to vn-segments (or vnis). User can configure
per-vlan tunnel information which the bridge driver can use
to bridge vlan into the corresponding vn-segment.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/if_bridge.h      |    1 +
 include/uapi/linux/if_bridge.h |   11 +++++++++++
 include/uapi/linux/if_link.h   |    1 +
 3 files changed, 13 insertions(+)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index debc9d5..c5847dc 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -47,6 +47,7 @@ struct br_ip_list {
 #define BR_PROXYARP_WIFI	BIT(10)
 #define BR_MCAST_FLOOD		BIT(11)
 #define BR_MULTICAST_TO_UNICAST	BIT(12)
+#define BR_VLAN_TUNNEL		BIT(13)
 
 #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
 
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
index b9aa564..320fc1e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -322,6 +322,7 @@ enum {
 	IFLA_BRPORT_PAD,
 	IFLA_BRPORT_MCAST_FLOOD,
 	IFLA_BRPORT_MCAST_TO_UCAST,
+	IFLA_BRPORT_VLAN_TUNNEL,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
-- 
1.7.10.4
