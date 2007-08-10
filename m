From: "Scott Thompson" <postfail@hushmail.com>
Subject: [PATCH 1/4]  /drivers/net ioremap balancing/returncode check (es3210.c)
Date: Fri, 10 Aug 2007 14:37:06 -0400
Message-ID: <20070810183707.36A1ADA81F@mailserver7.hushmail.com>
Reply-To: postfail@hushmail.com
Content-Type: text/plain; charset="UTF-8"
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

patchset against 2.6.23-rc2 for /drivers/net ioremap balancing / 
return check:

  corrects:
  --sbus_ioremap return unchecked.
  --ioremap function unchecked
  --function failure cases did not clean up ioremap'd values.
  lne390.c
   -- believe had incorrect/not ideal variable check on if for 
iounmap

this audit was only for files directly in drivers/net directory, 
not the full tree.

I split patches up by file changed as each file had different 
'owner' to ease accept/reject/revision process.

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

