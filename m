From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/4] net: increase frag hash size
Date: Wed, 24 Apr 2013 17:48:31 +0200
Message-ID: <20130424154822.16883.93014.stgit@dragon>
References: <20130424154624.16883.40974.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21350 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756641Ab3DXPsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 11:48:35 -0400
In-Reply-To: <20130424154624.16883.40974.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase fragmentation hash bucket size to 1024 from old 64 elems.

After we increased the frag mem limits (in commit v3.8-rc3-503-gc2a9366)
the hash size of 64 elements is simply too small.  Also considering
the mem limit is per netns and the hash table is shared for all netns.

For the embedded people, note that this increase will change the hash
table/array from using approx 1 Kbytes to 16 Kbytes.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index eb1d6ee..4e15856 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -41,7 +41,7 @@ struct inet_frag_queue {
 	struct netns_frags	*net;
 };
 
-#define INETFRAGS_HASHSZ		64
+#define INETFRAGS_HASHSZ	1024
 
 struct inet_frag_bucket {
 	struct hlist_head	chain;
