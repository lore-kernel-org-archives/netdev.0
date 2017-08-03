From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 10/14] sctp: remove the typedef sctp_addip_param_t
Date: Thu,  3 Aug 2017 15:42:18 +0800
Message-ID: <9ee006c5a40a15372502d1e2458b8f9f568ceb2e.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
 <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
 <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
 <61746e2a2efa75634ab632cf264ad902aa3f9685.1501745729.git.lucien.xin@gmail.com>
 <91fc6fd265b6623a2244f17a9e5581962a2183d0.1501745729.git.lucien.xin@gmail.com>
 <bc49ca93eba1ba96461674afe5fadc441f8d288a.1501745729.git.lucien.xin@gmail.com>
 <a5a3e5ce57d84377d2426a010f92d2afb5ca346d.1501745729.git.lucien.xin@gmail.com>
 <cd4fd6410dd3ee98ea8462b2b9eb8af3b39d536a.1501745729.git.lucien.xin@gmail.com>
 <4117cc15ad262c164f9725e4dee1f9d0b13dd992.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37995 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdHCHoQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:44:16 -0400
In-Reply-To: <4117cc15ad262c164f9725e4dee1f9d0b13dd992.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_addip_param_t, and
replace with struct sctp_addip_param in the places where it's
using this typedef.

It is to use sizeof(variable) instead of sizeof(type), and
also fix some indent problems.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  8 ++++----
 net/sctp/sm_make_chunk.c | 39 ++++++++++++++++++++-------------------
 2 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 2a97639..5b7d6d9 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -629,10 +629,10 @@ struct sctp_fwdtsn_chunk {
  *	The ASCONF Parameter Response is used in the ASCONF-ACK to
  *	report status of ASCONF processing.
  */
-typedef struct sctp_addip_param {
-	struct sctp_paramhdr	param_hdr;
-	__be32		crr_id;
-} sctp_addip_param_t;
+struct sctp_addip_param {
+	struct sctp_paramhdr param_hdr;
+	__be32 crr_id;
+};
 
 typedef struct sctp_addiphdr {
 	__be32	serial;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index e8e5065..bab3354 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2615,7 +2615,7 @@ static int sctp_process_param(struct sctp_association *asoc,
 		if (!net->sctp.addip_enable)
 			goto fall_through;
 
-		addr_param = param.v + sizeof(sctp_addip_param_t);
+		addr_param = param.v + sizeof(struct sctp_addip_param);
 
 		af = sctp_get_af_specific(param_type2af(addr_param->p.type));
 		if (af == NULL)
@@ -2810,7 +2810,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 					      int		      addrcnt,
 					      __be16		      flags)
 {
-	sctp_addip_param_t	param;
+	struct sctp_addip_param	param;
 	struct sctp_chunk	*retval;
 	union sctp_addr_param	addr_param;
 	union sctp_addr		*addr;
@@ -2896,7 +2896,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 struct sctp_chunk *sctp_make_asconf_set_prim(struct sctp_association *asoc,
 					     union sctp_addr *addr)
 {
-	sctp_addip_param_t	param;
+	struct sctp_addip_param	param;
 	struct sctp_chunk 	*retval;
 	int 			len = sizeof(param);
 	union sctp_addr_param	addrparam;
@@ -2965,9 +2965,10 @@ static struct sctp_chunk *sctp_make_asconf_ack(const struct sctp_association *as
 
 /* Add response parameters to an ASCONF_ACK chunk. */
 static void sctp_add_asconf_response(struct sctp_chunk *chunk, __be32 crr_id,
-			      __be16 err_code, sctp_addip_param_t *asconf_param)
+				     __be16 err_code,
+				     struct sctp_addip_param *asconf_param)
 {
-	sctp_addip_param_t 	ack_param;
+	struct sctp_addip_param ack_param;
 	struct sctp_errhdr	err_param;
 	int			asconf_param_len = 0;
 	int			err_param_len = 0;
@@ -3006,15 +3007,15 @@ static void sctp_add_asconf_response(struct sctp_chunk *chunk, __be32 crr_id,
 
 /* Process a asconf parameter. */
 static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
-				       struct sctp_chunk *asconf,
-				       sctp_addip_param_t *asconf_param)
+					struct sctp_chunk *asconf,
+					struct sctp_addip_param *asconf_param)
 {
 	struct sctp_transport *peer;
 	struct sctp_af *af;
 	union sctp_addr	addr;
 	union sctp_addr_param *addr_param;
 
-	addr_param = (void *)asconf_param + sizeof(sctp_addip_param_t);
+	addr_param = (void *)asconf_param + sizeof(*asconf_param);
 
 	if (asconf_param->param_hdr.type != SCTP_PARAM_ADD_IP &&
 	    asconf_param->param_hdr.type != SCTP_PARAM_DEL_IP &&
@@ -3174,13 +3175,13 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
 			if (addr_param_needed && !addr_param_seen)
 				return false;
 			length = ntohs(param.addip->param_hdr.length);
-			if (length < sizeof(sctp_addip_param_t) +
+			if (length < sizeof(struct sctp_addip_param) +
 				     sizeof(**errp))
 				return false;
 			break;
 		case SCTP_PARAM_SUCCESS_REPORT:
 		case SCTP_PARAM_ADAPTATION_LAYER_IND:
-			if (length != sizeof(sctp_addip_param_t))
+			if (length != sizeof(struct sctp_addip_param))
 				return false;
 			break;
 		default:
@@ -3289,7 +3290,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 
 /* Process a asconf parameter that is successfully acked. */
 static void sctp_asconf_param_success(struct sctp_association *asoc,
-				     sctp_addip_param_t *asconf_param)
+				      struct sctp_addip_param *asconf_param)
 {
 	struct sctp_af *af;
 	union sctp_addr	addr;
@@ -3298,7 +3299,7 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
 	struct sctp_transport *transport;
 	struct sctp_sockaddr_entry *saddr;
 
-	addr_param = (void *)asconf_param + sizeof(sctp_addip_param_t);
+	addr_param = (void *)asconf_param + sizeof(*asconf_param);
 
 	/* We have checked the packet before, so we do not check again.	*/
 	af = sctp_get_af_specific(param_type2af(addr_param->p.type));
@@ -3349,10 +3350,10 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
  * specific success indication is present for the parameter.
  */
 static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
-				      sctp_addip_param_t *asconf_param,
-				      int no_err)
+				       struct sctp_addip_param *asconf_param,
+				       int no_err)
 {
-	sctp_addip_param_t	*asconf_ack_param;
+	struct sctp_addip_param	*asconf_ack_param;
 	struct sctp_errhdr	*err_param;
 	int			length;
 	int			asconf_ack_len;
@@ -3370,8 +3371,8 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 	 * the first asconf_ack parameter.
 	 */
 	length = sizeof(sctp_addiphdr_t);
-	asconf_ack_param = (sctp_addip_param_t *)(asconf_ack->skb->data +
-						  length);
+	asconf_ack_param = (struct sctp_addip_param *)(asconf_ack->skb->data +
+						       length);
 	asconf_ack_len -= length;
 
 	while (asconf_ack_len > 0) {
@@ -3380,7 +3381,7 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 			case SCTP_PARAM_SUCCESS_REPORT:
 				return SCTP_ERROR_NO_ERROR;
 			case SCTP_PARAM_ERR_CAUSE:
-				length = sizeof(sctp_addip_param_t);
+				length = sizeof(*asconf_ack_param);
 				err_param = (void *)asconf_ack_param + length;
 				asconf_ack_len -= length;
 				if (asconf_ack_len > 0)
@@ -3407,7 +3408,7 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 {
 	struct sctp_chunk	*asconf = asoc->addip_last_asconf;
 	union sctp_addr_param	*addr_param;
-	sctp_addip_param_t	*asconf_param;
+	struct sctp_addip_param	*asconf_param;
 	int	length = 0;
 	int	asconf_len = asconf->skb->len;
 	int	all_param_pass = 0;
-- 
2.1.0
