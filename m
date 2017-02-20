From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 04/10] qed: Reserve doorbell BAR space for present CPUs
Date: Mon, 20 Feb 2017 22:43:33 +0200
Message-ID: <1487623419-6442-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46438 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751118AbdBTU7f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:59:35 -0500
In-Reply-To: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

Reserving doorbell BAR space according to the currently active CPUs
may result in a bug if disabled CPUs are later enabled but no
doorbell space was reserved for them.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 5ee7f04..d6c5a81 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -913,7 +913,7 @@ enum QED_ROCE_EDPM_MODE {
 		/* Either EDPM is mandatory, or we are attempting to allocate a
 		 * WID per CPU.
 		 */
-		n_cpus = num_active_cpus();
+		n_cpus = num_present_cpus();
 		rc = qed_hw_init_dpi_size(p_hwfn, p_ptt, pwm_regsize, n_cpus);
 	}
 
-- 
1.9.3
