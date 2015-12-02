From: Kamal Mostafa <kamal@canonical.com>
Subject: [PATCH 3.13.y-ckt 43/86] can: Use correct type in sizeof() in
 nla_put()
Date: Wed,  2 Dec 2015 14:54:04 -0800
Message-ID: <1449096887-23017-44-git-send-email-kamal@canonical.com>
References: <1449096887-23017-1-git-send-email-kamal@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Marek Vasut <marex@denx.de>, netdev@vger.kernel.org,
 Kamal Mostafa <kamal@canonical.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
 Wolfgang Grandegger <wg@grandegger.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 kernel-team@lists.ubuntu.com
Return-path: <kernel-team-bounces@lists.ubuntu.com>
In-Reply-To: <1449096887-23017-1-git-send-email-kamal@canonical.com>
List-Unsubscribe: <https://lists.ubuntu.com/mailman/options/kernel-team>,
 <mailto:kernel-team-request@lists.ubuntu.com?subject=unsubscribe>
List-Archive: <https://lists.ubuntu.com/archives/kernel-team>
List-Post: <mailto:kernel-team@lists.ubuntu.com>
List-Help: <mailto:kernel-team-request@lists.ubuntu.com?subject=help>
List-Subscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
 <mailto:kernel-team-request@lists.ubuntu.com?subject=subscribe>
Errors-To: kernel-team-bounces@lists.ubuntu.com
Sender: kernel-team-bounces@lists.ubuntu.com
List-Id: netdev.vger.kernel.org

3.13.11-ckt31 -stable review patch.  If anyone has any objections, please let me know.

------------------

From: Marek Vasut <marex@denx.de>

commit 562b103a21974c2f9cd67514d110f918bb3e1796 upstream.

The sizeof() is invoked on an incorrect variable, likely due to some
copy-paste error, and this might result in memory corruption. Fix this.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 drivers/net/can/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 3230ac8..5932b17 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -730,7 +730,7 @@ static int can_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    (priv->bittiming_const &&
 	     nla_put(skb, IFLA_CAN_BITTIMING_CONST,
 		     sizeof(*priv->bittiming_const), priv->bittiming_const)) ||
-	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock) ||
+	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(priv->clock), &priv->clock) ||
 	    nla_put_u32(skb, IFLA_CAN_STATE, state) ||
 	    nla_put(skb, IFLA_CAN_CTRLMODE, sizeof(cm), &cm) ||
 	    nla_put_u32(skb, IFLA_CAN_RESTART_MS, priv->restart_ms) ||
-- 
1.9.1
