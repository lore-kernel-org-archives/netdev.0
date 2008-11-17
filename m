From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: af_packet should update its inuse counter
Date: Mon, 17 Nov 2008 11:49:03 +0100
Message-ID: <49214C1F.2060000@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090105030200060303090902"
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:51432 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbYKQKtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 05:49:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090105030200060303090902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch is a preparation to namespace conversion of /proc/net/protocols

In order to have relevant information for PACKET protocols, we should use
sock_prot_inuse_add() to update a (percpu and pernamespace) counter of
inuse sockets.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---

--------------090105030200060303090902
Content-Type: text/plain;
 name="af_packet_inuse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_packet_inuse.patch"

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c718e7e..b4870a3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -910,6 +910,7 @@ static int packet_release(struct socket *sock)
 	skb_queue_purge(&sk->sk_receive_queue);
 	sk_refcnt_debug_release(sk);
 
+	sock_prot_inuse_add(net, sk->sk_prot, -1);
 	sock_put(sk);
 	return 0;
 }
@@ -1085,6 +1086,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
 	write_lock_bh(&net->packet.sklist_lock);
 	sk_add_node(sk, &net->packet.sklist);
 	write_unlock_bh(&net->packet.sklist_lock);
+	sock_prot_inuse_add(net, &packet_proto, 1);
 	return(0);
 out:
 	return err;

--------------090105030200060303090902--
