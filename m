From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next 1/5] hv_netvsc: remove redundant assignment in netvsc_recv_callback()
Date: Mon, 23 May 2016 17:50:34 +0200
Message-ID: <1464018638-22000-2-git-send-email-vkuznets@redhat.com>
References: <1464018638-22000-1-git-send-email-vkuznets@redhat.com>
Cc: linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464018638-22000-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
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
