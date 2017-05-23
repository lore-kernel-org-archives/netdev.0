From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v6 net-next 04/17] net: qca_spi: Use SET_NETDEV_DEV()
Date: Tue, 23 May 2017 15:12:40 +0200
Message-ID: <1495545173-22150-5-git-send-email-stefan.wahren@i2se.com>
References: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:61310 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760557AbdEWNNd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 09:13:33 -0400
In-Reply-To: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use SET_NETDEV_DEV() in qca_spi to create the "/sys/class/net/<if>/device"
symlink.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_spi.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 24ca7df..0c3fdee 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -894,6 +894,7 @@ qca_spi_probe(struct spi_device *spi)
 		return -ENOMEM;
 
 	qcaspi_netdev_setup(qcaspi_devs);
+	SET_NETDEV_DEV(qcaspi_devs, &spi->dev);
 
 	qca = netdev_priv(qcaspi_devs);
 	if (!qca) {
-- 
2.1.4
