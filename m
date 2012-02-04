From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 2/5] qlge: Fixed invalid reference to ip header
Date: Fri, 3 Feb 2012 16:06:49 -0800
Message-ID: <1328314013-20458-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1328314013-20458-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:22079
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754275Ab2BDAWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 19:22:47 -0500
In-Reply-To: <1328314013-20458-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we have copied skb into addr(page), skb->data doesn't contain ip
header information.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index b548987..582b237 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1576,13 +1576,14 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 		} else if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_U) &&
 				(ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_V4)) {
 			/* Unfragmented ipv4 UDP frame. */
-			struct iphdr *iph = (struct iphdr *) skb->data;
+			struct iphdr *iph =
+				(struct iphdr *) ((u8 *)addr + ETH_HLEN);
 			if (!(iph->frag_off &
 				cpu_to_be16(IP_MF|IP_OFFSET))) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				netif_printk(qdev, rx_status, KERN_DEBUG,
 					     qdev->ndev,
-					     "TCP checksum done!\n");
+					     "UDP checksum done!\n");
 			}
 		}
 	}
@@ -1690,7 +1691,7 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				netif_printk(qdev, rx_status, KERN_DEBUG,
 					     qdev->ndev,
-					     "TCP checksum done!\n");
+					     "UDP checksum done!\n");
 			}
 		}
 	}
-- 
1.7.6.rc1.1.g2c162b
