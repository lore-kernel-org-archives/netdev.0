From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3 v2] eql: Convert printks to pr_<level> and
 netdev_<level>
Date: Thu, 03 Mar 2011 13:08:12 -0800
Message-ID: <1299186492.4338.166.camel@Joe-Laptop>
References: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
	 <90c4322fefc5e2d4778862abd051e6eb12c0284b.1299086044.git.joe@perches.com>
	 <20110303.122153.70207563.davem@davemloft.net>
	 <20110303.125951.200370524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4084 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758618Ab1CCVIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 16:08:13 -0500
In-Reply-To: <20110303.125951.200370524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add pr_fmt.

Removed trailing "\n" from version,
add back via pr_info("%s\n", version);

Signed-off-by: Joe Perches <joe@perches.com>

---

> Something is busted with this change, although I can't quite figure it
> out myself:

Joined of a fixed string with an __initconst string.

 drivers/net/eql.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 0cb1cf9..a59cf96 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -111,6 +111,8 @@
  * Sorry, I had to rewrite most of this for 2.5.x -DaveM
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/capability.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -162,7 +164,7 @@ static void eql_timer(unsigned long param)
 }
 
 static const char version[] __initconst =
-	"Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)\n";
+	"Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)";
 
 static const struct net_device_ops eql_netdev_ops = {
 	.ndo_open	= eql_open,
@@ -204,8 +206,8 @@ static int eql_open(struct net_device *dev)
 	equalizer_t *eql = netdev_priv(dev);
 
 	/* XXX We should force this off automatically for the user. */
-	printk(KERN_INFO "%s: remember to turn off Van-Jacobson compression on "
-	       "your slave devices.\n", dev->name);
+	netdev_info(dev,
+		    "remember to turn off Van-Jacobson compression on your slave devices\n");
 
 	BUG_ON(!list_empty(&eql->queue.all_slaves));
 
@@ -591,7 +593,7 @@ static int __init eql_init_module(void)
 {
 	int err;
 
-	printk(version);
+	pr_info("%s\n", version);
 
 	dev_eql = alloc_netdev(sizeof(equalizer_t), "eql", eql_setup);
 	if (!dev_eql)


