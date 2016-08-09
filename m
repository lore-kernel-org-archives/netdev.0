From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 6/6] rxrpc: Free packets discarded in data_ready
Date: Tue, 09 Aug 2016 17:33:53 +0100
Message-ID: <147076043338.13232.13982890221086889631.stgit@warthog.procyon.org.uk>
References: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Under certain conditions, the data_ready handler will discard a packet.
These need to be freed.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 789719031462..70bb77818dea 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -744,6 +744,8 @@ cant_route_call:
 	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
 		_debug("reject type %d",sp->hdr.type);
 		rxrpc_reject_packet(local, skb);
+	} else {
+		rxrpc_free_skb(skb);
 	}
 	_leave(" [no call]");
 	return;
