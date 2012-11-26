From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: fix length for cross region descriptor
Date: Mon, 26 Nov 2012 17:57:27 +0200
Message-ID: <20121126155727.GA21716@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a single descriptor crosses a region, the
second chunk length should be decremented
by size translated so far, instead it includes
the full descriptor length.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index ef8f598..5a3d0f1 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1049,7 +1049,7 @@ static int translate_desc(struct vhost_dev *dev, u64 addr, u32 len,
 		}
 		_iov = iov + ret;
 		size = reg->memory_size - addr + reg->guest_phys_addr;
-		_iov->iov_len = min((u64)len, size);
+		_iov->iov_len = min((u64)len - s, size);
 		_iov->iov_base = (void __user *)(unsigned long)
 			(reg->userspace_addr + addr - reg->guest_phys_addr);
 		s += size;
-- 
MST
