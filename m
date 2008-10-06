From: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] net: define feature flags for FCoE offloads
Date: Mon, 06 Oct 2008 15:09:26 -0700
Message-ID: <20081006220926.3308.48505.stgit@zyfc9ini.jf.intel.com>
References: <20081006220524.3308.64889.stgit@zyfc9ini.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <20081006220524.3308.64889.stgit-23BaheqE+Bznoz6Kjl9f4RL4W9x8LtSr@public.gmane.org>
List-Unsubscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Chris Leech <christopher.leech-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Signed-off-by: Chris Leech <christopher.leech-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---

 include/linux/netdevice.h |    3 +++
 include/linux/skbuff.h    |    2 ++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9cfd20b..ef65927 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -522,6 +522,8 @@ struct net_device
 #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
 #define NETIF_F_LRO		32768	/* large receive offload */
 
+#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
+
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
 #define NETIF_F_GSO_MASK	0xffff0000
@@ -530,6 +532,7 @@ struct net_device
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
 #define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
 #define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_GSO_FCOE	(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
 
 	/* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 720b688..be60560 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -188,6 +188,8 @@ enum {
 	SKB_GSO_TCP_ECN = 1 << 3,
 
 	SKB_GSO_TCPV6 = 1 << 4,
+
+	SKB_GSO_FCOE = 1 << 5,
 };
 
 #if BITS_PER_LONG > 32
