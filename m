From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 5/6] net: use release_pages() in zerocopy_sg_from_iovec()
Date: Tue,  6 Aug 2013 17:45:07 +0800
Message-ID: <1375782308-10565-6-git-send-email-jasowang@redhat.com>
References: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To reduce the duplicated codes.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net/core/datagram.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index a8a795c..badcd93 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -48,6 +48,7 @@
 #include <linux/highmem.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
+#include <linux/pagemap.h>
 
 #include <net/protocol.h>
 #include <linux/skbuff.h>
@@ -638,10 +639,7 @@ int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 			return -EMSGSIZE;
 		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
 		if (num_pages != size) {
-			int j;
-
-			for (j = 0; j < num_pages; j++)
-				put_page(page[i + j]);
+			release_pages(&page[i], num_pages, 0);
 			return -EFAULT;
 		}
 		truesize = size * PAGE_SIZE;
-- 
1.7.1
