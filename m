From: akpm@linux-foundation.org
Subject: [patch 4/8] drivers/net/chelsio/: #if 0 unused functions
Date: Wed, 21 Nov 2007 15:02:55 -0800
Message-ID: <200711212302.lALN2t6O013661@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60753 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754210AbXKUXDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:03:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>

This patch #if 0's the following unused functions:
- espi.c:t1_espi_set_misc_ctrl()
- sge.c:t1_sched_set_max_avail_bytes()
- sge.c:t1_sched_set_drain_bits_per_us()

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/chelsio/espi.c |    2 ++
 drivers/net/chelsio/espi.h |    1 -
 drivers/net/chelsio/sge.c  |    4 ++++
 drivers/net/chelsio/sge.h  |    2 --
 4 files changed, 6 insertions(+), 3 deletions(-)

diff -puN drivers/net/chelsio/espi.c~drivers-net-chelsio-if-0-unused-functions drivers/net/chelsio/espi.c
--- a/drivers/net/chelsio/espi.c~drivers-net-chelsio-if-0-unused-functions
+++ a/drivers/net/chelsio/espi.c
@@ -297,6 +297,7 @@ struct peespi *t1_espi_create(adapter_t 
 	return espi;
 }
 
+#if 0
 void t1_espi_set_misc_ctrl(adapter_t *adapter, u32 val)
 {
 	struct peespi *espi = adapter->espi;
@@ -309,6 +310,7 @@ void t1_espi_set_misc_ctrl(adapter_t *ad
 	writel(espi->misc_ctrl, adapter->regs + A_ESPI_MISC_CONTROL);
 	spin_unlock(&espi->lock);
 }
+#endif  /*  0  */
 
 u32 t1_espi_get_mon(adapter_t *adapter, u32 addr, u8 wait)
 {
diff -puN drivers/net/chelsio/espi.h~drivers-net-chelsio-if-0-unused-functions drivers/net/chelsio/espi.h
--- a/drivers/net/chelsio/espi.h~drivers-net-chelsio-if-0-unused-functions
+++ a/drivers/net/chelsio/espi.h
@@ -62,7 +62,6 @@ void t1_espi_intr_disable(struct peespi 
 int t1_espi_intr_handler(struct peespi *);
 const struct espi_intr_counts *t1_espi_get_intr_counts(struct peespi *espi);
 
-void t1_espi_set_misc_ctrl(adapter_t *adapter, u32 val);
 u32 t1_espi_get_mon(adapter_t *adapter, u32 addr, u8 wait);
 int t1_espi_get_mon_t204(adapter_t *, u32 *, u8);
 
diff -puN drivers/net/chelsio/sge.c~drivers-net-chelsio-if-0-unused-functions drivers/net/chelsio/sge.c
--- a/drivers/net/chelsio/sge.c~drivers-net-chelsio-if-0-unused-functions
+++ a/drivers/net/chelsio/sge.c
@@ -330,6 +330,8 @@ unsigned int t1_sched_update_parms(struc
 	return max_avail_segs * (p->mtu - 40);
 }
 
+#if 0
+
 /*
  * t1_sched_max_avail_bytes() tells the scheduler the maximum amount of
  * data that can be pushed per port.
@@ -357,6 +359,8 @@ void t1_sched_set_drain_bits_per_us(stru
 	t1_sched_update_parms(sge, port, 0, 0);
 }
 
+#endif  /*  0  */
+
 
 /*
  * get_clock() implements a ns clock (see ktime_get)
diff -puN drivers/net/chelsio/sge.h~drivers-net-chelsio-if-0-unused-functions drivers/net/chelsio/sge.h
--- a/drivers/net/chelsio/sge.h~drivers-net-chelsio-if-0-unused-functions
+++ a/drivers/net/chelsio/sge.h
@@ -89,8 +89,6 @@ void t1_sge_intr_disable(struct sge *);
 void t1_sge_intr_clear(struct sge *);
 const struct sge_intr_counts *t1_sge_get_intr_counts(const struct sge *sge);
 void t1_sge_get_port_stats(const struct sge *sge, int port, struct sge_port_stats *);
-void t1_sched_set_max_avail_bytes(struct sge *, unsigned int);
-void t1_sched_set_drain_bits_per_us(struct sge *, unsigned int, unsigned int);
 unsigned int t1_sched_update_parms(struct sge *, unsigned int, unsigned int,
 			   unsigned int);
 
_
