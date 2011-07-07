From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] af_packet: lock imbalance
Date: Thu, 07 Jul 2011 15:33:07 +0200
Message-ID: <1310045587.2127.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45613 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823Ab1GGNdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 09:33:20 -0400
Received: by wwe5 with SMTP id 5so964107wwe.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 06:33:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fanout_add() might return with fanout_mutex held.

Reduce indentation level while we are at it

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/packet/af_packet.c |   62 +++++++++++++++++++--------------------
 1 file changed, 31 insertions(+), 31 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index aec50a1..caa9fba 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -589,43 +589,43 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 			break;
 		}
 	}
+	err = -EINVAL;
 	if (match && match->defrag != defrag)
-		return -EINVAL;
+		goto out;
 	if (!match) {
+		err = -ENOMEM;
 		match = kzalloc(sizeof(*match), GFP_KERNEL);
-		if (match) {
-			write_pnet(&match->net, sock_net(sk));
-			match->id = id;
-			match->type = type;
-			match->defrag = defrag;
-			atomic_set(&match->rr_cur, 0);
-			INIT_LIST_HEAD(&match->list);
-			spin_lock_init(&match->lock);
-			atomic_set(&match->sk_ref, 0);
-			match->prot_hook.type = po->prot_hook.type;
-			match->prot_hook.dev = po->prot_hook.dev;
-			match->prot_hook.func = packet_rcv_fanout;
-			match->prot_hook.af_packet_priv = match;
-			dev_add_pack(&match->prot_hook);
-			list_add(&match->list, &fanout_list);
-		}
+		if (!match)
+			goto out;
+		write_pnet(&match->net, sock_net(sk));
+		match->id = id;
+		match->type = type;
+		match->defrag = defrag;
+		atomic_set(&match->rr_cur, 0);
+		INIT_LIST_HEAD(&match->list);
+		spin_lock_init(&match->lock);
+		atomic_set(&match->sk_ref, 0);
+		match->prot_hook.type = po->prot_hook.type;
+		match->prot_hook.dev = po->prot_hook.dev;
+		match->prot_hook.func = packet_rcv_fanout;
+		match->prot_hook.af_packet_priv = match;
+		dev_add_pack(&match->prot_hook);
+		list_add(&match->list, &fanout_list);
 	}
-	err = -ENOMEM;
-	if (match) {
-		err = -EINVAL;
-		if (match->type == type &&
-		    match->prot_hook.type == po->prot_hook.type &&
-		    match->prot_hook.dev == po->prot_hook.dev) {
-			err = -ENOSPC;
-			if (atomic_read(&match->sk_ref) < PACKET_FANOUT_MAX) {
-				__dev_remove_pack(&po->prot_hook);
-				po->fanout = match;
-				atomic_inc(&match->sk_ref);
-				__fanout_link(sk, po);
-				err = 0;
-			}
+	err = -EINVAL;
+	if (match->type == type &&
+	    match->prot_hook.type == po->prot_hook.type &&
+	    match->prot_hook.dev == po->prot_hook.dev) {
+		err = -ENOSPC;
+		if (atomic_read(&match->sk_ref) < PACKET_FANOUT_MAX) {
+			__dev_remove_pack(&po->prot_hook);
+			po->fanout = match;
+			atomic_inc(&match->sk_ref);
+			__fanout_link(sk, po);
+			err = 0;
 		}
 	}
+out:
 	mutex_unlock(&fanout_mutex);
 	return err;
 }


