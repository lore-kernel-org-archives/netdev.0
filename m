From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 5/5] hv_netvsc: pass struct net_device to
 rndis_filter_set_offload_params()
Date: Fri,  3 Jun 2016 17:51:02 +0200
Message-ID: <1464969062-22132-6-git-send-email-vkuznets@redhat.com>
References: <1464969062-22132-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1464969062-22132-1-git-send-email-vkuznets@redhat.com>
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

The only caller rndis_filter_device_add() has 'struct net_device' pointer
already.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/rndis_filter.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index f1692bc..979fa44 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -620,10 +620,9 @@ cleanup:
 }
 
 static int
-rndis_filter_set_offload_params(struct hv_device *hdev,
+rndis_filter_set_offload_params(struct net_device *ndev,
 				struct ndis_offload_params *req_offloads)
 {
-	struct net_device *ndev = hv_get_drvdata(hdev);
 	struct netvsc_device *nvdev = net_device_to_netvsc_device(ndev);
 	struct rndis_device *rdev = nvdev->extension;
 	struct rndis_request *request;
@@ -1083,7 +1082,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	offloads.lso_v2_ipv4 = NDIS_OFFLOAD_PARAMETERS_LSOV2_ENABLED;
 
 
-	ret = rndis_filter_set_offload_params(dev, &offloads);
+	ret = rndis_filter_set_offload_params(net, &offloads);
 	if (ret)
 		goto err_dev_remv;
 
-- 
2.5.5
