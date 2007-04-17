From: "Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
Subject: [PATCH 2.6.20] networking: bonding documentation fix for multiple bonding interfaces
Date: Tue, 17 Apr 2007 11:49:58 +0400
Message-ID: <20070417074956.GA20123@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@osdl.org
To: lkml@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([82.179.117.235]:45470 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbXDQIPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 04:15:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix bonding driver documentation for the case of multiple bonding interfaces.

Signed-off-by: "Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
---
--- a/Documentation/networking/bonding.txt	2007-04-17 11:29:42.000000000 +0400
+++ b/Documentation/networking/bonding.txt	2007-04-17 11:35:54.000000000 +0400
@@ -920,40 +920,9 @@
 documented above.
 
 	To create multiple bonding devices with differing options, it
-is necessary to load the bonding driver multiple times.  Note that
-current versions of the sysconfig network initialization scripts
-handle this automatically; if your distro uses these scripts, no
-special action is needed.  See the section Configuring Bonding
-Devices, above, if you're not sure about your network initialization
-scripts.
-
-	To load multiple instances of the module, it is necessary to
-specify a different name for each instance (the module loading system
-requires that every loaded module, even multiple instances of the same
-module, have a unique name).  This is accomplished by supplying
-multiple sets of bonding options in /etc/modprobe.conf, for example:
-	
-alias bond0 bonding
-options bond0 -o bond0 mode=balance-rr miimon=100
-
-alias bond1 bonding
-options bond1 -o bond1 mode=balance-alb miimon=50
-
-	will load the bonding module two times.  The first instance is
-named "bond0" and creates the bond0 device in balance-rr mode with an
-miimon of 100.  The second instance is named "bond1" and creates the
-bond1 device in balance-alb mode with an miimon of 50.
-
-	In some circumstances (typically with older distributions),
-the above does not work, and the second bonding instance never sees
-its options.  In that case, the second options line can be substituted
-as follows:
-
-install bond1 /sbin/modprobe --ignore-install bonding -o bond1 \
-	mode=balance-alb miimon=50
+is necessary to use bonding parameters exported by sysfs, documented
+in the section below.
 
-	This may be repeated any number of times, specifying a new and
-unique name in place of bond1 for each subsequent instance.
 
 3.4 Configuring Bonding Manually via Sysfs
 ------------------------------------------
-- 
Alexandra N. Kossovsky
OKTET Labs (http://www.oktetlabs.ru/)
