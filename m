From: Pankaj Gupta <pagupta@redhat.com>
Subject: [PATCH v2 net-next 3/3] tuntap: Increase the number of queues in tun.
Date: Tue, 25 Nov 2014 00:04:10 +0530
Message-ID: <1416854050-10165-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, dgibson@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei.shtylyov@cogentembedded.com, pagupta@redhat.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Networking under kvm works best if we allocate a per-vCPU RX and TX
queue in a virtual NIC. This requires a per-vCPU queue on the host side.

It is now safe to increase the maximum number of queues.
Preceding patches:
        net: allow large number of rx queues
        tuntap: Reduce the size of tun_struct by using flex array

        made sure this won't cause failures due to high order memory
allocations. Increase it to 256: this is the max number of vCPUs
KVM supports.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
Reviewed-by: David Gibson <dgibson@redhat.com>
---
 drivers/net/tun.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e3fa65a..a19dc5f8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -113,10 +113,11 @@ struct tap_filter {
 	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
 };
 
-/* DEFAULT_MAX_NUM_RSS_QUEUES were chosen to let the rx/tx queues allocated for
- * the netdevice to be fit in one page. So we can make sure the success of
- * memory allocation. TODO: increase the limit. */
-#define MAX_TAP_QUEUES DEFAULT_MAX_NUM_RSS_QUEUES
+/* MAX_TAP_QUEUES 256 is chosen to allow rx/tx queues to be equal
+ * to max number of vCPUS in guest. Also, we are making sure here
+ * queue memory allocation do not fail.
+ */
+#define MAX_TAP_QUEUES 256
 #define MAX_TAP_FLOWS  4096
 
 #define TUN_FLOW_EXPIRE (3 * HZ)
-- 
1.8.3.1
