From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 17/17] bonding: Optimization to read MII only when
 link status has changed.
Date: Fri, 1 Jul 2005 14:14:00 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011410190.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Enhanced bond_mii_monitor fn: to read MII only when link status has 
changed for an enslaved adapter.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -2652,6 +2652,7 @@
  					if (slave == oldcurrent) {
  						do_failover = 1;
  					}
+					bond_update_speed_duplex(slave);
  				} else {
  					slave->delay--;
  				}
@@ -2742,6 +2675,7 @@
  				} else {
  					slave->delay--;
  				}
+				bond_update_speed_duplex(slave);
  			}
  			break;
  		default:
@@ -2754,8 +2675,6 @@
  			goto out;
  		} /* end of switch (slave->link) */

-		bond_update_speed_duplex(slave);
-
  		if (bond->params.mode == BOND_MODE_8023AD) {
  			if (old_speed != slave->speed) {
  				bond_3ad_adapter_speed_changed(slave);
~
