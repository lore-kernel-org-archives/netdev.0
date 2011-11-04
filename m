From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] bonding: comparing a u8 with -1 is always false
Date: Fri, 4 Nov 2011 21:21:38 +0300
Message-ID: <20111104182138.GB5796@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Weiping Pan <wpan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:53951 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320Ab1KDSWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 14:22:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

slave->duplex is a u8 type so the in bond_info_show_slave() when we
check "if (slave->duplex == -1)", it's always false.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b2b9109..b0c5772 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -560,8 +560,8 @@ static int bond_update_speed_duplex(struct slave *slave)
 	u32 slave_speed;
 	int res;
 
-	slave->speed = -1;
-	slave->duplex = -1;
+	slave->speed = SPEED_UNKNOWN;
+	slave->duplex = DUPLEX_UNKNOWN;
 
 	res = __ethtool_get_settings(slave_dev, &ecmd);
 	if (res < 0)
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 2acf0b0..ad284ba 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -158,12 +158,12 @@ static void bond_info_show_slave(struct seq_file *seq,
 	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
 	seq_printf(seq, "MII Status: %s\n",
 		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
-	if (slave->speed == -1)
+	if (slave->speed == SPEED_UNKNOWN)
 		seq_printf(seq, "Speed: %s\n", "Unknown");
 	else
 		seq_printf(seq, "Speed: %d Mbps\n", slave->speed);
 
-	if (slave->duplex == -1)
+	if (slave->duplex == DUPLEX_UNKNOWN)
 		seq_printf(seq, "Duplex: %s\n", "Unknown");
 	else
 		seq_printf(seq, "Duplex: %s\n", slave->duplex ? "full" : "half");
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 45f00b6..de33de1 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -1097,10 +1097,12 @@ struct ethtool_ops {
 #define SPEED_1000		1000
 #define SPEED_2500		2500
 #define SPEED_10000		10000
+#define SPEED_UNKNOWN		-1
 
 /* Duplex, half or full. */
 #define DUPLEX_HALF		0x00
 #define DUPLEX_FULL		0x01
+#define DUPLEX_UNKNOWN		0xff
 
 /* Which connector port. */
 #define PORT_TP			0x00
