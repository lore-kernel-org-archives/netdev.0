From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 3/4 linux-2.6.9-rc3/linux-2.4.28-pre3]
	prism54 print firmware version
Date: Sat, 2 Oct 2004 16:46:10 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200410021646.10748.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_y8rXBnhfvfllDc6"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_y8rXBnhfvfllDc6
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-10-02 Margit Schubert-While <margitsw@t-online.de>

* 03_fwprint.patch
*  Print firmware version
*
*  As per convention, make errno return negative

Margit

















--Boundary-00=_y8rXBnhfvfllDc6
Content-Type: text/x-diff;
  charset="us-ascii";
  name="03_fwprint.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="03_fwprint.patch"

diff -Naur linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_dev.c	2004-09-25 11:37:09.000000000 +0200
+++ linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_dev.c	2004-09-25 12:03:58.000000000 +0200
@@ -105,7 +105,7 @@
 			       "%s: firmware '%s' size is not multiple of 32bit, aborting!\n",
 			       "prism54", priv->firmware);
 			release_firmware(fw_entry);
-			return EILSEQ; /* Illegal byte sequence  */;
+			return -EILSEQ; /* Illegal byte sequence  */;
 		}
 
 		while (fw_len > 0) {
@@ -142,6 +142,10 @@
 
 		BUG_ON(fw_len != 0);
 
+		/* Firmware version is at offset 40 (also for "newmac") */
+		printk(KERN_DEBUG "%s: firmware version: %.8s\n",
+		       priv->ndev->name, fw_entry->data + 40);
+
 		release_firmware(fw_entry);
 	}
 

--Boundary-00=_y8rXBnhfvfllDc6
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_y8rXBnhfvfllDc6--
