From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 11/14] sctp: remove the typedef sctp_addiphdr_t
Date: Thu,  3 Aug 2017 15:42:19 +0800
Message-ID: <5374e7c1ae3374fc375f56b48893aa5c3c0208bf.1501745729.git.lucien.xin@gmail.com>
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
 <9ee006c5a40a15372502d1e2458b8f9f568ceb2e.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37749 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdHCHoY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:44:24 -0400
In-Reply-To: <9ee006c5a40a15372502d1e2458b8f9f568ceb2e.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_addiphdr_t, and
replace with struct sctp_addiphdr in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  6 +++---
 net/sctp/sm_make_chunk.c | 14 +++++++-------
 net/sctp/sm_statefuns.c  | 10 +++++-----
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 5b7d6d9..83dac9b 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -634,14 +634,14 @@ struct sctp_addip_param {
 	__be32 crr_id;
 };
 
-typedef struct sctp_addiphdr {
+struct sctp_addiphdr {
 	__be32	serial;
 	__u8	params[0];
-} sctp_addiphdr_t;
+};
 
 typedef struct sctp_addip_chunk {
 	struct sctp_chunkhdr chunk_hdr;
-	sctp_addiphdr_t addip_hdr;
+	struct sctp_addiphdr addip_hdr;
 } sctp_addip_chunk_t;
 
 /* AUTH
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index bab3354..0e71e50 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2752,7 +2752,7 @@ static struct sctp_chunk *sctp_make_asconf(struct sctp_association *asoc,
 					   union sctp_addr *addr,
 					   int vparam_len)
 {
-	sctp_addiphdr_t asconf;
+	struct sctp_addiphdr asconf;
 	struct sctp_chunk *retval;
 	int length = sizeof(asconf) + vparam_len;
 	union sctp_addr_param addrparam;
@@ -2945,7 +2945,7 @@ struct sctp_chunk *sctp_make_asconf_set_prim(struct sctp_association *asoc,
 static struct sctp_chunk *sctp_make_asconf_ack(const struct sctp_association *asoc,
 					       __u32 serial, int vparam_len)
 {
-	sctp_addiphdr_t		asconf;
+	struct sctp_addiphdr	asconf;
 	struct sctp_chunk	*retval;
 	int			length = sizeof(asconf) + vparam_len;
 
@@ -3210,7 +3210,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 	sctp_addip_chunk_t *addip = (sctp_addip_chunk_t *) asconf->chunk_hdr;
 	bool all_param_pass = true;
 	union sctp_params param;
-	sctp_addiphdr_t		*hdr;
+	struct sctp_addiphdr	*hdr;
 	union sctp_addr_param	*addr_param;
 	struct sctp_chunk	*asconf_ack;
 	__be16	err_code;
@@ -3220,11 +3220,11 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 
 	chunk_len = ntohs(asconf->chunk_hdr->length) -
 		    sizeof(struct sctp_chunkhdr);
-	hdr = (sctp_addiphdr_t *)asconf->skb->data;
+	hdr = (struct sctp_addiphdr *)asconf->skb->data;
 	serial = ntohl(hdr->serial);
 
 	/* Skip the addiphdr and store a pointer to address parameter.  */
-	length = sizeof(sctp_addiphdr_t);
+	length = sizeof(*hdr);
 	addr_param = (union sctp_addr_param *)(asconf->skb->data + length);
 	chunk_len -= length;
 
@@ -3370,7 +3370,7 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 	/* Skip the addiphdr from the asconf_ack chunk and store a pointer to
 	 * the first asconf_ack parameter.
 	 */
-	length = sizeof(sctp_addiphdr_t);
+	length = sizeof(struct sctp_addiphdr);
 	asconf_ack_param = (struct sctp_addip_param *)(asconf_ack->skb->data +
 						       length);
 	asconf_ack_len -= length;
@@ -3435,7 +3435,7 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 	 * failures are indicated, then all request(s) are considered
 	 * successful.
 	 */
-	if (asconf_ack->skb->len == sizeof(sctp_addiphdr_t))
+	if (asconf_ack->skb->len == sizeof(struct sctp_addiphdr))
 		all_param_pass = 1;
 
 	/* Process the TLVs contained in the last sent ASCONF chunk. */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index e13c83f..d722f38 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3613,7 +3613,7 @@ sctp_disposition_t sctp_sf_do_asconf(struct net *net,
 	struct sctp_chunk	*chunk = arg;
 	struct sctp_chunk	*asconf_ack = NULL;
 	struct sctp_paramhdr	*err_param = NULL;
-	sctp_addiphdr_t		*hdr;
+	struct sctp_addiphdr	*hdr;
 	__u32			serial;
 
 	if (!sctp_vtag_verify(chunk, asoc)) {
@@ -3636,7 +3636,7 @@ sctp_disposition_t sctp_sf_do_asconf(struct net *net,
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-	hdr = (sctp_addiphdr_t *)chunk->skb->data;
+	hdr = (struct sctp_addiphdr *)chunk->skb->data;
 	serial = ntohl(hdr->serial);
 
 	/* Verify the ASCONF chunk before processing it. */
@@ -3730,7 +3730,7 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 	struct sctp_chunk	*last_asconf = asoc->addip_last_asconf;
 	struct sctp_chunk	*abort;
 	struct sctp_paramhdr	*err_param = NULL;
-	sctp_addiphdr_t		*addip_hdr;
+	struct sctp_addiphdr	*addip_hdr;
 	__u32			sent_serial, rcvd_serial;
 
 	if (!sctp_vtag_verify(asconf_ack, asoc)) {
@@ -3753,7 +3753,7 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-	addip_hdr = (sctp_addiphdr_t *)asconf_ack->skb->data;
+	addip_hdr = (struct sctp_addiphdr *)asconf_ack->skb->data;
 	rcvd_serial = ntohl(addip_hdr->serial);
 
 	/* Verify the ASCONF-ACK chunk before processing it. */
@@ -3762,7 +3762,7 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 			   (void *)err_param, commands);
 
 	if (last_asconf) {
-		addip_hdr = (sctp_addiphdr_t *)last_asconf->subh.addip_hdr;
+		addip_hdr = (struct sctp_addiphdr *)last_asconf->subh.addip_hdr;
 		sent_serial = ntohl(addip_hdr->serial);
 	} else {
 		sent_serial = asoc->addip_serial - 1;
-- 
2.1.0
