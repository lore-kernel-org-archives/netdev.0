From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH v2] bonding: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Sun, 17 Aug 2014 13:21:45 +0300
Message-ID: <20140817102145.GA3854@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com
To: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This "rcu_dereference()" call is used directly in a condition.
Since its return value is never dereferenced it is recommended to use
"rcu_access_pointer()" instead of "rcu_dereference()".
Therefore, this patch makes this replacement.

The following Coccinelle semantic patch was used for solving it:
@@
@@

(
 if(
 (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
 ...+>)) {...}
|
 while(
 (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
  ...+>)) {...}
)

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
Changes in v2:
 - Modified subject line from
 "rcu: Replace rcu_dereference() with rcu_access_pointer()"
 to
 "bonding: Replace rcu_dereference() with rcu_access_pointer()",
 noted by David Miller <davem@davemloft.net>

 drivers/net/bonding/bond_alb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 76c0dad..1319c5b 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1385,7 +1385,7 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
 	}
 
 	if (tx_slave && bond_slave_can_tx(tx_slave)) {
-		if (tx_slave != rcu_dereference(bond->curr_active_slave)) {
+		if (tx_slave != rcu_access_pointer(bond->curr_active_slave)) {
 			ether_addr_copy(eth_data->h_source,
 					tx_slave->dev->dev_addr);
 		}
-- 
1.9.1
