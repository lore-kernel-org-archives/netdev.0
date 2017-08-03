From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 07/14] sctp: remove the typedef sctp_ecne_chunk_t
Date: Thu,  3 Aug 2017 15:42:15 +0800
Message-ID: <a5a3e5ce57d84377d2426a010f92d2afb5ca346d.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
 <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
 <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
 <61746e2a2efa75634ab632cf264ad902aa3f9685.1501745729.git.lucien.xin@gmail.com>
 <91fc6fd265b6623a2244f17a9e5581962a2183d0.1501745729.git.lucien.xin@gmail.com>
 <bc49ca93eba1ba96461674afe5fadc441f8d288a.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35104 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdHCHnu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:43:50 -0400
In-Reply-To: <bc49ca93eba1ba96461674afe5fadc441f8d288a.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_ecne_chunk_t, and
replace with struct sctp_ecne_chunk in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    | 4 ++--
 net/sctp/sm_statefuns.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 5ea739b..026bbdf 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -523,10 +523,10 @@ struct sctp_ecnehdr {
 	__be32 lowest_tsn;
 };
 
-typedef struct sctp_ecne_chunk {
+struct sctp_ecne_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_ecnehdr ence_hdr;
-} sctp_ecne_chunk_t;
+};
 
 /* RFC 2960.  Appendix A.  Explicit Congestion Notification.
  *   Congestion Window Reduced (CWR) (13)
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index de3e5bf..286dce1 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2869,7 +2869,7 @@ sctp_disposition_t sctp_sf_do_ecn_cwr(struct net *net,
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_ecne_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_ecne_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -2924,7 +2924,7 @@ sctp_disposition_t sctp_sf_do_ecne(struct net *net,
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_ecne_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_ecne_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-- 
2.1.0
