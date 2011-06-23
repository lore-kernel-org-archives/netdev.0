From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH 2/2 resend] mlx4: use pci_dev->revision
Date: Thu, 23 Jun 2011 18:44:30 +0400
Message-ID: <201106231844.30905.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:50457 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751975Ab1FWOqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 10:46:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 725c89997e03d71b09ea3c17c997da0712b9d835 (mlx4_en: Reporting HW revision
in ethtool -i) added code to read the revision ID from the PCI configuration
register while it's already stored by PCI subsystem in the 'revision' field of
'struct pci_dev'...

While at it, move the code being changed a bit in order to not break the
initialization sequence.

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.
It wasn't merged to Linux 3.0, hopefully it will be picked up for 3.1...

 drivers/net/mlx4/main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/mlx4/main.c
===================================================================
--- linux-2.6.orig/drivers/net/mlx4/main.c
+++ linux-2.6/drivers/net/mlx4/main.c
@@ -1230,11 +1230,11 @@ static int __mlx4_init_one(struct pci_de
 	INIT_LIST_HEAD(&priv->pgdir_list);
 	mutex_init(&priv->pgdir_mutex);
 
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &dev->rev_id);
-
 	INIT_LIST_HEAD(&priv->bf_list);
 	mutex_init(&priv->bf_mutex);
 
+	dev->rev_id = pdev->revision;
+
 	/*
 	 * Now reset the HCA before we touch the PCI capabilities or
 	 * attempt a firmware command, since a boot ROM may have left
