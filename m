From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH V1 8/9] net: increase frag queue hash size and
	cache-line
Date: Fri, 23 Nov 2012 14:08:42 +0100
Message-ID: <20121123130842.18764.21984.stgit@dragon>
References: <20121123130749.18764.25962.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777Ab2KWNKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 08:10:41 -0500
In-Reply-To: <20121123130749.18764.25962.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase frag queue hash size and assure cache-line alignment to
avoid false sharing.  Hash size is set to 256, because I have
observed 206 frag queues in use at 4x10G with packet size 4416 bytes.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 1efec6b..5054228 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -49,13 +49,12 @@ struct inet_frag_queue {
 	u16			max_size;
 };
 
-#define INETFRAGS_HASHSZ		64
-
+#define INETFRAGS_HASHSZ	256
 
 struct inet_frag_bucket {
 	struct hlist_head	chain;
 	spinlock_t		chain_lock;
-};
+} ____cacheline_aligned_in_smp;
 
 struct inet_frags {
 	struct inet_frag_bucket	hash[INETFRAGS_HASHSZ];
