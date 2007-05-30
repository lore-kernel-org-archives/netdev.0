From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2.6.22-rc3] ehea: Fixed multi queue RX bug
Date: Wed, 30 May 2007 12:39:23 +0200
Message-ID: <200705301239.23934.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:8727 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbXE3Kj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 06:39:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Must access the respective queue's dummy netdev instead of the port's netdev.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 602872d..e85a933 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0058"
+#define DRV_VERSION	"EHEA_0061"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index f6e0cb1..152bb20 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -428,7 +428,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 				}
 				skb_copy_to_linear_data(skb, ((char*)cqe) + 64,
 					       cqe->num_bytes_transfered - 4);
-				ehea_fill_skb(dev, skb, cqe);
+				ehea_fill_skb(port->netdev, skb, cqe);
 			} else if (rq == 2) {  /* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
 						       skb_arr_rq2_len, cqe);


