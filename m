From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] af_packet: fix warnings due to mismatched prototypes
Date: Wed,  2 Nov 2011 13:34:41 -0700
Message-ID: <1320266081-1387-1-git-send-email-olof@lixom.net>
Cc: netdev@vger.kernel.org, Olof Johansson <olof@lixom.net>,
	Chetan Loke <loke.chetan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:54862 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793Ab1KBUed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 16:34:33 -0400
Received: by pzk2 with SMTP id 2so1421293pzk.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 13:34:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial prototype mismatch fixes:

net/packet/af_packet.c:252: warning: 'prb_curr_blk_in_use' declared inline after being called
net/packet/af_packet.c:252: warning: previous declaration of 'prb_curr_blk_in_use' was here
net/packet/af_packet.c:258: warning: 'prb_queue_frozen' declared inline after being called
net/packet/af_packet.c:258: warning: previous declaration of 'prb_queue_frozen' was here
net/packet/af_packet.c:248: warning: 'packet_previous_frame' declared inline after being called
net/packet/af_packet.c:248: warning: previous declaration of 'packet_previous_frame' was here
net/packet/af_packet.c:251: warning: 'packet_increment_head' declared inline after being called
net/packet/af_packet.c:251: warning: previous declaration of 'packet_increment_head' was here

Signed-off-by: Olof Johansson <olof@lixom.net>
Cc: Chetan Loke <loke.chetan@gmail.com>
---

Dave, let me know if you prefer to shuffle code around and move the
inline helpers to the top instead -- I went with the smaller change by
default.


 net/packet/af_packet.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 03bb45a..9f4de7c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -245,17 +245,17 @@ struct packet_ring_buffer {
 struct packet_sock;
 static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);
 
-static void *packet_previous_frame(struct packet_sock *po,
+static inline void *packet_previous_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
 		int status);
-static void packet_increment_head(struct packet_ring_buffer *buff);
-static int prb_curr_blk_in_use(struct tpacket_kbdq_core *,
+static inline void packet_increment_head(struct packet_ring_buffer *buff);
+static inline int prb_curr_blk_in_use(struct tpacket_kbdq_core *,
 			struct tpacket_block_desc *);
 static void *prb_dispatch_next_block(struct tpacket_kbdq_core *,
 			struct packet_sock *);
 static void prb_retire_current_block(struct tpacket_kbdq_core *,
 		struct packet_sock *, unsigned int status);
-static int prb_queue_frozen(struct tpacket_kbdq_core *);
+static inline int prb_queue_frozen(struct tpacket_kbdq_core *);
 static void prb_open_block(struct tpacket_kbdq_core *,
 		struct tpacket_block_desc *);
 static void prb_retire_rx_blk_timer_expired(unsigned long);
-- 
1.7.4.1
