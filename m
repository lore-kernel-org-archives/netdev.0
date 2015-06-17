From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v5 1/3] net/xen-netfront: Correct printf format in xennet_get_responses
Date: Wed, 17 Jun 2015 12:38:21 +0100
Message-ID: <1434541103-31114-2-git-send-email-julien.grall@citrix.com>
References: <1434541103-31114-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Julien Grall <julien.grall@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:15075 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932396AbbFQLjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 07:39:35 -0400
In-Reply-To: <1434541103-31114-1-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rx->status is an int16_t, print it using %d rather than %u in order to
have a meaningful value when the field is negative.

Also use %u rather than %x for rx->offset.

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: netdev@vger.kernel.org

---
    Changes in v4:
        - Use %u for the rx->offset because offset is unsigned

    Changes in v3:
        - Use %d for the rx->offset too.

    Changes in v2:
        - Add David's Reviewed-by
---
 drivers/net/xen-netfront.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e031c94..281720f 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -733,7 +733,7 @@ static int xennet_get_responses(struct netfront_queue *queue,
 		if (unlikely(rx->status < 0 ||
 			     rx->offset + rx->status > PAGE_SIZE)) {
 			if (net_ratelimit())
-				dev_warn(dev, "rx->offset: %x, size: %u\n",
+				dev_warn(dev, "rx->offset: %u, size: %d\n",
 					 rx->offset, rx->status);
 			xennet_move_rx_slot(queue, skb, ref);
 			err = -EINVAL;
-- 
2.1.4
