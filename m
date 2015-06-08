From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] atm: use msecs_to_jiffies for conversions
Date: Mon,  8 Jun 2015 21:16:28 +0200
Message-ID: <1433790988-14635-1-git-send-email-hofrat@osadl.org>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Chas Williams <3chas3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:50144 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751955AbbFHTYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2015 15:24:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

API compliance scanning with coccinelle flagged:
./drivers/atm/iphase.c:2621:4-20:
        WARNING: timeout (50) seems HZ dependent

Numeric constants passed to schedule_timeout() make the effective
timeout HZ dependent which does not seem intended.
Fixed up by converting the constant to jiffies with msecs_to_jiffies()
As this driver was introduced in the early 2.3 series it is most 
likely assuming HZ=100 so the constant 50 is converted to 500ms.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was compile tested with i386_defconfig + CONFIG_ATM=y,
CONFIG_ATM_IA=m

Patch is against 4.1-rc6 (localversion-next is -next-20150605)

 drivers/atm/iphase.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 924f8e2..65e6590 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -2618,7 +2618,7 @@ static void ia_close(struct atm_vcc *vcc)
         if (vcc->qos.txtp.traffic_class != ATM_NONE) {
            iadev->close_pending++;
 	   prepare_to_wait(&iadev->timeout_wait, &wait, TASK_UNINTERRUPTIBLE);
-	   schedule_timeout(50);
+	   schedule_timeout(msecs_to_jiffies(500));
 	   finish_wait(&iadev->timeout_wait, &wait);
            spin_lock_irqsave(&iadev->tx_lock, flags); 
            while((skb = skb_dequeue(&iadev->tx_backlog))) {
-- 
1.7.10.4
