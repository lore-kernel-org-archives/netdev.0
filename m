From: Jerry Snitselaar <jsnitsel@redhat.com>
Subject: [PATCH] hv_netvsc: remove unused variable in netvsc_send()
Date: Mon,  4 May 2015 10:57:16 -0700
Message-ID: <1430762236-18660-1-git-send-email-jsnitsel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Haiyang Zhang <haiyangz@microsoft.com>,
 devel@linuxdriverproject.org
To: linux-kernel@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

With commit b56fc3c53654 ("hv_netvsc: Fix a bug in netvsc_start_xmit()"),
skb variable is no longer used in netvsc_send. Remove variable and dead
code that depended on it.

Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: K. Y. Srinivasan <kys@microsoft.com>
Signed-off-by: Jerry Snitselaar <jsnitsel@redhat.com>
---
 drivers/net/hyperv/netvsc.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 2d9ef53..ea091bc 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -826,7 +826,6 @@ int netvsc_send(struct hv_device *device,
 	u16 q_idx = packet->q_idx;
 	u32 pktlen = packet->total_data_buflen, msd_len = 0;
 	unsigned int section_index = NETVSC_INVALID_INDEX;
-	struct sk_buff *skb = NULL;
 	unsigned long flag;
 	struct multi_send_data *msdp;
 	struct hv_netvsc_packet *msd_send = NULL, *cur_send = NULL;
@@ -924,12 +923,8 @@ int netvsc_send(struct hv_device *device,
 	if (cur_send)
 		ret = netvsc_send_pkt(cur_send, net_device);
 
-	if (ret != 0) {
-		if (section_index != NETVSC_INVALID_INDEX)
-			netvsc_free_send_slot(net_device, section_index);
-	} else if (skb) {
-		dev_kfree_skb_any(skb);
-	}
+	if (ret != 0 && section_index != NETVSC_INVALID_INDEX)
+		netvsc_free_send_slot(net_device, section_index);
 
 	return ret;
 }
-- 
2.4.0.rc3.3.g6eb1401
