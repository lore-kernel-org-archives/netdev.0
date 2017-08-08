From: Pan Bian <bianpan2016@163.com>
Subject: xen/9pfs: check return value of xenbus_read correctly
Date: Tue,  8 Aug 2017 21:23:53 +0800
Message-ID: <1502198633-27144-1-git-send-email-bianpan2016@163.com>
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function xen_9pfs_front_probe(), variable len is checked against 0 to
to check the case that xenbus_read() fails. However, xenbus_read() may
return an ERR_PTR pointer even aften assigning a non-zero value to len.
As a result, the check of len cannot prevent from accessing bad memory.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 net/9p/trans_xen.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/9p/trans_xen.c b/net/9p/trans_xen.c
index 6ad3e04..c548781 100644
--- a/net/9p/trans_xen.c
+++ b/net/9p/trans_xen.c
@@ -389,7 +389,7 @@ static int xen_9pfs_front_probe(struct xenbus_device *dev,
 	unsigned int max_rings, max_ring_order, len = 0;
 
 	versions = xenbus_read(XBT_NIL, dev->otherend, "versions", &len);
-	if (!len)
+	if (IS_ERR(versions))
 		return -EINVAL;
 	if (strcmp(versions, "1")) {
 		kfree(versions);
-- 
1.9.1
