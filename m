From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next 4/4] hv_netvsc: hide warnings about
 uninitialized/missing rndis device
Date: Tue, 31 Oct 2017 14:42:04 +0100
Message-ID: <20171031134204.15287-5-vkuznets@redhat.com>
References: <20171031134204.15287-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 Stephen Hemminger <sthemmin@microsoft.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20171031134204.15287-1-vkuznets@redhat.com>
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
index 1c31e2b0216e..77cea50d0945 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -412,14 +412,14 @@ int rndis_filter_receive(struct net_device *ndev,
 
 	/* Make sure the rndis device state is initialized */
 	if (unlikely(!rndis_dev)) {
-		netif_err(net_device_ctx, rx_err, ndev,
+		netif_dbg(net_device_ctx, rx_err, ndev,
 			  "got rndis message but no rndis device!\n");
 		ret = NVSP_STAT_FAIL;
 		goto unlock;
 	}
 
 	if (unlikely(rndis_dev->state == RNDIS_DEV_UNINITIALIZED)) {
-		netif_err(net_device_ctx, rx_err, ndev,
+		netif_dbg(net_device_ctx, rx_err, ndev,
 			  "got rndis message uninitialized\n");
 		ret = NVSP_STAT_FAIL;
 		goto unlock;
-- 
2.13.6
