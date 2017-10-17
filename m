From: Andy Zhou <azhou@ovn.org>
Subject: [net-next v2 1/4] openvswitch: Add meter netlink definitions
Date: Tue, 17 Oct 2017 00:36:42 -0700
Message-ID: <1508225805-11613-2-git-send-email-azhou@ovn.org>
References: <1508225805-11613-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: pshelar@ovn.org, joe@ovn.org, gvrose8192@gmail.com,
        Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:56269 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933907AbdJQHiE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:38:04 -0400
Received: by mail-pg0-f65.google.com with SMTP id b11so752679pgn.12
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 00:38:04 -0700 (PDT)
In-Reply-To: <1508225805-11613-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meter has its own netlink family. Define netlink messages and attributes
for communicating with the user space programs.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 include/uapi/linux/openvswitch.h | 51 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 0cd6f8833147..d413a2398214 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -851,4 +851,55 @@ enum ovs_action_attr {
 
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
