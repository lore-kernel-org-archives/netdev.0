From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 18/27] sctp: add rfc6525 section 6.1.2
Date: Sun,  1 Jan 2017 19:20:35 +0800
Message-ID: <3a60ce82edef82f329fe2cc4ac83e9ca21831d8b.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
 <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
 <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
 <31abc54d31ef0714322f137bff43458014d7c276.1483269426.git.lucien.xin@gmail.com>
 <58860816816d6d51b062235fd54dae6540a4797a.1483269426.git.lucien.xin@gmail.com>
 <229608faf7af54c0bf908694ca8349205bbf6eab.1483269426.git.lucien.xin@gmail.com>
 <c4f16844620cd3a2aa76596df9eaadf1505fc8e6.1483269426.git.lucien.xin@gmail.com>
 <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
 <1e4560205cff3c10868d5614b62a3db14e87ccf0.1483269426.git.lucien.xin@gmail.com>
 <91b9171cc57c0f322d103dfbbcce1b9706800805.1483269426.git.lucien.xin@gmail.com>
 <d5fb0969ea5d055dea5bdc257569530b6d2fc7c2.1483269426.git.lucien.xin@gmail.com>
 <6a74f5a3ac408f20816a8c79edd6b9922ed3b573.1483269426.git.lucien.xin@gmail.com>
 <ef7d01cf1d5826e694a08303ee0b36c00201c666.1483269426.git.lucien.xin@gmail.com>
 <86b68f131d286ee20781cb04ce9d09d477aa5232.1483269426.git.lucien.xin@gmail.com>
 <1e8e248c38fd3874cf80c4b88e4699c8a617066d.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35395 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALXQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:23:16 -0500
In-Reply-To: <1e8e248c38fd3874cf80c4b88e4699c8a617066d.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add Association Reset Event described in section 6.1.2.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/ulpevent.h |  4 ++++
 include/uapi/linux/sctp.h   | 15 +++++++++++++++
 net/sctp/ulpevent.c         | 28 ++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+)

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 324b596..2ab7ed4 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -132,6 +132,10 @@ struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
 	const struct sctp_association *asoc, __u16 flags,
 	__u16 stream_num, __u16 *stream_list, gfp_t gfp);
 
+struct sctp_ulpevent *sctp_ulpevent_make_assoc_reset_event(
+	const struct sctp_association *asoc, __u16 flags,
+	 __u32 local_tsn, __u32 remote_tsn, gfp_t gfp);
+
 void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 				   struct msghdr *);
 void sctp_ulpevent_read_rcvinfo(const struct sctp_ulpevent *event,
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 97b8a96..9da165a 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -503,6 +503,17 @@ struct sctp_stream_reset_event {
 	uint16_t strreset_stream_list[];
 };
 
+#define SCTP_ASSOC_RESET_DENIED		0x0004
+#define SCTP_ASSOC_RESET_FAILED		0x0008
+struct sctp_assoc_reset_event {
+	uint16_t assocreset_type;
+	uint16_t assocreset_flags;
+	uint32_t assocreset_length;
+	sctp_assoc_t assocreset_assoc_id;
+	uint32_t assocreset_local_tsn;
+	uint32_t assocreset_remote_tsn;
+};
+
 /*
  * Described in Section 7.3
  *   Ancillary Data and Notification Interest Options
@@ -519,6 +530,7 @@ struct sctp_event_subscribe {
 	uint8_t sctp_authentication_event;
 	uint8_t sctp_sender_dry_event;
 	uint8_t sctp_stream_reset_event;
+	uint8_t sctp_assoc_reset_event;
 };
 
 /*
@@ -544,6 +556,7 @@ union sctp_notification {
 	struct sctp_authkey_event sn_authkey_event;
 	struct sctp_sender_dry_event sn_sender_dry_event;
 	struct sctp_stream_reset_event sn_strreset_event;
+	struct sctp_assoc_reset_event sn_assocreset_event;
 };
 
 /* Section 5.3.1
@@ -573,6 +586,8 @@ enum sctp_sn_type {
 #define SCTP_SENDER_DRY_EVENT		SCTP_SENDER_DRY_EVENT
 	SCTP_STREAM_RESET_EVENT,
 #define SCTP_STREAM_RESET_EVENT		SCTP_STREAM_RESET_EVENT
+	SCTP_ASSOC_RESET_EVENT,
+#define SCTP_ASSOC_RESET_EVENT		SCTP_ASSOC_RESET_EVENT
 };
 
 /* Notification error codes used to fill up the error fields in some
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 490d573..5492cd7 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -884,6 +884,34 @@ struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
 	return event;
 }
 
+struct sctp_ulpevent *sctp_ulpevent_make_assoc_reset_event(
+	const struct sctp_association *asoc, __u16 flags, __u32 local_tsn,
+	__u32 remote_tsn, gfp_t gfp)
+{
+	struct sctp_assoc_reset_event *areset;
+	struct sctp_ulpevent *event;
+	struct sk_buff *skb;
+
+	event = sctp_ulpevent_new(sizeof(struct sctp_assoc_reset_event),
+				  MSG_NOTIFICATION, gfp);
+	if (!event)
+		return NULL;
+
+	skb = sctp_event2skb(event);
+	areset = (struct sctp_assoc_reset_event *)
+		skb_put(skb, sizeof(struct sctp_assoc_reset_event));
+
+	areset->assocreset_type = SCTP_ASSOC_RESET_EVENT;
+	areset->assocreset_flags = flags;
+	areset->assocreset_length = sizeof(struct sctp_assoc_reset_event);
+	sctp_ulpevent_set_owner(event, asoc);
+	areset->assocreset_assoc_id = sctp_assoc2id(asoc);
+	areset->assocreset_local_tsn = local_tsn;
+	areset->assocreset_remote_tsn = remote_tsn;
+
+	return event;
+}
+
 /* Return the notification type, assuming this is a notification
  * event.
  */
-- 
2.1.0
