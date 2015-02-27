From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] net: pasemi: Use setup_timer and mod_timer
Date: Sat, 28 Feb 2015 00:20:59 +0530
Message-ID: <20150227185059.GA20385@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use timer API functions setup_timer and mod_timer instead
of structure assignments as they are standard way to set
the timer and to update the expire field of an active timer
respectively.

This is done using Coccinelle and semantic patch used for
this is as follows:

// <smpl>
@@
expression x,y,z,a,b;
@@

-init_timer (&x);
+setup_timer (&x, y, z);
+mod_timer (&a, b);
-x.function = y;
-x.data = z;
-x.expires = b;
-add_timer(&a);
// </smpl>

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/net/ethernet/pasemi/pasemi_mac.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 44e8d7d..57a6e6c 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1239,11 +1239,9 @@ static int pasemi_mac_open(struct net_device *dev)
 	if (mac->phydev)
 		phy_start(mac->phydev);
 
-	init_timer(&mac->tx->clean_timer);
-	mac->tx->clean_timer.function = pasemi_mac_tx_timer;
-	mac->tx->clean_timer.data = (unsigned long)mac->tx;
-	mac->tx->clean_timer.expires = jiffies+HZ;
-	add_timer(&mac->tx->clean_timer);
+	setup_timer(&mac->tx->clean_timer, pasemi_mac_tx_timer,
+		    (unsigned long)mac->tx);
+	mod_timer(&mac->tx->clean_timer, jiffies + HZ);
 
 	return 0;
 
-- 
1.9.1
