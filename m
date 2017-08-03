From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 12/14] sctp: remove the typedef sctp_addip_chunk_t
Date: Thu,  3 Aug 2017 15:42:20 +0800
Message-ID: <9e2aee0b88d26c3a5c041864d46fb0ebde965e11.1501745729.git.lucien.xin@gmail.com>
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
 <5374e7c1ae3374fc375f56b48893aa5c3c0208bf.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34139 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751255AbdHCHoc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:44:32 -0400
In-Reply-To: <5374e7c1ae3374fc375f56b48893aa5c3c0208bf.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_addip_chunk_t, and
replace with struct sctp_addip_chunk in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  4 ++--
 net/sctp/input.c         |  2 +-
 net/sctp/sm_make_chunk.c |  8 +++++---
 net/sctp/sm_statefuns.c  | 11 +++++++----
 4 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 83dac9b..e7b439e 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -639,10 +639,10 @@ struct sctp_addiphdr {
 	__u8	params[0];
 };
 
-typedef struct sctp_addip_chunk {
+struct sctp_addip_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_addiphdr addip_hdr;
-} sctp_addip_chunk_t;
+};
 
 /* AUTH
  * Section 4.1  Authentication Chunk (AUTH)
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 41eb2ec..92a0714 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -1111,7 +1111,7 @@ static struct sctp_association *__sctp_rcv_asconf_lookup(
 					__be16 peer_port,
 					struct sctp_transport **transportp)
 {
-	sctp_addip_chunk_t *asconf = (struct sctp_addip_chunk *)ch;
+	struct sctp_addip_chunk *asconf = (struct sctp_addip_chunk *)ch;
 	struct sctp_af *af;
 	union sctp_addr_param *param;
 	union sctp_addr paddr;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 0e71e50..ae54c6e 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3140,10 +3140,11 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
 			struct sctp_chunk *chunk, bool addr_param_needed,
 			struct sctp_paramhdr **errp)
 {
-	sctp_addip_chunk_t *addip = (sctp_addip_chunk_t *) chunk->chunk_hdr;
+	struct sctp_addip_chunk *addip;
 	union sctp_params param;
 	bool addr_param_seen = false;
 
+	addip = (struct sctp_addip_chunk *)chunk->chunk_hdr;
 	sctp_walk_params(param, addip, addip_hdr.params) {
 		size_t length = ntohs(param.p->length);
 
@@ -3207,7 +3208,7 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
 struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 				       struct sctp_chunk *asconf)
 {
-	sctp_addip_chunk_t *addip = (sctp_addip_chunk_t *) asconf->chunk_hdr;
+	struct sctp_addip_chunk *addip;
 	bool all_param_pass = true;
 	union sctp_params param;
 	struct sctp_addiphdr	*hdr;
@@ -3218,6 +3219,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 	int	chunk_len;
 	__u32	serial;
 
+	addip = (struct sctp_addip_chunk *)asconf->chunk_hdr;
 	chunk_len = ntohs(asconf->chunk_hdr->length) -
 		    sizeof(struct sctp_chunkhdr);
 	hdr = (struct sctp_addiphdr *)asconf->skb->data;
@@ -3419,7 +3421,7 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 	/* Skip the chunkhdr and addiphdr from the last asconf sent and store
 	 * a pointer to address parameter.
 	 */
-	length = sizeof(sctp_addip_chunk_t);
+	length = sizeof(struct sctp_addip_chunk);
 	addr_param = (union sctp_addr_param *)(asconf->skb->data + length);
 	asconf_len -= length;
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index d722f38..9c235bb 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3629,10 +3629,11 @@ sctp_disposition_t sctp_sf_do_asconf(struct net *net,
 	 * described in [I-D.ietf-tsvwg-sctp-auth].
 	 */
 	if (!net->sctp.addip_noauth && !chunk->auth)
-		return sctp_sf_discard_chunk(net, ep, asoc, type, arg, commands);
+		return sctp_sf_discard_chunk(net, ep, asoc, type, arg,
+					     commands);
 
 	/* Make sure that the ASCONF ADDIP chunk has a valid length.  */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_addip_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_addip_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -3746,10 +3747,12 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 	 * described in [I-D.ietf-tsvwg-sctp-auth].
 	 */
 	if (!net->sctp.addip_noauth && !asconf_ack->auth)
-		return sctp_sf_discard_chunk(net, ep, asoc, type, arg, commands);
+		return sctp_sf_discard_chunk(net, ep, asoc, type, arg,
+					     commands);
 
 	/* Make sure that the ADDIP chunk has a valid length.  */
-	if (!sctp_chunk_length_valid(asconf_ack, sizeof(sctp_addip_chunk_t)))
+	if (!sctp_chunk_length_valid(asconf_ack,
+				     sizeof(struct sctp_addip_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-- 
2.1.0
