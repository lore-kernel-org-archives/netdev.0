From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [PATCH}[bonding] Restore compatibilty with old ifenslave
Date: Mon, 29 Sep 2003 18:20:28 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309291820.28609.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The patch below restores compatibility that was removed during the
propagation set. That set added the ability to set the bond's hardware
address in the conventional way using SIOCSIFHWADDR but also removed
support for the very old way using BOND_SETHWADDR, which, although has
been removed from the ifenslave code for years, turns out to still be
in use in the ifenslave binary of recent distributions.

The patch applies on 2.4.23-pre5 and should also cleanly apply on
2.6.0-test6 after fully applying the propagation set (patch 2 wasn't
applied yet).

Jeff, please apply this patch soon so that 2.4.23 won't be released
with a bug that breaks compatibility.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |

diff -Naurp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Mon Sep 29 15:15:57 2003
+++ b/drivers/net/bonding/bond_main.c	Mon Sep 29 18:15:00 2003
@@ -3048,6 +3048,10 @@ static int bond_ioctl(struct net_device 
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
