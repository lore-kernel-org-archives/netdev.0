From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net] sctp: return back transport in __sctp_rcv_init_lookup
Date: Mon, 31 Oct 2016 00:42:35 +0800
Message-ID: <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477845755.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33999 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757116AbcJ3Qml (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 12:42:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch, it used a local variable to save the transport that is
looked up by __sctp_lookup_association(), and didn't return it back. But in
sctp_rcv, it is used to initialize chunk->transport. So when hitting this,
even if it found the transport, it was still initializing chunk->transport
with null instead.

This patch is to return the transport back through transport pointer
that is from __sctp_rcv_lookup_harder().

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/input.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index a2ea1d1..8e0bc58 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -1021,7 +1021,6 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
 	struct sctphdr *sh = sctp_hdr(skb);
 	union sctp_params params;
 	sctp_init_chunk_t *init;
-	struct sctp_transport *transport;
 	struct sctp_af *af;
 
 	/*
@@ -1052,7 +1051,7 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
 
 		af->from_addr_param(paddr, params.addr, sh->source, 0);
 
-		asoc = __sctp_lookup_association(net, laddr, paddr, &transport);
+		asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
 		if (asoc)
 			return asoc;
 	}
-- 
2.1.0
