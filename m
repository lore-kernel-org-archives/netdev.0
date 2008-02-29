From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH][BONDING] Allow setting max_bonds to zero
Date: Fri, 29 Feb 2008 10:52:57 -0800
Message-ID: <20080229185257.GB28138@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="WhfpMioaduB5tiZL"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:51089
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759428AbYB2Sw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 13:52:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--WhfpMioaduB5tiZL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline




--WhfpMioaduB5tiZL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-zerobonds

commit fc78750341ab174a16f865625b24377670e92e50
Author: Phil Oester <kernel@linuxace.com>
Date:   Fri Feb 29 13:43:34 2008 -0500

    If the bonding driver is compiled into the kernel, it will create a
    "bond0" device by default.  The patch below allows max_bonds to be
    set to 0 to prevent any devices from being created.
    
    Phil
    
    Signed-off-by: Phil Oester <kernel@linuxace.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 64597d8..2bef4b4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4624,11 +4624,11 @@ static int bond_check_params(struct bond_params *params)
 		}
 	}
 
-	if (max_bonds < 1 || max_bonds > INT_MAX) {
+	if (max_bonds > INT_MAX) {
 		printk(KERN_WARNING DRV_NAME
-		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
+		       ": Warning: max_bonds (%d) not in range 0-%d, so it "
 		       "was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
-		       max_bonds, 1, INT_MAX, BOND_DEFAULT_MAX_BONDS);
+		       max_bonds, INT_MAX, BOND_DEFAULT_MAX_BONDS);
 		max_bonds = BOND_DEFAULT_MAX_BONDS;
 	}
 
@@ -4982,9 +4982,11 @@ static int __init bonding_init(void)
 			goto err;
 	}
 
-	res = bond_create_sysfs();
-	if (res)
-		goto err;
+	if (max_bonds > 0) {
+		res = bond_create_sysfs();
+		if (res)
+			goto err;
+	}
 
 	register_netdevice_notifier(&bond_netdev_notifier);
 	register_inetaddr_notifier(&bond_inetaddr_notifier);

--WhfpMioaduB5tiZL--
