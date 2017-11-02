From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 2/2] hv_netvsc: hide warnings about
 uninitialized/missing rndis device
Date: Thu,  2 Nov 2017 11:35:31 +0100
Message-ID: <20171102103531.5514-3-vkuznets@redhat.com>
References: <20171102103531.5514-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <sthemmin@microsoft.com>,
 Eric Dumazet <eric.dumazet@gmail.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20171102103531.5514-1-vkuznets@redhat.com>
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

Hyper-V hosts are known to send RNDIS messages even after we halt the
device in rndis_filter_halt_device(). Remove user visible messages
as they are not really useful.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/rndis_filter.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 0648eebda829..8b1242b8d8ef 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -407,13 +407,13 @@ int rndis_filter_receive(struct net_device *ndev,
 
 	/* Make sure the rndis device state is initialized */
 	if (unlikely(!rndis_dev)) {
-		netif_err(net_device_ctx, rx_err, ndev,
+		netif_dbg(net_device_ctx, rx_err, ndev,
 			  "got rndis message but no rndis device!\n");
 		return NVSP_STAT_FAIL;
 	}
 
 	if (unlikely(rndis_dev->state == RNDIS_DEV_UNINITIALIZED)) {
-		netif_err(net_device_ctx, rx_err, ndev,
+		netif_dbg(net_device_ctx, rx_err, ndev,
 			  "got rndis message uninitialized\n");
 		return NVSP_STAT_FAIL;
 	}
-- 
2.13.6
