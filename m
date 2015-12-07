From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.1 62/95] can: Use correct type in sizeof() in nla_put()
Date: Mon,  7 Dec 2015 09:35:56 -0500
Message-ID: <20151207142742.326814939@linuxfoundation.org>
References: <20151207142739.317088107@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Marek Vasut <marex@denx.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151207142739.317088107@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

4.1-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Marek Vasut <marex@denx.de>

commit 562b103a21974c2f9cd67514d110f918bb3e1796 upstream.

The sizeof() is invoked on an incorrect variable, likely due to some
copy-paste error, and this might result in memory corruption. Fix this.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 drivers/net/can/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -915,7 +915,7 @@ static int can_fill_info(struct sk_buff
 	     nla_put(skb, IFLA_CAN_BITTIMING_CONST,
 		     sizeof(*priv->bittiming_const), priv->bittiming_const)) ||
 
-	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock) ||
+	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(priv->clock), &priv->clock) ||
 	    nla_put_u32(skb, IFLA_CAN_STATE, state) ||
 	    nla_put(skb, IFLA_CAN_CTRLMODE, sizeof(cm), &cm) ||
 	    nla_put_u32(skb, IFLA_CAN_RESTART_MS, priv->restart_ms) ||
