From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net 1/3] net: dp83640: fix broken calibration routine.
Date: Mon, 25 May 2015 11:55:43 +0200
Message-ID: <4b0f18351beba1c2a240dfce0f4347ba3cad50ea.1432547381.git.richardcochran@gmail.com>
References: <cover.1432547381.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Christian Riesch <christian.riesch@omicron.at>,
	Stefan Sorensen <stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35832 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbEYJzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 05:55:51 -0400
Received: by wicmx19 with SMTP id mx19so43175426wic.0
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 02:55:50 -0700 (PDT)
In-Reply-To: <cover.1432547381.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the calibration function that corrects the initial offsets
among multiple devices only works the first time.  If the function is
called more than once, the calibration fails and bogus offsets will be
programmed into the devices.

In a well hidden spot, the device documentation tells that trigger indexes
0 and 1 are special in allowing the TRIG_IF_LATE flag to actually work.

This patch fixes the issue by using one of the special triggers during the
recalibration method.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 496e02f..7a068d9 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -47,7 +47,7 @@
 #define PSF_TX		0x1000
 #define EXT_EVENT	1
 #define CAL_EVENT	7
-#define CAL_TRIGGER	7
+#define CAL_TRIGGER	1
 #define DP83640_N_PINS	12
 
 #define MII_DP83640_MICR 0x11
-- 
2.1.4
