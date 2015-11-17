From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] packet: Use PAGE_ALIGNED macro
Date: Tue, 17 Nov 2015 10:40:21 +0100
Message-ID: <1447753221-11998-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:37861 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751715AbbKQJkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2015 04:40:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use PAGE_ALIGNED(...) instead of open-coding it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/packet/af_packet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index af399ca..8f70523 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4107,7 +4107,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		err = -EINVAL;
 		if (unlikely((int)req->tp_block_size <= 0))
 			goto out;
-		if (unlikely(req->tp_block_size & (PAGE_SIZE - 1)))
+		if (unlikely(!PAGE_ALIGNED(req->tp_block_size)))
 			goto out;
 		if (po->tp_version >= TPACKET_V3 &&
 		    (int)(req->tp_block_size -
-- 
2.6.1.148.g7927db1
