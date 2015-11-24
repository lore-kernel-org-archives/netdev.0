From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3.2 24/52] can: Use correct type in sizeof() in nla_put()
Date: Tue, 24 Nov 2015 22:33:59 +0000
Message-ID: <lsq.1448404439.18455182@decadent.org.uk>
References: <lsq.1448404438.351251660@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: akpm@linux-foundation.org, "Marek Vasut" <marex@denx.de>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	"Wolfgang Grandegger" <wg@grandegger.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <lsq.1448404438.351251660@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.2.74-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Marek Vasut <marex@denx.de>

commit 562b103a21974c2f9cd67514d110f918bb3e1796 upstream.

The sizeof() is invoked on an incorrect variable, likely due to some
copy-paste error, and this might result in memory corruption. Fix this.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
[bwh: Backported to 3.2:
 - Keep using the old NLA_PUT macro
 - Adjust context]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/can/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -693,7 +693,7 @@ static int can_fill_info(struct sk_buff
 	NLA_PUT_U32(skb, IFLA_CAN_RESTART_MS, priv->restart_ms);
 	NLA_PUT(skb, IFLA_CAN_BITTIMING,
 		sizeof(priv->bittiming), &priv->bittiming);
-	NLA_PUT(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock);
+	NLA_PUT(skb, IFLA_CAN_CLOCK, sizeof(priv->clock), &priv->clock);
 	if (priv->do_get_berr_counter && !priv->do_get_berr_counter(dev, &bec))
 		NLA_PUT(skb, IFLA_CAN_BERR_COUNTER, sizeof(bec), &bec);
 	if (priv->bittiming_const)
