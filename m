From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] bonding: Documentation update
Date: Tue, 13 Nov 2007 18:58:53 -0800
Message-ID: <11074.1195009133@death>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Andy Gospodarek" <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:57894 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754534AbXKNC65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 21:58:57 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAE2wudY031765
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 21:58:56 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lAE2wuwX127246
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 19:58:56 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAE2wtVD019180
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 19:58:55 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Update the bonding documentation: more discussion on
initialization and configuration, changes to discussion of packet
reordering in balance-rr, update some out of date information.

	Based in part on input from Rick Jones <rick.jones2@hp.com> and
Andy Gospodarek <andy@greyhouse.net>.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 1134062..eda0f06 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -1,7 +1,7 @@
 
 		Linux Ethernet Bonding Driver HOWTO
 
-		Latest update: 24 April 2006
+		Latest update: 12 November 2007
 
 Initial release : Thomas Davis <tadavis at lbl.gov>
 Corrections, HA extensions : 2000/10/03-15 :
@@ -166,12 +166,17 @@ to use ifenslave.
 2. Bonding Driver Options
 =========================
 
-	Options for the bonding driver are supplied as parameters to
-the bonding module at load time.  They may be given as command line
-arguments to the insmod or modprobe command, but are usually specified
-in either the /etc/modules.conf or /etc/modprobe.conf configuration
-file, or in a distro-specific configuration file (some of which are
-detailed in the next section).
+	Options for the bonding driver are supplied as parameters to the
+bonding module at load time, or are specified via sysfs.
+
+	Module options may be given as command line arguments to the
+insmod or modprobe command, but are usually specified in either the
+/etc/modules.conf or /etc/modprobe.conf configuration file, or in a
+distro-specific configuration file (some of which are detailed in the next
+section).
+
+	Details on bonding support for sysfs is provided in the
+"Configuring Bonding Manually via Sysfs" section, below.
 
 	The available bonding driver parameters are listed below. If a
 parameter is not specified the default value is used.  When initially
@@ -787,11 +792,13 @@ the system /etc/modules.conf or /etc/modprobe.conf configuration file.
 3.2 Configuration with Initscripts Support
 ------------------------------------------
 
-	This section applies to distros using a version of initscripts
-with bonding support, for example, Red Hat Linux 9 or Red Hat
-Enterprise Linux version 3 or 4.  On these systems, the network
-initialization scripts have some knowledge of bonding, and can be
-configured to control bonding devices.
+	This section applies to distros using a recent version of
+initscripts with bonding support, for example, Red Hat Enterprise Linux
+version 3 or later, Fedora, etc.  On these systems, the network
+initialization scripts have knowledge of bonding, and can be configured to
+control bonding devices.  Note that older versions of the initscripts
+package have lower levels of support for bonding; this will be noted where
+applicable.
 
 	These distros will not automatically load the network adapter
 driver unless the ethX device is configured with an IP address.
@@ -839,11 +846,31 @@ USERCTL=no
 	Be sure to change the networking specific lines (IPADDR,
 NETMASK, NETWORK and BROADCAST) to match your network configuration.
 
-	Finally, it is necessary to edit /etc/modules.conf (or
-/etc/modprobe.conf, depending upon your distro) to load the bonding
-module with your desired options when the bond0 interface is brought
-up.  The following lines in /etc/modules.conf (or modprobe.conf) will
-load the bonding module, and select its options:
+	For later versions of initscripts, such as that found with Fedora
+7 and Red Hat Enterprise Linux version 5 (or later), it is possible, and,
+indeed, preferable, to specify the bonding options in the ifcfg-bond0
+file, e.g. a line of the format:
+
+BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=+192.168.1.254"
+
+	will configure the bond with the specified options.  The options
+specified in BONDING_OPTS are identical to the bonding module parameters
+except for the arp_ip_target field.  Each target should be included as a
+separate option and should be preceded by a '+' to indicate it should be
+added to the list of queried targets, e.g.,
+
+	arp_ip_target=+192.168.1.1 arp_ip_target=+192.168.1.2
+
+	is the proper syntax to specify multiple targets.  When specifying
+options via BONDING_OPTS, it is not necessary to edit /etc/modules.conf or
+/etc/modprobe.conf.
+
+	For older versions of initscripts that do not support
+BONDING_OPTS, it is necessary to edit /etc/modules.conf (or
+/etc/modprobe.conf, depending upon your distro) to load the bonding module
+with your desired options when the bond0 interface is brought up.  The
+following lines in /etc/modules.conf (or modprobe.conf) will load the
+bonding module, and select its options:
 
 alias bond0 bonding
 options bond0 mode=balance-alb miimon=100
@@ -858,9 +885,10 @@ up and running.
 3.2.1 Using DHCP with Initscripts
 ---------------------------------
 
-	Recent versions of initscripts (the version supplied with
-Fedora Core 3 and Red Hat Enterprise Linux 4 is reported to work) do
-have support for assigning IP information to bonding devices via DHCP.
+	Recent versions of initscripts (the versions supplied with Fedora
+Core 3 and Red Hat Enterprise Linux 4, or later versions, are reported to
+work) have support for assigning IP information to bonding devices via
+DHCP.
 
 	To configure bonding for DHCP, configure it as described
 above, except replace the line "BOOTPROTO=none" with "BOOTPROTO=dhcp"
@@ -870,18 +898,14 @@ is case sensitive.
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
+	Initscripts packages that are included with Fedora 7 and Red Hat
+Enterprise Linux 5 support multiple bonding interfaces by simply
+specifying the appropriate BONDING_OPTS= in ifcfg-bondX where X is the
+number of the bond.  This support requires sysfs support in the kernel,
+and a bonding driver of version 3.0.0 or later.  Other configurations may
+not support this method for specifying multiple bonding interfaces; for
+those instances, see the "Configuring Multiple Bonds Manually" section,
+below.
 
 3.3 Configuring Bonding Manually with Ifenslave
 -----------------------------------------------
@@ -952,15 +976,58 @@ initialization scripts lack support for configuring multiple bonds.
 options, you may wish to use the "max_bonds" module parameter,
 documented above.
 
-	To create multiple bonding devices with differing options, it
-is necessary to use bonding parameters exported by sysfs, documented
-in the section below.
+	To create multiple bonding devices with differing options, it is
+preferrable to use bonding parameters exported by sysfs, documented in the
+section below.
+
+	For versions of bonding without sysfs support, the only means to
+provide multiple instances of bonding with differing options is to load
+the bonding driver multiple times.  Note that current versions of the
+sysconfig network initialization scripts handle this automatically; if
+your distro uses these scripts, no special action is needed.  See the
+section Configuring Bonding Devices, above, if you're not sure about your
+network initialization scripts.
+
+	To load multiple instances of the module, it is necessary to
+specify a different name for each instance (the module loading system
+requires that every loaded module, even multiple instances of the same
+module, have a unique name).  This is accomplished by supplying multiple
+sets of bonding options in /etc/modprobe.conf, for example:
+
+alias bond0 bonding
+options bond0 -o bond0 mode=balance-rr miimon=100
+
+alias bond1 bonding
+options bond1 -o bond1 mode=balance-alb miimon=50
+
+	will load the bonding module two times.  The first instance is
+named "bond0" and creates the bond0 device in balance-rr mode with an
+miimon of 100.  The second instance is named "bond1" and creates the
+bond1 device in balance-alb mode with an miimon of 50.
+
+	In some circumstances (typically with older distributions),
+the above does not work, and the second bonding instance never sees
+its options.  In that case, the second options line can be substituted
+as follows:
+
+install bond1 /sbin/modprobe --ignore-install bonding -o bond1 \
+	mode=balance-alb miimon=50
 
+	This may be repeated any number of times, specifying a new and
+unique name in place of bond1 for each subsequent instance.
+
+	It has been observed that some Red Hat supplied kernels are unable
+to rename modules at load time (the "-o bond1" part).  Attempts to pass
+that option to modprobe will produce an "Operation not permitted" error.
+This has been reported on some Fedora Core kernels, and has been seen on
+RHEL 4 as well.  On kernels exhibiting this problem, it will be impossible
+to configure multiple bonds with differing parameters (as they are older
+kernels, and also lack sysfs support).
 
 3.4 Configuring Bonding Manually via Sysfs
 ------------------------------------------
 
-	Starting with version 3.0, Channel Bonding may be configured
+	Starting with version 3.0.0, Channel Bonding may be configured
 via the sysfs interface.  This interface allows dynamic configuration
 of all bonds in the system without unloading the module.  It also
 allows for adding and removing bonds at runtime.  Ifenslave is no
@@ -1005,9 +1072,6 @@ To enslave interface eth0 to bond bond0:
 To free slave eth0 from bond bond0:
 # echo -eth0 > /sys/class/net/bond0/bonding/slaves
 
-	NOTE: The bond must be up before slaves can be added.  All
-slaves are freed when the interface is brought down.
-
 	When an interface is enslaved to a bond, symlinks between the
 two are created in the sysfs filesystem.  In this case, you would get
 /sys/class/net/bond0/slave_eth0 pointing to /sys/class/net/eth0, and
@@ -1597,6 +1661,15 @@ one for each switch in the network).  This will insure that,
 regardless of which switch is active, the ARP monitor has a suitable
 target to query.
 
+	Note, also, that of late many switches now support a functionality
+generally referred to as "trunk failover."  This is a feature of the
+switch that causes the link state of a particular switch port to be set
+down (or up) when the state of another switch port goes down (or up).
+It's purpose is to propogate link failures from logically "exterior" ports
+to the logically "interior" ports that bonding is able to monitor via
+miimon.  Availability and configuration for trunk failover varies by
+switch, but this can be a viable alternative to the ARP monitor when using
+suitable switches.
 
 12. Configuring Bonding for Maximum Throughput
 ==============================================
@@ -1684,7 +1757,7 @@ balance-rr: This mode is the only mode that will permit a single
 	interfaces. It is therefore the only mode that will allow a
 	single TCP/IP stream to utilize more than one interface's
 	worth of throughput.  This comes at a cost, however: the
-	striping often results in peer systems receiving packets out
+	striping generally results in peer systems receiving packets out
 	of order, causing TCP/IP's congestion control system to kick
 	in, often by retransmitting segments.
 
@@ -1696,22 +1769,20 @@ balance-rr: This mode is the only mode that will permit a single
 	interface's worth of throughput, even after adjusting
 	tcp_reordering.
 
-	Note that this out of order delivery occurs when both the
-	sending and receiving systems are utilizing a multiple
-	interface bond.  Consider a configuration in which a
-	balance-rr bond feeds into a single higher capacity network
-	channel (e.g., multiple 100Mb/sec ethernets feeding a single
-	gigabit ethernet via an etherchannel capable switch).  In this
-	configuration, traffic sent from the multiple 100Mb devices to
-	a destination connected to the gigabit device will not see
-	packets out of order.  However, traffic sent from the gigabit
-	device to the multiple 100Mb devices may or may not see
-	traffic out of order, depending upon the balance policy of the
-	switch.  Many switches do not support any modes that stripe
-	traffic (instead choosing a port based upon IP or MAC level
-	addresses); for those devices, traffic flowing from the
-	gigabit device to the many 100Mb devices will only utilize one
-	interface.
+	Note that the fraction of packets that will be delivered out of
+	order is highly variable, and is unlikely to be zero.  The level
+	of reordering depends upon a variety of factors, including the
+	networking interfaces, the switch, and the topology of the
+	configuration.  Speaking in general terms, higher speed network
+	cards produce more reordering (due to factors such as packet
+	coalescing), and a "many to many" topology will reorder at a
+	higher rate than a "many slow to one fast" configuration.
+
+	Many switches do not support any modes that stripe traffic
+	(instead choosing a port based upon IP or MAC level addresses);
+	for those devices, traffic for a particular connection flowing
+	through the switch to a balance-rr bond will not utilize greater
+	than one interface's worth of bandwidth.
 
 	If you are utilizing protocols other than TCP/IP, UDP for
 	example, and your application can tolerate out of order
@@ -1911,6 +1982,10 @@ Failover may be delayed via the downdelay bonding module option.
 13.2 Duplicated Incoming Packets
 --------------------------------
 
+	NOTE: Starting with version 3.0.2, the bonding driver has logic to
+suppress duplicate packets, which should largely eliminate this problem.
+The following description is kept for reference.
+
 	It is not uncommon to observe a short burst of duplicated
 traffic when the bonding device is first used, or after it has been
 idle for some period of time.  This is most easily observed by issuing
@@ -2071,6 +2146,9 @@ The new driver was designed to be SMP safe from the start.
 EtherExpress PRO/100 and a 3com 3c905b, for example).  For most modes,
 devices need not be of the same speed.
 
+	Starting with version 3.2.1, bonding also supports Infiniband
+slaves in active-backup mode.
+
 3.  How many bonding devices can I have?
 
 	There is no limit.
@@ -2129,11 +2207,15 @@ switches currently available support 802.3ad.
 
 8.  Where does a bonding device get its MAC address from?
 
-	If not explicitly configured (with ifconfig or ip link), the
-MAC address of the bonding device is taken from its first slave
-device.  This MAC address is then passed to all following slaves and
-remains persistent (even if the first slave is removed) until the
-bonding device is brought down or reconfigured.
+	When using slave devices that have fixed MAC addresses, or when
+the fail_over_mac option is enabled, the bonding device's MAC address is
+the MAC address of the active slave.
+
+	For other configurations, if not explicitly configured (with
+ifconfig or ip link), the MAC address of the bonding device is taken from
+its first slave device.  This MAC address is then passed to all following
+slaves and remains persistent (even if the first slave is removed) until
+the bonding device is brought down or reconfigured.
 
 	If you wish to change the MAC address, you can set it with
 ifconfig or ip link:
