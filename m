From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc 3/3] tuntap: increase the max queues to 16
Date: Wed, 19 Jun 2013 13:40:52 +0800
Message-ID: <1371620452-49349-4-git-send-email-jasowang@redhat.com>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, edumazet@google.com, hkchu@google.com,
	mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since we've reduce the size of tun_struct and use flex array to allocate netdev
queues, it's safe for us to increase the limit of queues in tuntap.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8c5c124..205f6aa 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -110,10 +110,7 @@ struct tap_filter {
 	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
 };
 
-/* DEFAULT_MAX_NUM_RSS_QUEUES were choosed to let the rx/tx queues allocated for
- * the netdevice to be fit in one page. So we can make sure the success of
- * memory allocation. TODO: increase the limit. */
-#define MAX_TAP_QUEUES DEFAULT_MAX_NUM_RSS_QUEUES
+#define MAX_TAP_QUEUES 16
 #define MAX_TAP_FLOWS  4096
 
 #define TUN_FLOW_EXPIRE (3 * HZ)
-- 
1.7.1
