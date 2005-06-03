From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.12-rc5] bonding: documentation update
Date: Fri, 03 Jun 2005 11:48:09 -0700
Message-ID: <200506031848.j53ImAwZ031354@death.nxdomain.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Documentation update: added some more configuration info,
(hopefully) better examples, updated some out of date info, and a bonus
pass through ispell to banish the "paramters."

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


diff -ur linux-2.6.12-rc5/Documentation/networking/bonding.txt linux-doc/Documentation/networking/bonding.txt
--- linux-2.6.12-rc5/Documentation/networking/bonding.txt	2005-06-03 11:29:04.394823672 -0700
+++ linux-doc/Documentation/networking/bonding.txt	2005-06-03 11:29:41.143237064 -0700
@@ -1,5 +1,7 @@
 
-                   Linux Ethernet Bonding Driver HOWTO
+		Linux Ethernet Bonding Driver HOWTO
+
+		Latest update: 2 June 2005
 
 Initial release : Thomas Davis <tadavis at lbl.gov>
 Corrections, HA extensions : 2000/10/03-15 :
@@ -11,15 +13,22 @@
 
 Reorganized and updated Feb 2005 by Jay Vosburgh
 
-Note :
-------
+Introduction
+============
+
+	The Linux bonding driver provides a method for aggregating
+multiple network interfaces into a single logical "bonded" interface.
+The behavior of the bonded interfaces depends upon the mode; generally
+speaking, modes provide either hot standby or load balancing services.
+Additionally, link integrity monitoring may be performed.
 	
-The bonding driver originally came from Donald Becker's beowulf patches for
-kernel 2.0. It has changed quite a bit since, and the original tools from
-extreme-linux and beowulf sites will not work with this version of the driver.
+	The bonding driver originally came from Donald Becker's
+beowulf patches for kernel 2.0. It has changed quite a bit since, and
+the original tools from extreme-linux and beowulf sites will not work
+with this version of the driver.
 
-For new versions of the driver, patches for older kernels and the updated
-userspace tools, please follow the links at the end of this file.
+	For new versions of the driver, updated userspace tools, and
+who to ask for help, please follow the links at the end of this file.
 
 Table of Contents
 =================
@@ -30,9 +39,13 @@
 
 3. Configuring Bonding Devices
 3.1	Configuration with sysconfig support
+3.1.1		Using DHCP with sysconfig
+3.1.2		Configuring Multiple Bonds with sysconfig
 3.2	Configuration with initscripts support
+3.2.1		Using DHCP with initscripts
+3.2.2		Configuring Multiple Bonds with initscripts
 3.3	Configuring Bonding Manually
-3.4	Configuring Multiple Bonds
+3.3.1		Configuring Multiple Bonds Manually
 
 5. Querying Bonding Configuration
 5.1	Bonding Configuration
@@ -56,21 +69,28 @@
 
 11. Promiscuous mode
 
-12. High Availability Information
+12. Configuring Bonding for High Availability
 12.1	High Availability in a Single Switch Topology
-12.1.1		Bonding Mode Selection for Single Switch Topology
-12.1.2		Link Monitoring for Single Switch Topology
 12.2	High Availability in a Multiple Switch Topology
-12.2.1		Bonding Mode Selection for Multiple Switch Topology
-12.2.2		Link Monitoring for Multiple Switch Topology
-12.3	Switch Behavior Issues for High Availability
+12.2.1		HA Bonding Mode Selection for Multiple Switch Topology
+12.2.2		HA Link Monitoring for Multiple Switch Topology
+
+13. Configuring Bonding for Maximum Throughput
+13.1	Maximum Throughput in a Single Switch Topology
+13.1.1		MT Bonding Mode Selection for Single Switch Topology
+13.1.2		MT Link Monitoring for Single Switch Topology
+13.2	Maximum Throughput in a Multiple Switch Topology
+13.2.1		MT Bonding Mode Selection for Multiple Switch Topology
+13.2.2		MT Link Monitoring for Multiple Switch Topology
 
-13. Hardware Specific Considerations
-13.1	IBM BladeCenter
+14. Switch Behavior Issues
 
-14. Frequently Asked Questions
+15. Hardware Specific Considerations
+15.1	IBM BladeCenter
 
-15. Resources and Links
+16. Frequently Asked Questions
+
+17. Resources and Links
 
 
 1. Bonding Driver Installation
@@ -86,16 +106,10 @@
 1.1 Configure and build the kernel with bonding
 -----------------------------------------------
 
-	The latest version of the bonding driver is available in the
+	The current version of the bonding driver is available in the
 drivers/net/bonding subdirectory of the most recent kernel source
-(which is available on http://kernel.org).
-
-	Prior to the 2.4.11 kernel, the bonding driver was maintained
-largely outside the kernel tree; patches for some earlier kernels are
-available on the bonding sourceforge site, although those patches are
-still several years out of date.  Most users will want to use either
-the most recent kernel from kernel.org or whatever kernel came with
-their distro.
+(which is available on http://kernel.org).  Most users "rolling their
+own" will want to use the most recent kernel from kernel.org.
 
 	Configure kernel with "make menuconfig" (or "make xconfig" or
 "make config"), then select "Bonding driver support" in the "Network
@@ -103,8 +117,8 @@
 driver as module since it is currently the only way to pass parameters
 to the driver or configure more than one bonding device.
 
-	Build and install the new kernel and modules, then proceed to
-step 2.
+	Build and install the new kernel and modules, then continue
+below to install ifenslave.
 
 1.2 Install ifenslave Control Utility
 -------------------------------------
@@ -147,9 +161,9 @@
 	Options for the bonding driver are supplied as parameters to
 the bonding module at load time.  They may be given as command line
 arguments to the insmod or modprobe command, but are usually specified
-in either the /etc/modprobe.conf configuration file, or in a
-distro-specific configuration file (some of which are detailed in the
-next section).
+in either the /etc/modules.conf or /etc/modprobe.conf configuration
+file, or in a distro-specific configuration file (some of which are
+detailed in the next section).
 
 	The available bonding driver parameters are listed below. If a
 parameter is not specified the default value is used.  When initially
@@ -162,34 +176,34 @@
 support at least miimon, so there is really no reason not to use it.
 
 	Options with textual values will accept either the text name
-	or, for backwards compatibility, the option value.  E.g.,
-	"mode=802.3ad" and "mode=4" set the same mode.
+or, for backwards compatibility, the option value.  E.g.,
+"mode=802.3ad" and "mode=4" set the same mode.
 
 	The parameters are as follows:
 
 arp_interval
 
-	Specifies the ARP monitoring frequency in milli-seconds. If
-	ARP monitoring is used in a load-balancing mode (mode 0 or 2),
-	the switch should be configured in a mode that evenly
-	distributes packets across all links - such as round-robin. If
-	the switch is configured to distribute the packets in an XOR
+	Specifies the ARP link monitoring frequency in milliseconds.
+	If ARP monitoring is used in an etherchannel compatible mode
+	(modes 0 and 2), the switch should be configured in a mode
+	that evenly distributes packets across all links. If the
+	switch is configured to distribute the packets in an XOR
 	fashion, all replies from the ARP targets will be received on
 	the same link which could cause the other team members to
-	fail. ARP monitoring should not be used in conjunction with
-	miimon. A value of 0 disables ARP monitoring. The default
+	fail.  ARP monitoring should not be used in conjunction with
+	miimon.  A value of 0 disables ARP monitoring.  The default
 	value is 0.
 
 arp_ip_target
 
-	Specifies the ip addresses to use when arp_interval is > 0.
-	These are the targets of the ARP request sent to determine the
-	health of the link to the targets.  Specify these values in
-	ddd.ddd.ddd.ddd format.  Multiple ip adresses must be
-	seperated by a comma.  At least one IP address must be given
-	for ARP monitoring to function.  The maximum number of targets
-	that can be specified is 16.  The default value is no IP
-	addresses.
+	Specifies the IP addresses to use as ARP monitoring peers when
+	arp_interval is > 0.  These are the targets of the ARP request
+	sent to determine the health of the link to the targets.
+	Specify these values in ddd.ddd.ddd.ddd format.  Multiple IP
+	addresses must be separated by a comma.  At least one IP
+	address must be given for ARP monitoring to function.  The
+	maximum number of targets that can be specified is 16.  The
+	default value is no IP addresses.
 
 downdelay
 
@@ -207,11 +221,13 @@
 	are:
 
 	slow or 0
-		Request partner to transmit LACPDUs every 30 seconds (default)
+		Request partner to transmit LACPDUs every 30 seconds
 
 	fast or 1
 		Request partner to transmit LACPDUs every 1 second
 
+	The default is slow.
+
 max_bonds
 
 	Specifies the number of bonding devices to create for this
@@ -221,10 +237,11 @@
 
 miimon
 
-	Specifies the frequency in milli-seconds that MII link
-	monitoring will occur.  A value of zero disables MII link
-	monitoring.  A value of 100 is a good starting point.  The
-	use_carrier option, below, affects how the link state is
+	Specifies the MII link monitoring frequency in milliseconds.
+	This determines how often the link state of each slave is
+	inspected for link failures.  A value of zero disables MII
+	link monitoring.  A value of 100 is a good starting point.
+	The use_carrier option, below, affects how the link state is
 	determined.  See the High Availability section for additional
 	information.  The default value is 0.
 
@@ -270,7 +287,7 @@
 		duplex settings.  Utilizes all slaves in the active
 		aggregator according to the 802.3ad specification.
 
-		Pre-requisites:
+		Prerequisites:
 
 		1. Ethtool support in the base drivers for retrieving
 		the speed and duplex of each slave.
@@ -333,7 +350,7 @@
 
 		When a link is reconnected or a new slave joins the
 		bond the receive traffic is redistributed among all
-		active slaves in the bond by intiating ARP Replies
+		active slaves in the bond by initiating ARP Replies
 		with the selected mac address to each of the
 		clients. The updelay parameter (detailed below) must
 		be set to a value equal or greater than the switch's
@@ -448,8 +465,9 @@
 slave devices.  On SLES 9, this is most easily done by running the
 yast2 sysconfig configuration utility.  The goal is for to create an
 ifcfg-id file for each slave device.  The simplest way to accomplish
-this is to configure the devices for DHCP.  The name of the
-configuration file for each device will be of the form:
+this is to configure the devices for DHCP (this is only to get the
+file ifcfg-id file created; see below for some issues with DHCP).  The
+name of the configuration file for each device will be of the form:
 
 ifcfg-id-xx:xx:xx:xx:xx:xx
 
@@ -459,7 +477,7 @@
 	Once the set of ifcfg-id-xx:xx:xx:xx:xx:xx files has been
 created, it is necessary to edit the configuration files for the slave
 devices (the MAC addresses correspond to those of the slave devices).
-Before editing, the file will contain muliple lines, and will look
+Before editing, the file will contain multiple lines, and will look
 something like this:
 
 BOOTPROTO='dhcp'
@@ -501,11 +519,6 @@
 	Replace the sample BROADCAST, IPADDR, NETMASK and NETWORK
 values with the appropriate values for your network.
 
-	Note that configuring the bonding device with BOOTPROTO='dhcp'
-does not work; the scripts attempt to obtain the device address from
-DHCP prior to adding any of the slave devices.  Without active slaves,
-the DHCP requests are not sent to the network.
-
 	The STARTMODE specifies when the device is brought online.
 The possible values are:
 
@@ -544,7 +557,7 @@
 	Note that the network control script (/sbin/ifdown) will
 remove the bonding module as part of the network shutdown processing,
 so it is not necessary to remove the module by hand if, e.g., the
-module paramters have changed.
+module parameters have changed.
 
 	Also, at this writing, YaST/YaST2 will not manage bonding
 devices (they do not show bonding interfaces on its list of network
@@ -559,12 +572,37 @@
 	Note that the template does not document the various BONDING_
 settings described above, but does describe many of the other options.
 
+3.1.1 Using DHCP with sysconfig
+-------------------------------
+
+	Under sysconfig, configuring a device with BOOTPROTO='dhcp'
+will cause it to query DHCP for its IP address information.  At this
+writing, this does not function for bonding devices; the scripts
+attempt to obtain the device address from DHCP prior to adding any of
+the slave devices.  Without active slaves, the DHCP requests are not
+sent to the network.
+
+3.1.2 Configuring Multiple Bonds with sysconfig
+-----------------------------------------------
+
+	The sysconfig network initialization system is capable of
+handling multiple bonding devices.  All that is necessary is for each
+bonding instance to have an appropriately configured ifcfg-bondX file
+(as described above).  Do not specify the "max_bonds" parameter to any
+instance of bonding, as this will confuse sysconfig.  If you require
+multiple bonding devices with identical parameters, create multiple
+ifcfg-bondX files.
+
+	Because the sysconfig scripts supply the bonding module
+options in the ifcfg-bondX file, it is not necessary to add them to
+the system /etc/modules.conf or /etc/modprobe.conf configuration file.
+
 3.2 Configuration with initscripts support
 ------------------------------------------
 
 	This section applies to distros using a version of initscripts
 with bonding support, for example, Red Hat Linux 9 or Red Hat
-Enterprise Linux version 3.  On these systems, the network
+Enterprise Linux version 3 or 4.  On these systems, the network
 initialization scripts have some knowledge of bonding, and can be
 configured to control bonding devices.
 
@@ -614,10 +652,11 @@
 	Be sure to change the networking specific lines (IPADDR,
 NETMASK, NETWORK and BROADCAST) to match your network configuration.
 
-	Finally, it is necessary to edit /etc/modules.conf to load the
-bonding module when the bond0 interface is brought up.  The following
-sample lines in /etc/modules.conf will load the bonding module, and
-select its options:
+	Finally, it is necessary to edit /etc/modules.conf (or
+/etc/modprobe.conf, depending upon your distro) to load the bonding
+module with your desired options when the bond0 interface is brought
+up.  The following lines in /etc/modules.conf (or modprobe.conf) will
+load the bonding module, and select its options:
 
 alias bond0 bonding
 options bond0 mode=balance-alb miimon=100
@@ -629,6 +668,33 @@
 will restart the networking subsystem and your bond link should be now
 up and running.
 
+3.2.1 Using DHCP with initscripts
+---------------------------------
+
+	Recent versions of initscripts (the version supplied with
+Fedora Core 3 and Red Hat Enterprise Linux 4 is reported to work) do
+have support for assigning IP information to bonding devices via DHCP.
+
+	To configure bonding for DHCP, configure it as described
+above, except replace the line "BOOTPROTO=none" with "BOOTPROTO=dhcp"
+and add a line consisting of "TYPE=Bonding".  Note that the TYPE value
+is case sensitive.
+
+3.2.2 Configuring Multiple Bonds with initscripts
+-------------------------------------------------
+
+	At this writing, the initscripts package does not directly
+support loading the bonding driver multiple times, so the process for
+doing so is the same as described in the "Configuring Multiple Bonds
+Manually" section, below.
+
+	NOTE: It has been observed that some Red Hat supplied kernels
+are apparently unable to rename modules at load time (the "-obonding1"
+part).  Attempts to pass that option to modprobe will produce an
+"Operation not permitted" error.  This has been reported on some
+Fedora Core kernels, and has been seen on RHEL 4 as well.  On kernels
+exhibiting this problem, it will be impossible to configure multiple
+bonds with differing parameters.
 
 3.3 Configuring Bonding Manually
 --------------------------------
@@ -638,10 +704,11 @@
 knowledge of bonding.  One such distro is SuSE Linux Enterprise Server
 version 8.
 
-	The general methodology for these systems is to place the
-bonding module parameters into /etc/modprobe.conf, then add modprobe
-and/or ifenslave commands to the system's global init script.  The
-name of the global init script differs; for sysconfig, it is
+	The general method for these systems is to place the bonding
+module parameters into /etc/modules.conf or /etc/modprobe.conf (as
+appropriate for the installed distro), then add modprobe and/or
+ifenslave commands to the system's global init script.  The name of
+the global init script differs; for sysconfig, it is
 /etc/init.d/boot.local and for initscripts it is /etc/rc.d/rc.local.
 
 	For example, if you wanted to make a simple bond of two e100
@@ -649,7 +716,7 @@
 reboots, edit the appropriate file (/etc/init.d/boot.local or
 /etc/rc.d/rc.local), and add the following:
 
-modprobe bonding -obond0 mode=balance-alb miimon=100
+modprobe bonding mode=balance-alb miimon=100
 modprobe e100
 ifconfig bond0 192.168.1.1 netmask 255.255.255.0 up
 ifenslave bond0 eth0
@@ -657,11 +724,7 @@
 
 	Replace the example bonding module parameters and bond0
 network configuration (IP address, netmask, etc) with the appropriate
-values for your configuration.  The above example loads the bonding
-module with the name "bond0," this simplifies the naming if multiple
-bonding modules are loaded (each successive instance of the module is
-given a different name, and the module instance names match the
-bonding interface names).
+values for your configuration.
 
 	Unfortunately, this method will not provide support for the
 ifup and ifdown scripts on the bond devices.  To reload the bonding
@@ -684,20 +747,23 @@
 the following:
 
 # ifconfig bond0 down
-# rmmod bond0
+# rmmod bonding
 # rmmod e100
 
 	Again, for convenience, it may be desirable to create a script
 with these commands.
 
 
-3.4 Configuring Multiple Bonds
-------------------------------
+3.3.1 Configuring Multiple Bonds Manually
+-----------------------------------------
 
 	This section contains information on configuring multiple
-bonding devices with differing options.  If you require multiple
-bonding devices, but all with the same options, see the "max_bonds"
-module paramter, documented above.
+bonding devices with differing options for those systems whose network
+initialization scripts lack support for configuring multiple bonds.
+
+	If you require multiple bonding devices, but all with the same
+options, you may wish to use the "max_bonds" module parameter,
+documented above.
 
 	To create multiple bonding devices with differing options, it
 is necessary to load the bonding driver multiple times.  Note that
@@ -724,11 +790,16 @@
 miimon of 100.  The second instance is named "bond1" and creates the
 bond1 device in balance-alb mode with an miimon of 50.
 
+	In some circumstances (typically with older distributions),
+the above does not work, and the second bonding instance never sees
+its options.  In that case, the second options line can be substituted
+as follows:
+
+install bonding1 /sbin/modprobe bonding -obond1 mode=balance-alb miimon=50
+
 	This may be repeated any number of times, specifying a new and
-unique name in place of bond0 or bond1 for each instance.
+unique name in place of bond1 for each subsequent instance.
 
-	When the appropriate module paramters are in place, then
-configure bonding according to the instructions for your distro.
 
 5. Querying Bonding Configuration 
 =================================
@@ -846,8 +917,8 @@
 self generated packets.
 
 	For reasons of simplicity, and to support the use of adapters
-that can do VLAN hardware acceleration offloding, the bonding
-interface declares itself as fully hardware offloaing capable, it gets
+that can do VLAN hardware acceleration offloading, the bonding
+interface declares itself as fully hardware offloading capable, it gets
 the add_vid/kill_vid notifications to gather the necessary
 information, and it propagates those actions to the slaves.  In case
 of mixed adapter types, hardware accelerated tagged packets that
@@ -880,7 +951,7 @@
 matches the hardware address of the VLAN interfaces.
 
 	Note that changing a VLAN interface's HW address would set the
-underlying device -- i.e. the bonding interface -- to promiscouos
+underlying device -- i.e. the bonding interface -- to promiscuous
 mode, which might not be what you want.
 
 
@@ -923,7 +994,7 @@
 an additional target (or several) increases the reliability of the ARP
 monitoring.
 
-	Multiple ARP targets must be seperated by commas as follows:
+	Multiple ARP targets must be separated by commas as follows:
 
 # example options for ARP monitoring with three targets
 alias bond0 bonding
@@ -1045,7 +1116,7 @@
 	This will, when loading the bonding module, rather than
 performing the normal action, instead execute the provided command.
 This command loads the device drivers in the order needed, then calls
-modprobe with --ingore-install to cause the normal action to then take
+modprobe with --ignore-install to cause the normal action to then take
 place.  Full documentation on this can be found in the modprobe.conf
 and modprobe manual pages.
 
@@ -1130,14 +1201,14 @@
 common to enable promiscuous mode on the device, so that all traffic
 is seen (instead of seeing only traffic destined for the local host).
 The bonding driver handles promiscuous mode changes to the bonding
-master device (e.g., bond0), and propogates the setting to the slave
+master device (e.g., bond0), and propagates the setting to the slave
 devices.
 
 	For the balance-rr, balance-xor, broadcast, and 802.3ad modes,
-the promiscuous mode setting is propogated to all slaves.
+the promiscuous mode setting is propagated to all slaves.
 
 	For the active-backup, balance-tlb and balance-alb modes, the
-promiscuous mode setting is propogated only to the active slave.
+promiscuous mode setting is propagated only to the active slave.
 
 	For balance-tlb mode, the active slave is the slave currently
 receiving inbound traffic.
@@ -1148,46 +1219,182 @@
 
 	For the active-backup, balance-tlb and balance-alb modes, when
 the active slave changes (e.g., due to a link failure), the
-promiscuous setting will be propogated to the new active slave.
+promiscuous setting will be propagated to the new active slave.
 
-12. High Availability Information
-=================================
+12. Configuring Bonding for High Availability
+=============================================
 
 	High Availability refers to configurations that provide
 maximum network availability by having redundant or backup devices,
-links and switches between the host and the rest of the world.
-
-	There are currently two basic methods for configuring to
-maximize availability. They are dependent on the network topology and
-the primary goal of the configuration, but in general, a configuration
-can be optimized for maximum available bandwidth, or for maximum
-network availability.
+links or switches between the host and the rest of the world.  The
+goal is to provide the maximum availability of network connectivity
+(i.e., the network always works), even though other configurations
+could provide higher throughput.
 
 12.1 High Availability in a Single Switch Topology
 --------------------------------------------------
 
-	If two hosts (or a host and a switch) are directly connected
-via multiple physical links, then there is no network availability
-penalty for optimizing for maximum bandwidth: there is only one switch
-(or peer), so if it fails, you have no alternative access to fail over
-to.
-
-Example 1 : host to switch (or other host)
-
-          +----------+                          +----------+
-          |          |eth0                  eth0|  switch  |
-          | Host A   +--------------------------+    or    |
-          |          +--------------------------+  other   |
-          |          |eth1                  eth1|  host    |
-          +----------+                          +----------+
+	If two hosts (or a host and a single switch) are directly
+connected via multiple physical links, then there is no availability
+penalty to optimizing for maximum bandwidth.  In this case, there is
+only one switch (or peer), so if it fails, there is no alternative
+access to fail over to.  Additionally, the bonding load balance modes
+support link monitoring of their members, so if individual links fail,
+the load will be rebalanced across the remaining devices.
+
+	See Section 13, "Configuring Bonding for Maximum Throughput"
+for information on configuring bonding with one peer device.
 
+12.2 High Availability in a Multiple Switch Topology
+----------------------------------------------------
 
-12.1.1 Bonding Mode Selection for single switch topology
---------------------------------------------------------
+	With multiple switches, the configuration of bonding and the
+network changes dramatically.  In multiple switch topologies, there is
+a trade off between network availability and usable bandwidth.
+
+	Below is a sample network, configured to maximize the
+availability of the network:
+
+                |                                     |
+                |port3                           port3|
+          +-----+----+                          +-----+----+
+          |          |port2       ISL      port2|          |
+          | switch A +--------------------------+ switch B |
+          |          |                          |          |
+          +-----+----+                          +-----++---+
+                |port1                           port1|
+                |             +-------+               |
+                +-------------+ host1 +---------------+
+                         eth0 +-------+ eth1
+
+	In this configuration, there is a link between the two
+switches (ISL, or inter switch link), and multiple ports connecting to
+the outside world ("port3" on each switch).  There is no technical
+reason that this could not be extended to a third switch.
+
+12.2.1 HA Bonding Mode Selection for Multiple Switch Topology
+-------------------------------------------------------------
+
+	In a topology such as the example above, the active-backup and
+broadcast modes are the only useful bonding modes when optimizing for
+availability; the other modes require all links to terminate on the
+same peer for them to behave rationally.
+
+active-backup: This is generally the preferred mode, particularly if
+	the switches have an ISL and play together well.  If the
+	network configuration is such that one switch is specifically
+	a backup switch (e.g., has lower capacity, higher cost, etc),
+	then the primary option can be used to insure that the
+	preferred link is always used when it is available.
+
+broadcast: This mode is really a special purpose mode, and is suitable
+	only for very specific needs.  For example, if the two
+	switches are not connected (no ISL), and the networks beyond
+	them are totally independent.  In this case, if it is
+	necessary for some specific one-way traffic to reach both
+	independent networks, then the broadcast mode may be suitable.
+
+12.2.2 HA Link Monitoring Selection for Multiple Switch Topology
+----------------------------------------------------------------
+
+	The choice of link monitoring ultimately depends upon your
+switch.  If the switch can reliably fail ports in response to other
+failures, then either the MII or ARP monitors should work.  For
+example, in the above example, if the "port3" link fails at the remote
+end, the MII monitor has no direct means to detect this.  The ARP
+monitor could be configured with a target at the remote end of port3,
+thus detecting that failure without switch support.
+
+	In general, however, in a multiple switch topology, the ARP
+monitor can provide a higher level of reliability in detecting end to
+end connectivity failures (which may be caused by the failure of any
+individual component to pass traffic for any reason).  Additionally,
+the ARP monitor should be configured with multiple targets (at least
+one for each switch in the network).  This will insure that,
+regardless of which switch is active, the ARP monitor has a suitable
+target to query.
+
+
+13. Configuring Bonding for Maximum Throughput
+==============================================
+
+13.1 Maximizing Throughput in a Single Switch Topology
+------------------------------------------------------
+
+	In a single switch configuration, the best method to maximize
+throughput depends upon the application and network environment.  The
+various load balancing modes each have strengths and weaknesses in
+different environments, as detailed below.
+
+	For this discussion, we will break down the topologies into
+two categories.  Depending upon the destination of most traffic, we
+categorize them into either "gatewayed" or "local" configurations.
+
+	In a gatewayed configuration, the "switch" is acting primarily
+as a router, and the majority of traffic passes through this router to
+other networks.  An example would be the following:
+
+
+     +----------+                     +----------+
+     |          |eth0            port1|          | to other networks
+     | Host A   +---------------------+ router   +------------------->
+     |          +---------------------+          | Hosts B and C are out
+     |          |eth1            port2|          | here somewhere
+     +----------+                     +----------+
+
+	The router may be a dedicated router device, or another host
+acting as a gateway.  For our discussion, the important point is that
+the majority of traffic from Host A will pass through the router to
+some other network before reaching its final destination.
+
+	In a gatewayed network configuration, although Host A may
+communicate with many other systems, all of its traffic will be sent
+and received via one other peer on the local network, the router.
+
+	Note that the case of two systems connected directly via
+multiple physical links is, for purposes of configuring bonding, the
+same as a gatewayed configuration.  In that case, it happens that all
+traffic is destined for the "gateway" itself, not some other network
+beyond the gateway.
+
+	In a local configuration, the "switch" is acting primarily as
+a switch, and the majority of traffic passes through this switch to
+reach other stations on the same network.  An example would be the
+following:
+
+    +----------+            +----------+       +--------+
+    |          |eth0   port1|          +-------+ Host B |
+    |  Host A  +------------+  switch  |port3  +--------+
+    |          +------------+          |                  +--------+
+    |          |eth1   port2|          +------------------+ Host C |
+    +----------+            +----------+port4             +--------+
+
+
+	Again, the switch may be a dedicated switch device, or another
+host acting as a gateway.  For our discussion, the important point is
+that the majority of traffic from Host A is destined for other hosts
+on the same local network (Hosts B and C in the above example).
+
+	In summary, in a gatewayed configuration, traffic to and from
+the bonded device will be to the same MAC level peer on the network
+(the gateway itself, i.e., the router), regardless of its final
+destination.  In a local configuration, traffic flows directly to and
+from the final destinations, thus, each destination (Host B, Host C)
+will be addressed directly by their individual MAC addresses.
+
+	This distinction between a gatewayed and a local network
+configuration is important because many of the load balancing modes
+available use the MAC addresses of the local network source and
+destination to make load balancing decisions.  The behavior of each
+mode is described below.
+
+
+13.1.1 MT Bonding Mode Selection for Single Switch Topology
+-----------------------------------------------------------
 
 	This configuration is the easiest to set up and to understand,
 although you will have to decide which bonding mode best suits your
-needs.  The tradeoffs for each mode are detailed below:
+needs.  The trade offs for each mode are detailed below:
 
 balance-rr: This mode is the only mode that will permit a single
 	TCP/IP connection to stripe traffic across multiple
@@ -1206,6 +1413,23 @@
 	interface's worth of throughput, even after adjusting
 	tcp_reordering.
 
+	Note that this out of order delivery occurs when both the
+	sending and receiving systems are utilizing a multiple
+	interface bond.  Consider a configuration in which a
+	balance-rr bond feeds into a single higher capacity network
+	channel (e.g., multiple 100Mb/sec ethernets feeding a single
+	gigabit ethernet via an etherchannel capable switch).  In this
+	configuration, traffic sent from the multiple 100Mb devices to
+	a destination connected to the gigabit device will not see
+	packets out of order.  However, traffic sent from the gigabit
+	device to the multiple 100Mb devices may or may not see
+	traffic out of order, depending upon the balance policy of the
+	switch.  Many switches do not support any modes that stripe
+	traffic (instead choosing a port based upon IP or MAC level
+	addresses); for those devices, traffic flowing from the
+	gigabit device to the many 100Mb devices will only utilize one
+	interface.
+
 	If you are utilizing protocols other than TCP/IP, UDP for
 	example, and your application can tolerate out of order
 	delivery, then this mode can allow for single stream datagram
@@ -1220,16 +1444,21 @@
 	connected to the same peer as the primary.  In this case, a
 	load balancing mode (with link monitoring) will provide the
 	same level of network availability, but with increased
-	available bandwidth.  On the plus side, it does not require
-	any configuration of the switch.
+	available bandwidth.  On the plus side, active-backup mode
+	does not require any configuration of the switch, so it may
+	have value if the hardware available does not support any of
+	the load balance modes.
 
 balance-xor: This mode will limit traffic such that packets destined
 	for specific peers will always be sent over the same
 	interface.  Since the destination is determined by the MAC
-	addresses involved, this may be desirable if you have a large
-	network with many hosts.  It is likely to be suboptimal if all
-	your traffic is passed through a single router, however.  As
-	with balance-rr, the switch ports need to be configured for
+	addresses involved, this mode works best in a "local" network
+	configuration (as described above), with destinations all on
+	the same local network.  This mode is likely to be suboptimal
+	if all your traffic is passed through a single router (i.e., a
+	"gatewayed" network configuration, as described above).
+
+	As with balance-rr, the switch ports need to be configured for
 	"etherchannel" or "trunking."
 
 broadcast: Like active-backup, there is not much advantage to this
@@ -1241,122 +1470,128 @@
 	protocol includes automatic configuration of the aggregates,
 	so minimal manual configuration of the switch is needed
 	(typically only to designate that some set of devices is
-	usable for 802.3ad).  The 802.3ad standard also mandates that
-	frames be delivered in order (within certain limits), so in
-	general single connections will not see misordering of
+	available for 802.3ad).  The 802.3ad standard also mandates
+	that frames be delivered in order (within certain limits), so
+	in general single connections will not see misordering of
 	packets.  The 802.3ad mode does have some drawbacks: the
 	standard mandates that all devices in the aggregate operate at
 	the same speed and duplex.  Also, as with all bonding load
 	balance modes other than balance-rr, no single connection will
 	be able to utilize more than a single interface's worth of
-	bandwidth.  Additionally, the linux bonding 802.3ad
-	implementation distributes traffic by peer (using an XOR of
-	MAC addresses), so in general all traffic to a particular
-	destination will use the same interface.  Finally, the 802.3ad
-	mode mandates the use of the MII monitor, therefore, the ARP
-	monitor is not available in this mode.
-
-balance-tlb: This mode is also a good choice for this type of
-	topology.  It has no special switch configuration
-	requirements, and balances outgoing traffic by peer, in a
-	vaguely intelligent manner (not a simple XOR as in balance-xor
-	or 802.3ad mode), so that unlucky MAC addresses will not all
-	"bunch up" on a single interface.  Interfaces may be of
-	differing speeds.  On the down side, in this mode all incoming
-	traffic arrives over a single interface, this mode requires
-	certain ethtool support in the network device driver of the
-	slave interfaces, and the ARP monitor is not available.
-
-balance-alb: This mode is everything that balance-tlb is, and more. It
-	has all of the features (and restrictions) of balance-tlb, and
-	will also balance incoming traffic from peers (as described in
-	the Bonding Module Options section, above).  The only extra
-	down side to this mode is that the network device driver must
-	support changing the hardware address while the device is
-	open.
+	bandwidth.  
 
-12.1.2 Link Monitoring for Single Switch Topology
--------------------------------------------------
+	Additionally, the linux bonding 802.3ad implementation
+	distributes traffic by peer (using an XOR of MAC addresses),
+	so in a "gatewayed" configuration, all outgoing traffic will
+	generally use the same device.  Incoming traffic may also end
+	up on a single device, but that is dependent upon the
+	balancing policy of the peer's 8023.ad implementation.  In a
+	"local" configuration, traffic will be distributed across the
+	devices in the bond.
+
+	Finally, the 802.3ad mode mandates the use of the MII monitor,
+	therefore, the ARP monitor is not available in this mode.
+
+balance-tlb: The balance-tlb mode balances outgoing traffic by peer.
+	Since the balancing is done according to MAC address, in a
+	"gatewayed" configuration (as described above), this mode will
+	send all traffic across a single device.  However, in a
+	"local" network configuration, this mode balances multiple
+	local network peers across devices in a vaguely intelligent
+	manner (not a simple XOR as in balance-xor or 802.3ad mode),
+	so that mathematically unlucky MAC addresses (i.e., ones that
+	XOR to the same value) will not all "bunch up" on a single
+	interface.
+
+	Unlike 802.3ad, interfaces may be of differing speeds, and no
+	special switch configuration is required.  On the down side,
+	in this mode all incoming traffic arrives over a single
+	interface, this mode requires certain ethtool support in the
+	network device driver of the slave interfaces, and the ARP
+	monitor is not available.
+
+balance-alb: This mode is everything that balance-tlb is, and more.
+	It has all of the features (and restrictions) of balance-tlb,
+	and will also balance incoming traffic from local network
+	peers (as described in the Bonding Module Options section,
+	above).
+
+	The only additional down side to this mode is that the network
+	device driver must support changing the hardware address while
+	the device is open.
+
+13.1.2 MT Link Monitoring for Single Switch Topology
+----------------------------------------------------
 
 	The choice of link monitoring may largely depend upon which
 mode you choose to use.  The more advanced load balancing modes do not
 support the use of the ARP monitor, and are thus restricted to using
-the MII monitor (which does not provide as high a level of assurance
-as the ARP monitor).
-
-
-12.2 High Availability in a Multiple Switch Topology
-----------------------------------------------------
-
-	With multiple switches, the configuration of bonding and the
-network changes dramatically.  In multiple switch topologies, there is
-a tradeoff between network availability and usable bandwidth.
-
-	Below is a sample network, configured to maximize the
-availability of the network:
-
-                |                                     |
-                |port3                           port3|
-          +-----+----+                          +-----+----+
-          |          |port2       ISL      port2|          |
-          | switch A +--------------------------+ switch B |
-          |          |                          |          |
-          +-----+----+                          +-----++---+
-                |port1                           port1|
-                |             +-------+               |
-                +-------------+ host1 +---------------+
-                         eth0 +-------+ eth1
-
-	In this configuration, there is a link between the two
-switches (ISL, or inter switch link), and multiple ports connecting to
-the outside world ("port3" on each switch).  There is no technical
-reason that this could not be extended to a third switch.
+the MII monitor (which does not provide as high a level of end to end
+assurance as the ARP monitor).
 
-12.2.1 Bonding Mode Selection for Multiple Switch Topology
-----------------------------------------------------------
+13.2 Maximum Throughput in a Multiple Switch Topology
+-----------------------------------------------------
 
-	In a topology such as this, the active-backup and broadcast
-modes are the only useful bonding modes; the other modes require all
-links to terminate on the same peer for them to behave rationally.
-
-active-backup: This is generally the preferred mode, particularly if
-	the switches have an ISL and play together well.  If the
-	network configuration is such that one switch is specifically
-	a backup switch (e.g., has lower capacity, higher cost, etc),
-	then the primary option can be used to insure that the
-	preferred link is always used when it is available.
+	Multiple switches may be utilized to optimize for throughput
+when they are configured in parallel as part of an isolated network
+between two or more systems, for example:
+
+                       +-----------+
+                       |  Host A   | 
+                       +-+---+---+-+
+                         |   |   |
+                +--------+   |   +---------+
+                |            |             |
+         +------+---+  +-----+----+  +-----+----+
+         | Switch A |  | Switch B |  | Switch C |
+         +------+---+  +-----+----+  +-----+----+
+                |            |             |
+                +--------+   |   +---------+
+                         |   |   |
+                       +-+---+---+-+
+                       |  Host B   | 
+                       +-----------+
+
+	In this configuration, the switches are isolated from one
+another.  One reason to employ a topology such as this is for an
+isolated network with many hosts (a cluster configured for high
+performance, for example), using multiple smaller switches can be more
+cost effective than a single larger switch, e.g., on a network with 24
+hosts, three 24 port switches can be significantly less expensive than
+a single 72 port switch.
+
+	If access beyond the network is required, an individual host
+can be equipped with an additional network device connected to an
+external network; this host then additionally acts as a gateway.
 
-broadcast: This mode is really a special purpose mode, and is suitable
-	only for very specific needs.  For example, if the two
-	switches are not connected (no ISL), and the networks beyond
-	them are totally independant.  In this case, if it is
-	necessary for some specific one-way traffic to reach both
-	independent networks, then the broadcast mode may be suitable.
-
-12.2.2 Link Monitoring Selection for Multiple Switch Topology
+13.2.1 MT Bonding Mode Selection for Multiple Switch Topology
 -------------------------------------------------------------
 
-	The choice of link monitoring ultimately depends upon your
-switch.  If the switch can reliably fail ports in response to other
-failures, then either the MII or ARP monitors should work.  For
-example, in the above example, if the "port3" link fails at the remote
-end, the MII monitor has no direct means to detect this.  The ARP
-monitor could be configured with a target at the remote end of port3,
-thus detecting that failure without switch support.
-
-	In general, however, in a multiple switch topology, the ARP
-monitor can provide a higher level of reliability in detecting link
-failures.  Additionally, it should be configured with multiple targets
-(at least one for each switch in the network).  This will insure that,
-regardless of which switch is active, the ARP monitor has a suitable
-target to query.
-
+	In actual practice, the bonding mode typically employed in
+configurations of this type is balance-rr.  Historically, in this
+network configuration, the usual caveats about out of order packet
+delivery are mitigated by the use of network adapters that do not do
+any kind of packet coalescing (via the use of NAPI, or because the
+device itself does not generate interrupts until some number of
+packets has arrived).  When employed in this fashion, the balance-rr
+mode allows individual connections between two hosts to effectively
+utilize greater than one interface's bandwidth.
+
+13.2.2 MT Link Monitoring for Multiple Switch Topology
+------------------------------------------------------
+
+	Again, in actual practice, the MII monitor is most often used
+in this configuration, as performance is given preference over
+availability.  The ARP monitor will function in this topology, but its
+advantages over the MII monitor are mitigated by the volume of probes
+needed as the number of systems involved grows (remember that each
+host in the network is configured with bonding).
 
-12.3 Switch Behavior Issues for High Availability
--------------------------------------------------
+14. Switch Behavior Issues
+--------------------------
 
-	You may encounter issues with the timing of link up and down
-reporting by the switch.
+	Some switches exhibit undesirable behavior with regard to the
+timing of link up and down reporting by the switch.
 
 	First, when a link comes up, some switches may indicate that
 the link is up (carrier available), but not pass traffic over the
@@ -1370,30 +1605,31 @@
 	Second, some switches may "bounce" the link state one or more
 times while a link is changing state.  This occurs most commonly while
 the switch is initializing.  Again, an appropriate updelay value may
-help, but note that if all links are down, then updelay is ignored
-when any link becomes active (the slave closest to completing its
-updelay is chosen).
+help.
 
 	Note that when a bonding interface has no active links, the
-driver will immediately reuse the first link that goes up, even if
-updelay parameter was specified.  If there are slave interfaces
-waiting for the updelay timeout to expire, the interface that first
-went into that state will be immediately reused.  This reduces down
-time of the network if the value of updelay has been overestimated.
+driver will immediately reuse the first link that goes up, even if the
+updelay parameter has been specified (the updelay is ignored in this
+case).  If there are slave interfaces waiting for the updelay timeout
+to expire, the interface that first went into that state will be
+immediately reused.  This reduces down time of the network if the
+value of updelay has been overestimated, and since this occurs only in
+cases with no connectivity, there is no additional penalty for
+ignoring the updelay.
 
 	In addition to the concerns about switch timings, if your
 switches take a long time to go into backup mode, it may be desirable
 to not activate a backup interface immediately after a link goes down.
 Failover may be delayed via the downdelay bonding module option.
 
-13. Hardware Specific Considerations
+15. Hardware Specific Considerations
 ====================================
 
 	This section contains additional information for configuring
 bonding on specific hardware platforms, or for interfacing bonding
 with particular switches or other devices.
 
-13.1 IBM BladeCenter
+15.1 IBM BladeCenter
 --------------------
 
 	This applies to the JS20 and similar systems.
@@ -1407,12 +1643,12 @@
 --------------------------------
 
 	All JS20s come with two Broadcom Gigabit Ethernet ports
-integrated on the planar.  In the BladeCenter chassis, the eth0 port
-of all JS20 blades is hard wired to I/O Module #1; similarly, all eth1
-ports are wired to I/O Module #2.  An add-on Broadcom daughter card
-can be installed on a JS20 to provide two more Gigabit Ethernet ports.
-These ports, eth2 and eth3, are wired to I/O Modules 3 and 4,
-respectively.
+integrated on the planar (that's "motherboard" in IBM-speak).  In the
+BladeCenter chassis, the eth0 port of all JS20 blades is hard wired to
+I/O Module #1; similarly, all eth1 ports are wired to I/O Module #2.
+An add-on Broadcom daughter card can be installed on a JS20 to provide
+two more Gigabit Ethernet ports.  These ports, eth2 and eth3, are
+wired to I/O Modules 3 and 4, respectively.
 
 	Each I/O Module may contain either a switch or a passthrough
 module (which allows ports to be directly connected to an external
@@ -1432,29 +1668,30 @@
 of ways, this discussion will be confined to describing basic
 configurations.
 
-	Normally, Ethernet Switch Modules (ESM) are used in I/O
+	Normally, Ethernet Switch Modules (ESMs) are used in I/O
 modules 1 and 2.  In this configuration, the eth0 and eth1 ports of a
 JS20 will be connected to different internal switches (in the
 respective I/O modules).
 
-	An optical passthru module (OPM) connects the I/O module
-directly to an external switch.  By using OPMs in I/O module #1 and
-#2, the eth0 and eth1 interfaces of a JS20 can be redirected to the
-outside world and connected to a common external switch.
-
-	Depending upon the mix of ESM and OPM modules, the network
-will appear to bonding as either a single switch topology (all OPM
-modules) or as a multiple switch topology (one or more ESM modules,
-zero or more OPM modules).  It is also possible to connect ESM modules
-together, resulting in a configuration much like the example in "High
-Availability in a multiple switch topology."
-
-Requirements for specifc modes
-------------------------------
-
-	The balance-rr mode requires the use of OPM modules for
-devices in the bond, all connected to an common external switch.  That
-switch must be configured for "etherchannel" or "trunking" on the
+	A passthrough module (OPM or CPM, optical or copper,
+passthrough module) connects the I/O module directly to an external
+switch.  By using PMs in I/O module #1 and #2, the eth0 and eth1
+interfaces of a JS20 can be redirected to the outside world and
+connected to a common external switch.
+
+	Depending upon the mix of ESMs and PMs, the network will
+appear to bonding as either a single switch topology (all PMs) or as a
+multiple switch topology (one or more ESMs, zero or more PMs).  It is
+also possible to connect ESMs together, resulting in a configuration
+much like the example in "High Availability in a Multiple Switch
+Topology," above.
+
+Requirements for specific modes
+-------------------------------
+
+	The balance-rr mode requires the use of passthrough modules
+for devices in the bond, all connected to an common external switch.
+That switch must be configured for "etherchannel" or "trunking" on the
 appropriate ports, as is usual for balance-rr.
 
 	The balance-alb and balance-tlb modes will function with
@@ -1484,17 +1721,18 @@
 Other concerns
 --------------
 
-	The Serial Over LAN link is established over the primary
+	The Serial Over LAN (SoL) link is established over the primary
 ethernet (eth0) only, therefore, any loss of link to eth0 will result
 in losing your SoL connection.  It will not fail over with other
-network traffic.
+network traffic, as the SoL system is beyond the control of the
+bonding driver.
 
 	It may be desirable to disable spanning tree on the switch
 (either the internal Ethernet Switch Module, or an external switch) to
-avoid fail-over delays issues when using bonding.
+avoid fail-over delay issues when using bonding.
 
 	
-14. Frequently Asked Questions
+16. Frequently Asked Questions
 ==============================
 
 1.  Is it SMP safe?
@@ -1505,8 +1743,8 @@
 2.  What type of cards will work with it?
 
 	Any Ethernet type cards (you can even mix cards - a Intel
-EtherExpress PRO/100 and a 3com 3c905b, for example).  They need not
-be of the same speed.
+EtherExpress PRO/100 and a 3com 3c905b, for example).  For most modes,
+devices need not be of the same speed.
 
 3.  How many bonding devices can I have?
 
@@ -1524,11 +1762,12 @@
 disabled.  The active-backup mode will fail over to a backup link, and
 other modes will ignore the failed link.  The link will continue to be
 monitored, and should it recover, it will rejoin the bond (in whatever
-manner is appropriate for the mode). See the section on High
-Availability for additional information.
+manner is appropriate for the mode). See the sections on High
+Availability and the documentation for each mode for additional
+information.
 	
 	Link monitoring can be enabled via either the miimon or
-arp_interval paramters (described in the module paramters section,
+arp_interval parameters (described in the module parameters section,
 above).  In general, miimon monitors the carrier state as sensed by
 the underlying network device, and the arp monitor (arp_interval)
 monitors connectivity to another host on the local network.
@@ -1536,7 +1775,7 @@
 	If no link monitoring is configured, the bonding driver will
 be unable to detect link failures, and will assume that all links are
 always available.  This will likely result in lost packets, and a
-resulting degredation of performance.  The precise performance loss
+resulting degradation of performance.  The precise performance loss
 depends upon the bonding mode and network configuration.
 
 6.  Can bonding be used for High Availability?
@@ -1550,12 +1789,12 @@
 	In the basic balance modes (balance-rr and balance-xor), it
 works with any system that supports etherchannel (also called
 trunking).  Most managed switches currently available have such
-support, and many unmananged switches as well.
+support, and many unmanaged switches as well.
 
 	The advanced balance modes (balance-tlb and balance-alb) do
 not have special switch requirements, but do need device drivers that
 support specific features (described in the appropriate section under
-module paramters, above).
+module parameters, above).
 
 	In 802.3ad mode, it works with with systems that support IEEE
 802.3ad Dynamic Link Aggregation.  Most managed and many unmanaged
@@ -1565,17 +1804,19 @@
 
 8.  Where does a bonding device get its MAC address from?
 
-	If not explicitly configured with ifconfig, the MAC address of
-the bonding device is taken from its first slave device. This MAC
-address is then passed to all following slaves and remains persistent
-(even if the the first slave is removed) until the bonding device is
-brought down or reconfigured.
+	If not explicitly configured (with ifconfig or ip link), the
+MAC address of the bonding device is taken from its first slave
+device.  This MAC address is then passed to all following slaves and
+remains persistent (even if the the first slave is removed) until the
+bonding device is brought down or reconfigured.
 
 	If you wish to change the MAC address, you can set it with
-ifconfig:
+ifconfig or ip link:
 
 # ifconfig bond0 hw ether 00:11:22:33:44:55
 
+# ip link set bond0 address 66:77:88:99:aa:bb
+
 	The MAC address can be also changed by bringing down/up the
 device and then changing its slaves (or their order):
 
@@ -1591,23 +1832,28 @@
 then restore the MAC addresses that the slaves had before they were
 enslaved.
 
-15. Resources and Links
+16. Resources and Links
 =======================
 
 The latest version of the bonding driver can be found in the latest
 version of the linux kernel, found on http://kernel.org
 
+The latest version of this document can be found in either the latest
+kernel source (named Documentation/networking/bonding.txt), or on the
+bonding sourceforge site:
+
+http://www.sourceforge.net/projects/bonding
+
 Discussions regarding the bonding driver take place primarily on the
 bonding-devel mailing list, hosted at sourceforge.net.  If you have
-questions or problems, post them to the list.
+questions or problems, post them to the list.  The list address is:
 
 bonding-devel@lists.sourceforge.net
 
-https://lists.sourceforge.net/lists/listinfo/bonding-devel
-
-There is also a project site on sourceforge.
+	The administrative interface (to subscribe or unsubscribe) can
+be found at:
 
-http://www.sourceforge.net/projects/bonding
+https://lists.sourceforge.net/lists/listinfo/bonding-devel
 
 Donald Becker's Ethernet Drivers and diag programs may be found at :
  - http://www.scyld.com/network/
