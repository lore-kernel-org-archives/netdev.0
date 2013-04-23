From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net] gianfar: do not advertise any alarm capability.
Date: Tue, 23 Apr 2013 07:42:16 +0200
Message-ID: <16ea6333aec82761aa7e2207b53cfbad85e9245b.1366695641.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>, <stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An early draft of the PHC patch series included an alarm in the
gianfar driver. During the review process, the alarm code was dropped,
but the capability removal was overlooked. This patch fixes the issue
by advertising zero alarms.

This patch should be applied to every 3.x stable kernel.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Reported-by: Chris LaRocque <clarocq@gmail.com>
Cc: <stable@vger.kernel.org>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 2e5daee..a3f8a25 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -127,7 +127,6 @@ struct gianfar_ptp_registers {
 
 #define DRIVER		"gianfar_ptp"
 #define DEFAULT_CKSEL	1
-#define N_ALARM		1 /* first alarm is used internally to reset fipers */
 #define N_EXT_TS	2
 #define REG_SIZE	sizeof(struct gianfar_ptp_registers)
 
@@ -410,7 +409,7 @@ static struct ptp_clock_info ptp_gianfar_caps = {
 	.owner		= THIS_MODULE,
 	.name		= "gianfar clock",
 	.max_adj	= 512000,
-	.n_alarm	= N_ALARM,
+	.n_alarm	= 0,
 	.n_ext_ts	= N_EXT_TS,
 	.n_per_out	= 0,
 	.pps		= 1,
-- 
1.7.2.5
