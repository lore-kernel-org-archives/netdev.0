From: Stefan Rompf <srompf@isg.de>
Subject: Patch: b44.c: Always restore pci config on resume
Date: Wed, 26 May 2004 23:17:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405262317.32299.srompf@isg.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_slQtANxsvxnf7oo"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_slQtANxsvxnf7oo
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

the Broadcom BCM4401 driver restores pci configuration on resume only when the 
device is up. On my notebook, this leads to a failure when the device is down 
during the S3 cycle. Short solution for now: Always restore pci config. Patch 
against 2.6.7rc1 attached, please apply.

Stefan

--Boundary-00=_slQtANxsvxnf7oo
Content-Type: text/x-diff;
  charset="us-ascii";
  name="b44-resume.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="b44-resume.diff"

--- linux-2.6.7rc1-orig/drivers/net/b44.c	2004-05-26 23:00:59.474435392 +0200
+++ linux-2.6.7rc1/drivers/net/b44.c	2004-05-26 22:22:12.000000000 +0200
@@ -1882,11 +1882,11 @@ static int b44_resume(struct pci_dev *pd
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct b44 *bp = dev->priv;
 
+	pci_restore_state(pdev, bp->pci_cfg_state);
+
 	if (!netif_running(dev))
 		return 0;
 
-	pci_restore_state(pdev, bp->pci_cfg_state);
-
 	spin_lock_irq(&bp->lock);
 
 	b44_init_rings(bp);

--Boundary-00=_slQtANxsvxnf7oo--
