From: sunil.kovvuri@gmail.com
Subject: [PATCH 17/21] net: thunderx: Don't set mac address for secondary Qset
 VFs
Date: Wed, 10 Aug 2016 12:12:49 +0530
Message-ID: <1470811373-28277-18-git-send-email-sunil.kovvuri@gmail.com>
References: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Set MAC addresses only for primary VF's and don't for
secondary VFs.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c   | 2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 3932c45..167291b 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -174,7 +174,7 @@ static void nic_mbx_send_ready(struct nicpf *nic, int vf)
 
 	mbx.nic_cfg.tns_mode = NIC_TNS_BYPASS_MODE;
 
-	if (vf < MAX_LMAC) {
+	if (vf < nic->num_vf_en) {
 		bgx_idx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
 		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
 
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 300416a..4a084ab 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1209,7 +1209,7 @@ int nicvf_open(struct net_device *netdev)
 	}
 
 	/* Check if we got MAC address from PF or else generate a radom MAC */
-	if (is_zero_ether_addr(netdev->dev_addr)) {
+	if (!nic->sqs_mode && is_zero_ether_addr(netdev->dev_addr)) {
 		eth_hw_addr_random(netdev);
 		nicvf_hw_set_mac_addr(nic, netdev);
 	}
-- 
2.7.4
