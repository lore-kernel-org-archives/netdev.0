From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v3 1/2] net/xen-netfront: Correct printf format in xennet_get_responses
Date: Thu, 4 Jun 2015 16:35:13 +0100
Message-ID: <1433432114-22198-2-git-send-email-julien.grall@citrix.com>
References: <1433432114-22198-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Julien Grall <julien.grall@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433432114-22198-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rx->status is an int16_t, print it using %d rather than %u in order to
have a meaningful value when the field is negative.

Also use %d rather than %x for rx->offset.

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: netdev@vger.kernel.org

---
    Changes in v3:
        - Use %d for the rx-offset too.

    Changes in v2:
        - Add David's Reviewed-by
---
 drivers/net/xen-netfront.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e031c94..3c1ca8b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -733,7 +733,7 @@ static int xennet_get_responses(struct netfront_queue *queue,
 		if (unlikely(rx->status < 0 ||
 			     rx->offset + rx->status > PAGE_SIZE)) {
 			if (net_ratelimit())
-				dev_warn(dev, "rx->offset: %x, size: %u\n",
+				dev_warn(dev, "rx->offset: %d, size: %d\n",
 					 rx->offset, rx->status);
 			xennet_move_rx_slot(queue, skb, ref);
 			err = -EINVAL;
-- 
2.1.4
