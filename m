From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] hyperv: fix sparse warnings
Date: Thu,  5 Feb 2015 15:06:33 +0000
Message-ID: <1423148793-19610-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
 linux-kernel@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>,
 Haiyang Zhang <haiyangz@microsoft.com>, devel@linuxdriverproject.org
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

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warnings:

netvsc.c:688:5: warning: symbol 'netvsc_copy_to_send_buf' was not declared. Should it be static?
rndis_filter.c:627:5: warning: symbol 'rndis_filter_set_offload_params' was not declared. Should it be static?
rndis_filter.c:702:5: warning: symbol 'rndis_filter_set_rss_param' was not declared. Should it be static?

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.9.2,
 sparse version  0.4.5-rc1) and applies on top linux-next.

 drivers/net/hyperv/netvsc.c       | 6 +++---
 drivers/net/hyperv/rndis_filter.c | 5 +++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 58bb410..208eb05 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -685,9 +685,9 @@ static u32 netvsc_get_next_send_section(struct netvsc_device *net_device)
 	return ret_val;
 }
 
-u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
-			    unsigned int section_index,
-			    struct hv_netvsc_packet *packet)
+static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
+				   unsigned int section_index,
+				   struct hv_netvsc_packet *packet)
 {
 	char *start = net_device->send_buf;
 	char *dest = (start + (section_index * net_device->send_section_size));
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 7bd8387..7816d98 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -624,7 +624,8 @@ cleanup:
 	return ret;
 }
 
-int rndis_filter_set_offload_params(struct hv_device *hdev,
+static int
+rndis_filter_set_offload_params(struct hv_device *hdev,
 				struct ndis_offload_params *req_offloads)
 {
 	struct netvsc_device *nvdev = hv_get_drvdata(hdev);
@@ -699,7 +700,7 @@ u8 netvsc_hash_key[HASH_KEYLEN] = {
 	0x6a, 0x42, 0xb7, 0x3b, 0xbe, 0xac, 0x01, 0xfa
 };
 
-int rndis_filter_set_rss_param(struct rndis_device *rdev, int num_queue)
+static int rndis_filter_set_rss_param(struct rndis_device *rdev, int num_queue)
 {
 	struct net_device *ndev = rdev->net_dev->ndev;
 	struct rndis_request *request;
-- 
1.9.1
