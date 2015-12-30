From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 5/5] sctp: remove the local_bh_disable/enable in sctp_endpoint_lookup_assoc
Date: Wed, 30 Dec 2015 23:50:50 +0800
Message-ID: <5c66f765871d629154da51b4ddfbdef171592e92.1451490447.git.lucien.xin@gmail.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
 <2c413161eb3a2c74453bd8dc11815af7e237515e.1451490447.git.lucien.xin@gmail.com>
 <8d89800920719b527dbd6e36dbbcf3c0804fbd7c.1451490447.git.lucien.xin@gmail.com>
 <8694e8698924a89a1dad097a3f1120d4b24443a1.1451490447.git.lucien.xin@gmail.com>
 <85d66441be7419a830ad75a5334d2c3b31c0bda6.1451490447.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36831 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375AbbL3PvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 10:51:18 -0500
In-Reply-To: <85d66441be7419a830ad75a5334d2c3b31c0bda6.1451490447.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1451490447.git.lucien.xin@gmail.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_endpoint_lookup_assoc is called in the protection of sock lock
there is no need to call local_bh_disable in this function. so remove
them.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/endpointola.c | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 8838bf4..52838ea 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -317,7 +317,7 @@ struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *ep,
  * We lookup the transport from hashtable at first, then get association
  * through t->assoc.
  */
-static struct sctp_association *__sctp_endpoint_lookup_assoc(
+struct sctp_association *sctp_endpoint_lookup_assoc(
 	const struct sctp_endpoint *ep,
 	const union sctp_addr *paddr,
 	struct sctp_transport **transport)
@@ -342,21 +342,6 @@ out:
 	return asoc;
 }
 
-/* Lookup association on an endpoint based on a peer address.  BH-safe.  */
-struct sctp_association *sctp_endpoint_lookup_assoc(
-	const struct sctp_endpoint *ep,
-	const union sctp_addr *paddr,
-	struct sctp_transport **transport)
-{
-	struct sctp_association *asoc;
-
-	local_bh_disable();
-	asoc = __sctp_endpoint_lookup_assoc(ep, paddr, transport);
-	local_bh_enable();
-
-	return asoc;
-}
-
 /* Look for any peeled off association from the endpoint that matches the
  * given peer address.
  */
-- 
2.1.0
