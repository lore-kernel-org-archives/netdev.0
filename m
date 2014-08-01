From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 3/6] inet: frags: enum the flag definitions and add descriptions
Date: Fri,  1 Aug 2014 12:29:45 +0200
Message-ID: <1406888988-20742-4-git-send-email-nikolay@redhat.com>
References: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9268 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754130AbaHAKax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 06:30:53 -0400
In-Reply-To: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the flags to an enum definion, swap FIRST_IN/LAST_IN to be in increasing
order and add comments explaining each flag and the inet_frag_queue struct
members.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: new patch, broken off the old patch 02

 include/net/inet_frag.h | 46 +++++++++++++++++++++++++++++++++++-----------
 1 file changed, 35 insertions(+), 11 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 5024d6c20407..90015c47b447 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -15,25 +15,49 @@ struct netns_frags {
 	int			low_thresh;
 };
 
+/**
+ * fragment queue flags
+ *
+ * @INET_FRAG_FIRST_IN: first fragment has arrived
+ * @INET_FRAG_LAST_IN: final fragment has arrived
+ * @INET_FRAG_COMPLETE: frag queue has been processed and is due for destruction
+ * @INET_FRAG_EVICTED: frag queue is being evicted
+ */
+enum {
+	INET_FRAG_FIRST_IN	= BIT(0),
+	INET_FRAG_LAST_IN	= BIT(1),
+	INET_FRAG_COMPLETE	= BIT(2),
+	INET_FRAG_EVICTED	= BIT(3)
+};
+
+/**
+ * struct inet_frag_queue - fragment queue
+ *
+ * @lock: spinlock protecting the queue
+ * @timer: queue expiration timer
+ * @list: hash bucket list
+ * @refcnt: reference count of the queue
+ * @fragments: received fragments head
+ * @fragments_tail: received fragments tail
+ * @stamp: timestamp of the last received fragment
+ * @len: total length of the original datagram
+ * @meat: length of received fragments so far
+ * @flags: fragment queue flags
+ * @max_size: (ipv4 only) maximum received fragment size with IP_DF set
+ * @net: namespace that this frag belongs to
+ */
 struct inet_frag_queue {
 	spinlock_t		lock;
-	struct timer_list	timer;      /* when will this queue expire? */
+	struct timer_list	timer;
 	struct hlist_node	list;
 	atomic_t		refcnt;
-	struct sk_buff		*fragments; /* list of received fragments */
+	struct sk_buff		*fragments;
 	struct sk_buff		*fragments_tail;
 	ktime_t			stamp;
-	int			len;        /* total length of orig datagram */
+	int			len;
 	int			meat;
-	__u8			flags;    /* first/last segment arrived? */
-
-#define INET_FRAG_EVICTED	8
-#define INET_FRAG_COMPLETE	4
-#define INET_FRAG_FIRST_IN	2
-#define INET_FRAG_LAST_IN	1
-
+	__u8			flags;
 	u16			max_size;
-
 	struct netns_frags	*net;
 };
 
-- 
1.9.3
