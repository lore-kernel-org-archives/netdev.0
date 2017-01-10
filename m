From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] packet: pdiag_put_ring() should return TX_RING info for TPACKET_V3
Date: Tue, 10 Jan 2017 07:47:15 -0800
Message-ID: <b1ae12eaef34ce413e2dc3bc5075a3c0198d7ad1.1484060892.git.sowmini.varadhan@oracle.com>
References: <cover.1484060892.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net
To: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17698 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752091AbdAJPrt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 10:47:49 -0500
In-Reply-To: <cover.1484060892.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7f953ab2ba46 ("af_packet: TX_RING support for TPACKET_V3")
now makes it possible to use TX_RING with TPACKET_V3, so make the
the relevant information available via 'ss -e -a --packet'

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/packet/diag.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/packet/diag.c b/net/packet/diag.c
index 0ed68f0..7ef1c88 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -73,8 +73,7 @@ static int pdiag_put_ring(struct packet_ring_buffer *ring, int ver, int nl_type,
 {
 	struct packet_diag_ring pdr;
 
-	if (!ring->pg_vec || ((ver > TPACKET_V2) &&
-				(nl_type == PACKET_DIAG_TX_RING)))
+	if (!ring->pg_vec)
 		return 0;
 
 	pdr.pdr_block_size = ring->pg_vec_pages << PAGE_SHIFT;
-- 
1.7.1
