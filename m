From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCH] fix oopsable net driver bug
Date: Sun, 23 Nov 2003 12:36:11 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031123173611.GA27637@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@osdl.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


dev_kfree_skb, unlike kfree, will oops if passed NULL...
and it might be passed NULL in this case, if skb_padto() returns NULL.


Linus, please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.5

This will update the following files:

 drivers/net/sis190.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

through these ChangeSets:

<jgarzik@redhat.com> (03/11/20 1.1478)
   [netdrvr sis190] fix oopsable bug in TX path, related to skb_padto return
   
   Caught by Francois Romieu.

diff -Nru a/drivers/net/sis190.c b/drivers/net/sis190.c
--- a/drivers/net/sis190.c	Sun Nov 23 12:34:07 2003
+++ b/drivers/net/sis190.c	Sun Nov 23 12:34:07 2003
@@ -949,7 +949,8 @@
 
 drop_tx:
 	tp->stats.tx_dropped++;
-	dev_kfree_skb(skb);
+	if (skb)
+		dev_kfree_skb(skb);
 	return 0;
 }
 
