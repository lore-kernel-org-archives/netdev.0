From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/5] bnx2x: Fix timesync endianity
Date: Mon, 25 Aug 2014 17:48:33 +0300
Message-ID: <1408978113-27902-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>,
	Michal Kalderon <Michal.Kalderon@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:20882 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932959AbaHYOtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:49:07 -0400
In-Reply-To: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <Michal.Kalderon@qlogic.com>

Commit eeed018cbfa30 ("bnx2x: Add timestamping and PTP hardware clock support")
has a missing conversion to LE32, which will prevent the feature from working
on big endian machines.

Signed-off-by: Michal Kalderon <Michal.Kalderon@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 798e97f..38acecd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -5877,8 +5877,10 @@ int bnx2x_func_send_set_timesync(struct bnx2x *bp,
 		set_timesync_params->add_sub_drift_adjust_value;
 	rdata->drift_adjust_value = set_timesync_params->drift_adjust_value;
 	rdata->drift_adjust_period = set_timesync_params->drift_adjust_period;
-	rdata->offset_delta.lo = U64_LO(set_timesync_params->offset_delta);
-	rdata->offset_delta.hi = U64_HI(set_timesync_params->offset_delta);
+	rdata->offset_delta.lo =
+		cpu_to_le32(U64_LO(set_timesync_params->offset_delta));
+	rdata->offset_delta.hi =
+		cpu_to_le32(U64_HI(set_timesync_params->offset_delta));
 
 	DP(BNX2X_MSG_SP, "Set timesync command params: drift_cmd = %d, offset_cmd = %d, add_sub_drift = %d, drift_val = %d, drift_period = %d, offset_lo = %d, offset_hi = %d\n",
 	   rdata->drift_adjust_cmd, rdata->offset_cmd,
-- 
1.8.3.1
