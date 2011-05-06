From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH 2/2] PCH_GbE : Fixed the issue of checksum judgment
Date: Fri, 06 May 2011 21:53:56 +0900
Message-ID: <4DC3EF64.9050305@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Tomoya Morinaga <tomoya-linux@dsn.okisemi.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Ewe, Kok Howg" <kok.howg.ewe@intel.com>
To: ML netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The checksum judgment was mistaken.
  Judgment result
     0:Correct 1:Wrong

This patch fixes the issue.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index babe663..6f10361 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -1494,12 +1494,11 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			/* Write meta date of skb */
 			skb_put(skb, length);
 			skb->protocol = eth_type_trans(skb, netdev);
-			if ((tcp_ip_status & PCH_GBE_RXD_ACC_STAT_TCPIPOK) ==
-			    PCH_GBE_RXD_ACC_STAT_TCPIPOK) {
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-			} else {
+			if (tcp_ip_status & PCH_GBE_RXD_ACC_STAT_TCPIPOK)
 				skb->ip_summed = CHECKSUM_NONE;
-			}
+			else
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+
 			napi_gro_receive(&adapter->napi, skb);
 			(*work_done)++;
 			pr_debug("Receive skb->ip_summed: %d length: %d\n",
-- 
1.6.2.5
