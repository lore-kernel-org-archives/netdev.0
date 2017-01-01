From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 27/27] sctp: add reconf chunk event
Date: Sun,  1 Jan 2017 19:20:44 +0800
Message-ID: <b765925613f97c4734d1ecff726bf6eaf0d93280.1483269426.git.lucien.xin@gmail.com>
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
 <3a60ce82edef82f329fe2cc4ac83e9ca21831d8b.1483269426.git.lucien.xin@gmail.com>
 <9be4c65c6bac7df0dbf51328af92727e5606dc5c.1483269426.git.lucien.xin@gmail.com>
 <b5eb3a199dded2efe517b19b5cac6ae498a6c0c8.1483269426.git.lucien.xin@gmail.com>
 <c59df697bb54348de10f8418a23e9d14bce30135.1483269426.git.lucien.xin@gmail.com>
 <470b9f2b5248e0c1870c501f262a1887be66509b.1483269426.git.lucien.xin@gmail.com>
 <105630d2f9a54de9c3ce49988452d2b111c71b3d.1483269426.git.lucien.xin@gmail.com>
 <19ee2333d24194c0a4b3e724a1a738873ca27445.1483269426.git.lucien.xin@gmail.com>
 <880e62cecc950ad9b5dad09ae581e5e6f92ecf46.1483269426.git.lucien.xin@gmail.com>
 <24997940f9c6ca9d4cbb8ce72741fdddcfe4ebc1.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35634 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755101AbdAALY2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:24:28 -0500
In-Reply-To: <24997940f9c6ca9d4cbb8ce72741fdddcfe4ebc1.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add reconf chunk event based on the sctp event
frame, after which, the reconf chunk process would be activated.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h |  3 +++
 net/sctp/sm_statetable.c     | 30 ++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 3567c97..b07a745 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -60,11 +60,14 @@ enum { SCTP_DEFAULT_INSTREAMS = SCTP_MAX_STREAM };
 
 #define SCTP_NUM_PRSCTP_CHUNK_TYPES	1
 
+#define SCTP_NUM_RECONF_CHUNK_TYPES	1
+
 #define SCTP_NUM_AUTH_CHUNK_TYPES	1
 
 #define SCTP_NUM_CHUNK_TYPES		(SCTP_NUM_BASE_CHUNK_TYPES + \
 					 SCTP_NUM_ADDIP_CHUNK_TYPES +\
 					 SCTP_NUM_PRSCTP_CHUNK_TYPES +\
+					 SCTP_NUM_RECONF_CHUNK_TYPES +\
 					 SCTP_NUM_AUTH_CHUNK_TYPES)
 
 /* These are the different flavours of event.  */
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index b5438b4..419b18e 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -482,6 +482,32 @@ static const sctp_sm_table_entry_t prsctp_chunk_event_table[SCTP_NUM_PRSCTP_CHUN
 	TYPE_SCTP_FWD_TSN,
 }; /*state_fn_t prsctp_chunk_event_table[][] */
 
+#define TYPE_SCTP_RECONF { \
+	/* SCTP_STATE_CLOSED */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_COOKIE_WAIT */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_COOKIE_ECHOED */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_ESTABLISHED */ \
+	TYPE_SCTP_FUNC(sctp_sf_do_reconf), \
+	/* SCTP_STATE_SHUTDOWN_PENDING */ \
+	TYPE_SCTP_FUNC(sctp_sf_do_reconf), \
+	/* SCTP_STATE_SHUTDOWN_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+} /* TYPE_SCTP_RECONF */
+
+/* The primary index for this table is the chunk type.
+ * The secondary index for this table is the state.
+ */
+static const sctp_sm_table_entry_t reconf_chunk_event_table[SCTP_NUM_RECONF_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
+	TYPE_SCTP_RECONF,
+}; /*state_fn_t reconf_chunk_event_table[][] */
+
 #define TYPE_SCTP_AUTH { \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
@@ -964,6 +990,10 @@ static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(struct net *net,
 			return &addip_chunk_event_table[1][state];
 	}
 
+	if (net->sctp.reconf_enable)
+		if (cid == SCTP_CID_RECONF)
+			return &reconf_chunk_event_table[0][state];
+
 	if (net->sctp.auth_enable) {
 		if (cid == SCTP_CID_AUTH)
 			return &auth_chunk_event_table[0][state];
-- 
2.1.0
