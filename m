From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 06/11] sctp: remove the typedef sctp_param_t
Date: Fri, 30 Jun 2017 11:52:17 +0800
Message-ID: <794094c6a1a0fdbf5374c983b2558e1316a51fd4.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
 <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
 <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
 <d522a5f819078da037df984f9fa1897b0cf57433.1498794482.git.lucien.xin@gmail.com>
 <bd4d24bbff8ff402d30c8a148f6ea4332beb5005.1498794482.git.lucien.xin@gmail.com>
 <2ae031641ce87e8fa77af7d3ea31b163f6c25f3d.1498794482.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34262 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdF3Dxd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:53:33 -0400
In-Reply-To: <2ae031641ce87e8fa77af7d3ea31b163f6c25f3d.1498794482.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_param_t, and replace with
struct sctp_paramhdr in the places where it's using this typedef.

It is also to remove the useless declaration sctp_addip_addr_config
and fix the lack of params for some other functions' declaration.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  4 ++--
 include/net/sctp/sm.h    | 14 ++++++--------
 net/sctp/sm_make_chunk.c |  2 +-
 3 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 142bb6a..5eecc0f 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -167,7 +167,7 @@ struct sctp_paramhdr {
 	__be16 length;
 };
 
-typedef enum {
+enum sctp_param {
 
 	/* RFC 2960 Section 3.3.5 */
 	SCTP_PARAM_HEARTBEAT_INFO		= cpu_to_be16(1),
@@ -207,7 +207,7 @@ typedef enum {
 	SCTP_PARAM_RESET_RESPONSE		= cpu_to_be16(0x0010),
 	SCTP_PARAM_RESET_ADD_OUT_STREAMS	= cpu_to_be16(0x0011),
 	SCTP_PARAM_RESET_ADD_IN_STREAMS		= cpu_to_be16(0x0012),
-} sctp_param_t; /* enum */
+}; /* enum */
 
 
 /* RFC 2960 Section 3.2.1
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 47113f2..245eb22 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -325,19 +325,17 @@ void sctp_generate_heartbeat_event(unsigned long peer);
 void sctp_generate_reconf_event(unsigned long peer);
 void sctp_generate_proto_unreach_event(unsigned long peer);
 
-void sctp_ootb_pkt_free(struct sctp_packet *);
+void sctp_ootb_pkt_free(struct sctp_packet *packet);
 
-struct sctp_association *sctp_unpack_cookie(const struct sctp_endpoint *,
-				       const struct sctp_association *,
-				       struct sctp_chunk *,
+struct sctp_association *sctp_unpack_cookie(const struct sctp_endpoint *ep,
+				       const struct sctp_association *asoc,
+				       struct sctp_chunk *chunk,
 				       gfp_t gfp, int *err,
 				       struct sctp_chunk **err_chk_p);
-int sctp_addip_addr_config(struct sctp_association *, sctp_param_t,
-			   struct sockaddr_storage*, int);
 
 /* 3rd level prototypes */
-__u32 sctp_generate_tag(const struct sctp_endpoint *);
-__u32 sctp_generate_tsn(const struct sctp_endpoint *);
+__u32 sctp_generate_tag(const struct sctp_endpoint *ep);
+__u32 sctp_generate_tsn(const struct sctp_endpoint *ep);
 
 /* Extern declarations for major data structures.  */
 extern sctp_timer_event_t *sctp_timer_events[SCTP_NUM_TIMEOUT_TYPES];
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 9f9d40c..3ed2108 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1882,7 +1882,7 @@ struct __sctp_missing {
  * Report a missing mandatory parameter.
  */
 static int sctp_process_missing_param(const struct sctp_association *asoc,
-				      sctp_param_t paramtype,
+				      enum sctp_param paramtype,
 				      struct sctp_chunk *chunk,
 				      struct sctp_chunk **errp)
 {
-- 
2.1.0
