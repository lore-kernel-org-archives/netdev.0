From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 2.6.3 - incorrect handling of the status code from skge_probe
Date: Fri, 20 Feb 2004 23:50:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220235040.B26032@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mlindner@syskonnect.de, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


skge_probe() can return -ENODEV as well as number of detected adapters.


 drivers/net/sk98lin/skge.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff -puN drivers/net/sk98lin/skge.c~sk98-bad-test drivers/net/sk98lin/skge.c
--- linux-2.6.3/drivers/net/sk98lin/skge.c~sk98-bad-test	2004-02-20 23:39:41.000000000 +0100
+++ linux-2.6.3-fr/drivers/net/sk98lin/skge.c	2004-02-20 23:43:59.000000000 +0100
@@ -779,9 +779,10 @@ static int __init skge_init_module(void)
 
 	cards = skge_probe();
 	if (cards == 0) {
-		printk("sk98lin: No adapter found.\n");
+		printk(KERN_INFO "sk98lin: No adapter found.\n");
+		cards = -ENODEV;
 	}
-	return cards ? 0 : -ENODEV;
+	return (cards > 0 ) ? 0 : cards;
 } /* skge_init_module */
 
 

_
