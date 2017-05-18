From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] xen/9pfs: p9_trans_xen_init and p9_trans_xen_exit can be static
Date: Thu, 18 May 2017 15:22:41 +0000
Message-ID: <20170518152241.4830-1-weiyj.lk@gmail.com>
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
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36149 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932643AbdERPW6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:22:58 -0400
Received: by mail-pg0-f68.google.com with SMTP id h64so6346378pge.3
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 08:22:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warnings:

net/9p/trans_xen.c:528:5: warning:
 symbol 'p9_trans_xen_init' was not declared. Should it be static?
net/9p/trans_xen.c:540:6: warning:
 symbol 'p9_trans_xen_exit' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/9p/trans_xen.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/9p/trans_xen.c b/net/9p/trans_xen.c
index 71e8564..3deb17f 100644
--- a/net/9p/trans_xen.c
+++ b/net/9p/trans_xen.c
@@ -525,7 +525,7 @@ static struct xenbus_driver xen_9pfs_front_driver = {
 	.otherend_changed = xen_9pfs_front_changed,
 };
 
-int p9_trans_xen_init(void)
+static int p9_trans_xen_init(void)
 {
 	if (!xen_domain())
 		return -ENODEV;
@@ -537,7 +537,7 @@ int p9_trans_xen_init(void)
 }
 module_init(p9_trans_xen_init);
 
-void p9_trans_xen_exit(void)
+static void p9_trans_xen_exit(void)
 {
 	v9fs_unregister_trans(&p9_xen_trans);
 	return xenbus_unregister_driver(&xen_9pfs_front_driver);
