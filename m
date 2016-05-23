From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next 5/5] hv_netvsc: pass struct net_device to rndis_filter_set_offload_params()
Date: Mon, 23 May 2016 17:50:38 +0200
Message-ID: <1464018638-22000-6-git-send-email-vkuznets@redhat.com>
References: <1464018638-22000-1-git-send-email-vkuznets@redhat.com>
Cc: linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464018638-22000-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
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
