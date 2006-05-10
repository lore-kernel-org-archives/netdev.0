From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bonding: fix sparse warnings
Date: Wed, 10 May 2006 16:14:05 -0700
Message-ID: <20060510161405.4ded4250@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18838 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965073AbWEJXOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 19:14:11 -0400
To: ctindel@users.sourceforge.net, Jay Vosburgh <fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix warning from sparse in bonding code about "incorrect type in assignment"

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- orig/drivers/net/bonding/bond_main.c	2006-05-04 16:22:10.000000000 -0700
+++ new/drivers/net/bonding/bond_main.c	2006-05-10 16:04:38.000000000 -0700
@@ -629,7 +629,7 @@
 	ioctl = slave_dev->do_ioctl;
 	strncpy(ifr.ifr_name, slave_dev->name, IFNAMSIZ);
 	etool.cmd = ETHTOOL_GSET;
-	ifr.ifr_data = (char*)&etool;
+	ifr.ifr_data = (void __user *) &etool;
 	if (!ioctl || (IOCTL(slave_dev, &ifr, SIOCETHTOOL) < 0)) {
 		return -1;
 	}
@@ -726,7 +726,7 @@
 	if (ioctl) {
 		strncpy(ifr.ifr_name, slave_dev->name, IFNAMSIZ);
 		etool.cmd = ETHTOOL_GLINK;
-		ifr.ifr_data = (char*)&etool;
+		ifr.ifr_data = (void __user *) &etool;
 		if (IOCTL(slave_dev, &ifr, SIOCETHTOOL) == 0) {
 			if (etool.data == 1) {
 				return BMSR_LSTATUS;
