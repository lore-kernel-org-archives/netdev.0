From: Shmulik Hen <hshmulik@intel.com>
Subject: [PATCH][bonding] division by zero bug
Date: Tue, 4 Mar 2003 19:11:42 +0200 (IST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0303041902400.13312-100000@jrslxjul4.npdj.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com
Return-path: <linux-net-owner@vger.kernel.org>
To: bonding-devel@lists.sourceforge.net, <linux-net@vger.kernel.org>,
	<netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

The following patch fixes a division by zero bug in the bonding module 
that happens when transmitting through a bond with no slaves, in the XOR 
bonding mode.
The patch is against bonding-2.4.20-20030207 in sorceforge 
(http://sourceforge.net/projects/bonding/).


diff -urN linux-2.4.20-20030207/drivers/net/bonding.c linux-2.4.20-devel/drivers/net/bonding.c
--- linux-2.4.20-20030207/drivers/net/bonding.c	2003-03-02 14:01:46.000000000 +0200
+++ linux-2.4.20-devel/drivers/net/bonding.c	2003-03-02 14:35:04.000000000 +0200
@@ -2597,6 +2597,13 @@
 		return 0;
 	}
 
+	if (bond->slave_cnt == 0) {
+		/* no slaves in the bond, frame not sent */
+		dev_kfree_skb(skb);
+		read_unlock_irqrestore(&bond->lock, flags);
+		return 0;
+	}
+	
 	slave_no = (data->h_dest[5]^slave->dev->dev_addr[5]) % bond->slave_cnt;
 
 	while ( (slave_no > 0) && (slave != (slave_t *)bond) ) {


-- 
| Shmulik Hen                                 |
| Israel Design Center (Jerusalem)            |
| LAN Access Division                         |
| Intel Communications Group, Intel corp.     |
|                                             |
| Anti-Spam: shmulik dot hen at intel dot com |

