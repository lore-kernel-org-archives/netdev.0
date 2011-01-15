From: Shreyas N Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next 1/8] vmxnet3: fix ring size update
Date: Fri, 14 Jan 2011 16:59:25 -0800
Message-ID: <20110115005925.1064.62053.stgit@sbhatewara-dev1.eng.vmware.com>
References: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, Dmitry Torokhov <dtor@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a bug while changing ring size when MTU is changed.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
Acked-by: Dmitry Torokhov <dtor@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index d143e8b..562bdbb 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2426,7 +2426,7 @@ vmxnet3_adjust_rx_ring_size(struct vmxnet3_adapter *adapter)
 	sz = adapter->rx_buf_per_pkt * VMXNET3_RING_SIZE_ALIGN;
 	ring0_size = adapter->rx_queue[0].rx_ring[0].size;
 	ring0_size = (ring0_size + sz - 1) / sz * sz;
-	ring0_size = min_t(u32, rq->rx_ring[0].size, VMXNET3_RX_RING_MAX_SIZE /
+	ring0_size = min_t(u32, ring0_size, VMXNET3_RX_RING_MAX_SIZE /
 			   sz * sz);
 	ring1_size = adapter->rx_queue[0].rx_ring[1].size;
 	comp_size = ring0_size + ring1_size;
