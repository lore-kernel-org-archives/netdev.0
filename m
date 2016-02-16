From: sunil.kovvuri@gmail.com
Subject: [PATCH 2/3] net: thunderx: Fix for HW TSO not enabled for secondary qsets
Date: Tue, 16 Feb 2016 16:29:50 +0530
Message-ID: <1455620391-31619-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1455620391-31619-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455620391-31619-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

For secondary Qsets 'hw_tso' is not getting set as probe() returns
much earlier. Fixed it by moving silicon revision check.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index f8012c4..84c5a33 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1537,6 +1537,9 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	nicvf_send_vf_struct(nic);
 
+	if (!pass1_silicon(nic->pdev))
+		nic->hw_tso = true;
+
 	/* Check if this VF is in QS only mode */
 	if (nic->sqs_mode)
 		return 0;
@@ -1556,9 +1559,6 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 
-	if (!pass1_silicon(nic->pdev))
-		nic->hw_tso = true;
-
 	netdev->netdev_ops = &nicvf_netdev_ops;
 	netdev->watchdog_timeo = NICVF_TX_TIMEOUT;
 
-- 
1.7.1
