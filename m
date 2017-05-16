From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] xen/9pfs: fix return value check in xen_9pfs_front_probe()
Date: Tue, 16 May 2017 14:22:47 +0000
Message-ID: <20170516142247.12301-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Stefano Stabellini <sstabellini@kernel.org>,
        Juergen Gross <jgross@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36627 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752130AbdEPOWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 10:22:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id n23so19009839pfb.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 07:22:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

In case of error, the function xenbus_read() returns ERR_PTR() and never
returns NULL. The NULL test in the return value check should be replaced
with IS_ERR().

Fixes: 71ebd71921e4 ("xen/9pfs: connect to the backend")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/9p/trans_xen.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/9p/trans_xen.c b/net/9p/trans_xen.c
index 71e8564..83fe487 100644
--- a/net/9p/trans_xen.c
+++ b/net/9p/trans_xen.c
@@ -454,8 +454,8 @@ static int xen_9pfs_front_probe(struct xenbus_device *dev,
 			goto error_xenbus;
 	}
 	priv->tag = xenbus_read(xbt, dev->nodename, "tag", NULL);
-	if (!priv->tag) {
-		ret = -EINVAL;
+	if (IS_ERR(priv->tag)) {
+		ret = PTR_ERR(priv->tag);
 		goto error_xenbus;
 	}
 	ret = xenbus_transaction_end(xbt, 0);
