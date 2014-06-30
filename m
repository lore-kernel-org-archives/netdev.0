From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH 3/4] net: macb: Use clk_find_nearest_rate() API
Date: Mon, 30 Jun 2014 09:56:35 -0700
Message-ID: <1404147396-8041-4-git-send-email-soren.brinkmann@xilinx.com>
References: <1404147396-8041-1-git-send-email-soren.brinkmann@xilinx.com>
Cc: Russell King <linux@arm.linux.org.uk>,
	Michal Simek <michal.simek@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, linux-pm@vger.kernel.org,
	linux-kernel@vger.kernel.org, cpufreq@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Soren Brinkmann <soren.brinkmann@xilinx.com>,
	netdev@vger.kernel.org
To: Mike Turquette <mturquette@linaro.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:52569 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756510AbaF3Q46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 12:56:58 -0400
In-Reply-To: <1404147396-8041-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet clock has to match the specified frequencies as accurately
as possible. clk_round_rate() does not specify how rounding is
implemented. Hence use clk_find_nearest_rate().

Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
---

 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e9daa072ebb4..7b7f5eb1b341 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -223,7 +223,7 @@ static void macb_set_tx_clk(struct clk *clk, int speed, struct net_device *dev)
 		return;
 	}
 
-	rate_rounded = clk_round_rate(clk, rate);
+	rate_rounded = clk_find_nearest_rate(clk, rate);
 	if (rate_rounded < 0)
 		return;
 
-- 
2.0.1.1.gfbfc394
