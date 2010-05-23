From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] net/irda: bfin_sir: IRDA is not affected by anomaly 05000230
Date: Sun, 23 May 2010 04:00:10 -0400
Message-ID: <1274601610-882-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Graf Yang <graf.yang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:50046 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751900Ab0EWH4j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 May 2010 03:56:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graf Yang <graf.yang@analog.com>

Anomaly 05000230 (over sampling of the UART STOP bit) applies only when
the peripheral is operating in UART mode.  So drop the anomaly handling
in the IRDA code.

Signed-off-by: Graf Yang <graf.yang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
Note: this is fine for 2.6.35 or 2.6.36

 drivers/net/irda/bfin_sir.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index 911c082..f940dfa 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -107,8 +107,12 @@ static int bfin_sir_set_speed(struct bfin_sir_port *port, int speed)
 	case 57600:
 	case 115200:
 
-		quot = (port->clk + (8 * speed)) / (16 * speed)\
-						- ANOMALY_05000230;
+		/*
+		 * IRDA is not affected by anomaly 05000230, so there is no
+		 * need to tweak the divisor like he UART driver (which will
+		 * slightly speed up the baud rate on us).
+		 */
+		quot = (port->clk + (8 * speed)) / (16 * speed);
 
 		do {
 			udelay(utime);
-- 
1.7.1

