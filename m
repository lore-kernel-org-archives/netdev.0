From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove useless MOD_{INC,DEC}_USE_COUNT
Date: Fri, 7 May 2004 12:43:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040507104311.GA10873@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

*grr* - this one slipped in after my last round of audits it seems.


--- 1.15/drivers/net/gt96100eth.c	Mon Apr  5 22:31:23 2004
+++ edited/drivers/net/gt96100eth.c	Mon May  3 13:22:22 2004
@@ -1070,22 +1070,18 @@
 {
 	int retval;
     
-	MOD_INC_USE_COUNT;
-
 	dbg(2, "%s: dev=%p\n", __FUNCTION__, dev);
 
 	// Initialize and startup the GT-96100 ethernet port
 	if ((retval = gt96100_init(dev))) {
 		err("error in gt96100_init\n");
 		free_irq(dev->irq, dev);
-		MOD_DEC_USE_COUNT;
 		return retval;
 	}
 
 	if ((retval = request_irq(dev->irq, &gt96100_interrupt,
 				  SA_SHIRQ, dev->name, dev))) {
 		err("unable to get IRQ %d\n", dev->irq);
-		MOD_DEC_USE_COUNT;
 		return retval;
 	}
 	
@@ -1106,8 +1102,6 @@
 	}
 
 	free_irq(dev->irq, dev);
-    
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
