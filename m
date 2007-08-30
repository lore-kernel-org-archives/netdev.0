From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] bonding: update some distro-specific documentation
Date: Thu, 30 Aug 2007 17:24:29 -0400
Message-ID: <20070830212429.GA12676@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42995 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756646AbXH3VbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 17:31:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These are some changes that update some of the distro-specific details
in for configuring bonding.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---

 bonding.txt |   45 ++++++++++++++++++++++++++-------------------
 1 files changed, 26 insertions(+), 19 deletions(-)


diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 1da5666..52fc1d0 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -755,9 +755,9 @@ the system /etc/modules.conf or /etc/modprobe.conf configuration file.
 ------------------------------------------
 
 	This section applies to distros using a version of initscripts
-with bonding support, for example, Red Hat Linux 9 or Red Hat
-Enterprise Linux version 3 or 4.  On these systems, the network
-initialization scripts have some knowledge of bonding, and can be
+with bonding support, for example, Red Hat Linux 9, Red Hat Enterprise
+Linux version 3, 4 or 5, Fedora, etc.  On these systems, the network
+initialization scripts have some knowledge of bonding, and can be 
 configured to control bonding devices.
 
 	These distros will not automatically load the network adapter
@@ -802,15 +802,20 @@ BROADCAST=192.168.1.255
 ONBOOT=yes
 BOOTPROTO=none
 USERCTL=no
+BONDING_OPTS="mode=balance-alb miimon=100"
 
 	Be sure to change the networking specific lines (IPADDR,
 NETMASK, NETWORK and BROADCAST) to match your network configuration.
+You also need to set the BONDING_OPTS= line to specify the desired
+options for your bond0 interface.  Specifying bonding options in this
+way is the preferred method for configuring bonding interfaces.
 
-	Finally, it is necessary to edit /etc/modules.conf (or
+	It is no longer necessary to edit /etc/modules.conf (or
 /etc/modprobe.conf, depending upon your distro) to load the bonding
 module with your desired options when the bond0 interface is brought
 up.  The following lines in /etc/modules.conf (or modprobe.conf) will
-load the bonding module, and select its options:
+load the bonding module, and select its options but this is no longer
+the preferred method.
 
 alias bond0 bonding
 options bond0 mode=balance-alb miimon=100
@@ -826,8 +831,9 @@ up and running.
 ---------------------------------
 
 	Recent versions of initscripts (the version supplied with
-Fedora Core 3 and Red Hat Enterprise Linux 4 is reported to work) do
-have support for assigning IP information to bonding devices via DHCP.
+Fedora Core 3 and Red Hat Enterprise Linux 4 and later is reported to
+work) do have support for assigning IP information to bonding devices
+via DHCP.
 
 	To configure bonding for DHCP, configure it as described
 above, except replace the line "BOOTPROTO=none" with "BOOTPROTO=dhcp"
@@ -837,18 +843,19 @@ is case sensitive.
 3.2.2 Configuring Multiple Bonds with Initscripts
 -------------------------------------------------
 
-	At this writing, the initscripts package does not directly
-support loading the bonding driver multiple times, so the process for
-doing so is the same as described in the "Configuring Multiple Bonds
-Manually" section, below.
-
-	NOTE: It has been observed that some Red Hat supplied kernels
-are apparently unable to rename modules at load time (the "-o bond1"
-part).  Attempts to pass that option to modprobe will produce an
-"Operation not permitted" error.  This has been reported on some
-Fedora Core kernels, and has been seen on RHEL 4 as well.  On kernels
-exhibiting this problem, it will be impossible to configure multiple
-bonds with differing parameters.
+	Initscripts packages that are included with Fedora 7 and Red
+Hat Enterprise Linux 5 support multiple bonding interfaces by simply
+specifying the appropriate BONDING_OPTS= in ifcfg-bondX where X is
+the number of the bond.  Other distros may not include support in
+initscripts for multiple bonding interfaces, so you may need to follow
+the process as described in the "Configuring Multiple Bonds Manually"
+section, below.
+
+	It has been observed that much older kernels are apparently
+unable to rename modules at load time (the "-o bond1" part).  Attempts
+to pass that option to modprobe will produce an "Operation not 
+permitted" error.  On kernels exhibiting this problem, it will be 
+impossible to configure multiple bonds with differing parameters.
 
 3.3 Configuring Bonding Manually with Ifenslave
 -----------------------------------------------
