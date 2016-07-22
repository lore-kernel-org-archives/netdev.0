From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 9/9] staging: slicoss: simplify struct for statistics
Date: Fri, 22 Jul 2016 23:09:19 +0200
Message-ID: <1469221759-17652-10-git-send-email-LinoSanfilippo@gmx.de>
References: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Lino Sanfilippo <LinoSanfilippo@gmx.de>, linux-kernel@vger.kernel.org
To: liodot@gmail.com,
	charrer@alacritech.com,
	gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Merge several structures for statistics to one structure and remove
unnecessary union nesting.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/staging/slicoss/slic.h    | 18 +++++++++
 drivers/staging/slicoss/slichw.h  | 79 ---------------------------------------
 drivers/staging/slicoss/slicoss.c | 70 ++++++++++++++--------------------
 3 files changed, 47 insertions(+), 120 deletions(-)

diff --git a/drivers/staging/slicoss/slic.h b/drivers/staging/slicoss/slic.h
index 4ac1fd2..fe1d2ce 100644
--- a/drivers/staging/slicoss/slic.h
+++ b/drivers/staging/slicoss/slic.h
@@ -351,6 +351,24 @@ struct base_driver {
 	uint                 cardnuminuse[SLIC_MAX_CARDS];
 };
 
+struct slic_stats {
+	/* xmit stats */
+	u64 xmit_tcp_bytes;
+	u64 xmit_tcp_segs;
+	u64 xmit_bytes;
+	u64 xmit_collisions;
+	u64 xmit_unicasts;
+	u64 xmit_other_error;
+	u64 xmit_excess_collisions;
+	/* rcv stats */
+	u64 rcv_tcp_bytes;
+	u64 rcv_tcp_segs;
+	u64 rcv_bytes;
+	u64 rcv_unicasts;
+	u64 rcv_other_error;
+	u64 rcv_drops;
+};
+
 struct slic_shmem_data {
 	u32 isr;
 	u32 lnkstatus;
diff --git a/drivers/staging/slicoss/slichw.h b/drivers/staging/slicoss/slichw.h
index ae04bf6..49cb91a 100644
--- a/drivers/staging/slicoss/slichw.h
+++ b/drivers/staging/slicoss/slichw.h
@@ -459,85 +459,6 @@ struct slic_pnp_capabilities {
 	struct slicpm_wakeup_capabilities wakeup_capabilities;
 };
 
-struct xmt_stats {
-	u32 xmit_tcp_bytes;
-	u32 xmit_tcp_segs;
-	u32 xmit_bytes;
-	u32 xmit_collisions;
-	u32 xmit_unicasts;
-	u32 xmit_other_error;
-	u32 xmit_excess_collisions;
-};
-
-struct rcv_stats {
-	u32 rcv_tcp_bytes;
-	u32 rcv_tcp_segs;
-	u32 rcv_bytes;
-	u32 rcv_unicasts;
-	u32 rcv_other_error;
-	u32 rcv_drops;
-};
-
-struct xmt_statsgb {
-	u64 xmit_tcp_bytes;
-	u64 xmit_tcp_segs;
-	u64 xmit_bytes;
-	u64 xmit_collisions;
-	u64 xmit_unicasts;
-	u64 xmit_other_error;
-	u64 xmit_excess_collisions;
-};
-
-struct rcv_statsgb {
-	u64 rcv_tcp_bytes;
-	u64 rcv_tcp_segs;
-	u64 rcv_bytes;
-	u64 rcv_unicasts;
-	u64 rcv_other_error;
-	u64 rcv_drops;
-};
-
-struct slic_stats {
-	union {
-		struct {
-			struct xmt_stats xmt100;
-			struct rcv_stats rcv100;
-		} stats_100;
-		struct {
-			struct xmt_statsgb xmtGB;
-			struct rcv_statsgb rcvGB;
-		} stats_GB;
-	} u;
-};
-
-#define xmit_tcp_segs100		u.stats_100.xmt100.xmit_tcp_segs
-#define xmit_tcp_bytes100		u.stats_100.xmt100.xmit_tcp_bytes
-#define xmit_bytes100			u.stats_100.xmt100.xmit_bytes
-#define xmit_collisions100		u.stats_100.xmt100.xmit_collisions
-#define xmit_unicasts100		u.stats_100.xmt100.xmit_unicasts
-#define xmit_other_error100		u.stats_100.xmt100.xmit_other_error
-#define xmit_excess_collisions100	u.stats_100.xmt100.xmit_excess_collisions
-#define rcv_tcp_segs100			u.stats_100.rcv100.rcv_tcp_segs
-#define rcv_tcp_bytes100		u.stats_100.rcv100.rcv_tcp_bytes
-#define rcv_bytes100			u.stats_100.rcv100.rcv_bytes
-#define rcv_unicasts100			u.stats_100.rcv100.rcv_unicasts
-#define rcv_other_error100		u.stats_100.rcv100.rcv_other_error
-#define rcv_drops100			u.stats_100.rcv100.rcv_drops
-#define xmit_tcp_segs_gb		u.stats_GB.xmtGB.xmit_tcp_segs
-#define xmit_tcp_bytes_gb		u.stats_GB.xmtGB.xmit_tcp_bytes
-#define xmit_bytes_gb			u.stats_GB.xmtGB.xmit_bytes
-#define xmit_collisions_gb		u.stats_GB.xmtGB.xmit_collisions
-#define xmit_unicasts_gb		u.stats_GB.xmtGB.xmit_unicasts
-#define xmit_other_error_gb		u.stats_GB.xmtGB.xmit_other_error
-#define xmit_excess_collisions_gb	u.stats_GB.xmtGB.xmit_excess_collisions
-
-#define rcv_tcp_segs_gb			u.stats_GB.rcvGB.rcv_tcp_segs
-#define rcv_tcp_bytes_gb		u.stats_GB.rcvGB.rcv_tcp_bytes
-#define rcv_bytes_gb			u.stats_GB.rcvGB.rcv_bytes
-#define rcv_unicasts_gb			u.stats_GB.rcvGB.rcv_unicasts
-#define rcv_other_error_gb		u.stats_GB.rcvGB.rcv_other_error
-#define rcv_drops_gb			u.stats_GB.rcvGB.rcv_drops
-
 struct slic_config_mac {
 	u8 macaddrA[6];
 };
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 9a8c6f9..7834bda 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -1015,61 +1015,49 @@ static void slic_upr_request_complete(struct adapter *adapter, u32 isr)
 			break;
 		}
 
-		UPDATE_STATS_GB(stst->tcp.xmit_tcp_segs,
-				stats->xmit_tcp_segs_gb,
-				old->xmit_tcp_segs_gb);
+		UPDATE_STATS_GB(stst->tcp.xmit_tcp_segs, stats->xmit_tcp_segs,
+				old->xmit_tcp_segs);
 
-		UPDATE_STATS_GB(stst->tcp.xmit_tcp_bytes,
-				stats->xmit_tcp_bytes_gb,
-				old->xmit_tcp_bytes_gb);
+		UPDATE_STATS_GB(stst->tcp.xmit_tcp_bytes, stats->xmit_tcp_bytes,
+				old->xmit_tcp_bytes);
 
-		UPDATE_STATS_GB(stst->tcp.rcv_tcp_segs,
-				stats->rcv_tcp_segs_gb,
-				old->rcv_tcp_segs_gb);
+		UPDATE_STATS_GB(stst->tcp.rcv_tcp_segs, stats->rcv_tcp_segs,
+				old->rcv_tcp_segs);
 
-		UPDATE_STATS_GB(stst->tcp.rcv_tcp_bytes,
-				stats->rcv_tcp_bytes_gb,
-				old->rcv_tcp_bytes_gb);
+		UPDATE_STATS_GB(stst->tcp.rcv_tcp_bytes, stats->rcv_tcp_bytes,
+				old->rcv_tcp_bytes);
 
-		UPDATE_STATS_GB(stst->iface.xmt_bytes,
-				stats->xmit_bytes_gb,
-				old->xmit_bytes_gb);
+		UPDATE_STATS_GB(stst->iface.xmt_bytes, stats->xmit_bytes,
+				old->xmit_bytes);
 
-		UPDATE_STATS_GB(stst->iface.xmt_ucast,
-				stats->xmit_unicasts_gb,
-				old->xmit_unicasts_gb);
+		UPDATE_STATS_GB(stst->iface.xmt_ucast, stats->xmit_unicasts,
+				old->xmit_unicasts);
 
-		UPDATE_STATS_GB(stst->iface.rcv_bytes,
-				stats->rcv_bytes_gb,
-				old->rcv_bytes_gb);
+		UPDATE_STATS_GB(stst->iface.rcv_bytes, stats->rcv_bytes,
+				old->rcv_bytes);
 
-		UPDATE_STATS_GB(stst->iface.rcv_ucast,
-				stats->rcv_unicasts_gb,
-				old->rcv_unicasts_gb);
+		UPDATE_STATS_GB(stst->iface.rcv_ucast, stats->rcv_unicasts,
+				old->rcv_unicasts);
 
-		UPDATE_STATS_GB(stst->iface.xmt_errors,
-				stats->xmit_collisions_gb,
-				old->xmit_collisions_gb);
+		UPDATE_STATS_GB(stst->iface.xmt_errors, stats->xmit_collisions,
+				old->xmit_collisions);
 
 		UPDATE_STATS_GB(stst->iface.xmt_errors,
-				stats->xmit_excess_collisions_gb,
-				old->xmit_excess_collisions_gb);
+				stats->xmit_excess_collisions,
+				old->xmit_excess_collisions);
 
-		UPDATE_STATS_GB(stst->iface.xmt_errors,
-				stats->xmit_other_error_gb,
-				old->xmit_other_error_gb);
+		UPDATE_STATS_GB(stst->iface.xmt_errors, stats->xmit_other_error,
+				old->xmit_other_error);
 
-		UPDATE_STATS_GB(stst->iface.rcv_errors,
-				stats->rcv_other_error_gb,
-				old->rcv_other_error_gb);
+		UPDATE_STATS_GB(stst->iface.rcv_errors, stats->rcv_other_error,
+				old->rcv_other_error);
 
-		UPDATE_STATS_GB(stst->iface.rcv_discards,
-				stats->rcv_drops_gb,
-				old->rcv_drops_gb);
+		UPDATE_STATS_GB(stst->iface.rcv_discards, stats->rcv_drops,
+				old->rcv_drops);
 
-		if (stats->rcv_drops_gb > old->rcv_drops_gb)
-			adapter->rcv_drops += (stats->rcv_drops_gb -
-					       old->rcv_drops_gb);
+		if (stats->rcv_drops > old->rcv_drops)
+			adapter->rcv_drops += (stats->rcv_drops -
+					       old->rcv_drops);
 		memcpy_fromio(old, stats, sizeof(*stats));
 		break;
 	}
-- 
1.9.1
