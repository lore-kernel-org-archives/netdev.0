From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 13/14] sctp: remove the typedef sctp_authhdr_t
Date: Thu,  3 Aug 2017 15:42:21 +0800
Message-ID: <99eaf082a43fa5cd141ad9e25b9a7de3f33d69b7.1501745729.git.lucien.xin@gmail.com>
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
 <9e2aee0b88d26c3a5c041864d46fb0ebde965e11.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34053 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751245AbdHCHol (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:44:41 -0400
In-Reply-To: <9e2aee0b88d26c3a5c041864d46fb0ebde965e11.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_authhdr_t, and
replace with struct sctp_authhdr in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     | 6 +++---
 net/sctp/sm_make_chunk.c | 8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index e7b439e..b7603f5 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -693,15 +693,15 @@ struct sctp_addip_chunk {
  *   HMAC: n bytes (unsigned integer) This hold the result of the HMAC
  *      calculation.
  */
-typedef struct sctp_authhdr {
+struct sctp_authhdr {
 	__be16 shkey_id;
 	__be16 hmac_id;
 	__u8   hmac[0];
-} sctp_authhdr_t;
+};
 
 typedef struct sctp_auth_chunk {
 	struct sctp_chunkhdr chunk_hdr;
-	sctp_authhdr_t auth_hdr;
+	struct sctp_authhdr auth_hdr;
 } sctp_auth_chunk_t;
 
 struct sctp_infox {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index ae54c6e..d17e8d1 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1282,16 +1282,16 @@ struct sctp_chunk *sctp_make_auth(const struct sctp_association *asoc)
 		return NULL;
 
 	retval = sctp_make_control(asoc, SCTP_CID_AUTH, 0,
-			hmac_desc->hmac_len + sizeof(sctp_authhdr_t),
-			GFP_ATOMIC);
+				   hmac_desc->hmac_len + sizeof(auth_hdr),
+				   GFP_ATOMIC);
 	if (!retval)
 		return NULL;
 
 	auth_hdr.hmac_id = htons(hmac_desc->hmac_id);
 	auth_hdr.shkey_id = htons(asoc->active_key_id);
 
-	retval->subh.auth_hdr = sctp_addto_chunk(retval, sizeof(sctp_authhdr_t),
-						&auth_hdr);
+	retval->subh.auth_hdr = sctp_addto_chunk(retval, sizeof(auth_hdr),
+						 &auth_hdr);
 
 	hmac = skb_put_zero(retval->skb, hmac_desc->hmac_len);
 
-- 
2.1.0
