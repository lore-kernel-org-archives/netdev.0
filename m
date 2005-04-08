From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 5/17] bonding: reset RLB flag during ALB init
Date: Fri, 8 Apr 2005 16:30:38 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081629200.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

s patch makes the ALB init function explicitly clear the RLB flag if
RLB is not used. This is required by the sysfs interfaces, which allows
the user to change mode without destroying the bond.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_alb.c linux-2.6.12-rc2/drivers/net/bonding/bond_alb.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_alb.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_alb.c	2005-04-07 13:57:29.000000000 -0700
@@ -1256,7 +1256,10 @@
  			tlb_deinitialize(bond);
  			return res;
  		}
+	} else {
+		bond->alb_info.rlb_enabled = 0;
  	}
+

  	return 0;
  }
