From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 04/10] qed: Reserve doorbell BAR space for present CPUs
Date: Sun, 19 Feb 2017 15:26:17 +0200
Message-ID: <1487510783-19919-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54335 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751864AbdBSN0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 08:26:46 -0500
In-Reply-To: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
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
index 3b22500..993df15 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -873,7 +873,7 @@ enum QED_ROCE_EDPM_MODE {
 		/* Either EDPM is mandatory, or we are attempting to allocate a
 		 * WID per CPU.
 		 */
-		n_cpus = num_active_cpus();
+		n_cpus = num_present_cpus();
 		rc = qed_hw_init_dpi_size(p_hwfn, p_ptt, pwm_regsize, n_cpus);
 	}
 
-- 
1.9.3
