From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] 2.4 bonding backwards compat resend
Date: Wed, 29 Oct 2003 10:38:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310291838.h9TIct7I013610@death.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Dave, the appended patch has been waiting for Jeff to apply it
for quite a while, but he seems to be really busy lately.  Can you
apply this?  This needs to go in before 2.4.23 is released.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com



From:  Shmulik Hen <shmulik.hen@intel.com>
Subject:  [PATCH}[bonding] Restore compatibilty with old ifenslave
To:  "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Cc:  bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Date:  Mon, 29 Sep 2003 18:20:28 +0300

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
