From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [PATCH][bonding] Restore compatibilty with old ifenslave (resend)
Date: Sun, 12 Oct 2003 16:50:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310121650.46755.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The patch below restores compatibility that was removed during the
propagation set. That set added the ability to set the bond's
hardware address in the conventional way using SIOCSIFHWADDR but
also removed support for the very old way using BOND_SETHWADDR,
which, although has been removed from the ifenslave code for years,
turns out to still be in use in the ifenslave binary of recent
distributions (we got the complaint from an RH9 user).

The patch applies on 2.4.23-pre7.

Jeff, please apply this patch soon so that 2.4.23 won't be released
with a bug that breaks compatibility.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |



diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2003-10-12 16:24:42.000000000 +0200
+++ b/drivers/net/bonding/bond_main.c	2003-10-12 16:27:12.000000000 +0200
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
