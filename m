From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 14/25] net: mvpp2: Rename a jump label in two functions
Date: Mon, 17 Apr 2017 17:24:11 +0200
Message-ID: <77376169-1cc0-c138-216e-c409948b8eb0@users.sourceforge.net>
References: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:54819 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754332AbdDQPY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 11:24:28 -0400
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 11:10:47 +0200

Adjust jump labels according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 4f4b659d7297..89237abf386d 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6065,7 +6065,7 @@ static int mvpp2_set_mac_address(struct net_device *dev, void *p)
 
 	if (!is_valid_ether_addr(addr->sa_data)) {
 		err = -EADDRNOTAVAIL;
-		goto error;
+		goto log_error;
 	}
 
 	if (!netif_running(dev)) {
@@ -6075,7 +6075,7 @@ static int mvpp2_set_mac_address(struct net_device *dev, void *p)
 		/* Reconfigure parser to accept the original MAC address */
 		err = mvpp2_prs_update_mac_da(dev, dev->dev_addr);
 		if (err)
-			goto error;
+			goto log_error;
 	}
 
 	mvpp2_stop_dev(port);
@@ -6087,14 +6087,13 @@ static int mvpp2_set_mac_address(struct net_device *dev, void *p)
 	/* Reconfigure parser accept the original MAC address */
 	err = mvpp2_prs_update_mac_da(dev, dev->dev_addr);
 	if (err)
-		goto error;
+		goto log_error;
 out_start:
 	mvpp2_start_dev(port);
 	mvpp2_egress_enable(port);
 	mvpp2_ingress_enable(port);
 	return 0;
-
-error:
+log_error:
 	netdev_err(dev, "fail to change MAC address\n");
 	return err;
 }
@@ -6120,7 +6119,7 @@ static int mvpp2_change_mtu(struct net_device *dev, int mtu)
 		/* Reconfigure BM to the original MTU */
 		err = mvpp2_bm_update_mtu(dev, dev->mtu);
 		if (err)
-			goto error;
+			goto log_error;
 	}
 
 	mvpp2_stop_dev(port);
@@ -6134,7 +6133,7 @@ static int mvpp2_change_mtu(struct net_device *dev, int mtu)
 	/* Reconfigure BM to the original MTU */
 	err = mvpp2_bm_update_mtu(dev, dev->mtu);
 	if (err)
-		goto error;
+		goto log_error;
 
 out_start:
 	mvpp2_start_dev(port);
@@ -6142,8 +6141,7 @@ static int mvpp2_change_mtu(struct net_device *dev, int mtu)
 	mvpp2_ingress_enable(port);
 
 	return 0;
-
-error:
+log_error:
 	netdev_err(dev, "fail to change MTU\n");
 	return err;
 }
-- 
2.12.2
