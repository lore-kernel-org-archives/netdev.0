From: sunil.kovvuri@gmail.com
Subject: [PATCH 4/4] net: thunderx: Allow IPv6 frames with zero UDP checksum
Date: Fri,  3 Mar 2017 16:17:50 +0530
Message-ID: <1488538070-12549-5-git-send-email-sunil.kovvuri@gmail.com>
References: <1488538070-12549-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>,
 Thanneeru Srinivasulu <tsrinivasulu@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488538070-12549-1-git-send-email-sunil.kovvuri@gmail.com>
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

From: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>

Do not consider IPv6 frames with zero UDP checksum as frames
with bad checksum and drop them.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index ee3aa16..77a86a6 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -657,9 +657,11 @@ static void nicvf_rcv_queue_config(struct nicvf *nic, struct queue_set *qs,
 	nicvf_send_msg_to_pf(nic, &mbx);
 
 	if (!nic->sqs_mode && (qidx == 0)) {
-		/* Enable checking L3/L4 length and TCP/UDP checksums */
+		/* Enable checking L3/L4 length and TCP/UDP checksums
+		 * Also allow IPv6 pkts with zero UDP checksum.
+		 */
 		nicvf_queue_reg_write(nic, NIC_QSET_RQ_GEN_CFG, 0,
-				      (BIT(24) | BIT(23) | BIT(21)));
+				      (BIT(24) | BIT(23) | BIT(21) | BIT(20)));
 		nicvf_config_vlan_stripping(nic, nic->netdev->features);
 	}
 
-- 
2.7.4
