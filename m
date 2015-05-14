From: Julien Grall <julien.grall@citrix.com>
Subject: [RFC 07/23] net/xen-netfront: Correct printf format in
	xennet_get_responses
Date: Thu, 14 May 2015 18:00:47 +0100
Message-ID: <1431622863-28575-8-git-send-email-julien.grall@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com,
	netdev@vger.kernel.org, tim@xen.org, linux-kernel@vger.kernel.org,
	Julien Grall <julien.grall@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	linux-arm-kernel@lists.infradead.org
To: <xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

rx->status is an int16_t, print it using %d rather than %u in order to
have a meaningful value when the field is negative.

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/xen-netfront.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index ff88f31..381d38f 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -732,7 +732,7 @@ static int xennet_get_responses(struct netfront_queue *queue,
 		if (unlikely(rx->status < 0 ||
 			     rx->offset + rx->status > PAGE_SIZE)) {
 			if (net_ratelimit())
-				dev_warn(dev, "rx->offset: %x, size: %u\n",
+				dev_warn(dev, "rx->offset: %x, size: %d\n",
 					 rx->offset, rx->status);
 			xennet_move_rx_slot(queue, skb, ref);
 			err = -EINVAL;
-- 
2.1.4
