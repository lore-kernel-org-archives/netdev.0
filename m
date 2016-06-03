From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 1/5] hv_netvsc: remove redundant assignment in
 netvsc_recv_callback()
Date: Fri,  3 Jun 2016 17:50:58 +0200
Message-ID: <1464969062-22132-2-git-send-email-vkuznets@redhat.com>
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

net_device_ctx is assigned in the very beginning of the function and 'net'
pointer doesn't change.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 6a69b5c..db8fedf 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -701,7 +701,6 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 	}
 
 vf_injection_done:
-	net_device_ctx = netdev_priv(net);
 	rx_stats = this_cpu_ptr(net_device_ctx->rx_stats);
 
 	/* Allocate a skb - TODO direct I/O to pages? */
-- 
2.5.5
