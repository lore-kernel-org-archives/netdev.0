From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] packet: Don't check frames_per_block against negative values
Date: Tue, 17 Nov 2015 10:38:36 +0100
Message-ID: <1447753116-11831-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:37857 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbbKQJik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2015 04:38:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rb->frames_per_block is an unsigned int, thus can never be negative.

Also fix spacing in the calculation of frames_per_block.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/packet/af_packet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index af399ca..4c27ae76 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4119,8 +4119,8 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		if (unlikely(req->tp_frame_size & (TPACKET_ALIGNMENT - 1)))
 			goto out;
 
-		rb->frames_per_block = req->tp_block_size/req->tp_frame_size;
-		if (unlikely(rb->frames_per_block <= 0))
+		rb->frames_per_block = req->tp_block_size / req->tp_frame_size;
+		if (unlikely(rb->frames_per_block == 0))
 			goto out;
 		if (unlikely((rb->frames_per_block * req->tp_block_nr) !=
 					req->tp_frame_nr))
-- 
2.6.3.368.gf34be46.dirty
