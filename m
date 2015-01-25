From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH v2] hyperv: match wait_for_completion_timeout return type
Date: Sun, 25 Jan 2015 15:48:23 +0100
Message-ID: <1422197303-8035-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 Nicholas Mc Guire <der.herr@hofr.at>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>
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

return type of wait_for_completion_timeout is unsigned long not int, this
patch just fixes up the declarations.

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---

v2: fixed subject line

The return type of wait_for_completion_timeout is unsigned long not
int. This patch fixes up the declarations only.

Patch was compile tested only for x86_64_defconfig + CONFIG_X86_VSMP=y
CONFIG_HYPERV=m, CONFIG_HYPERV_NET=m

Patch is against 3.19.0-rc5 -next-20150123

 drivers/net/hyperv/rndis_filter.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index ec0c40a..7bd8387 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -470,7 +470,7 @@ static int rndis_filter_query_device(struct rndis_device *dev, u32 oid,
 	struct rndis_query_request *query;
 	struct rndis_query_complete *query_complete;
 	int ret = 0;
-	int t;
+	unsigned long t;
 
 	if (!result)
 		return -EINVAL;
@@ -560,7 +560,8 @@ int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac)
 	char macstr[2*ETH_ALEN+1];
 	u32 extlen = sizeof(struct rndis_config_parameter_info) +
 		2*NWADR_STRLEN + 4*ETH_ALEN;
-	int ret, t;
+	int ret;
+	unsigned long t;
 
 	request = get_rndis_request(rdev, RNDIS_MSG_SET,
 		RNDIS_MESSAGE_SIZE(struct rndis_set_request) + extlen);
@@ -634,7 +635,8 @@ int rndis_filter_set_offload_params(struct hv_device *hdev,
 	struct ndis_offload_params *offload_params;
 	struct rndis_set_complete *set_complete;
 	u32 extlen = sizeof(struct ndis_offload_params);
-	int ret, t;
+	int ret;
+	unsigned long t;
 	u32 vsp_version = nvdev->nvsp_version;
 
 	if (vsp_version <= NVSP_PROTOCOL_VERSION_4) {
@@ -708,7 +710,8 @@ int rndis_filter_set_rss_param(struct rndis_device *rdev, int num_queue)
 	struct ndis_recv_scale_param *rssp;
 	u32 *itab;
 	u8 *keyp;
-	int i, t, ret;
+	int i, ret;
+	unsigned long t;
 
 	request = get_rndis_request(
 			rdev, RNDIS_MSG_SET,
@@ -792,7 +795,8 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 	struct rndis_set_request *set;
 	struct rndis_set_complete *set_complete;
 	u32 status;
-	int ret, t;
+	int ret;
+	unsigned long t;
 	struct net_device *ndev;
 
 	ndev = dev->net_dev->ndev;
@@ -848,7 +852,8 @@ static int rndis_filter_init_device(struct rndis_device *dev)
 	struct rndis_initialize_request *init;
 	struct rndis_initialize_complete *init_complete;
 	u32 status;
-	int ret, t;
+	int ret;
+	unsigned long t;
 
 	request = get_rndis_request(dev, RNDIS_MSG_INIT,
 			RNDIS_MESSAGE_SIZE(struct rndis_initialize_request));
@@ -998,7 +1003,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	struct netvsc_device_info *device_info = additional_info;
 	struct ndis_offload_params offloads;
 	struct nvsp_message *init_packet;
-	int t;
+	unsigned long t;
 	struct ndis_recv_scale_cap rsscap;
 	u32 rsscap_size = sizeof(struct ndis_recv_scale_cap);
 	u32 mtu, size;
-- 
1.7.10.4
