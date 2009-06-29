From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] net/irda: convert bfin_sir to net_device_ops
Date: Mon, 29 Jun 2009 15:34:20 -0400
Message-ID: <1246304060-20606-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	Graf Yang <graf.yang@analog.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:47643 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167AbZF2Teo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 15:34:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graf Yang <graf.yang@analog.com>

Signed-off-by: Graf Yang <graf.yang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/irda/bfin_sir.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index f3eed6a..911c082 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -677,6 +677,14 @@ static int bfin_sir_init_iobuf(iobuff_t *io, int size)
 	return 0;
 }
 
+static const struct net_device_ops bfin_sir_ndo = {
+	.ndo_open		= bfin_sir_open,
+	.ndo_stop		= bfin_sir_stop,
+	.ndo_start_xmit		= bfin_sir_hard_xmit,
+	.ndo_do_ioctl		= bfin_sir_ioctl,
+	.ndo_get_stats		= bfin_sir_stats,
+};
+
 static int __devinit bfin_sir_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
@@ -718,12 +726,8 @@ static int __devinit bfin_sir_probe(struct platform_device *pdev)
 	if (err)
 		goto err_mem_3;
 
-	dev->hard_start_xmit = bfin_sir_hard_xmit;
-	dev->open            = bfin_sir_open;
-	dev->stop            = bfin_sir_stop;
-	dev->do_ioctl        = bfin_sir_ioctl;
-	dev->get_stats       = bfin_sir_stats;
-	dev->irq             = sir_port->irq;
+	dev->netdev_ops = &bfin_sir_ndo;
+	dev->irq = sir_port->irq;
 
 	irda_init_max_qos_capabilies(&self->qos);
 
-- 
1.6.3.3

