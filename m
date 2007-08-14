From: Scott Thompson <postfailathushmaildotcom@yahoo.com>
Subject: [PATCH 2/3] /drivers/net myri_sbus.c ioremap balancing/returncode check (resend)
Date: Mon, 13 Aug 2007 21:44:49 -0700 (PDT)
Message-ID: <303513.3821.qm@web44906.mail.sp1.yahoo.com>
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
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 13444da..138aabd 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -1007,6 +1007,13 @@ static int __devinit myri_ether_init(struct sbus_dev *sdev)
 		mp->lanai =
 			sbus_ioremap(&sdev->resource[0], (512 * 1024),
 				     mp->eeprom.ramsz, "MyriCOM SRAM");
+
+
+		if (!mp->cregs || !mp->lregs || !mp->lanai ) {
+			printk("MyriCOM: Cannot map registers for ioremap fail.\n");
+			goto err;
+		}
+		
 	}
 	DET(("Registers mapped: cregs[%p] lregs[%p] lanai[%p]\n",
 	     mp->cregs, mp->lregs, mp->lanai));
@@ -1108,6 +1115,16 @@ err_free_irq:
 err:
 	/* This will also free the co-allocated 'dev->priv' */
 	free_netdev(dev);
+
+	if (mp->regs)
+		sbus_iounmap(mp->regs, mp->reg_size);
+	if (mp->cregs)
+		sbus_iounmap(mp->cregs, PAGE_SIZE);
+	if (mp->lregs)
+		sbus_iounmap(mp->lregs, (256 * 1024));
+	if (mp->lanai)
+		sbus_iounmap(mp->lanai, (512 * 1024));
+
 	return -ENODEV;
 }
 



       
____________________________________________________________________________________
Be a better Heartthrob. Get better relationship answers from someone who knows. Yahoo! Answers - Check it out. 
http://answers.yahoo.com/dir/?link=list&sid=396545433

