From: Arthur Kepner <akepner@sgi.com>
Subject: [PATCH] use NETIF_F_LLTX in bonding device
Date: Tue, 15 Mar 2005 10:29:16 -0800 (PST)
Message-ID: <Pine.LNX.4.61.0503151016580.18478@linux.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Lock contention on the bonding device's xmit_lock can 
become a bottleneck when 3 or more gige links are aggregated. 
And it looks like it's unnecessary too, so use the 
NETIF_F_LLTX flag to avoid grabbing this lock. 

Signed-off-by: <akepner@sgi.com>

--- linux.orig/drivers/net/bonding/bond_main.c	2005-03-14 14:08:29.000000000 -0800
+++ linux/drivers/net/bonding/bond_main.c	2005-03-14 17:08:57.000000000 -0800
@@ -4306,6 +4306,10 @@ static int __init bond_init(struct net_d
 	 */
 	bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
 
+	/* don't acquire bond device's xmit_lock when 
+	 * transmitting */
+	bond_dev->features |= NETIF_F_LLTX;
+
 	/* By default, we declare the bond to be fully
 	 * VLAN hardware accelerated capable. Special
 	 * care is taken in the various xmit functions

--
Arthur
