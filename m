From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 4/4][SCTP]: Change adaption -> adaptation as per the latest
	API draft.
Date: Wed, 13 Dec 2006 12:44:52 -0800
Message-ID: <1166042692.4670.13.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:33587 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbWLMUpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 15:45:05 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDKiugb022751
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:56 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDKiuwX261868
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:56 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDKiuO1023092
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:56 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Change adaption -> adaptation as per the latest API draft.

Signed-off-by: Ivan Skytte Jorgensen <isj-sctp@i1.dk>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/linux/sctp.h        |   10 +++++-----
 include/net/sctp/structs.h  |    8 ++++----
 include/net/sctp/ulpevent.h |    2 +-
 include/net/sctp/user.h     |   28 ++++++++++++++--------------
 net/sctp/sm_make_chunk.c    |   24 ++++++++++++------------
 net/sctp/sm_statefuns.c     |   32 ++++++++++++++++----------------
 net/sctp/socket.c           |   34 +++++++++++++++++-----------------
 net/sctp/ulpevent.c         |   20 ++++++++++----------
 8 files changed, 79 insertions(+), 79 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 35108fe..d4f8656 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -180,7 +180,7 @@ typedef enum {
 	SCTP_PARAM_ERR_CAUSE		= __constant_htons(0xc003),
 	SCTP_PARAM_SET_PRIMARY		= __constant_htons(0xc004),
 	SCTP_PARAM_SUCCESS_REPORT	= __constant_htons(0xc005),
-	SCTP_PARAM_ADAPTION_LAYER_IND   = __constant_htons(0xc006),
+	SCTP_PARAM_ADAPTATION_LAYER_IND = __constant_htons(0xc006),
 
 } sctp_param_t; /* enum */
 
@@ -281,11 +281,11 @@ typedef struct sctp_ecn_capable_param {
 	sctp_paramhdr_t param_hdr;
 } __attribute__((packed)) sctp_ecn_capable_param_t;
 
-/* ADDIP Section 3.2.6 Adaption Layer Indication */
-typedef struct sctp_adaption_ind_param {
+/* ADDIP Section 3.2.6 Adaptation Layer Indication */
+typedef struct sctp_adaptation_ind_param {
 	struct sctp_paramhdr param_hdr;
-	__be32 adaption_ind;
-} __attribute__((packed)) sctp_adaption_ind_param_t;
+	__be32 adaptation_ind;
+} __attribute__((packed)) sctp_adaptation_ind_param_t;
 
 /* RFC 2960.  Section 3.3.3 Initiation Acknowledgement (INIT ACK) (2):
  *   The INIT ACK chunk is used to acknowledge the initiation of an SCTP
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 8d7f26d..c9075d0 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -306,7 +306,7 @@ struct sctp_sock {
 	__u8 disable_fragments;
 	__u8 pd_mode;
 	__u8 v4mapped;
-	__u32 adaption_ind;
+	__u32 adaptation_ind;
 
 	/* Receive to here while partial delivery is in effect. */
 	struct sk_buff_head pd_lobby;
@@ -388,7 +388,7 @@ struct sctp_cookie {
 	/* Padding for future use */
 	__u8 padding;  		
 
-	__u32 adaption_ind;	
+	__u32 adaptation_ind;	
 

 	/* This is a shim for my peer's INIT packet, followed by
@@ -431,7 +431,7 @@ union sctp_params {
 	struct sctp_ipv4addr_param *v4;
 	struct sctp_ipv6addr_param *v6;
 	union sctp_addr_param *addr;
-	struct sctp_adaption_ind_param *aind;
+	struct sctp_adaptation_ind_param *aind;
 };
 
 /* RFC 2960.  Section 3.3.5 Heartbeat.
@@ -1483,7 +1483,7 @@ struct sctp_association {
 		__u8    asconf_capable;  /* Does peer support ADDIP? */
 		__u8    prsctp_capable;  /* Can peer do PR-SCTP? */
 
-		__u32   adaption_ind;	 /* Adaption Code point. */
+		__u32   adaptation_ind;	 /* Adaptation Code point. */
 
 		/* This mask is used to disable sending the ASCONF chunk
 		 * with specified parameter to peer.
diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 1a4ddc1..2923e3d 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -120,7 +120,7 @@ struct sctp_ulpevent *sctp_ulpevent_make
 	const struct sctp_association *asoc,
 	__u32 indication, gfp_t gfp);
 
-struct sctp_ulpevent *sctp_ulpevent_make_adaption_indication(
+struct sctp_ulpevent *sctp_ulpevent_make_adaptation_indication(
 	const struct sctp_association *asoc, gfp_t gfp);
 
 struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 9e4a39f..4116b0d 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -75,8 +75,8 @@ #define SCTP_AUTOCLOSE SCTP_AUTOCLOSE
 #define SCTP_SET_PEER_PRIMARY_ADDR SCTP_SET_PEER_PRIMARY_ADDR
 	SCTP_PRIMARY_ADDR,
 #define SCTP_PRIMARY_ADDR SCTP_PRIMARY_ADDR
-	SCTP_ADAPTION_LAYER,      
-#define SCTP_ADAPTION_LAYER SCTP_ADAPTION_LAYER
+	SCTP_ADAPTATION_LAYER,      
+#define SCTP_ADAPTATION_LAYER SCTP_ADAPTATION_LAYER
 	SCTP_DISABLE_FRAGMENTS,
 #define SCTP_DISABLE_FRAGMENTS SCTP_DISABLE_FRAGMENTS
 	SCTP_PEER_ADDR_PARAMS,
@@ -331,17 +331,17 @@ struct sctp_shutdown_event {
 };
 
 /*
- * 5.3.1.6 SCTP_ADAPTION_INDICATION
+ * 5.3.1.6 SCTP_ADAPTATION_INDICATION
  *
- *   When a peer sends a Adaption Layer Indication parameter , SCTP
+ *   When a peer sends a Adaptation Layer Indication parameter , SCTP
  *   delivers this notification to inform the application
- *   that of the peers requested adaption layer.
+ *   that of the peers requested adaptation layer.
  */
-struct sctp_adaption_event {
+struct sctp_adaptation_event {
 	__u16 sai_type;
 	__u16 sai_flags;
 	__u32 sai_length;
-	__u32 sai_adaption_ind;
+	__u32 sai_adaptation_ind;
 	sctp_assoc_t sai_assoc_id;
 };
 
@@ -374,7 +374,7 @@ struct sctp_event_subscribe {
 	__u8 sctp_peer_error_event;
 	__u8 sctp_shutdown_event;
 	__u8 sctp_partial_delivery_event;
-	__u8 sctp_adaption_layer_event;
+	__u8 sctp_adaptation_layer_event;
 };
 
 /*
@@ -395,7 +395,7 @@ union sctp_notification {
 	struct sctp_remote_error sn_remote_error;
 	struct sctp_send_failed sn_send_failed;
 	struct sctp_shutdown_event sn_shutdown_event;
-	struct sctp_adaption_event sn_adaption_event;
+	struct sctp_adaptation_event sn_adaptation_event;
 	struct sctp_pdapi_event sn_pdapi_event;
 };
 
@@ -412,7 +412,7 @@ enum sctp_sn_type {
 	SCTP_REMOTE_ERROR,
 	SCTP_SHUTDOWN_EVENT,
 	SCTP_PARTIAL_DELIVERY_EVENT,
-	SCTP_ADAPTION_INDICATION,
+	SCTP_ADAPTATION_INDICATION,
 };
 
 /* Notification error codes used to fill up the error fields in some
@@ -488,13 +488,13 @@ struct sctp_prim {
 } __attribute__((packed, aligned(4)));
 
 /*
- * 7.1.11 Set Adaption Layer Indicator (SCTP_ADAPTION_LAYER)
+ * 7.1.11 Set Adaptation Layer Indicator (SCTP_ADAPTATION_LAYER)
  *
- * Requests that the local endpoint set the specified Adaption Layer
+ * Requests that the local endpoint set the specified Adaptation Layer
  * Indication parameter for all future INIT and INIT-ACK exchanges.
  */
-struct sctp_setadaption {
-	__u32	ssb_adaption_ind;
+struct sctp_setadaptation {
+	__u32	ssb_adaptation_ind;
 };
 
 /*
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 30927d3..f0bbe36 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -184,7 +184,7 @@ struct sctp_chunk *sctp_make_init(const 
 	struct sctp_sock *sp;
 	sctp_supported_addrs_param_t sat;
 	__be16 types[2];
-	sctp_adaption_ind_param_t aiparam;
+	sctp_adaptation_ind_param_t aiparam;
 
 	/* RFC 2960 3.3.2 Initiation (INIT) (1)
 	 *
@@ -249,9 +249,9 @@ struct sctp_chunk *sctp_make_init(const 
 	sctp_addto_chunk(retval, sizeof(ecap_param), &ecap_param);
 	if (sctp_prsctp_enable)
 		sctp_addto_chunk(retval, sizeof(prsctp_param), &prsctp_param);
-	aiparam.param_hdr.type = SCTP_PARAM_ADAPTION_LAYER_IND;
+	aiparam.param_hdr.type = SCTP_PARAM_ADAPTATION_LAYER_IND;
 	aiparam.param_hdr.length = htons(sizeof(aiparam));
-	aiparam.adaption_ind = htonl(sp->adaption_ind);
+	aiparam.adaptation_ind = htonl(sp->adaptation_ind);
 	sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
 nodata:
 	kfree(addrs.v);
@@ -269,7 +269,7 @@ struct sctp_chunk *sctp_make_init_ack(co
 	sctp_cookie_param_t *cookie;
 	int cookie_len;
 	size_t chunksize;
-	sctp_adaption_ind_param_t aiparam;
+	sctp_adaptation_ind_param_t aiparam;
 
 	retval = NULL;
 
@@ -323,9 +323,9 @@ struct sctp_chunk *sctp_make_init_ack(co
 	if (asoc->peer.prsctp_capable)
 		sctp_addto_chunk(retval, sizeof(prsctp_param), &prsctp_param);
 
-	aiparam.param_hdr.type = SCTP_PARAM_ADAPTION_LAYER_IND;
+	aiparam.param_hdr.type = SCTP_PARAM_ADAPTATION_LAYER_IND;
 	aiparam.param_hdr.length = htons(sizeof(aiparam));
-	aiparam.adaption_ind = htonl(sctp_sk(asoc->base.sk)->adaption_ind);
+	aiparam.adaptation_ind = htonl(sctp_sk(asoc->base.sk)->adaptation_ind);
 	sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
 
 	/* We need to remove the const qualifier at this point.  */
@@ -1300,8 +1300,8 @@ static sctp_cookie_param_t *sctp_pack_co
 	/* Remember PR-SCTP capability. */
 	cookie->c.prsctp_capable = asoc->peer.prsctp_capable;
 
-	/* Save adaption indication in the cookie. */
-	cookie->c.adaption_ind = asoc->peer.adaption_ind;
+	/* Save adaptation indication in the cookie. */
+	cookie->c.adaptation_ind = asoc->peer.adaptation_ind;
 
 	/* Set an expiration time for the cookie.  */
 	do_gettimeofday(&cookie->c.expiration);
@@ -1512,7 +1512,7 @@ no_hmac:
 	retval->addip_serial = retval->c.initial_tsn;
 	retval->adv_peer_ack_point = retval->ctsn_ack_point;
 	retval->peer.prsctp_capable = retval->c.prsctp_capable;
-	retval->peer.adaption_ind = retval->c.adaption_ind;
+	retval->peer.adaptation_ind = retval->c.adaptation_ind;
 
 	/* The INIT stuff will be done by the side effects.  */
 	return retval;
@@ -1743,7 +1743,7 @@ static int sctp_verify_param(const struc
 	case SCTP_PARAM_HEARTBEAT_INFO:
 	case SCTP_PARAM_UNRECOGNIZED_PARAMETERS:
 	case SCTP_PARAM_ECN_CAPABLE:
-	case SCTP_PARAM_ADAPTION_LAYER_IND:
+	case SCTP_PARAM_ADAPTATION_LAYER_IND:
 		break;
 
 	case SCTP_PARAM_HOST_NAME_ADDRESS:
@@ -2098,8 +2098,8 @@ static int sctp_process_param(struct sct
 		asoc->peer.ecn_capable = 1;
 		break;
 
-	case SCTP_PARAM_ADAPTION_LAYER_IND:
-		asoc->peer.adaption_ind = param.aind->adaption_ind;
+	case SCTP_PARAM_ADAPTATION_LAYER_IND:
+		asoc->peer.adaptation_ind = param.aind->adaptation_ind;
 		break;
 
 	case SCTP_PARAM_FWD_TSN_SUPPORT:
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 27cc444..aa51d19 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -688,12 +688,12 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(co
 		goto nomem_ev;
 
 	/* Sockets API Draft Section 5.3.1.6 	
-	 * When a peer sends a Adaption Layer Indication parameter , SCTP
+	 * When a peer sends a Adaptation Layer Indication parameter , SCTP
 	 * delivers this notification to inform the application that of the
-	 * peers requested adaption layer.
+	 * peers requested adaptation layer.
 	 */
-	if (new_asoc->peer.adaption_ind) {
-		ai_ev = sctp_ulpevent_make_adaption_indication(new_asoc,
+	if (new_asoc->peer.adaptation_ind) {
+		ai_ev = sctp_ulpevent_make_adaptation_indication(new_asoc,
 							    GFP_ATOMIC);
 		if (!ai_ev)
 			goto nomem_aiev;
@@ -820,12 +820,12 @@ sctp_disposition_t sctp_sf_do_5_1E_ca(co
 	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
 
 	/* Sockets API Draft Section 5.3.1.6
-	 * When a peer sends a Adaption Layer Indication parameter , SCTP
+	 * When a peer sends a Adaptation Layer Indication parameter , SCTP
 	 * delivers this notification to inform the application that of the
-	 * peers requested adaption layer.
+	 * peers requested adaptation layer.
 	 */
-	if (asoc->peer.adaption_ind) {
-		ev = sctp_ulpevent_make_adaption_indication(asoc, GFP_ATOMIC);
+	if (asoc->peer.adaptation_ind) {
+		ev = sctp_ulpevent_make_adaptation_indication(asoc, GFP_ATOMIC);
 		if (!ev)
 			goto nomem;
 
@@ -1698,12 +1698,12 @@ static sctp_disposition_t sctp_sf_do_dup
 	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
 
 	/* Sockets API Draft Section 5.3.1.6
-	 * When a peer sends a Adaption Layer Indication parameter , SCTP
+	 * When a peer sends a Adaptation Layer Indication parameter , SCTP
 	 * delivers this notification to inform the application that of the
-	 * peers requested adaption layer.
+	 * peers requested adaptation layer.
 	 */
-	if (asoc->peer.adaption_ind) {
-		ev = sctp_ulpevent_make_adaption_indication(asoc, GFP_ATOMIC);
+	if (asoc->peer.adaptation_ind) {
+		ev = sctp_ulpevent_make_adaptation_indication(asoc, GFP_ATOMIC);
 		if (!ev)
 			goto nomem_ev;
 
@@ -1791,12 +1791,12 @@ static sctp_disposition_t sctp_sf_do_dup
 			goto nomem;
 
 		/* Sockets API Draft Section 5.3.1.6
-		 * When a peer sends a Adaption Layer Indication parameter,
+		 * When a peer sends a Adaptation Layer Indication parameter,
 		 * SCTP delivers this notification to inform the application
-		 * that of the peers requested adaption layer.
+		 * that of the peers requested adaptation layer.
 		 */
-		if (asoc->peer.adaption_ind) {
-			ai_ev = sctp_ulpevent_make_adaption_indication(asoc,
+		if (asoc->peer.adaptation_ind) {
+			ai_ev = sctp_ulpevent_make_adaptation_indication(asoc,
 								 GFP_ATOMIC);
 			if (!ai_ev)
 				goto nomem;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index bdd8bd4..ec70201 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2731,17 +2731,17 @@ static int sctp_setsockopt_peer_primary_
 	return err;
 }
 
-static int sctp_setsockopt_adaption_layer(struct sock *sk, char __user *optval,
+static int sctp_setsockopt_adaptation_layer(struct sock *sk, char __user *optval,
 					  int optlen)
 {
-	struct sctp_setadaption adaption;
+	struct sctp_setadaptation adaptation;
 
-	if (optlen != sizeof(struct sctp_setadaption))
+	if (optlen != sizeof(struct sctp_setadaptation))
 		return -EINVAL;
-	if (copy_from_user(&adaption, optval, optlen)) 
+	if (copy_from_user(&adaptation, optval, optlen)) 
 		return -EFAULT;
 
-	sctp_sk(sk)->adaption_ind = adaption.ssb_adaption_ind;
+	sctp_sk(sk)->adaptation_ind = adaptation.ssb_adaptation_ind;
 
 	return 0;
 }
@@ -2894,8 +2894,8 @@ SCTP_STATIC int sctp_setsockopt(struct s
 	case SCTP_MAXSEG:
 		retval = sctp_setsockopt_maxseg(sk, optval, optlen);
 		break;
-	case SCTP_ADAPTION_LAYER:
-		retval = sctp_setsockopt_adaption_layer(sk, optval, optlen);
+	case SCTP_ADAPTATION_LAYER:
+		retval = sctp_setsockopt_adaptation_layer(sk, optval, optlen);
 		break;
 	case SCTP_CONTEXT:
 		retval = sctp_setsockopt_context(sk, optval, optlen);
@@ -3123,7 +3123,7 @@ SCTP_STATIC int sctp_init_sock(struct so
 	/* User specified fragmentation limit. */
 	sp->user_frag         = 0;
 
-	sp->adaption_ind = 0;
+	sp->adaptation_ind = 0;
 
 	sp->pf = sctp_get_pf_specific(sk->sk_family);
 
@@ -4210,21 +4210,21 @@ static int sctp_getsockopt_primary_addr(
 }
 
 /*
- * 7.1.11  Set Adaption Layer Indicator (SCTP_ADAPTION_LAYER)
+ * 7.1.11  Set Adaptation Layer Indicator (SCTP_ADAPTATION_LAYER)
  *
- * Requests that the local endpoint set the specified Adaption Layer
+ * Requests that the local endpoint set the specified Adaptation Layer
  * Indication parameter for all future INIT and INIT-ACK exchanges.
  */
-static int sctp_getsockopt_adaption_layer(struct sock *sk, int len,
+static int sctp_getsockopt_adaptation_layer(struct sock *sk, int len,
 				  char __user *optval, int __user *optlen)
 {
-	struct sctp_setadaption adaption;
+	struct sctp_setadaptation adaptation;
 
-	if (len != sizeof(struct sctp_setadaption))
+	if (len != sizeof(struct sctp_setadaptation))
 		return -EINVAL;
 
-	adaption.ssb_adaption_ind = sctp_sk(sk)->adaption_ind;
-	if (copy_to_user(optval, &adaption, len))
+	adaptation.ssb_adaptation_ind = sctp_sk(sk)->adaptation_ind;
+	if (copy_to_user(optval, &adaptation, len))
 		return -EFAULT;
 
 	return 0;
@@ -4635,8 +4635,8 @@ SCTP_STATIC int sctp_getsockopt(struct s
 		retval = sctp_getsockopt_peer_addr_info(sk, len, optval,
 							optlen);
 		break;
-	case SCTP_ADAPTION_LAYER:
-		retval = sctp_getsockopt_adaption_layer(sk, len, optval,
+	case SCTP_ADAPTATION_LAYER:
+		retval = sctp_getsockopt_adaptation_layer(sk, len, optval,
 							optlen);
 		break;
 	case SCTP_CONTEXT:
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 93ac63b..445e07a 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -609,31 +609,31 @@ fail:
 	return NULL;
 }
 
-/* Create and initialize a SCTP_ADAPTION_INDICATION notification.
+/* Create and initialize a SCTP_ADAPTATION_INDICATION notification.
  *
  * Socket Extensions for SCTP
- * 5.3.1.6 SCTP_ADAPTION_INDICATION
+ * 5.3.1.6 SCTP_ADAPTATION_INDICATION
  */
-struct sctp_ulpevent *sctp_ulpevent_make_adaption_indication(
+struct sctp_ulpevent *sctp_ulpevent_make_adaptation_indication(
 	const struct sctp_association *asoc, gfp_t gfp)
 {
 	struct sctp_ulpevent *event;
-	struct sctp_adaption_event *sai;
+	struct sctp_adaptation_event *sai;
 	struct sk_buff *skb;
 
-	event = sctp_ulpevent_new(sizeof(struct sctp_adaption_event),
+	event = sctp_ulpevent_new(sizeof(struct sctp_adaptation_event),
 				  MSG_NOTIFICATION, gfp);
 	if (!event)
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	sai = (struct sctp_adaption_event *)
-		skb_put(skb, sizeof(struct sctp_adaption_event));
+	sai = (struct sctp_adaptation_event *)
+		skb_put(skb, sizeof(struct sctp_adaptation_event));
 
-	sai->sai_type = SCTP_ADAPTION_INDICATION;
+	sai->sai_type = SCTP_ADAPTATION_INDICATION;
 	sai->sai_flags = 0;
-	sai->sai_length = sizeof(struct sctp_adaption_event);
-	sai->sai_adaption_ind = asoc->peer.adaption_ind;
+	sai->sai_length = sizeof(struct sctp_adaptation_event);
+	sai->sai_adaptation_ind = asoc->peer.adaptation_ind;
 	sctp_ulpevent_set_owner(event, asoc);
 	sai->sai_assoc_id = sctp_assoc2id(asoc);
 


