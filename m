From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] bonding: update documentation - alternate configuration.
Date: Tue, 25 Jan 2011 00:21:37 +0100
Message-ID: <1295911297-11438-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, nicolas.2p.debian@free.fr
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:41280 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab1AXXWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 18:22:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding documentation used to provide configuration
details and examples for initscripts and sysconfig only.

This patch describe the third possible configuration:
/etc/network/interfaces.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 Documentation/networking/bonding.txt |   83 ++++++++++++++++++++++++++=
+++-----
 1 files changed, 71 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/netwo=
rking/bonding.txt
index 5dc6387..b37e36f 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -49,7 +49,8 @@ Table of Contents
 3.3	Configuring Bonding Manually with Ifenslave
 3.3.1		Configuring Multiple Bonds Manually
 3.4	Configuring Bonding Manually via Sysfs
-3.5	Overriding Configuration for Special Cases
+3.5	Configuration with Interfaces Support
+3.6	Overriding Configuration for Special Cases
=20
 4. Querying Bonding Configuration
 4.1	Bonding Configuration
@@ -161,8 +162,8 @@ onwards) do not have /usr/include/linux symbolicall=
y linked to the
 default kernel source include directory.
=20
 SECOND IMPORTANT NOTE:
-	If you plan to configure bonding using sysfs, you do not need
-to use ifenslave.
+	If you plan to configure bonding using sysfs or using the
+/etc/network/interfaces file, you do not need to use ifenslave.
=20
 2. Bonding Driver Options
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
@@ -779,22 +780,26 @@ resend_igmp
=20
 	You can configure bonding using either your distro's network
 initialization scripts, or manually using either ifenslave or the
-sysfs interface.  Distros generally use one of two packages for the
-network initialization scripts: initscripts or sysconfig.  Recent
-versions of these packages have support for bonding, while older
+sysfs interface.  Distros generally use one of three packages for the
+network initialization scripts: initscripts, sysconfig or interfaces.
+Recent versions of these packages have support for bonding, while olde=
r
 versions do not.
=20
 	We will first describe the options for configuring bonding for
-distros using versions of initscripts and sysconfig with full or
-partial support for bonding, then provide information on enabling
+distros using versions of initscripts, sysconfig and interfaces with f=
ull
+or partial support for bonding, then provide information on enabling
 bonding without support from the network initialization scripts (i.e.,
 older versions of initscripts or sysconfig).
=20
-	If you're unsure whether your distro uses sysconfig or
-initscripts, or don't know if it's new enough, have no fear.
+	If you're unsure whether your distro uses sysconfig,=20
+initscripts or interfaces, or don't know if it's new enough, have no f=
ear.
 Determining this is fairly straightforward.
=20
-	First, issue the command:
+	First, look for a file called interfaces in /etc/network directory.
+If this file is present in your system, then your system use interface=
s. See
+Configuration with Interfaces Support.
+=09
+	Else, issue the command:
=20
 $ rpm -qf /sbin/ifup
=20
@@ -1327,8 +1332,62 @@ echo 2000 > /sys/class/net/bond1/bonding/arp_int=
erval
 echo +eth2 > /sys/class/net/bond1/bonding/slaves
 echo +eth3 > /sys/class/net/bond1/bonding/slaves
=20
-3.5 Overriding Configuration for Special Cases
+3.5 Configuration with Interfaces Support
+-----------------------------------------
+
+        This section applies to distros which use /etc/network/interfa=
ces file
+to describe network interface configuration, most notably Debian and i=
t's
+derivatives.
+
+	The ifup and ifdown commands on Debian don't support bonding out of
+the box. The ifenslave-2.6 package should be installed to provide bond=
ing
+support.  Once installed, this package will provide bond-* options to =
be used
+into /etc/network/interfaces.
+
+	Note that ifenslave-2.6 package will load the bonding module and use
+the ifenslave command when appropriate.
+
+Example Configurations
+----------------------
+
+In /etc/network/interfaces, the following stanza will configure bond0,=
 in
+active-backup mode, with eth0 and eth1 as slaves.
+
+auto bond0
+iface bond0 inet dhcp
+	bond-slaves eth0 eth1
+	bond-mode active-backup
+	bond-miimon 100
+	bond-primary eth0 eth1
+
+If the above configuration doesn't work, you might have a system using
+upstart for system startup. This is most notably true for recent
+Ubuntu versions. The following stanza in /etc/network/interfaces will
+produce the same result on those systems.
+
+auto bond0
+iface bond0 inet dhcp
+	bond-slaves none
+	bond-mode active-backup
+	bond-miimon 100
+
+auto eth0
+iface eth0 inet manual
+	bond-master bond0
+	bond-primary eth0 eth1
+
+auto eth1
+iface eth1 inet manual
+	bond-master bond0
+	bond-primary eth0 eth1
+
+For a full list of bond-* supported options in /etc/network/interfaces=
 and some
+more advanced examples tailored to you particular distros, see the fil=
es in
+/usr/share/doc/ifenslave-2.6.
+
+3.6 Overriding Configuration for Special Cases
 ----------------------------------------------
+
 When using the bonding driver, the physical port which transmits a fra=
me is
 typically selected by the bonding driver, and is not relevant to the u=
ser or
 system administrator.  The output port is simply selected using the po=
licies of
--=20
1.7.2.3

