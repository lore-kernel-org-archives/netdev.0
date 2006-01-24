From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Subject: [PATCH] sky2: fix ethtool ops
Date: Tue, 24 Jan 2006 13:49:26 +0100
Message-ID: <43D62256.2080207@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030467AbWAXMwM@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes setting rx_coalesce_usecs_irq via ethtool in sky2.
The write was directed to the wrong register.

Signed-off-by: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>

--- linux/drivers/net/sky2.c	2006-01-23 23:41:35.000000000 +0100
+++ linux/drivers/net/sky2.c	2006-01-24 12:52:11.000000000 +0100
@@ -2843,7 +2843,7 @@
 	if (ecmd->rx_coalesce_usecs_irq == 0)
 		sky2_write8(hw, STAT_ISR_TIMER_CTRL, TIM_STOP);
 	else {
-		sky2_write32(hw, STAT_TX_TIMER_INI,
+		sky2_write32(hw, STAT_ISR_TIMER_INI,
 			     sky2_us2clk(hw, ecmd->rx_coalesce_usecs_irq));
 		sky2_write8(hw, STAT_ISR_TIMER_CTRL, TIM_START);
 	}
