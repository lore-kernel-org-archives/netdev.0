From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 4/6] tg3: move functions related to reset_task together
Date: Fri, 16 Dec 2011 10:19:47 -0800
Message-ID: <9d22a13148f86998fb5766dd8d5249655937fb1d.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Cc: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Robin Getz <rgetz@blackfin.uclinux.org>,
	Matt Mackall <mpm@selenic.com>,
	David Decotigny <decot@googlers.com>
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f74.google.com ([209.85.213.74]:55154 "EHLO
	mail-yw0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760397Ab1LPSZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:25:43 -0500
Received: by mail-yw0-f74.google.com with SMTP id j51so537702yhj.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 10:25:43 -0800 (PST)
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This prepares next patches: simply move functions related to
reset_task close to its definition.



Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 9deb6a6..ecd6ea5 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -416,6 +416,7 @@ static const struct {
 
 static inline void tg3_full_lock(struct tg3 *tp, int irq_sync);
 static inline void tg3_full_unlock(struct tg3 *tp);
+static inline void tg3_reset_task_schedule(struct tg3 *tp);
 
 static void tg3_write32(struct tg3 *tp, u32 off, u32 val)
 {
@@ -6080,18 +6081,6 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 	return work_done;
 }
 
-static inline void tg3_reset_task_schedule(struct tg3 *tp)
-{
-	if (!test_and_set_bit(TG3_FLAG_RESET_TASK_PENDING, tp->tg3_flags))
-		schedule_work(&tp->reset_task);
-}
-
-static inline void tg3_reset_task_cancel(struct tg3 *tp)
-{
-	cancel_work_sync(&tp->reset_task);
-	tg3_flag_clear(tp, RESET_TASK_PENDING);
-}
-
 static int tg3_poll_msix(struct napi_struct *napi, int budget)
 {
 	struct tg3_napi *tnapi = container_of(napi, struct tg3_napi, napi);
@@ -6543,6 +6532,18 @@ out:
 	tg3_flag_clear(tp, RESET_TASK_PENDING);
 }
 
+static inline void tg3_reset_task_schedule(struct tg3 *tp)
+{
+	if (!test_and_set_bit(TG3_FLAG_RESET_TASK_PENDING, tp->tg3_flags))
+		schedule_work(&tp->reset_task);
+}
+
+static inline void tg3_reset_task_cancel(struct tg3 *tp)
+{
+	cancel_work_sync(&tp->reset_task);
+	tg3_flag_clear(tp, RESET_TASK_PENDING);
+}
+
 static void tg3_tx_timeout(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
-- 
1.7.3.1
