From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 8/8] [Blackfin] EMAC driver: Fix bug: The clock divisor is set to all ones at reset.
Date: Wed, 30 Jan 2008 16:52:28 +0800
Message-ID: <1201683148-23931-9-git-send-email-bryan.wu@analog.com>
References: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Cc: linux-kernel@vger.kernel.org, Bryan Wu <bryan.wu@analog.com>,
	Kalle Pokki <kalle.pokki@eke.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:33791 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755710AbYA3Iwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:52:39 -0500
In-Reply-To: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Kalle Pokki <kalle.pokki@eke.com>
Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/bfin_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 0a17fb4..c993a32 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -408,7 +408,7 @@ static int mii_probe(struct net_device *dev)
 	mdc_div = ((sclk / MDC_CLK) / 2) - 1;
 
 	sysctl = bfin_read_EMAC_SYSCTL();
-	sysctl |= SET_MDCDIV(mdc_div);
+	sysctl = (sysctl & ~MDCDIV) | SET_MDCDIV(mdc_div);
 	bfin_write_EMAC_SYSCTL(sysctl);
 
 	/* search for connect PHY device */
-- 
1.5.3.4
