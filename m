From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC 4/4] tuntap: Increase the number of queues in tun
Date: Mon, 18 Aug 2014 19:07:20 +0530
Message-ID: <1408369040-1216-5-git-send-email-pagupta@redhat.com>
References: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com, wuzhy@linux.vnet.ibm.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, Pankaj Gupta <pagupta@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Networking under kvm works best if we allocate a per-vCPU RX and TX
queue in a virtual NIC. This requires a per-vCPU queue on the host side.

It is now safe to increase the maximum number of queues.
Preceding patches:
	net: allow large number of rx queues
  	tuntap: Reduce the size of tun_struct by using flex array
	tuntap: Publish tuntap max queue length as module_param

	made sure this won't cause failures due to high order memory
allocations. Increase it to 256: this is the max number of vCPUs
KVM supports.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 drivers/net/tun.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 98bad1f..893eba8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -111,10 +111,11 @@ struct tap_filter {
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
