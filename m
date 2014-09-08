From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next] skb: Add documentation for skb_clone_sk
Date: Mon, 08 Sep 2014 12:18:22 -0400
Message-ID: <20140908161748.13099.29093.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51714 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753550AbaIHQ11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 12:27:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds some documentation to the call skb_clone_sk.  This is
meant to help clarify the purpose of the function for other developers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/skbuff.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a18dfb0..3f83a8a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3511,6 +3511,17 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
 }
 EXPORT_SYMBOL(sock_dequeue_err_skb);
 
+/**
+ * skb_clone_sk - create clone of skb, and take reference to socket
+ * @skb: the skb to clone
+ *
+ * For functions such as timestamping it is necessary to clone an skb and
+ * hold a reference to the socket for it until the hardware delivers the
+ * actual timestamp or the timestamp is timed out.  As as such this
+ * function is useful for creating a clone to later be handed off to
+ * skb_complete_tx_timestamp or kfree_skb to take care of cleaning up
+ * the reference handling for the socket.
+ */
 struct sk_buff *skb_clone_sk(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
