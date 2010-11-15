From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH] gianfar: fix signedness issue
Date: Mon, 15 Nov 2010 21:59:42 +0100
Message-ID: <20101115215942.354b0394@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

irq_of_parse_and_map() has an unsigned return type.
Testing for a negative error value doesn't work here.

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---
I see that in numerous places the return value is tested
for NO_IRQ. I hope it's the right thing to do here as well?

 drivers/net/gianfar.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 49e4ce1..d1bec62 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -577,11 +577,10 @@ static int gfar_parse_group(struct device_node *np,
 			irq_of_parse_and_map(np, 1);
 		priv->gfargrp[priv->num_grps].interruptError =
 			irq_of_parse_and_map(np,2);
-		if (priv->gfargrp[priv->num_grps].interruptTransmit < 0 ||
-			priv->gfargrp[priv->num_grps].interruptReceive < 0 ||
-			priv->gfargrp[priv->num_grps].interruptError < 0) {
+		if (priv->gfargrp[priv->num_grps].interruptTransmit == NO_IRQ ||
+		    priv->gfargrp[priv->num_grps].interruptReceive  == NO_IRQ ||
+		    priv->gfargrp[priv->num_grps].interruptError    == NO_IRQ)
 			return -EINVAL;
-		}
 	}
 
 	priv->gfargrp[priv->num_grps].grp_id = priv->num_grps;
-- 
1.7.2.2
