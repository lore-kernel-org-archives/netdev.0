From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.4.x net driver updates
Date: Sat, 28 Aug 2004 20:26:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829002606.GA14433@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.4

This will update the following files:

 drivers/net/e1000/e1000_param.c |    2 +-
 drivers/net/fealnx.c            |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

through these ChangeSets:

<ha505@hszk.bme.hu> (04/08/28 1.1550)
   [netdrvr fealnx] fix spin_unlock_irqrestore() usage

<tharbaugh@lnxi.com> (04/08/28 1.1549)
   [netdrvr e1000] disable DITR, which apparently hurts performance

diff -Nru a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
--- a/drivers/net/e1000/e1000_param.c	2004-08-28 20:25:30 -04:00
+++ b/drivers/net/e1000/e1000_param.c	2004-08-28 20:25:30 -04:00
@@ -212,7 +212,7 @@
 #define MAX_TXABSDELAY            0xFFFF
 #define MIN_TXABSDELAY                 0
 
-#define DEFAULT_ITR                    1
+#define DEFAULT_ITR                 8000
 #define MAX_ITR                   100000
 #define MIN_ITR                      100
 
diff -Nru a/drivers/net/fealnx.c b/drivers/net/fealnx.c
--- a/drivers/net/fealnx.c	2004-08-28 20:25:30 -04:00
+++ b/drivers/net/fealnx.c	2004-08-28 20:25:30 -04:00
@@ -1796,7 +1796,7 @@
 	unsigned long flags;
 	spin_lock_irqsave(lp, flags);
 	__set_rx_mode(dev);
-	spin_unlock_irqrestore(&lp, flags);
+	spin_unlock_irqrestore(lp, flags);
 }
 
 
