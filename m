From: Tanmay Upadhyay <tanmay.upadhyay@einfochips.com>
Subject: [PATCH] net: pxa168: Fix build errors by including interrupt.h
Date: Tue,  6 Sep 2011 11:02:04 +0530
Message-ID: <1315287124-13972-2-git-send-email-tanmay.upadhyay@einfochips.com>
References: <1315287124-13972-1-git-send-email-tanmay.upadhyay@einfochips.com>
Cc: netdev@vger.kernel.org,
	Tanmay Upadhyay <tanmay.upadhyay@einfochips.com>
To: ssanap@marvell.com, zgao6@marvell.com, prakity@marvell.com,
	markb@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ahm.einfochips.com ([203.76.128.206]:8159 "EHLO
	ahm.einfochips.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031Ab1IFFli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 01:41:38 -0400
In-Reply-To: <1315287124-13972-1-git-send-email-tanmay.upadhyay@einfochips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a6b7a407865aab9f849dd99a71072b7cd1175116 removed
linux/interrupt.h from netdevice.h. This fixes below build failure

drivers/net/pxa168_eth.c: In function 'pxa168_eth_collect_events':
drivers/net/pxa168_eth.c:866: error: 'IRQ_NONE' undeclared (first use in this function)
drivers/net/pxa168_eth.c:866: error: (Each undeclared identifier is reported only once
drivers/net/pxa168_eth.c:866: error: for each function it appears in.)
drivers/net/pxa168_eth.c: At top level:
drivers/net/pxa168_eth.c:913: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'pxa168_eth_int_handler'
drivers/net/pxa168_eth.c: In function 'pxa168_eth_open':
drivers/net/pxa168_eth.c:1133: error: implicit declaration of function 'request_irq'
drivers/net/pxa168_eth.c:1133: error: 'pxa168_eth_int_handler' undeclared (first use in this function)
drivers/net/pxa168_eth.c:1134: error: 'IRQF_DISABLED' undeclared (first use in this function)
drivers/net/pxa168_eth.c:1160: error: implicit declaration of function 'free_irq'

Signed-off-by: Tanmay Upadhyay <tanmay.upadhyay@einfochips.com>
---
 drivers/net/pxa168_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 1a3033d..d17d062 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -40,6 +40,7 @@
 #include <linux/clk.h>
 #include <linux/phy.h>
 #include <linux/io.h>
+#include <linux/interrupt.h>
 #include <linux/types.h>
 #include <asm/pgtable.h>
 #include <asm/system.h>
-- 
1.7.0.4
