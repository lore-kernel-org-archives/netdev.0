From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 3/4] rxrpc: Fix checking of error from ip6_route_output()
Date: Thu, 13 Oct 2016 17:12:31 +0100
Message-ID: <147637515104.17348.6976931105913936732.stgit@warthog.procyon.org.uk>
References: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        dan.carpenter@oracle.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip6_route_output() doesn't return a negative error when it fails, rather
the ->error field of the returned dst_entry struct needs to be checked.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 75b54cb57ca3 ("rxrpc: Add IPv6 support")
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/peer_object.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 941b724d523b..862eea6b266c 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -193,8 +193,8 @@ static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 		fl6->fl6_dport = htons(7001);
 		fl6->fl6_sport = htons(7000);
 		dst = ip6_route_output(&init_net, NULL, fl6);
-		if (IS_ERR(dst)) {
-			_leave(" [route err %ld]", PTR_ERR(dst));
+		if (dst->error) {
+			_leave(" [route err %d]", dst->error);
 			return;
 		}
 		break;
