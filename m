From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hyperv: Add IPv6 into the hash computation for vRSS
Date: Thu, 30 Oct 2014 14:07:17 -0700
Message-ID: <1414703237-11510-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
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

This will allow the workload spreading via vRSS for IPv6.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c   |    4 +++-
 drivers/net/hyperv/rndis_filter.c |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 78ec33f..3295e4e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -193,7 +193,9 @@ static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
 	struct flow_keys flow;
 	int data_len;
 
-	if (!skb_flow_dissect(skb, &flow) || flow.n_proto != htons(ETH_P_IP))
+	if (!skb_flow_dissect(skb, &flow) ||
+	    !(flow.n_proto == htons(ETH_P_IP) ||
+	      flow.n_proto == htons(ETH_P_IPV6)))
 		return false;
 
 	if (flow.ip_proto == IPPROTO_TCP)
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 2b86f0b..ccce6f2 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -728,7 +728,8 @@ int rndis_filter_set_rss_param(struct rndis_device *rdev, int num_queue)
 	rssp->hdr.size = sizeof(struct ndis_recv_scale_param);
 	rssp->flag = 0;
 	rssp->hashinfo = NDIS_HASH_FUNC_TOEPLITZ | NDIS_HASH_IPV4 |
-			 NDIS_HASH_TCP_IPV4;
+			 NDIS_HASH_TCP_IPV4 | NDIS_HASH_IPV6 |
+			 NDIS_HASH_TCP_IPV6;
 	rssp->indirect_tabsize = 4*ITAB_NUM;
 	rssp->indirect_taboffset = sizeof(struct ndis_recv_scale_param);
 	rssp->hashkey_size = HASH_KEYLEN;
-- 
1.7.1
