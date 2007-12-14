From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/11] drivers/net/sunvnet.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:09 -0800
Message-ID: <d70fb8ac3a19e2bc8ca4976aeacee3c31dd52073.1197671367.git.joe__22183.3042720847$1197671908$gmane$org@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
 <1197671652-32492-2-git-send-email-joe@perches.com>
 <1197671652-32492-3-git-send-email-joe@perches.com>
 <1197671652-32492-4-git-send-email-joe@perches.com>
 <1197671652-32492-5-git-send-email-joe@perches.com>
 <1197671652-32492-6-git-send-email-joe@perches.com>
 <1197671652-32492-7-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934078AbXLNWhp@vger.kernel.org>
In-Reply-To: <1197671652-32492-7-git-send-email-joe@perches.com>
Message-Id: <d70fb8ac3a19e2bc8ca4976aeacee3c31dd52073.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/sunvnet.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index ff1028a..4a0035f 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -1149,6 +1149,7 @@ static int __devinit vnet_port_probe(struct vio_dev *vdev,
 	struct vnet *vp;
 	const u64 *rmac;
 	int len, i, err, switch_port;
+	DECLARE_MAC_BUF(mac);
 
 	print_version();
 
@@ -1213,12 +1214,9 @@ static int __devinit vnet_port_probe(struct vio_dev *vdev,
 
 	dev_set_drvdata(&vdev->dev, port);
 
-	printk(KERN_INFO "%s: PORT ( remote-mac ", vp->dev->name);
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", port->raddr[i], i == 5 ? ' ' : ':');
-	if (switch_port)
-		printk("switch-port ");
-	printk(")\n");
+	printk(KERN_INFO "%s: PORT ( remote-mac %s%s )\n",
+	       vp->dev->name, print_mac(mac, port->raddr),
+	       switch_port ? " switch-port" : "");
 
 	vio_port_up(&port->vio);
 
-- 
1.5.3.7.949.g2221a6

