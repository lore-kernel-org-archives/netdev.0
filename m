From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Subject: [PATCH V4 net-next 5/5] xen-net{back,
	front}: Document multi-queue feature in netif.h
Date: Mon, 17 Feb 2014 17:58:00 +0000
Message-ID: <1392659880-2538-6-git-send-email-andrew.bennieston@citrix.com>
References: <1392659880-2538-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	paul.durrant@citrix.com, david.vrabel@citrix.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: <xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1392659880-2538-1-git-send-email-andrew.bennieston@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>

Document the multi-queue feature in terms of XenStore keys to be written
by the backend and by the frontend.

Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
---
 include/xen/interface/io/netif.h |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
index c50061d..8868c51 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -51,6 +51,27 @@
  */
 
 /*
+ * Multiple transmit and receive queues:
+ * If supported, the backend will write "multi-queue-max-queues" and set its
+ * value to the maximum supported number of queues.
+ * Frontends that are aware of this feature and wish to use it can write the
+ * key "multi-queue-num-queues", set to the number they wish to use.
+ *
+ * Queues replicate the shared rings and event channels, and
+ * "feature-split-event-channels" is required when using multiple queues.
+ *
+ * For frontends requesting just one queue, the usual event-channel and
+ * ring-ref keys are written as before, simplifying the backend processing
+ * to avoid distinguishing between a frontend that doesn't understand the
+ * multi-queue feature, and one that does, but requested only one queue.
+ *
+ * Frontends requesting two or more queues must not write the toplevel
+ * event-channel and ring-ref keys, instead writing them under sub-keys having
+ * the name "queue-N" where N is the integer ID of the queue for which those
+ * keys belong. Queues are indexed from zero.
+ */
+
+/*
  * "feature-no-csum-offload" should be used to turn IPv4 TCP/UDP checksum
  * offload off or on. If it is missing then the feature is assumed to be on.
  * "feature-ipv6-csum-offload" should be used to turn IPv6 TCP/UDP checksum
-- 
1.7.10.4
