From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH][BONDING] Add max_bonds kernel parameter
Date: Fri, 29 Feb 2008 10:51:30 -0800
Message-ID: <20080229185130.GA28138@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:51088
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1760000AbYB2Svb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 13:51:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline




--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-maxbonds

commit eb8694ab0a53343ebb45abeb2a9568d6267fa2f2
Author: Phil Oester <kernel@linuxace.com>
Date:   Fri Feb 29 13:26:34 2008 -0500

    The bonding driver (and initscripts) seem to assume everyone loads bonding
    as a module.  So when compiled into the kernel, changing the max_bonds
    parameter can only be done in the source code.
    
    Below adds a kernel command line parameter to change max_bonds when
    compiled in.
    
    Phil
    
    Signed-off-by: Phil Oester <kernel@linuxace.com>

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 9a5b665..4b21045 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1071,6 +1071,10 @@ and is between 256 and 4096 characters. It is defined in the file
 			(machvec) in a generic kernel.
 			Example: machvec=hpzx1_swiotlb
 
+	max_bonds=	[NET] Maximum number of bonded devices which can be
+			created and the default number of devices which
+			will be created automatically at boot.
+
 	max_loop=	[LOOP] Maximum number of loopback devices that can
 			be mounted
 			Format: <1-256>
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0942d82..64597d8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5032,3 +5032,12 @@ MODULE_SUPPORTED_DEVICE("most ethernet devices");
  * End:
  */
 
+#ifndef MODULE
+static int __init max_bonds_setup(char *str)
+{
+        max_bonds = simple_strtol(str, NULL, 0);
+        return 1;
+}
+
+__setup("max_bonds=", max_bonds_setup);
+#endif

--gBBFr7Ir9EOA20Yy--
