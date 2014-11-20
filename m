From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] macvtap: advance iov iterator when needed in macvtap_put_user()
Date: Thu, 20 Nov 2014 16:31:05 +0800
Message-ID: <1416472265-10151-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When mergeable buffer is used, vnet_hdr_sz is greater than sizeof struct
virtio_net_hdr. So we need advance the iov iterators in this case.

Fixes 6c36d2e26cda1ad3e2c4b90dd843825fc62fe5b4 ("macvtap: Use iovec iterators")
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index cea99d4..42a80d3 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -797,6 +797,8 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter) !=
 		    sizeof(vnet_hdr))
 			return -EFAULT;
+
+		iov_iter_advance(iter, vnet_hdr_len - sizeof(vnet_hdr));
 	}
 	total = vnet_hdr_len;
 	total += skb->len;
-- 
1.9.1
