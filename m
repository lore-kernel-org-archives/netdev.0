From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next 1/2] tipc: honor msg2addr return
	value
Date: Mon, 27 Jun 2016 13:34:06 +0200
Message-ID: <1467027247-25469-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The UDP msg2addr function tipc_udp_msg2addr() can return -EINVAL which
prior to this patch was unhanded in the caller.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/discover.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index ad9d477..6b109a8 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -135,9 +135,12 @@ void tipc_disc_rcv(struct net *net, struct sk_buff *skb,
 	u16 caps = msg_node_capabilities(hdr);
 	bool respond = false;
 	bool dupl_addr = false;
+	int err;
 
-	bearer->media->msg2addr(bearer, &maddr, msg_media_addr(hdr));
+	err = bearer->media->msg2addr(bearer, &maddr, msg_media_addr(hdr));
 	kfree_skb(skb);
+	if (err)
+		return;
 
 	/* Ensure message from node is valid and communication is permitted */
 	if (net_id != tn->net_id)
-- 
2.1.4


------------------------------------------------------------------------------
Attend Shape: An AT&T Tech Expo July 15-16. Meet us at AT&T Park in San
Francisco, CA to explore cutting-edge tech and listen to tech luminaries
present their vision of the future. This family event has something for
everyone, including kids. Get more information and register today.
http://sdm.link/attshape
