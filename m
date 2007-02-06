From: akpm@linux-foundation.org
Subject: [patch 08/11] slip: Replace kmalloc() + memset() pairs with the appropriate kzalloc() calls
Date: Mon, 05 Feb 2007 16:31:06 -0800
Message-ID: <200702060032.l160W99K004640@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	joe.jin@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41472 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965128AbXBFAcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:32:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: joe jin <joe.jin@oracle.com>

This patch replace kmalloc() + memset() pairs with the appropriate
kzalloc().

Signed-off-by: Joe Jin <joe.jin@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/slip.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff -puN drivers/net/slip.c~slip-replace-kmalloc-memset-pairs-with-the drivers/net/slip.c
--- a/drivers/net/slip.c~slip-replace-kmalloc-memset-pairs-with-the
+++ a/drivers/net/slip.c
@@ -1343,15 +1343,12 @@ static int __init slip_init(void)
 	printk(KERN_INFO "SLIP linefill/keepalive option.\n");
 #endif
 
-	slip_devs = kmalloc(sizeof(struct net_device *)*slip_maxdev, GFP_KERNEL);
+	slip_devs = kzalloc(sizeof(struct net_device *)*slip_maxdev, GFP_KERNEL);
 	if (!slip_devs) {
 		printk(KERN_ERR "SLIP: Can't allocate slip devices array!  Uaargh! (-> No SLIP available)\n");
 		return -ENOMEM;
 	}
 
-	/* Clear the pointer array, we allocate devices when we need them */
-	memset(slip_devs, 0, sizeof(struct net_device *)*slip_maxdev);
-
 	/* Fill in our line protocol discipline, and register it */
 	if ((status = tty_register_ldisc(N_SLIP, &sl_ldisc)) != 0)  {
 		printk(KERN_ERR "SLIP: can't register line discipline (err = %d)\n", status);
_
