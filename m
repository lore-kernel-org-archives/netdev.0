From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] via-velocity: FLOW_CNTL_RX does not disable Asymmetric pause
 in set_mii_flow_control()
Date: Mon, 22 Mar 2010 21:25:14 +0100
Message-ID: <4BA7D22A.6080300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Asymmetric pause was not disabled in the RX case.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
I spotted this because In the FLOW_CNTL_RX and FLOW_CNTL_TX_RX
cases the same code is executed, is the amendment below required?

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 3a486f3..2d478cf 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -807,7 +807,7 @@ static void set_mii_flow_control(struct velocity_info *vptr)
 
 	case FLOW_CNTL_RX:
 		MII_REG_BITS_ON(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_OFF(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
 		break;
 
 	case FLOW_CNTL_TX_RX:
