From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] tipc: Use kmemdup instead of kmalloc and memcpy
Date: Thu, 23 Jun 2016 10:19:37 +0530
Message-ID: <20160623044937.GA14109@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: jon.maloy@ericsson.com, ying.xue@windriver.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace calls to kmalloc followed by a memcpy with a direct call to
kmemdup.

The Coccinelle semantic patch used to make this change is as follows:
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 net/tipc/server.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index 2446bfb..38a6f33 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -411,13 +411,12 @@ static struct outqueue_entry *tipc_alloc_entry(void *data, int len)
 	if (!entry)
 		return NULL;
 
-	buf = kmalloc(len, GFP_ATOMIC);
+	buf = kmemdup(data, len, GFP_ATOMIC);
 	if (!buf) {
 		kfree(entry);
 		return NULL;
 	}
 
-	memcpy(buf, data, len);
 	entry->iov.iov_base = buf;
 	entry->iov.iov_len = len;
 
-- 
1.9.1
