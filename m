From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] drivers/net/chelsio/: #if 0 unused functions
Date: Fri, 2 Nov 2007 16:43:32 +0100
Message-ID: <20071102154332.GL30287@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:49697 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757158AbXKBPnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 11:43:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch #if 0's the following unused functions:
- espi.c:t1_espi_set_misc_ctrl()
- sge.c:t1_sched_set_max_avail_bytes()
- sge.c:t1_sched_set_drain_bits_per_us()

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/chelsio/espi.c |    2 ++
 drivers/net/chelsio/espi.h |    1 -
 drivers/net/chelsio/sge.c  |    4 ++++
 drivers/net/chelsio/sge.h  |    2 --
 4 files changed, 6 insertions(+), 3 deletions(-)

21c8ac8bf68a9ca84d7548003294535484140b59 
diff --git a/drivers/net/chelsio/espi.c b/drivers/net/chelsio/espi.c
index d7c5406..1e0749e 100644
--- a/drivers/net/chelsio/espi.c
+++ b/drivers/net/chelsio/espi.c
@@ -297,6 +297,7 @@ struct peespi *t1_espi_create(adapter_t *adapter)
 	return espi;
 }
 
+#if 0
 void t1_espi_set_misc_ctrl(adapter_t *adapter, u32 val)
 {
 	struct peespi *espi = adapter->espi;
@@ -309,6 +310,7 @@ void t1_espi_set_misc_ctrl(adapter_t *adapter, u32 val)
 	writel(espi->misc_ctrl, adapter->regs + A_ESPI_MISC_CONTROL);
 	spin_unlock(&espi->lock);
 }
+#endif  /*  0  */
 
 u32 t1_espi_get_mon(adapter_t *adapter, u32 addr, u8 wait)
 {
diff --git a/drivers/net/chelsio/espi.h b/drivers/net/chelsio/espi.h
index 84f2c98..5694aad 100644
--- a/drivers/net/chelsio/espi.h
+++ b/drivers/net/chelsio/espi.h
@@ -62,7 +62,6 @@ void t1_espi_intr_disable(struct peespi *);
 int t1_espi_intr_handler(struct peespi *);
 const struct espi_intr_counts *t1_espi_get_intr_counts(struct peespi *espi);
 
-void t1_espi_set_misc_ctrl(adapter_t *adapter, u32 val);
 u32 t1_espi_get_mon(adapter_t *adapter, u32 addr, u8 wait);
 int t1_espi_get_mon_t204(adapter_t *, u32 *, u8);
 
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index ffa7e64..e3668d7 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -330,6 +330,8 @@ unsigned int t1_sched_update_parms(struct sge *sge, unsigned int port,
 	return max_avail_segs * (p->mtu - 40);
 }
 
+#if 0
+
 /*
  * t1_sched_max_avail_bytes() tells the scheduler the maximum amount of
  * data that can be pushed per port.
@@ -357,6 +359,8 @@ void t1_sched_set_drain_bits_per_us(struct sge *sge, unsigned int port,
 	t1_sched_update_parms(sge, port, 0, 0);
 }
 
+#endif  /*  0  */
+
 
 /*
  * get_clock() implements a ns clock (see ktime_get)
diff --git a/drivers/net/chelsio/sge.h b/drivers/net/chelsio/sge.h
index 713d9c5..e1cbded 100644
--- a/drivers/net/chelsio/sge.h
+++ b/drivers/net/chelsio/sge.h
@@ -89,8 +89,6 @@ void t1_sge_intr_disable(struct sge *);
 void t1_sge_intr_clear(struct sge *);
 const struct sge_intr_counts *t1_sge_get_intr_counts(const struct sge *sge);
 void t1_sge_get_port_stats(const struct sge *sge, int port, struct sge_port_stats *);
-void t1_sched_set_max_avail_bytes(struct sge *, unsigned int);
-void t1_sched_set_drain_bits_per_us(struct sge *, unsigned int, unsigned int);
 unsigned int t1_sched_update_parms(struct sge *, unsigned int, unsigned int,
 			   unsigned int);
 

