From: Andy Zhou <azhou@ovn.org>
Subject: [net-next RFC 1/4] openvswitch: Add meter netlink definitions
Date: Thu, 12 Oct 2017 15:38:40 -0700
Message-ID: <1507847923-13612-2-git-send-email-azhou@ovn.org>
References: <1507847923-13612-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: pshelar@ovn.org, joe@ovn.org, gvrose8192@gmail.com,
        Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:43517 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753191AbdJLWkH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 18:40:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id a8so6526636pfc.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 15:40:07 -0700 (PDT)
In-Reply-To: <1507847923-13612-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meter has its own netlink family. Define netlink messages and attributes
for communicating with the user space programs.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 include/uapi/linux/openvswitch.h | 51 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 156ee4cab82e..325049a129e4 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -848,4 +848,55 @@ enum ovs_action_attr {
 
 #define OVS_ACTION_ATTR_MAX (__OVS_ACTION_ATTR_MAX - 1)
 
+/* Meters. */
+#define OVS_METER_FAMILY  "ovs_meter"
+#define OVS_METER_MCGROUP "ovs_meter"
+#define OVS_METER_VERSION 0x1
+
+enum ovs_meter_cmd {
+	OVS_METER_CMD_UNSPEC,
+	OVS_METER_CMD_FEATURES,	/* Get features supported by the datapath. */
+	OVS_METER_CMD_SET,	/* Add or modify a meter. */
+	OVS_METER_CMD_DEL,	/* Delete a meter. */
+	OVS_METER_CMD_GET	/* Get meter stats. */
+};
+
+enum ovs_meter_attr {
+	OVS_METER_ATTR_UNSPEC,
+	OVS_METER_ATTR_ID,	/* u32 meter ID within datapath. */
+	OVS_METER_ATTR_KBPS,	/* No argument. If set, units in kilobits
+				 * per second. Otherwise, units in
+				 * packets per second.
+				 */
+	OVS_METER_ATTR_STATS,	/* struct ovs_flow_stats for the meter. */
+	OVS_METER_ATTR_BANDS,	/* Nested attributes for meter bands. */
+	OVS_METER_ATTR_USED,	/* u64 msecs last used in monotonic time. */
+	OVS_METER_ATTR_CLEAR,	/* Flag to clear stats, used. */
+	OVS_METER_ATTR_MAX_METERS, /* u32 number of meters supported. */
+	OVS_METER_ATTR_MAX_BANDS,  /* u32 max number of bands per meter. */
+	OVS_METER_ATTR_PAD,
+	__OVS_METER_ATTR_MAX
+};
+
+#define OVS_METER_ATTR_MAX (__OVS_METER_ATTR_MAX - 1)
+
+enum ovs_band_attr {
+	OVS_BAND_ATTR_UNSPEC,
+	OVS_BAND_ATTR_TYPE,	/* u32 OVS_METER_BAND_TYPE_* constant. */
+	OVS_BAND_ATTR_RATE,	/* u32 band rate in meter units (see above). */
+	OVS_BAND_ATTR_BURST,	/* u32 burst size in meter units. */
+	OVS_BAND_ATTR_STATS,	/* struct ovs_flow_stats for the band. */
+	__OVS_BAND_ATTR_MAX
+};
+
+#define OVS_BAND_ATTR_MAX (__OVS_BAND_ATTR_MAX - 1)
+
+enum ovs_meter_band_type {
+	OVS_METER_BAND_TYPE_UNSPEC,
+	OVS_METER_BAND_TYPE_DROP,   /* Drop exceeding packets. */
+	__OVS_METER_BAND_TYPE_MAX
+};
+
+#define OVS_METER_BAND_TYPE_MAX (__OVS_METER_BAND_TYPE_MAX - 1)
+
 #endif /* _LINUX_OPENVSWITCH_H */
-- 
1.8.3.1
