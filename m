From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/24] ceph: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:27 -0700
Message-ID: <f211b163caf9dbf6e39c16bc21d9050a625812db.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ceph/messenger.c |    5 +----
 net/ceph/msgpool.c   |    6 +-----
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index c340e2e..2cd6683 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -2331,11 +2331,8 @@ struct ceph_msg *ceph_msg_new(int type, int front_len, gfp_t flags)
 		} else {
 			m->front.iov_base = kmalloc(front_len, flags);
 		}
-		if (m->front.iov_base == NULL) {
-			pr_err("msg_new can't allocate %d bytes\n",
-			     front_len);
+		if (m->front.iov_base == NULL)
 			goto out2;
-		}
 	} else {
 		m->front.iov_base = NULL;
 	}
diff --git a/net/ceph/msgpool.c b/net/ceph/msgpool.c
index d5f2d97..4ac37d4 100644
--- a/net/ceph/msgpool.c
+++ b/net/ceph/msgpool.c
@@ -10,12 +10,8 @@
 static void *alloc_fn(gfp_t gfp_mask, void *arg)
 {
 	struct ceph_msgpool *pool = arg;
-	void *p;
 
-	p = ceph_msg_new(0, pool->front_len, gfp_mask);
-	if (!p)
-		pr_err("msgpool %s alloc failed\n", pool->name);
-	return p;
+	return ceph_msg_new(0, pool->front_len, gfp_mask);
 }
 
 static void free_fn(void *element, void *arg)
-- 
1.7.6.405.gc1be0
