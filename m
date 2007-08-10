From: "Scott Thompson" <postfail@hushmail.com>
Subject: [PATCH 2/4]  /drivers/net ioremap balancing/returncode check (lne390.c)
Date: Fri, 10 Aug 2007 14:38:34 -0400
Message-ID: <20070810183834.B00E3DA81F@mailserver7.hushmail.com>
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
diff --git a/drivers/net/lne390.c b/drivers/net/lne390.c
index 0a08d0c..f6d9fb6 100644
--- a/drivers/net/lne390.c
+++ b/drivers/net/lne390.c
@@ -290,7 +290,7 @@ static int __init lne390_probe1(struct 
net_device *dev, int ioaddr)
 		goto unmap;
 	return 0;
 unmap:
-	if (ei_status.reg0)
+	if (ei_status.mem)
 		iounmap(ei_status.mem);
 cleanup:
 	free_irq(dev->irq, dev);



