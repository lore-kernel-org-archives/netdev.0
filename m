From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH RFC] irda: condition with no effect
Date: Tue,  3 Feb 2015 13:34:18 -0500
Message-ID: <1422988458-29496-1-git-send-email-hofrat@osadl.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The if and the else branch code are identical - so the condition has no
effect on the effective code - this patch removes the condition and the
duplicated code.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

As the if and else is functionally identical they could probably be 
joined. From the comments it does seem that they might need to be
different cases - which could mean there is a bug here - someone that
knows the details of the drivers will need to check.

Joined the comments on the modes - which also might not be correct.

Note: this gives some warnings on CamelCase usage - but those are not
      related to the proposed changes.

Patch was only compile tested for x86_64_defconfig + CONFIG_IRDA=m
CONFIG_VIA_FIR=m

Patch is against 3.19.0-rc7 (localversion-next = -next-20150203)

 drivers/net/irda/via-ircc.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 6960d4c..4005306 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -595,15 +595,10 @@ static void via_ircc_change_dongle_speed(int iobase, int speed,
 		InvertTX(iobase, OFF);
 		InvertRX(iobase, OFF);
 		SlowIRRXLowActive(iobase, OFF);
-		if (IsSIROn(iobase)) {	//sir
-			EnGPIOtoRX2(iobase, OFF);
-			WriteGIO(iobase, OFF);
-			EnRX2(iobase, OFF);	//sir to rx2
-		} else {	// fir mir
-			EnGPIOtoRX2(iobase, OFF);
-			WriteGIO(iobase, OFF);
-			EnRX2(iobase, OFF);	//fir to rx
-		}
+		/* sir | fir | mir */
+		EnGPIOtoRX2(iobase, OFF);
+		WriteGIO(iobase, OFF);
+		EnRX2(iobase, OFF);
 		break;
 
 	case 0x11:		/* Temic TFDS4500 */
-- 
1.7.10.4
