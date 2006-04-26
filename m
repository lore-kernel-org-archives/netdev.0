From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH 2.6.16.11] updated bonding documentation
Date: Wed, 26 Apr 2006 11:05:00 -0700
Message-ID: <Pine.CYG.4.58.0604261101030.860@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:4290 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S932370AbWDZSFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 14:05:16 -0400
To: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added new section describing the sysfs interface.
Renumbered sections to be sequential (section 4 was AWOL).
Minor spelling corrections.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urpN linux-2.6.16.11-clean/Documentation/networking/bonding.txt linux-2.6.16.11/Documentation/networking/bonding.txt
--- linux-2.6.16.11-clean/Documentation/networking/bonding.txt	2006-04-24 13:20:24.000000000 -0700
+++ linux-2.6.16.11/Documentation/networking/bonding.txt	2006-04-24 16:18:25.000000000 -0700
@@ -1,7 +1,7 @@

 		Linux Ethernet Bonding Driver HOWTO

-		Latest update: 21 June 2005
+		Latest update: 24 April 2006

 Initial release : Thomas Davis <tadavis at lbl.gov>
 Corrections, HA extensions : 2000/10/03-15 :
@@ -12,6 +12,8 @@ Corrections, HA extensions : 2000/10/03-
   - Jay Vosburgh <fubar at us dot ibm dot com>

 Reorganized and updated Feb 2005 by Jay Vosburgh
+Added Sysfs information: 2006/04/24
+  - Mitch Williams <mitch.a.williams at intel.com>

 Introduction
 ============
@@ -38,61 +40,62 @@ Table of Contents
 2. Bonding Driver Options

 3. Configuring Bonding Devices
-3.1	Configuration with sysconfig support
-3.1.1		Using DHCP with sysconfig
-3.1.2		Configuring Multiple Bonds with sysconfig
-3.2	Configuration with initscripts support
-3.2.1		Using DHCP with initscripts
-3.2.2		Configuring Multiple Bonds with initscripts
-3.3	Configuring Bonding Manually
+3.1	Configuration with Sysconfig Support
+3.1.1		Using DHCP with Sysconfig
+3.1.2		Configuring Multiple Bonds with Sysconfig
+3.2	Configuration with Initscripts Support
+3.2.1		Using DHCP with Initscripts
+3.2.2		Configuring Multiple Bonds with Initscripts
+3.3	Configuring Bonding Manually with Ifenslave
 3.3.1		Configuring Multiple Bonds Manually
+3.4	Configuring Bonding Manually via Sysfs

-5. Querying Bonding Configuration
-5.1	Bonding Configuration
-5.2	Network Configuration
+4. Querying Bonding Configuration
+4.1	Bonding Configuration
+4.2	Network Configuration

-6. Switch Configuration
+5. Switch Configuration

-7. 802.1q VLAN Support
+6. 802.1q VLAN Support

-8. Link Monitoring
-8.1	ARP Monitor Operation
-8.2	Configuring Multiple ARP Targets
-8.3	MII Monitor Operation
+7. Link Monitoring
+7.1	ARP Monitor Operation
+7.2	Configuring Multiple ARP Targets
+7.3	MII Monitor Operation

-9. Potential Trouble Sources
-9.1	Adventures in Routing
-9.2	Ethernet Device Renaming
-9.3	Painfully Slow Or No Failed Link Detection By Miimon
+8. Potential Trouble Sources
+8.1	Adventures in Routing
+8.2	Ethernet Device Renaming
+8.3	Painfully Slow Or No Failed Link Detection By Miimon

-10. SNMP agents
+9. SNMP agents

-11. Promiscuous mode
+10. Promiscuous mode

-12. Configuring Bonding for High Availability
-12.1	High Availability in a Single Switch Topology
-12.2	High Availability in a Multiple Switch Topology
-12.2.1		HA Bonding Mode Selection for Multiple Switch Topology
-12.2.2		HA Link Monitoring for Multiple Switch Topology
+11. Configuring Bonding for High Availability
+11.1	High Availability in a Single Switch Topology
+11.2	High Availability in a Multiple Switch Topology
+11.2.1		HA Bonding Mode Selection for Multiple Switch Topology
+11.2.2		HA Link Monitoring for Multiple Switch Topology

-13. Configuring Bonding for Maximum Throughput
-13.1	Maximum Throughput in a Single Switch Topology
-13.1.1		MT Bonding Mode Selection for Single Switch Topology
-13.1.2		MT Link Monitoring for Single Switch Topology
-13.2	Maximum Throughput in a Multiple Switch Topology
-13.2.1		MT Bonding Mode Selection for Multiple Switch Topology
-13.2.2		MT Link Monitoring for Multiple Switch Topology
+12. Configuring Bonding for Maximum Throughput
+12.1	Maximum Throughput in a Single Switch Topology
+12.1.1		MT Bonding Mode Selection for Single Switch Topology
+12.1.2		MT Link Monitoring for Single Switch Topology
+12.2	Maximum Throughput in a Multiple Switch Topology
+12.2.1		MT Bonding Mode Selection for Multiple Switch Topology
+12.2.2		MT Link Monitoring for Multiple Switch Topology

-14. Switch Behavior Issues
-14.1	Link Establishment and Failover Delays
-14.2	Duplicated Incoming Packets
+13. Switch Behavior Issues
+13.1	Link Establishment and Failover Delays
+13.2	Duplicated Incoming Packets

-15. Hardware Specific Considerations
-15.1	IBM BladeCenter
+14. Hardware Specific Considerations
+14.1	IBM BladeCenter

-16. Frequently Asked Questions
+15. Frequently Asked Questions

-17. Resources and Links
+16. Resources and Links


 1. Bonding Driver Installation
@@ -156,6 +159,9 @@ you're trying to build it for.  Some dis
 onwards) do not have /usr/include/linux symbolically linked to the
 default kernel source include directory.

+SECOND IMPORTANT NOTE:
+	If you plan to configure bonding using sysfs, you do not need
+to use ifenslave.

 2. Bonding Driver Options
 =========================
@@ -270,7 +276,7 @@ mode
 		In bonding version 2.6.2 or later, when a failover
 		occurs in active-backup mode, bonding will issue one
 		or more gratuitous ARPs on the newly active slave.
-		One gratutious ARP is issued for the bonding master
+		One gratuitous ARP is issued for the bonding master
 		interface and each VLAN interfaces configured above
 		it, provided that the interface has at least one IP
 		address configured.  Gratuitous ARPs issued for VLAN
@@ -377,7 +383,7 @@ mode
 		When a link is reconnected or a new slave joins the
 		bond the receive traffic is redistributed among all
 		active slaves in the bond by initiating ARP Replies
-		with the selected mac address to each of the
+		with the selected MAC address to each of the
 		clients. The updelay parameter (detailed below) must
 		be set to a value equal or greater than the switch's
 		forwarding delay so that the ARP Replies sent to the
@@ -498,11 +504,12 @@ not exist, and the layer2 policy is the
 3. Configuring Bonding Devices
 ==============================

-	There are, essentially, two methods for configuring bonding:
-with support from the distro's network initialization scripts, and
-without.  Distros generally use one of two packages for the network
-initialization scripts: initscripts or sysconfig.  Recent versions of
-these packages have support for bonding, while older versions do not.
+	You can configure bonding using either your distro's network
+initialization scripts, or manually using either ifenslave or the
+sysfs interface.  Distros generally use one of two packages for the
+network initialization scripts: initscripts or sysconfig.  Recent
+versions of these packages have support for bonding, while older
+versions do not.

 	We will first describe the options for configuring bonding for
 distros using versions of initscripts and sysconfig with full or
@@ -530,7 +537,7 @@ $ grep ifenslave /sbin/ifup
 	If this returns any matches, then your initscripts or
 sysconfig has support for bonding.

-3.1 Configuration with sysconfig support
+3.1 Configuration with Sysconfig Support
 ----------------------------------------

 	This section applies to distros using a version of sysconfig
@@ -538,7 +545,7 @@ with bonding support, for example, SuSE

 	SuSE SLES 9's networking configuration system does support
 bonding, however, at this writing, the YaST system configuration
-frontend does not provide any means to work with bonding devices.
+front end does not provide any means to work with bonding devices.
 Bonding devices can be managed by hand, however, as follows.

 	First, if they have not already been configured, configure the
@@ -660,7 +667,7 @@ format can be found in an example ifcfg
 	Note that the template does not document the various BONDING_
 settings described above, but does describe many of the other options.

-3.1.1 Using DHCP with sysconfig
+3.1.1 Using DHCP with Sysconfig
 -------------------------------

 	Under sysconfig, configuring a device with BOOTPROTO='dhcp'
@@ -670,7 +677,7 @@ attempt to obtain the device address fro
 the slave devices.  Without active slaves, the DHCP requests are not
 sent to the network.

-3.1.2 Configuring Multiple Bonds with sysconfig
+3.1.2 Configuring Multiple Bonds with Sysconfig
 -----------------------------------------------

 	The sysconfig network initialization system is capable of
@@ -685,7 +692,7 @@ ifcfg-bondX files.
 options in the ifcfg-bondX file, it is not necessary to add them to
 the system /etc/modules.conf or /etc/modprobe.conf configuration file.

-3.2 Configuration with initscripts support
+3.2 Configuration with Initscripts Support
 ------------------------------------------

 	This section applies to distros using a version of initscripts
@@ -756,7 +763,7 @@ options for your configuration.
 will restart the networking subsystem and your bond link should be now
 up and running.

-3.2.1 Using DHCP with initscripts
+3.2.1 Using DHCP with Initscripts
 ---------------------------------

 	Recent versions of initscripts (the version supplied with
@@ -768,7 +775,7 @@ above, except replace the line "BOOTPROT
 and add a line consisting of "TYPE=Bonding".  Note that the TYPE value
 is case sensitive.

-3.2.2 Configuring Multiple Bonds with initscripts
+3.2.2 Configuring Multiple Bonds with Initscripts
 -------------------------------------------------

 	At this writing, the initscripts package does not directly
@@ -784,8 +791,8 @@ Fedora Core kernels, and has been seen o
 exhibiting this problem, it will be impossible to configure multiple
 bonds with differing parameters.

-3.3 Configuring Bonding Manually
---------------------------------
+3.3 Configuring Bonding Manually with Ifenslave
+-----------------------------------------------

 	This section applies to distros whose network initialization
 scripts (the sysconfig or initscripts package) do not have specific
@@ -889,11 +896,139 @@ install bond1 /sbin/modprobe --ignore-in
 	This may be repeated any number of times, specifying a new and
 unique name in place of bond1 for each subsequent instance.

+3.4 Configuring Bonding Manually via Sysfs
+------------------------------------------
+
+	Starting with version 3.0, Channel Bonding may be configured
+via the sysfs interface.  This interface allows dynamic configuration
+of all bonds in the system without unloading the module.  It also
+allows for adding and removing bonds at runtime.  Ifenslave is no
+longer required, though it is still supported.
+
+	Use of the sysfs interface allows you to use multiple bonds
+with different configurations without having to reload the module.
+It also allows you to use multiple, differently configured bonds when
+bonding is compiled into the kernel.
+
+	You must have the sysfs filesystem mounted to configure
+bonding this way.  The examples in this document assume that you
+are using the standard mount point for sysfs, e.g. /sys.  If your
+sysfs filesystem is mounted elsewhere, you will need to adjust the
+example paths accordingly.
+
+Creating and Destroying Bonds
+-----------------------------
+To add a new bond foo:
+# echo +foo > /sys/class/net/bonding_masters
+
+To remove an existing bond bar:
+# echo -bar > /sys/class/net/bonding_masters
+
+To show all existing bonds:
+# cat /sys/class/net/bonding_masters
+
+NOTE: due to 4K size limitation of sysfs files, this list may be
+truncated if you have more than a few hundred bonds.  This is unlikely
+to occur under normal operating conditions.
+
+Adding and Removing Slaves
+--------------------------
+	Interfaces may be enslaved to a bond using the file
+/sys/class/net/<bond>/bonding/slaves.  The semantics for this file
+are the same as for the bonding_masters file.
+
+To enslave interface eth0 to bond bond0:
+# ifconfig bond0 up
+# echo +eth0 > /sys/class/net/bond0/bonding/slaves
+
+To free slave eth0 from bond bond0:
+# echo -eth0 > /sys/class/net/bond0/bonding/slaves
+
+	NOTE: The bond must be up before slaves can be added.  All
+slaves are freed when the interface is brought down.
+
+	When an interface is enslaved to a bond, symlinks between the
+two are created in the sysfs filesystem.  In this case, you would get
+/sys/class/net/bond0/slave_eth0 pointing to /sys/class/net/eth0, and
+/sys/class/net/eth0/master pointing to /sys/class/net/bond0.
+
+	This means that you can tell quickly whether or not an
+interface is enslaved by looking for the master symlink.  Thus:
+# echo -eth0 > /sys/class/net/eth0/master/bonding/slaves
+will free eth0 from whatever bond it is enslaved to, regardless of
+the name of the bond interface.
+
+Changing a Bond's Configuration
+-------------------------------
+	Each bond may be configured individually by manipulating the
+files located in /sys/class/net/<bond name>/bonding
+
+	The names of these files correspond directly with the command-
+line parameters described elsewhere in in this file, and, with the
+exception of arp_ip_target, they accept the same values.  To see the
+current setting, simply cat the appropriate file.
+
+	A few examples will be given here; for specific usage
+guidelines for each parameter, see the appropriate section in this
+document.
+
+To configure bond0 for balance-alb mode:
+# ifconfig bond0 down
+# echo 6 > /sys/class/net/bond0/bonding/mode
+ - or -
+# echo balance-alb > /sys/class/net/bond0/bonding/mode
+	NOTE: The bond interface must be down before the mode can be
+changed.
+
+To enable MII monitoring on bond0 with a 1 second interval:
+# echo 1000 > /sys/class/net/bond0/bonding/miimon
+	NOTE: If ARP monitoring is enabled, it will disabled when MII
+monitoring is enabled, and vice-versa.
+
+To add ARP targets:
+# echo +192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target
+# echo +192.168.0.101 > /sys/class/net/bond0/bonding/arp_ip_target
+	NOTE:  up to 10 target addresses may be specified.
+
+To remove an ARP target:
+# echo -192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target
+
+Example Configuration
+---------------------
+	We begin with the same example that is shown in section 3.3,
+executed with sysfs, and without using ifenslave.
+
+	To make a simple bond of two e100 devices (presumed to be eth0
+and eth1), and have it persist across reboots, edit the appropriate
+file (/etc/init.d/boot.local or /etc/rc.d/rc.local), and add the
+following:
+
+modprobe bonding
+modprobe e100
+echo balance-alb > /sys/class/net/bond0/bonding/mode
+ifconfig bond0 192.168.1.1 netmask 255.255.255.0 up
+echo 100 > /sys/class/net/bond0/bonding/miimon
+echo +eth0 > /sys/class/net/bond0/bonding/slaves
+echo +eth1 > /sys/class/net/bond0/bonding/slaves
+
+	To add a second bond, with two e1000 interfaces in
+active-backup mode, using ARP monitoring, add the following lines to
+your init script:
+
+modprobe e1000
+echo +bond1 > /sys/class/net/bonding_masters
+echo active-backup > /sys/class/net/bond1/bonding/mode
+ifconfig bond1 192.168.2.1 netmask 255.255.255.0 up
+echo +192.168.2.100 /sys/class/net/bond1/bonding/arp_ip_target
+echo 2000 > /sys/class/net/bond1/bonding/arp_interval
+echo +eth2 > /sys/class/net/bond1/bonding/slaves
+echo +eth3 > /sys/class/net/bond1/bonding/slaves
+

-5. Querying Bonding Configuration
+4. Querying Bonding Configuration
 =================================

-5.1 Bonding Configuration
+4.1 Bonding Configuration
 -------------------------

 	Each bonding device has a read-only file residing in the
@@ -923,7 +1058,7 @@ generally as follows:
 	The precise format and contents will change depending upon the
 bonding configuration, state, and version of the bonding driver.

-5.2 Network configuration
+4.2 Network configuration
 -------------------------

 	The network configuration can be inspected using the ifconfig
@@ -958,7 +1093,7 @@ eth1      Link encap:Ethernet  HWaddr 00
           collisions:0 txqueuelen:100
           Interrupt:9 Base address:0x1400

-6. Switch Configuration
+5. Switch Configuration
 =======================

 	For this section, "switch" refers to whatever system the
@@ -991,7 +1126,7 @@ transmit policy for an EtherChannel grou
 with another EtherChannel group.


-7. 802.1q VLAN Support
+6. 802.1q VLAN Support
 ======================

 	It is possible to configure VLAN devices over a bond interface
@@ -1042,7 +1177,7 @@ underlying device -- i.e. the bonding in
 mode, which might not be what you want.


-8. Link Monitoring
+7. Link Monitoring
 ==================

 	The bonding driver at present supports two schemes for
@@ -1053,7 +1188,7 @@ monitor.
 bonding driver itself, it is not possible to enable both ARP and MII
 monitoring simultaneously.

-8.1 ARP Monitor Operation
+7.1 ARP Monitor Operation
 -------------------------

 	The ARP monitor operates as its name suggests: it sends ARP
@@ -1071,7 +1206,7 @@ those slaves will stay down.  If network
 shows the ARP requests and replies on the network, then it may be that
 your device driver is not updating last_rx and trans_start.

-8.2 Configuring Multiple ARP Targets
+7.2 Configuring Multiple ARP Targets
 ------------------------------------

 	While ARP monitoring can be done with just one target, it can
@@ -1094,7 +1229,7 @@ alias bond0 bonding
 options bond0 arp_interval=60 arp_ip_target=192.168.0.100


-8.3 MII Monitor Operation
+7.3 MII Monitor Operation
 -------------------------

 	The MII monitor monitors only the carrier state of the local
@@ -1120,14 +1255,14 @@ does not support or had some error in pr
 and ethtool requests), then the MII monitor will assume the link is
 up.

-9. Potential Sources of Trouble
+8. Potential Sources of Trouble
 ===============================

-9.1 Adventures in Routing
+8.1 Adventures in Routing
 -------------------------

 	When bonding is configured, it is important that the slave
-devices not have routes that supercede routes of the master (or,
+devices not have routes that supersede routes of the master (or,
 generally, not have routes at all).  For example, suppose the bonding
 device bond0 has two slaves, eth0 and eth1, and the routing table is
 as follows:
@@ -1154,11 +1289,11 @@ by the state of the routing table.

 	The solution here is simply to insure that slaves do not have
 routes of their own, and if for some reason they must, those routes do
-not supercede routes of their master.  This should generally be the
+not supersede routes of their master.  This should generally be the
 case, but unusual configurations or errant manual or automatic static
 route additions may cause trouble.

-9.2 Ethernet Device Renaming
+8.2 Ethernet Device Renaming
 ----------------------------

 	On systems with network configuration scripts that do not
@@ -1207,7 +1342,7 @@ modprobe with --ignore-install to cause
 place.  Full documentation on this can be found in the modprobe.conf
 and modprobe manual pages.

-9.3. Painfully Slow Or No Failed Link Detection By Miimon
+8.3. Painfully Slow Or No Failed Link Detection By Miimon
 ---------------------------------------------------------

 	By default, bonding enables the use_carrier option, which
@@ -1235,7 +1370,7 @@ carrier state.  It has no way to determi
 beyond other ports of a switch, or if a switch is refusing to pass
 traffic while still maintaining carrier on.

-10. SNMP agents
+9. SNMP agents
 ===============

 	If running SNMP agents, the bonding driver should be loaded
@@ -1281,7 +1416,7 @@ ifDescr, the association between the IP
 and SNMP functions such as Interface_Scan_Next will report that
 association.

-11. Promiscuous mode
+10. Promiscuous mode
 ====================

 	When running network monitoring tools, e.g., tcpdump, it is
@@ -1308,7 +1443,7 @@ sending to peers that are unassigned or
 the active slave changes (e.g., due to a link failure), the
 promiscuous setting will be propagated to the new active slave.

-12. Configuring Bonding for High Availability
+11. Configuring Bonding for High Availability
 =============================================

 	High Availability refers to configurations that provide
@@ -1318,7 +1453,7 @@ goal is to provide the maximum availabil
 (i.e., the network always works), even though other configurations
 could provide higher throughput.

-12.1 High Availability in a Single Switch Topology
+11.1 High Availability in a Single Switch Topology
 --------------------------------------------------

 	If two hosts (or a host and a single switch) are directly
@@ -1332,7 +1467,7 @@ the load will be rebalanced across the r
 	See Section 13, "Configuring Bonding for Maximum Throughput"
 for information on configuring bonding with one peer device.

-12.2 High Availability in a Multiple Switch Topology
+11.2 High Availability in a Multiple Switch Topology
 ----------------------------------------------------

 	With multiple switches, the configuration of bonding and the
@@ -1359,7 +1494,7 @@ switches (ISL, or inter switch link), an
 the outside world ("port3" on each switch).  There is no technical
 reason that this could not be extended to a third switch.

-12.2.1 HA Bonding Mode Selection for Multiple Switch Topology
+11.2.1 HA Bonding Mode Selection for Multiple Switch Topology
 -------------------------------------------------------------

 	In a topology such as the example above, the active-backup and
@@ -1381,7 +1516,7 @@ broadcast: This mode is really a special
 	necessary for some specific one-way traffic to reach both
 	independent networks, then the broadcast mode may be suitable.

-12.2.2 HA Link Monitoring Selection for Multiple Switch Topology
+11.2.2 HA Link Monitoring Selection for Multiple Switch Topology
 ----------------------------------------------------------------

 	The choice of link monitoring ultimately depends upon your
@@ -1402,10 +1537,10 @@ regardless of which switch is active, th
 target to query.


-13. Configuring Bonding for Maximum Throughput
+12. Configuring Bonding for Maximum Throughput
 ==============================================

-13.1 Maximizing Throughput in a Single Switch Topology
+12.1 Maximizing Throughput in a Single Switch Topology
 ------------------------------------------------------

 	In a single switch configuration, the best method to maximize
@@ -1476,7 +1611,7 @@ destination to make load balancing decis
 mode is described below.


-13.1.1 MT Bonding Mode Selection for Single Switch Topology
+12.1.1 MT Bonding Mode Selection for Single Switch Topology
 -----------------------------------------------------------

 	This configuration is the easiest to set up and to understand,
@@ -1607,7 +1742,7 @@ balance-alb: This mode is everything tha
 	device driver must support changing the hardware address while
 	the device is open.

-13.1.2 MT Link Monitoring for Single Switch Topology
+12.1.2 MT Link Monitoring for Single Switch Topology
 ----------------------------------------------------

 	The choice of link monitoring may largely depend upon which
@@ -1616,7 +1751,7 @@ support the use of the ARP monitor, and
 the MII monitor (which does not provide as high a level of end to end
 assurance as the ARP monitor).

-13.2 Maximum Throughput in a Multiple Switch Topology
+12.2 Maximum Throughput in a Multiple Switch Topology
 -----------------------------------------------------

 	Multiple switches may be utilized to optimize for throughput
@@ -1651,7 +1786,7 @@ a single 72 port switch.
 can be equipped with an additional network device connected to an
 external network; this host then additionally acts as a gateway.

-13.2.1 MT Bonding Mode Selection for Multiple Switch Topology
+12.2.1 MT Bonding Mode Selection for Multiple Switch Topology
 -------------------------------------------------------------

 	In actual practice, the bonding mode typically employed in
@@ -1664,7 +1799,7 @@ packets has arrived).  When employed in
 mode allows individual connections between two hosts to effectively
 utilize greater than one interface's bandwidth.

-13.2.2 MT Link Monitoring for Multiple Switch Topology
+12.2.2 MT Link Monitoring for Multiple Switch Topology
 ------------------------------------------------------

 	Again, in actual practice, the MII monitor is most often used
@@ -1674,10 +1809,10 @@ advantages over the MII monitor are miti
 needed as the number of systems involved grows (remember that each
 host in the network is configured with bonding).

-14. Switch Behavior Issues
+13. Switch Behavior Issues
 ==========================

-14.1 Link Establishment and Failover Delays
+13.1 Link Establishment and Failover Delays
 -------------------------------------------

 	Some switches exhibit undesirable behavior with regard to the
@@ -1712,7 +1847,7 @@ switches take a long time to go into bac
 to not activate a backup interface immediately after a link goes down.
 Failover may be delayed via the downdelay bonding module option.

-14.2 Duplicated Incoming Packets
+13.2 Duplicated Incoming Packets
 --------------------------------

 	It is not uncommon to observe a short burst of duplicated
@@ -1751,14 +1886,14 @@ behavior, it can be induced by clearing
 most Cisco switches, the privileged command "clear mac address-table
 dynamic" will accomplish this).

-15. Hardware Specific Considerations
+14. Hardware Specific Considerations
 ====================================

 	This section contains additional information for configuring
 bonding on specific hardware platforms, or for interfacing bonding
 with particular switches or other devices.

-15.1 IBM BladeCenter
+14.1 IBM BladeCenter
 --------------------

 	This applies to the JS20 and similar systems.
@@ -1861,7 +1996,7 @@ bonding driver.
 avoid fail-over delay issues when using bonding.


-16. Frequently Asked Questions
+15. Frequently Asked Questions
 ==============================

 1.  Is it SMP safe?
@@ -1925,7 +2060,7 @@ not have special switch requirements, bu
 support specific features (described in the appropriate section under
 module parameters, above).

-	In 802.3ad mode, it works with with systems that support IEEE
+	In 802.3ad mode, it works with systems that support IEEE
 802.3ad Dynamic Link Aggregation.  Most managed and many unmanaged
 switches currently available support 802.3ad.

