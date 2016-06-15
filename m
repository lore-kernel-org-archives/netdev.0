From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/8] rxrpc: Don't assume anything about the address
 in an ICMP packet
Date: Wed, 15 Jun 2016 17:42:06 +0100
Message-ID: <146600892656.18270.13704590800333247497.stgit@warthog.procyon.org.uk>
References: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't assume anything about the address in an ICMP packet in
rxrpc_error_report() as the address may not be IPv4 in future, especially
since we're just printing these details.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/peer_event.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 80de84257227..6ba798d6659e 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -120,8 +120,6 @@ void rxrpc_error_report(struct sock *sk)
 	struct rxrpc_local *local = sk->sk_user_data;
 	struct rxrpc_peer *peer;
 	struct sk_buff *skb;
-	__be32 addr;
-	__be16 port;
 
 	_enter("%p{%d}", sk, local->debug_id);
 
@@ -139,12 +137,6 @@ void rxrpc_error_report(struct sock *sk)
 
 	rxrpc_new_skb(skb);
 
-	addr = *(__be32 *)(skb_network_header(skb) + serr->addr_offset);
-	port = serr->port;
-
-	_net("Rx UDP Error from %pI4:%hu", &addr, ntohs(port));
-	_debug("Msg l:%d d:%d", skb->len, skb->data_len);
-
 	rcu_read_lock();
 	peer = rxrpc_lookup_peer_icmp_rcu(local, skb);
 	if (peer && !rxrpc_get_peer_maybe(peer))
