From: Scott Thompson <postfailathushmaildotcom@yahoo.com>
Subject: [PATCH 1/3] /drivers/net ioremap balancing/returncode check (resend)
Date: Mon, 13 Aug 2007 21:42:17 -0700 (PDT)
Message-ID: <851437.53933.qm@web44909.mail.sp1.yahoo.com>
Reply-To: postfail@hushmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, postfail@hushmail.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

resending patchset against 2.6.23-rc3 for /drivers/net ioremap balancing / return check,
previous patchset contained wordwrap errors:

  corrects:
  --sbus_ioremap return unchecked.
  --ioremap function unchecked
  --function failure cases did not clean up ioremap'd values.
  lne390.c  -- believe had incorrect/not ideal variable check on if for iounmap

this audit was only for files directly in drivers/net directory, not the full tree.

Signed-off-by: Scott Thompson <postfail <at> hushmail.com>
----------------------------------------------------------
diff --git a/drivers/net/es3210.c b/drivers/net/es3210.c
index 822e5bf..d7d6b90 100644
--- a/drivers/net/es3210.c
+++ b/drivers/net/es3210.c
@@ -307,6 +307,10 @@ out1:
 	free_irq(dev->irq, dev);
 out:
 	release_region(ioaddr + ES_SA_PROM, ES_IO_EXTENT);
+
+	if (ei_status.mem)
+		iounmap(ei_status.mem);
+	
 	return retval;
 }
 
diff --git a/drivers/net/lne390.c b/drivers/net/lne390.c
index 0a08d0c..f6d9fb6 100644
--- a/drivers/net/lne390.c
+++ b/drivers/net/lne390.c
@@ -290,7 +290,7 @@ static int __init lne390_probe1(struct net_device *dev, int ioaddr)
 		goto unmap;
 	return 0;
 unmap:
-	if (ei_status.reg0)
+	if (ei_status.mem)
 		iounmap(ei_status.mem);
 cleanup:
 	free_irq(dev->irq, dev);


       
____________________________________________________________________________________
Take the Internet to Go: Yahoo!Go puts the Internet in your pocket: mail, news, photos & more. 
http://mobile.yahoo.com/go?refer=1GNXIC

