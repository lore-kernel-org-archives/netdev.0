From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 1/2] [bonding 2.6] Restore missing backward compatibility
Date: Thu, 20 Nov 2003 19:56:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311201956.24771.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch (against latest 2.6.0) is also waiting for almost a month.
It's already in 2.4 but is still very much needed for 2.6.

Old ifenslave versions (like the one in Red Hat 9) don't work with
the bonding module in the latest 2.6 kernel without it.

Amir


diff -Naurp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Oct 30 10:38:34 2003
+++ b/drivers/net/bonding/bond_main.c	Sun Nov  2 15:14:21 2003
@@ -3047,6 +3047,10 @@ static int bond_ioctl(struct net_device 
 		case SIOCBONDRELEASE:	
 			ret = bond_release(master_dev, slave_dev); 
 			break;
+		case BOND_SETHWADDR_OLD:
+		case SIOCBONDSETHWADDR:
+			ret = bond_sethwaddr(master_dev, slave_dev);
+			break;
 		case BOND_CHANGE_ACTIVE_OLD:
 		case SIOCBONDCHANGEACTIVE:
 			if (USES_PRIMARY(bond_mode)) {
