From: frank.blaschka@de.ibm.com
Subject: [patch 3/4] [PATCH][S390] Kconfig: have CCWGROUP depend on CLAW
Date: Wed, 08 Sep 2010 09:14:41 +0200
Message-ID: <20100908071601.413478927@de.ibm.com>
References: <20100908071438.085729717@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Mike Frysinger <vapier@gentoo.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:50099 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757759Ab0IHHQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:16:08 -0400
Content-Disposition: inline; filename=602-claw-kconfig-ccwgroup.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>

Since the claw code calls ccwgroup_remove_ccwdev(), we need to make sure
CCWGROUP is enabled when CLAW is enabled.  Otherwise we hit fun undefined
references at build time:
ERROR: "ccwgroup_remove_ccwdev" [drivers/s390/net/claw.ko] undefined!
ERROR: "ccwgroup_probe_ccwdev" [drivers/s390/net/claw.ko] undefined!
ERROR: "ccwgroup_driver_register" [drivers/s390/net/claw.ko] undefined!
ERROR: "ccwgroup_driver_unregister" [drivers/s390/net/claw.ko] undefined!
ERROR: "ccwgroup_create_from_string" [drivers/s390/net/claw.ko] undefined!

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/Kconfig linux-2.6-patched/drivers/s390/net/Kconfig
--- linux-2.6/drivers/s390/net/Kconfig	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/Kconfig	2010-09-07 09:57:35.000000000 +0200
@@ -100,6 +100,6 @@ config QETH_IPV6
 
 config CCWGROUP
 	tristate
-	default (LCS || CTCM || QETH)
+	default (LCS || CTCM || QETH || CLAW)
 
 endmenu

