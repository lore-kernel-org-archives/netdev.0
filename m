From: Sven Eckelmann <sven.eckelmann@gmx.de>
Subject: [PATCHv4] net: Add batman-adv meshing protocol
Date: Sun,  5 Sep 2010 02:25:53 +0200
Message-ID: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.net,
	Sven Eckelmann <sven.eckelmann@gmx.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:55018 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754187Ab0IEA02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Sep 2010 20:26:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a routing
protocol for multi-hop ad-hoc mesh networks. The networks may be wired or
wireless. See http://www.open-mesh.org/ for more information and user space
tools.

Signed-off-by: Sven Eckelmann <sven.eckelmann@gmx.de>
---
batman-adv is a layer2 meshing protocol currently in
drivers/staging/batman-adv. GregKH recently [1][2] gave us his blessing
to leave the staging tree and move to a more suitable location.

Short functionality overview:

The batman-adv module is an implementation of the B.A.T.M.A.N. routing
protocol operating on layer2 optimized for (but not limited to) wireless
networks. Next to finding the best possible path through the network it
encapsulates the data traffic and optimizes the transport as well. There
also is a user space tool "batctl" which offers various functionalities
next to a kernel module configuration interface. Detailed documentation
can be found at the project homepage[3].

Everything is addressed in the last round of comments [4].

[1] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2010-June/002881.html
[2] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2010-June/002968.html
[3] http://www.open-mesh.org
[4] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2010-July/003138.html

 .../ABI/testing/sysfs-class-net-batman-adv         |   14 +
 Documentation/ABI/testing/sysfs-class-net-mesh     |   33 +
 Documentation/networking/batman-adv.txt            |  239 ++++
 MAINTAINERS                                        |    8 +
 net/Kconfig                                        |    1 +
 net/Makefile                                       |    1 +
 net/batman-adv/Kconfig                             |   26 +
 net/batman-adv/Makefile                            |   22 +
 net/batman-adv/aggregation.c                       |  270 ++++
 net/batman-adv/aggregation.h                       |   43 +
 net/batman-adv/bat_debugfs.c                       |  341 +++++
 net/batman-adv/bat_debugfs.h                       |   33 +
 net/batman-adv/bat_sysfs.c                         |  536 ++++++++
 net/batman-adv/bat_sysfs.h                         |   42 +
 net/batman-adv/bitarray.c                          |  201 +++
 net/batman-adv/bitarray.h                          |   47 +
 net/batman-adv/hard-interface.c                    |  596 +++++++++
 net/batman-adv/hard-interface.h                    |   45 +
 net/batman-adv/hash.c                              |  306 +++++
 net/batman-adv/hash.h                              |  100 ++
 net/batman-adv/icmp_socket.c                       |  356 +++++
 net/batman-adv/icmp_socket.h                       |   34 +
 net/batman-adv/main.c                              |  225 ++++
 net/batman-adv/main.h                              |  185 +++
 net/batman-adv/originator.c                        |  539 ++++++++
 net/batman-adv/originator.h                        |   36 +
 net/batman-adv/packet.h                            |  134 ++
 net/batman-adv/ring_buffer.c                       |   52 +
 net/batman-adv/ring_buffer.h                       |   28 +
 net/batman-adv/routing.c                           | 1387 ++++++++++++++++++++
 net/batman-adv/routing.h                           |   46 +
 net/batman-adv/send.c                              |  577 ++++++++
 net/batman-adv/send.h                              |   41 +
 net/batman-adv/soft-interface.c                    |  395 ++++++
 net/batman-adv/soft-interface.h                    |   32 +
 net/batman-adv/translation-table.c                 |  513 ++++++++
 net/batman-adv/translation-table.h                 |   45 +
 net/batman-adv/types.h                             |  244 ++++
 net/batman-adv/unicast.c                           |  265 ++++
 net/batman-adv/unicast.h                           |   39 +
 net/batman-adv/vis.c                               |  901 +++++++++++++
 net/batman-adv/vis.h                               |   37 +
 42 files changed, 9015 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-batman-adv
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-mesh
 create mode 100644 Documentation/networking/batman-adv.txt
 create mode 100644 net/batman-adv/Kconfig
 create mode 100644 net/batman-adv/Makefile
 create mode 100644 net/batman-adv/aggregation.c
 create mode 100644 net/batman-adv/aggregation.h
 create mode 100644 net/batman-adv/bat_debugfs.c
 create mode 100644 net/batman-adv/bat_debugfs.h
 create mode 100644 net/batman-adv/bat_sysfs.c
 create mode 100644 net/batman-adv/bat_sysfs.h
 create mode 100644 net/batman-adv/bitarray.c
 create mode 100644 net/batman-adv/bitarray.h
 create mode 100644 net/batman-adv/hard-interface.c
 create mode 100644 net/batman-adv/hard-interface.h
 create mode 100644 net/batman-adv/hash.c
 create mode 100644 net/batman-adv/hash.h
 create mode 100644 net/batman-adv/icmp_socket.c
 create mode 100644 net/batman-adv/icmp_socket.h
 create mode 100644 net/batman-adv/main.c
 create mode 100644 net/batman-adv/main.h
 create mode 100644 net/batman-adv/originator.c
 create mode 100644 net/batman-adv/originator.h
 create mode 100644 net/batman-adv/packet.h
 create mode 100644 net/batman-adv/ring_buffer.c
 create mode 100644 net/batman-adv/ring_buffer.h
 create mode 100644 net/batman-adv/routing.c
 create mode 100644 net/batman-adv/routing.h
 create mode 100644 net/batman-adv/send.c
 create mode 100644 net/batman-adv/send.h
 create mode 100644 net/batman-adv/soft-interface.c
 create mode 100644 net/batman-adv/soft-interface.h
 create mode 100644 net/batman-adv/translation-table.c
 create mode 100644 net/batman-adv/translation-table.h
 create mode 100644 net/batman-adv/types.h
 create mode 100644 net/batman-adv/unicast.c
 create mode 100644 net/batman-adv/unicast.h
 create mode 100644 net/batman-adv/vis.c
 create mode 100644 net/batman-adv/vis.h

diff --git a/Documentation/ABI/testing/sysfs-class-net-batman-adv b/Documentation/ABI/testing/sysfs-class-net-batman-adv
new file mode 100644
index 0000000..38dd762
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-batman-adv
@@ -0,0 +1,14 @@
+
+What:           /sys/class/net/<iface>/batman-adv/mesh_iface
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Description:
+                The /sys/class/net/<iface>/batman-adv/mesh_iface file
+                displays the batman mesh interface this <iface>
+                currently is associated with.
+
+What:           /sys/class/net/<iface>/batman-adv/iface_status
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Description:
+                Indicates the status of <iface> as it is seen by batman.
diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
new file mode 100644
index 0000000..5aa1912
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -0,0 +1,33 @@
+
+What:           /sys/class/net/<mesh_iface>/mesh/aggregated_ogms
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Description:
+                Indicates whether the batman protocol messages of the
+                mesh <mesh_iface> shall be aggregated or not.
+
+What:           /sys/class/net/<mesh_iface>/mesh/bonding
+Date:           June 2010
+Contact:        Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
+Description:
+                Indicates whether the data traffic going through the
+                mesh will be sent using multiple interfaces at the
+                same time (if available).
+
+What:           /sys/class/net/<mesh_iface>/mesh/orig_interval
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Description:
+                Defines the interval in milliseconds in which batman
+                sends its protocol messages.
+
+What:           /sys/class/net/<mesh_iface>/mesh/vis_mode
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Description:
+                Each batman node only maintains information about its
+                own local neighborhood, therefore generating graphs
+                showing the topology of the entire mesh is not easily
+                feasible without having a central instance to collect
+                the local topologies from all nodes. This file allows
+                to activate the collecting (server) mode.
diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
new file mode 100644
index 0000000..3a975fc
--- /dev/null
+++ b/Documentation/networking/batman-adv.txt
@@ -0,0 +1,239 @@
+[state: 04-09-2010]
+
+BATMAN-ADV
+----------
+
+Batman  advanced  is  a new approach to wireless networking which
+does no longer operate on the IP basis. Unlike the batman daemon,
+which  exchanges  information  using UDP packets and sets routing
+tables, batman-advanced operates on ISO/OSI Layer 2 only and uses
+and  routes  (or  better: bridges) Ethernet Frames. It emulates a
+virtual network switch of all nodes participating.  Therefore all
+nodes  appear  to be link local, thus all higher operating proto-
+cols won't be affected by any changes within the network. You can
+run almost any protocol above batman advanced, prominent examples
+are: IPv4, IPv6, DHCP, IPX.
+
+Batman advanced was implemented as a Linux kernel driver  to  re-
+duce the overhead to a minimum. It does not depend on any (other)
+network driver, and can be used on wifi as well as ethernet  lan,
+vpn,  etc ... (anything with ethernet-style layer 2).
+
+CONFIGURATION
+-------------
+
+Load the batman-adv module into your kernel:
+
+# insmod batman-adv.ko
+
+The  module  is now waiting for activation. You must add some in-
+terfaces on which batman can operate. After  loading  the  module
+batman  advanced  will scan your systems interfaces to search for
+compatible interfaces. Once found, it will create  subfolders  in
+the /sys directories of each supported interface, e.g.
+
+# ls /sys/class/net/eth0/batman_adv/
+# iface_status  mesh_iface
+
+If an interface does not have the "batman_adv" subfolder it prob-
+ably is not supported. Not supported  interfaces  are:  loopback,
+non-ethernet and batman's own interfaces.
+
+Note:  After the module was loaded it will continuously watch for
+new interfaces to verify the compatibility. There is no  need  to
+reload the module if you plug your USB wifi adapter into your ma-
+chine after batman advanced was initially loaded.
+
+To activate a  given  interface  simply  write  "bat0"  into  its
+"mesh_iface" file inside the batman_adv subfolder:
+
+# echo bat0 > /sys/class/net/eth0/batman_adv/mesh_iface
+
+Repeat  this step for all interfaces you wish to add.  Now batman
+starts using/broadcasting on this/these interface(s).
+
+By reading the "iface_status" file you can check its status:
+
+# cat /sys/class/net/eth0/batman_adv/iface_status
+# active
+
+To deactivate an interface you have  to  write  "none"  into  its
+"mesh_iface" file:
+
+# echo none > /sys/class/net/eth0/batman_adv/mesh_iface
+
+
+All  mesh  wide  settings  can be found in batman's own interface
+folder:
+
+#  ls  /sys/class/net/bat0/mesh/
+#  aggregated_ogms  bonding  orig_interval  vis_mode
+
+
+There is a special folder for debugging informations:
+
+#  ls /sys/kernel/debug/batman_adv/bat0/
+#  originators  socket  transtable_global  transtable_local
+#  vis_data
+
+
+Some of the files contain all sort of status information  regard-
+ing  the  mesh  network.  For  example, you can view the table of
+originators (mesh participants) with:
+
+# cat /sys/kernel/debug/batman_adv/bat0/originators
+
+Other files allow to change batman's behaviour to better fit your
+requirements.  For instance, you can check the current originator
+interval (value in milliseconds which determines how often batman
+sends its broadcast packets):
+
+# cat /sys/class/net/bat0/mesh/orig_interval
+# 1000
+
+and also change its value:
+
+# echo 3000 > /sys/class/net/bat0/mesh/orig_interval
+
+In very mobile scenarios, you might want to adjust the originator
+interval to a lower value. This will make the mesh  more  respon-
+sive to topology changes, but will also increase the overhead.
+
+
+USAGE
+-----
+
+To  make use of your newly created mesh, batman advanced provides
+a new interface "bat0" which you should use from this  point  on.
+All  interfaces  added  to  batman  advanced are not relevant any
+longer because batman handles them for you. Basically, one "hands
+over" the data by using the batman interface and batman will make
+sure it reaches its destination.
+
+The "bat0" interface can be used like any  other  regular  inter-
+face.  It needs an IP address which can be either statically con-
+figured or dynamically (by using DHCP or similar services):
+
+# NodeA: ifconfig bat0 192.168.0.1
+# NodeB: ifconfig bat0 192.168.0.2
+# NodeB: ping 192.168.0.1
+
+Note:  In  order to avoid problems remove all IP addresses previ-
+ously assigned to interfaces now used by batman advanced, e.g.
+
+# ifconfig eth0 0.0.0.0
+
+
+VISUALIZATION
+-------------
+
+If you want topology visualization, at least one mesh  node  must
+be configured as VIS-server:
+
+# echo "server" > /sys/class/net/bat0/mesh/vis_mode
+
+Each  node  is  either configured as "server" or as "client" (de-
+fault: "client").  Clients send their topology data to the server
+next to them, and server synchronize with other servers. If there
+is no server configured (default) within the  mesh,  no  topology
+information   will  be  transmitted.  With  these  "synchronizing
+servers", there can be 1 or more vis servers sharing the same (or
+at least very similar) data.
+
+When  configured  as  server,  you can get a topology snapshot of
+your mesh:
+
+# cat /sys/kernel/debug/batman_adv/bat0/vis_data
+
+This raw output is intended to be easily parsable and convertable
+with  other tools. Have a look at the batctl README if you want a
+vis output in dot or json format for instance and how those  out-
+puts could then be visualised in an image.
+
+The raw format consists of comma separated values per entry where
+each entry is giving information about a  certain  source  inter-
+face.  Each  entry can/has to have the following values:
+-> "mac" - mac address of an originator's source interface
+           (each line begins with it)
+-> "TQ mac  value"  -  src mac's link quality towards mac address
+                       of a neighbor originator's interface which
+                       is being used for routing
+-> "HNA mac" - HNA announced by source mac
+-> "PRIMARY" - this  is a primary interface
+-> "SEC mac" - secondary mac address of source
+               (requires preceding PRIMARY)
+
+The TQ value has a range from 4 to 255 with 255 being  the  best.
+The HNA entries are showing which hosts are connected to the mesh
+via bat0 or being bridged into the mesh network.  The PRIMARY/SEC
+values are only applied on primary interfaces
+
+
+LOGGING/DEBUGGING
+-----------------
+
+All error messages, warnings and information messages are sent to
+the kernel log. Depending on your operating  system  distribution
+this  can  be read in one of a number of ways. Try using the com-
+mands: dmesg, logread, or looking in the files  /var/log/kern.log
+or  /var/log/syslog.  All  batman-adv  messages are prefixed with
+"batman-adv:" So to see just these messages try
+
+# dmesg | grep batman-adv
+
+When investigating problems with your mesh network  it  is  some-
+times  necessary  to see more detail debug messages. This must be
+enabled when compiling the batman-adv module. When building  bat-
+man-adv  as  part of kernel, use "make menuconfig" and enable the
+option "B.A.T.M.A.N. debugging".
+
+Those additional  debug messages can be accessed  using a special
+file in debugfs
+
+# cat /sys/kernel/debug/batman_adv/bat0/log
+
+The additional debug output is by default disabled. It can be en-
+abled  during run time. Following log_levels are defined:
+
+0 - All  debug  output  disabled
+1 - Enable messages related to routing / flooding / broadcasting
+2 - Enable route or hna added / changed / deleted
+3 - Enable all messages
+
+The debug output can be changed at runtime  using  the  file
+/sys/class/net/bat0/mesh/log_level. e.g.
+
+# echo 2 > /sys/class/net/bat0/mesh/log_level
+
+will enable debug messages for when routes or HNAs change.
+
+
+BATCTL
+------
+
+As batman advanced operates on layer 2 all hosts participating in
+the  virtual switch are completely transparent for all  protocols
+above layer 2. Therefore the common diagnosis tools do  not  work
+as  expected.  To  overcome these problems batctl was created. At
+the  moment the  batctl contains ping,  traceroute,  tcpdump  and
+interfaces to the kernel module settings.
+
+For more information, please see the manpage (man batctl).
+
+batctl is available on http://www.open-mesh.org/
+
+
+CONTACT
+-------
+
+Please send us comments, experiences, questions, anything :)
+
+IRC:            #batman   on   irc.freenode.org
+Mailing-list:   b.a.t.m.a.n@open-mesh.net (optional  subscription
+          at https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n)
+
+You can also contact the Authors:
+
+Marek  Lindner  <lindner_marek@yahoo.de>
+Simon  Wunderlich  <siwu@hrz.tu-chemnitz.de>
+
diff --git a/MAINTAINERS b/MAINTAINERS
index 9aec4f2..339b244 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1262,6 +1262,14 @@ S:	Maintained
 F:	drivers/video/backlight/
 F:	include/linux/backlight.h
 
+BATMAN ADVANCED
+M:	Marek Lindner <lindner_marek@yahoo.de>
+M:	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
+L:	b.a.t.m.a.n@lists.open-mesh.net
+W:	http://www.open-mesh.org/
+S:	Maintained
+F:	net/batman-adv/
+
 BAYCOM/HDLCDRV DRIVERS FOR AX.25
 M:	Thomas Sailer <t.sailer@alumni.ethz.ch>
 L:	linux-hams@vger.kernel.org
diff --git a/net/Kconfig b/net/Kconfig
index e330594..ffc602f 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -214,6 +214,7 @@ source "net/ieee802154/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
 source "net/dns_resolver/Kconfig"
+source "net/batman-adv/Kconfig"
 
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index ea60fbc..6f211df 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -68,3 +68,4 @@ obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
 endif
 obj-$(CONFIG_WIMAX)		+= wimax/
 obj-$(CONFIG_DNS_RESOLVER)	+= dns_resolver/
+obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
new file mode 100644
index 0000000..8553f35
--- /dev/null
+++ b/net/batman-adv/Kconfig
@@ -0,0 +1,26 @@
+#
+# B.A.T.M.A.N meshing protocol
+#
+
+config BATMAN_ADV
+	tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
+	depends on NET
+        default n
+	---help---
+
+        B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is
+        a routing protocol for multi-hop ad-hoc mesh networks. The
+        networks may be wired or wireless. See
+        http://www.open-mesh.org/ for more information and user space
+        tools.
+
+config BATMAN_ADV_DEBUG
+	bool "B.A.T.M.A.N. debugging"
+	depends on BATMAN_ADV != n
+	---help---
+
+	  This is an option for use by developers; most people should
+	  say N here. This enables compilation of support for
+	  outputting debugging information to the kernel log. The
+	  output is controlled via the module parameter debug.
+
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
new file mode 100644
index 0000000..4b5c434
--- /dev/null
+++ b/net/batman-adv/Makefile
@@ -0,0 +1,22 @@
+#
+# Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+#
+# Marek Lindner, Simon Wunderlich
+#
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of version 2 of the GNU General Public
+# License as published by the Free Software Foundation.
+#
+# This program is distributed in the hope that it will be useful, but
+# WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+# General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software
+# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+# 02110-1301, USA
+#
+
+obj-$(CONFIG_BATMAN_ADV) += batman-adv.o
+batman-adv-objs := main.o bat_debugfs.o bat_sysfs.o send.o routing.o soft-interface.o icmp_socket.o translation-table.o bitarray.o hash.o ring_buffer.o vis.o hard-interface.o aggregation.o originator.o unicast.o
diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
new file mode 100644
index 0000000..46b9c2b
--- /dev/null
+++ b/net/batman-adv/aggregation.c
@@ -0,0 +1,270 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "aggregation.h"
+#include "send.h"
+#include "routing.h"
+
+/* calculate the size of the hna information for a given packet */
+static int hna_len(struct batman_packet *batman_packet)
+{
+	return batman_packet->num_hna * ETH_ALEN;
+}
+
+/* return true if new_packet can be aggregated with forw_packet */
+static bool can_aggregate_with(struct batman_packet *new_batman_packet,
+			       int packet_len,
+			       unsigned long send_time,
+			       bool directlink,
+			       struct batman_if *if_incoming,
+			       struct forw_packet *forw_packet)
+{
+	struct batman_packet *batman_packet =
+		(struct batman_packet *)forw_packet->skb->data;
+	int aggregated_bytes = forw_packet->packet_len + packet_len;
+
+	/**
+	 * we can aggregate the current packet to this aggregated packet
+	 * if:
+	 *
+	 * - the send time is within our MAX_AGGREGATION_MS time
+	 * - the resulting packet wont be bigger than
+	 *   MAX_AGGREGATION_BYTES
+	 */
+
+	if (time_before(send_time, forw_packet->send_time) &&
+	    time_after_eq(send_time + msecs_to_jiffies(MAX_AGGREGATION_MS),
+					forw_packet->send_time) &&
+	    (aggregated_bytes <= MAX_AGGREGATION_BYTES)) {
+
+		/**
+		 * check aggregation compatibility
+		 * -> direct link packets are broadcasted on
+		 *    their interface only
+		 * -> aggregate packet if the current packet is
+		 *    a "global" packet as well as the base
+		 *    packet
+		 */
+
+		/* packets without direct link flag and high TTL
+		 * are flooded through the net  */
+		if ((!directlink) &&
+		    (!(batman_packet->flags & DIRECTLINK)) &&
+		    (batman_packet->ttl != 1) &&
+
+		    /* own packets originating non-primary
+		     * interfaces leave only that interface */
+		    ((!forw_packet->own) ||
+		     (forw_packet->if_incoming->if_num == 0)))
+			return true;
+
+		/* if the incoming packet is sent via this one
+		 * interface only - we still can aggregate */
+		if ((directlink) &&
+		    (new_batman_packet->ttl == 1) &&
+		    (forw_packet->if_incoming == if_incoming) &&
+
+		    /* packets from direct neighbors or
+		     * own secondary interface packets
+		     * (= secondary interface packets in general) */
+		    (batman_packet->flags & DIRECTLINK ||
+		     (forw_packet->own &&
+		      forw_packet->if_incoming->if_num != 0)))
+			return true;
+	}
+
+	return false;
+}
+
+#define atomic_dec_not_zero(v)          atomic_add_unless((v), -1, 0)
+/* create a new aggregated packet and add this packet to it */
+static void new_aggregated_packet(unsigned char *packet_buff, int packet_len,
+				  unsigned long send_time, bool direct_link,
+				  struct batman_if *if_incoming,
+				  int own_packet)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct forw_packet *forw_packet_aggr;
+	unsigned long flags;
+	unsigned char *skb_buff;
+
+	/* own packet should always be scheduled */
+	if (!own_packet) {
+		if (!atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
+			bat_dbg(DBG_BATMAN, bat_priv,
+				"batman packet queue full\n");
+			return;
+		}
+	}
+
+	forw_packet_aggr = kmalloc(sizeof(struct forw_packet), GFP_ATOMIC);
+	if (!forw_packet_aggr) {
+		if (!own_packet)
+			atomic_inc(&bat_priv->batman_queue_left);
+		return;
+	}
+
+	forw_packet_aggr->skb = dev_alloc_skb(MAX_AGGREGATION_BYTES +
+					      sizeof(struct ethhdr));
+	if (!forw_packet_aggr->skb) {
+		if (!own_packet)
+			atomic_inc(&bat_priv->batman_queue_left);
+		kfree(forw_packet_aggr);
+		return;
+	}
+	skb_reserve(forw_packet_aggr->skb, sizeof(struct ethhdr));
+
+	INIT_HLIST_NODE(&forw_packet_aggr->list);
+
+	skb_buff = skb_put(forw_packet_aggr->skb, packet_len);
+	forw_packet_aggr->packet_len = packet_len;
+	memcpy(skb_buff, packet_buff, packet_len);
+
+	forw_packet_aggr->own = own_packet;
+	forw_packet_aggr->if_incoming = if_incoming;
+	forw_packet_aggr->num_packets = 0;
+	forw_packet_aggr->direct_link_flags = 0;
+	forw_packet_aggr->send_time = send_time;
+
+	/* save packet direct link flag status */
+	if (direct_link)
+		forw_packet_aggr->direct_link_flags |= 1;
+
+	/* add new packet to packet list */
+	spin_lock_irqsave(&bat_priv->forw_bat_list_lock, flags);
+	hlist_add_head(&forw_packet_aggr->list, &bat_priv->forw_bat_list);
+	spin_unlock_irqrestore(&bat_priv->forw_bat_list_lock, flags);
+
+	/* start timer for this packet */
+	INIT_DELAYED_WORK(&forw_packet_aggr->delayed_work,
+			  send_outstanding_bat_packet);
+	queue_delayed_work(bat_event_workqueue,
+			   &forw_packet_aggr->delayed_work,
+			   send_time - jiffies);
+}
+
+/* aggregate a new packet into the existing aggregation */
+static void aggregate(struct forw_packet *forw_packet_aggr,
+		      unsigned char *packet_buff,
+		      int packet_len,
+		      bool direct_link)
+{
+	unsigned char *skb_buff;
+
+	skb_buff = skb_put(forw_packet_aggr->skb, packet_len);
+	memcpy(skb_buff, packet_buff, packet_len);
+	forw_packet_aggr->packet_len += packet_len;
+	forw_packet_aggr->num_packets++;
+
+	/* save packet direct link flag status */
+	if (direct_link)
+		forw_packet_aggr->direct_link_flags |=
+			(1 << forw_packet_aggr->num_packets);
+}
+
+void add_bat_packet_to_list(struct bat_priv *bat_priv,
+			    unsigned char *packet_buff, int packet_len,
+			    struct batman_if *if_incoming, char own_packet,
+			    unsigned long send_time)
+{
+	/**
+	 * _aggr -> pointer to the packet we want to aggregate with
+	 * _pos -> pointer to the position in the queue
+	 */
+	struct forw_packet *forw_packet_aggr = NULL, *forw_packet_pos = NULL;
+	struct hlist_node *tmp_node;
+	struct batman_packet *batman_packet =
+		(struct batman_packet *)packet_buff;
+	bool direct_link = batman_packet->flags & DIRECTLINK ? 1 : 0;
+	unsigned long flags;
+
+	/* find position for the packet in the forward queue */
+	spin_lock_irqsave(&bat_priv->forw_bat_list_lock, flags);
+	/* own packets are not to be aggregated */
+	if ((atomic_read(&bat_priv->aggregation_enabled)) && (!own_packet)) {
+		hlist_for_each_entry(forw_packet_pos, tmp_node,
+				     &bat_priv->forw_bat_list, list) {
+			if (can_aggregate_with(batman_packet,
+					       packet_len,
+					       send_time,
+					       direct_link,
+					       if_incoming,
+					       forw_packet_pos)) {
+				forw_packet_aggr = forw_packet_pos;
+				break;
+			}
+		}
+	}
+
+	/* nothing to aggregate with - either aggregation disabled or no
+	 * suitable aggregation packet found */
+	if (forw_packet_aggr == NULL) {
+		/* the following section can run without the lock */
+		spin_unlock_irqrestore(&bat_priv->forw_bat_list_lock, flags);
+
+		/**
+		 * if we could not aggregate this packet with one of the others
+		 * we hold it back for a while, so that it might be aggregated
+		 * later on
+		 */
+		if ((!own_packet) &&
+		    (atomic_read(&bat_priv->aggregation_enabled)))
+			send_time += msecs_to_jiffies(MAX_AGGREGATION_MS);
+
+		new_aggregated_packet(packet_buff, packet_len,
+				      send_time, direct_link,
+				      if_incoming, own_packet);
+	} else {
+		aggregate(forw_packet_aggr,
+			  packet_buff, packet_len,
+			  direct_link);
+		spin_unlock_irqrestore(&bat_priv->forw_bat_list_lock, flags);
+	}
+}
+
+/* unpack the aggregated packets and process them one by one */
+void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packet_buff,
+			     int packet_len, struct batman_if *if_incoming)
+{
+	struct batman_packet *batman_packet;
+	int buff_pos = 0;
+	unsigned char *hna_buff;
+
+	batman_packet = (struct batman_packet *)packet_buff;
+
+	while (aggregated_packet(buff_pos, packet_len,
+				 batman_packet->num_hna)) {
+
+		/* network to host order for our 32bit seqno, and the
+		   orig_interval. */
+		batman_packet->seqno = ntohl(batman_packet->seqno);
+
+		hna_buff = packet_buff + buff_pos + BAT_PACKET_LEN;
+		receive_bat_packet(ethhdr, batman_packet,
+				   hna_buff, hna_len(batman_packet),
+				   if_incoming);
+
+		buff_pos += BAT_PACKET_LEN + hna_len(batman_packet);
+		batman_packet = (struct batman_packet *)
+			(packet_buff + buff_pos);
+	}
+}
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
new file mode 100644
index 0000000..71a91b3
--- /dev/null
+++ b/net/batman-adv/aggregation.h
@@ -0,0 +1,43 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_AGGREGATION_H_
+#define _NET_BATMAN_ADV_AGGREGATION_H_
+
+#include "main.h"
+
+/* is there another aggregated packet here? */
+static inline int aggregated_packet(int buff_pos, int packet_len, int num_hna)
+{
+	int next_buff_pos = buff_pos + BAT_PACKET_LEN + (num_hna * ETH_ALEN);
+
+	return (next_buff_pos <= packet_len) &&
+		(next_buff_pos <= MAX_AGGREGATION_BYTES);
+}
+
+void add_bat_packet_to_list(struct bat_priv *bat_priv,
+			    unsigned char *packet_buff, int packet_len,
+			    struct batman_if *if_incoming, char own_packet,
+			    unsigned long send_time);
+void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packet_buff,
+			     int packet_len, struct batman_if *if_incoming);
+
+#endif /* _NET_BATMAN_ADV_AGGREGATION_H_ */
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
new file mode 100644
index 0000000..507da68
--- /dev/null
+++ b/net/batman-adv/bat_debugfs.c
@@ -0,0 +1,341 @@
+/*
+ * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+
+#include <linux/debugfs.h>
+
+#include "bat_debugfs.h"
+#include "translation-table.h"
+#include "originator.h"
+#include "hard-interface.h"
+#include "vis.h"
+#include "icmp_socket.h"
+
+static struct dentry *bat_debugfs;
+
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+#define LOG_BUFF_MASK (log_buff_len-1)
+#define LOG_BUFF(idx) (debug_log->log_buff[(idx) & LOG_BUFF_MASK])
+
+static int log_buff_len = LOG_BUF_LEN;
+
+static void emit_log_char(struct debug_log *debug_log, char c)
+{
+	LOG_BUFF(debug_log->log_end) = c;
+	debug_log->log_end++;
+
+	if (debug_log->log_end - debug_log->log_start > log_buff_len)
+		debug_log->log_start = debug_log->log_end - log_buff_len;
+}
+
+static int fdebug_log(struct debug_log *debug_log, char *fmt, ...)
+{
+	int printed_len;
+	va_list args;
+	static char debug_log_buf[256];
+	char *p;
+	unsigned long flags;
+
+	if (!debug_log)
+		return 0;
+
+	spin_lock_irqsave(&debug_log->lock, flags);
+	va_start(args, fmt);
+	printed_len = vscnprintf(debug_log_buf, sizeof(debug_log_buf),
+				 fmt, args);
+	va_end(args);
+
+	for (p = debug_log_buf; *p != 0; p++)
+		emit_log_char(debug_log, *p);
+
+	spin_unlock_irqrestore(&debug_log->lock, flags);
+
+	wake_up(&debug_log->queue_wait);
+
+	return 0;
+}
+
+int debug_log(struct bat_priv *bat_priv, char *fmt, ...)
+{
+	va_list args;
+	char tmp_log_buf[256];
+
+	va_start(args, fmt);
+	vscnprintf(tmp_log_buf, sizeof(tmp_log_buf), fmt, args);
+	fdebug_log(bat_priv->debug_log, "[%10u] %s",
+		   (jiffies / HZ), tmp_log_buf);
+	va_end(args);
+
+	return 0;
+}
+
+static int log_open(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	inc_module_count();
+	return 0;
+}
+
+static int log_release(struct inode *inode, struct file *file)
+{
+	dec_module_count();
+	return 0;
+}
+
+static ssize_t log_read(struct file *file, char __user *buf,
+			size_t count, loff_t *ppos)
+{
+	struct bat_priv *bat_priv = file->private_data;
+	struct debug_log *debug_log = bat_priv->debug_log;
+	int error, i = 0;
+	char c;
+	unsigned long flags;
+
+	if ((file->f_flags & O_NONBLOCK) &&
+	    !(debug_log->log_end - debug_log->log_start))
+		return -EAGAIN;
+
+	if ((!buf) || (count < 0))
+		return -EINVAL;
+
+	if (count == 0)
+		return 0;
+
+	if (!access_ok(VERIFY_WRITE, buf, count))
+		return -EFAULT;
+
+	error = wait_event_interruptible(debug_log->queue_wait,
+				(debug_log->log_start - debug_log->log_end));
+
+	if (error)
+		return error;
+
+	spin_lock_irqsave(&debug_log->lock, flags);
+
+	while ((!error) && (i < count) &&
+	       (debug_log->log_start != debug_log->log_end)) {
+		c = LOG_BUFF(debug_log->log_start);
+
+		debug_log->log_start++;
+
+		spin_unlock_irqrestore(&debug_log->lock, flags);
+
+		error = __put_user(c, buf);
+
+		spin_lock_irqsave(&debug_log->lock, flags);
+
+		buf++;
+		i++;
+
+	}
+
+	spin_unlock_irqrestore(&debug_log->lock, flags);
+
+	if (!error)
+		return i;
+
+	return error;
+}
+
+static unsigned int log_poll(struct file *file, poll_table *wait)
+{
+	struct bat_priv *bat_priv = file->private_data;
+	struct debug_log *debug_log = bat_priv->debug_log;
+
+	poll_wait(file, &debug_log->queue_wait, wait);
+
+	if (debug_log->log_end - debug_log->log_start)
+		return POLLIN | POLLRDNORM;
+
+	return 0;
+}
+
+static const struct file_operations log_fops = {
+	.open           = log_open,
+	.release        = log_release,
+	.read           = log_read,
+	.poll           = log_poll,
+};
+
+static int debug_log_setup(struct bat_priv *bat_priv)
+{
+	struct dentry *d;
+
+	if (!bat_priv->debug_dir)
+		goto err;
+
+	bat_priv->debug_log = kzalloc(sizeof(struct debug_log), GFP_ATOMIC);
+	if (!bat_priv->debug_log)
+		goto err;
+
+	spin_lock_init(&bat_priv->debug_log->lock);
+	init_waitqueue_head(&bat_priv->debug_log->queue_wait);
+
+	d = debugfs_create_file("log", S_IFREG | S_IRUSR,
+				bat_priv->debug_dir, bat_priv, &log_fops);
+	if (d)
+		goto err;
+
+	return 0;
+
+err:
+	return 1;
+}
+
+static void debug_log_cleanup(struct bat_priv *bat_priv)
+{
+	kfree(bat_priv->debug_log);
+	bat_priv->debug_log = NULL;
+}
+#else /* CONFIG_BATMAN_ADV_DEBUG */
+static int debug_log_setup(struct bat_priv *bat_priv)
+{
+	bat_priv->debug_log = NULL;
+	return 0;
+}
+
+static void debug_log_cleanup(struct bat_priv *bat_priv)
+{
+	return;
+}
+#endif
+
+static int originators_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev = (struct net_device *)inode->i_private;
+	return single_open(file, orig_seq_print_text, net_dev);
+}
+
+static int transtable_global_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev = (struct net_device *)inode->i_private;
+	return single_open(file, hna_global_seq_print_text, net_dev);
+}
+
+static int transtable_local_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev = (struct net_device *)inode->i_private;
+	return single_open(file, hna_local_seq_print_text, net_dev);
+}
+
+static int vis_data_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev = (struct net_device *)inode->i_private;
+	return single_open(file, vis_seq_print_text, net_dev);
+}
+
+struct bat_debuginfo {
+	struct attribute attr;
+	const struct file_operations fops;
+};
+
+#define BAT_DEBUGINFO(_name, _mode, _open)	\
+struct bat_debuginfo bat_debuginfo_##_name = {	\
+	.attr = { .name = __stringify(_name),	\
+		  .mode = _mode, },		\
+	.fops = { .owner = THIS_MODULE,		\
+		  .open = _open,		\
+		  .read	= seq_read,		\
+		  .llseek = seq_lseek,		\
+		  .release = single_release,	\
+		}				\
+};
+
+static BAT_DEBUGINFO(originators, S_IRUGO, originators_open);
+static BAT_DEBUGINFO(transtable_global, S_IRUGO, transtable_global_open);
+static BAT_DEBUGINFO(transtable_local, S_IRUGO, transtable_local_open);
+static BAT_DEBUGINFO(vis_data, S_IRUGO, vis_data_open);
+
+static struct bat_debuginfo *mesh_debuginfos[] = {
+	&bat_debuginfo_originators,
+	&bat_debuginfo_transtable_global,
+	&bat_debuginfo_transtable_local,
+	&bat_debuginfo_vis_data,
+	NULL,
+};
+
+void debugfs_init(void)
+{
+	bat_debugfs = debugfs_create_dir(DEBUGFS_BAT_SUBDIR, NULL);
+	if (bat_debugfs == ERR_PTR(-ENODEV))
+		bat_debugfs = NULL;
+}
+
+void debugfs_destroy(void)
+{
+	if (bat_debugfs) {
+		debugfs_remove_recursive(bat_debugfs);
+		bat_debugfs = NULL;
+	}
+}
+
+int debugfs_add_meshif(struct net_device *dev)
+{
+	struct bat_priv *bat_priv = netdev_priv(dev);
+	struct bat_debuginfo **bat_debug;
+	struct dentry *file;
+
+	if (!bat_debugfs)
+		goto out;
+
+	bat_priv->debug_dir = debugfs_create_dir(dev->name, bat_debugfs);
+	if (!bat_priv->debug_dir)
+		goto out;
+
+	bat_socket_setup(bat_priv);
+	debug_log_setup(bat_priv);
+
+	for (bat_debug = mesh_debuginfos; *bat_debug; ++bat_debug) {
+		file = debugfs_create_file(((*bat_debug)->attr).name,
+					  S_IFREG | ((*bat_debug)->attr).mode,
+					  bat_priv->debug_dir,
+					  dev, &(*bat_debug)->fops);
+		if (!file) {
+			bat_err(dev, "Can't add debugfs file: %s/%s\n",
+				dev->name, ((*bat_debug)->attr).name);
+			goto rem_attr;
+		}
+	}
+
+	return 0;
+rem_attr:
+	debugfs_remove_recursive(bat_priv->debug_dir);
+	bat_priv->debug_dir = NULL;
+out:
+#ifdef CONFIG_DEBUG_FS
+	return -ENOMEM;
+#else
+	return 0;
+#endif /* CONFIG_DEBUG_FS */
+}
+
+void debugfs_del_meshif(struct net_device *dev)
+{
+	struct bat_priv *bat_priv = netdev_priv(dev);
+
+	debug_log_cleanup(bat_priv);
+
+	if (bat_debugfs) {
+		debugfs_remove_recursive(bat_priv->debug_dir);
+		bat_priv->debug_dir = NULL;
+	}
+}
diff --git a/net/batman-adv/bat_debugfs.h b/net/batman-adv/bat_debugfs.h
new file mode 100644
index 0000000..72df532
--- /dev/null
+++ b/net/batman-adv/bat_debugfs.h
@@ -0,0 +1,33 @@
+/*
+ * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+
+#ifndef _NET_BATMAN_ADV_DEBUGFS_H_
+#define _NET_BATMAN_ADV_DEBUGFS_H_
+
+#define DEBUGFS_BAT_SUBDIR "batman_adv"
+
+void debugfs_init(void);
+void debugfs_destroy(void);
+int debugfs_add_meshif(struct net_device *dev);
+void debugfs_del_meshif(struct net_device *dev);
+
+#endif /* _NET_BATMAN_ADV_DEBUGFS_H_ */
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
new file mode 100644
index 0000000..0610169
--- /dev/null
+++ b/net/batman-adv/bat_sysfs.c
@@ -0,0 +1,536 @@
+/*
+ * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "bat_sysfs.h"
+#include "translation-table.h"
+#include "originator.h"
+#include "hard-interface.h"
+#include "vis.h"
+
+#define to_dev(obj)     container_of(obj, struct device, kobj)
+
+#define BAT_ATTR(_name, _mode, _show, _store)	\
+struct bat_attribute bat_attr_##_name = {	\
+	.attr = {.name = __stringify(_name),	\
+		 .mode = _mode },		\
+	.show   = _show,			\
+	.store  = _store,			\
+};
+
+static ssize_t show_aggr_ogms(struct kobject *kobj, struct attribute *attr,
+			     char *buff)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct bat_priv *bat_priv = netdev_priv(to_net_dev(dev));
+	int aggr_status = atomic_read(&bat_priv->aggregation_enabled);
+
+	return sprintf(buff, "%s\n",
+		       aggr_status == 0 ? "disabled" : "enabled");
+}
+
+static ssize_t store_aggr_ogms(struct kobject *kobj, struct attribute *attr,
+			      char *buff, size_t count)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct net_device *net_dev = to_net_dev(dev);
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	int aggr_tmp = -1;
+
+	if (((count == 2) && (buff[0] == '1')) ||
+	    (strncmp(buff, "enable", 6) == 0))
+		aggr_tmp = 1;
+
+	if (((count == 2) && (buff[0] == '0')) ||
+	    (strncmp(buff, "disable", 7) == 0))
+		aggr_tmp = 0;
+
+	if (aggr_tmp < 0) {
+		if (buff[count - 1] == '\n')
+			buff[count - 1] = '\0';
+
+		bat_info(net_dev,
+			 "Invalid parameter for 'aggregate OGM' setting"
+			 "received: %s\n", buff);
+		return -EINVAL;
+	}
+
+	if (atomic_read(&bat_priv->aggregation_enabled) == aggr_tmp)
+		return count;
+
+	bat_info(net_dev, "Changing aggregation from: %s to: %s\n",
+		 atomic_read(&bat_priv->aggregation_enabled) == 1 ?
+		 "enabled" : "disabled", aggr_tmp == 1 ? "enabled" :
+		 "disabled");
+
+	atomic_set(&bat_priv->aggregation_enabled, (unsigned)aggr_tmp);
+	return count;
+}
+
+static ssize_t show_bond(struct kobject *kobj, struct attribute *attr,
+			     char *buff)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct bat_priv *bat_priv = netdev_priv(to_net_dev(dev));
+	int bond_status = atomic_read(&bat_priv->bonding_enabled);
+
+	return sprintf(buff, "%s\n",
+		       bond_status == 0 ? "disabled" : "enabled");
+}
+
+static ssize_t store_bond(struct kobject *kobj, struct attribute *attr,
+			  char *buff, size_t count)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct net_device *net_dev = to_net_dev(dev);
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	int bonding_enabled_tmp = -1;
+
+	if (((count == 2) && (buff[0] == '1')) ||
+	    (strncmp(buff, "enable", 6) == 0))
+		bonding_enabled_tmp = 1;
+
+	if (((count == 2) && (buff[0] == '0')) ||
+	    (strncmp(buff, "disable", 7) == 0))
+		bonding_enabled_tmp = 0;
+
+	if (bonding_enabled_tmp < 0) {
+		if (buff[count - 1] == '\n')
+			buff[count - 1] = '\0';
+
+		bat_err(net_dev,
+			"Invalid parameter for 'bonding' setting received: "
+			"%s\n", buff);
+		return -EINVAL;
+	}
+
+	if (atomic_read(&bat_priv->bonding_enabled) == bonding_enabled_tmp)
+		return count;
+
+	bat_info(net_dev, "Changing bonding from: %s to: %s\n",
+		 atomic_read(&bat_priv->bonding_enabled) == 1 ?
+		 "enabled" : "disabled",
+		 bonding_enabled_tmp == 1 ? "enabled" : "disabled");
+
+	atomic_set(&bat_priv->bonding_enabled, (unsigned)bonding_enabled_tmp);
+	return count;
+}
+
+static ssize_t show_frag(struct kobject *kobj, struct attribute *attr,
+			     char *buff)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct bat_priv *bat_priv = netdev_priv(to_net_dev(dev));
+	int frag_status = atomic_read(&bat_priv->frag_enabled);
+
+	return sprintf(buff, "%s\n",
+		       frag_status == 0 ? "disabled" : "enabled");
+}
+
+static ssize_t store_frag(struct kobject *kobj, struct attribute *attr,
+			  char *buff, size_t count)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct net_device *net_dev = to_net_dev(dev);
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	int frag_enabled_tmp = -1;
+
+	if (((count == 2) && (buff[0] == '1')) ||
+	    (strncmp(buff, "enable", 6) == 0))
+		frag_enabled_tmp = 1;
+
+	if (((count == 2) && (buff[0] == '0')) ||
+	    (strncmp(buff, "disable", 7) == 0))
+		frag_enabled_tmp = 0;
+
+	if (frag_enabled_tmp < 0) {
+		if (buff[count - 1] == '\n')
+			buff[count - 1] = '\0';
+
+		bat_err(net_dev,
+			"Invalid parameter for 'fragmentation' setting on mesh"
+			"received: %s\n", buff);
+		return -EINVAL;
+	}
+
+	if (atomic_read(&bat_priv->frag_enabled) == frag_enabled_tmp)
+		return count;
+
+	bat_info(net_dev, "Changing fragmentation from: %s to: %s\n",
+		 atomic_read(&bat_priv->frag_enabled) == 1 ?
+		 "enabled" : "disabled",
+		 frag_enabled_tmp == 1 ? "enabled" : "disabled");
+
+	atomic_set(&bat_priv->frag_enabled, (unsigned)frag_enabled_tmp);
+	update_min_mtu(net_dev);
+	return count;
+}
+
+static ssize_t show_vis_mode(struct kobject *kobj, struct attribute *attr,
+			     char *buff)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct bat_priv *bat_priv = netdev_priv(to_net_dev(dev));
+	int vis_mode = atomic_read(&bat_priv->vis_mode);
+
+	return sprintf(buff, "%s\n",
+		       vis_mode == VIS_TYPE_CLIENT_UPDATE ?
+							"client" : "server");
+}
+
+static ssize_t store_vis_mode(struct kobject *kobj, struct attribute *attr,
+			      char *buff, size_t count)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct net_device *net_dev = to_net_dev(dev);
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	unsigned long val;
+	int ret, vis_mode_tmp = -1;
+
+	ret = strict_strtoul(buff, 10, &val);
+
+	if (((count == 2) && (!ret) && (val == VIS_TYPE_CLIENT_UPDATE)) ||
+	    (strncmp(buff, "client", 6) == 0) ||
+	    (strncmp(buff, "off", 3) == 0))
+		vis_mode_tmp = VIS_TYPE_CLIENT_UPDATE;
+
+	if (((count == 2) && (!ret) && (val == VIS_TYPE_SERVER_SYNC)) ||
+	    (strncmp(buff, "server", 6) == 0))
+		vis_mode_tmp = VIS_TYPE_SERVER_SYNC;
+
+	if (vis_mode_tmp < 0) {
+		if (buff[count - 1] == '\n')
+			buff[count - 1] = '\0';
+
+		bat_info(net_dev,
+			 "Invalid parameter for 'vis mode' setting received: "
+			 "%s\n", buff);
+		return -EINVAL;
+	}
+
+	if (atomic_read(&bat_priv->vis_mode) == vis_mode_tmp)
+		return count;
+
+	bat_info(net_dev, "Changing vis mode from: %s to: %s\n",
+		 atomic_read(&bat_priv->vis_mode) == VIS_TYPE_CLIENT_UPDATE ?
+		 "client" : "server", vis_mode_tmp == VIS_TYPE_CLIENT_UPDATE ?
+		 "client" : "server");
+
+	atomic_set(&bat_priv->vis_mode, (unsigned)vis_mode_tmp);
+	return count;
+}
+
+static ssize_t show_orig_interval(struct kobject *kobj, struct attribute *attr,
+				 char *buff)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct bat_priv *bat_priv = netdev_priv(to_net_dev(dev));
+
+	return sprintf(buff, "%i\n",
+		       atomic_read(&bat_priv->orig_interval));
+}
+
+static ssize_t store_orig_interval(struct kobject *kobj, struct attribute *attr,
+				  char *buff, size_t count)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct net_device *net_dev = to_net_dev(dev);
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	unsigned long orig_interval_tmp;
+	int ret;
+
+	ret = strict_strtoul(buff, 10, &orig_interval_tmp);
+	if (ret) {
+		bat_info(net_dev, "Invalid parameter for 'orig_interval' "
+			 "setting received: %s\n", buff);
+		return -EINVAL;
+	}
+
+	if (orig_interval_tmp < JITTER * 2) {
+		bat_info(net_dev, "New originator interval too small: %li "
+			 "(min: %i)\n", orig_interval_tmp, JITTER * 2);
+		return -EINVAL;
+	}
+
+	if (atomic_read(&bat_priv->orig_interval) == orig_interval_tmp)
+		return count;
+
+	bat_info(net_dev, "Changing originator interval from: %i to: %li\n",
+		 atomic_read(&bat_priv->orig_interval),
+		 orig_interval_tmp);
+
+	atomic_set(&bat_priv->orig_interval, orig_interval_tmp);
+	return count;
+}
+
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+static ssize_t show_log_level(struct kobject *kobj, struct attribute *attr,
+			     char *buff)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct bat_priv *bat_priv = netdev_priv(to_net_dev(dev));
+	int log_level = atomic_read(&bat_priv->log_level);
+
+	return sprintf(buff, "%d\n", log_level);
+}
+
+static ssize_t store_log_level(struct kobject *kobj, struct attribute *attr,
+			      char *buff, size_t count)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct net_device *net_dev = to_net_dev(dev);
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	unsigned long log_level_tmp;
+	int ret;
+
+	ret = strict_strtoul(buff, 10, &log_level_tmp);
+	if (ret) {
+		bat_info(net_dev, "Invalid parameter for 'log_level' "
+			 "setting received: %s\n", buff);
+		return -EINVAL;
+	}
+
+	if (log_level_tmp > 3) {
+		bat_info(net_dev, "New log level too big: %li "
+			 "(max: %i)\n", log_level_tmp, 3);
+		return -EINVAL;
+	}
+
+	if (atomic_read(&bat_priv->log_level) == log_level_tmp)
+		return count;
+
+	bat_info(net_dev, "Changing log level from: %i to: %li\n",
+		 atomic_read(&bat_priv->log_level),
+		 log_level_tmp);
+
+	atomic_set(&bat_priv->log_level, (unsigned)log_level_tmp);
+	return count;
+}
+#endif
+
+static BAT_ATTR(aggregated_ogms, S_IRUGO | S_IWUSR,
+		show_aggr_ogms, store_aggr_ogms);
+static BAT_ATTR(bonding, S_IRUGO | S_IWUSR, show_bond, store_bond);
+static BAT_ATTR(fragmentation, S_IRUGO | S_IWUSR, show_frag, store_frag);
+static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, show_vis_mode, store_vis_mode);
+static BAT_ATTR(orig_interval, S_IRUGO | S_IWUSR,
+		show_orig_interval, store_orig_interval);
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+static BAT_ATTR(log_level, S_IRUGO | S_IWUSR, show_log_level, store_log_level);
+#endif
+
+static struct bat_attribute *mesh_attrs[] = {
+	&bat_attr_aggregated_ogms,
+	&bat_attr_bonding,
+	&bat_attr_fragmentation,
+	&bat_attr_vis_mode,
+	&bat_attr_orig_interval,
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+	&bat_attr_log_level,
+#endif
+	NULL,
+};
+
+int sysfs_add_meshif(struct net_device *dev)
+{
+	struct kobject *batif_kobject = &dev->dev.kobj;
+	struct bat_priv *bat_priv = netdev_priv(dev);
+	struct bat_attribute **bat_attr;
+	int err;
+
+	bat_priv->mesh_obj = kobject_create_and_add(SYSFS_IF_MESH_SUBDIR,
+						    batif_kobject);
+	if (!bat_priv->mesh_obj) {
+		bat_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
+			SYSFS_IF_MESH_SUBDIR);
+		goto out;
+	}
+
+	for (bat_attr = mesh_attrs; *bat_attr; ++bat_attr) {
+		err = sysfs_create_file(bat_priv->mesh_obj,
+					&((*bat_attr)->attr));
+		if (err) {
+			bat_err(dev, "Can't add sysfs file: %s/%s/%s\n",
+				dev->name, SYSFS_IF_MESH_SUBDIR,
+				((*bat_attr)->attr).name);
+			goto rem_attr;
+		}
+	}
+
+	return 0;
+
+rem_attr:
+	for (bat_attr = mesh_attrs; *bat_attr; ++bat_attr)
+		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
+
+	kobject_put(bat_priv->mesh_obj);
+	bat_priv->mesh_obj = NULL;
+out:
+	return -ENOMEM;
+}
+
+void sysfs_del_meshif(struct net_device *dev)
+{
+	struct bat_priv *bat_priv = netdev_priv(dev);
+	struct bat_attribute **bat_attr;
+
+	for (bat_attr = mesh_attrs; *bat_attr; ++bat_attr)
+		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
+
+	kobject_put(bat_priv->mesh_obj);
+	bat_priv->mesh_obj = NULL;
+}
+
+static ssize_t show_mesh_iface(struct kobject *kobj, struct attribute *attr,
+			       char *buff)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct net_device *net_dev = to_net_dev(dev);
+	struct batman_if *batman_if = get_batman_if_by_netdev(net_dev);
+
+	if (!batman_if)
+		return 0;
+
+	return sprintf(buff, "%s\n",
+		       batman_if->if_status == IF_NOT_IN_USE ?
+					"none" : batman_if->soft_iface->name);
+}
+
+static ssize_t store_mesh_iface(struct kobject *kobj, struct attribute *attr,
+				char *buff, size_t count)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct net_device *net_dev = to_net_dev(dev);
+	struct batman_if *batman_if = get_batman_if_by_netdev(net_dev);
+	int status_tmp = -1;
+
+	if (!batman_if)
+		return count;
+
+	if (buff[count - 1] == '\n')
+		buff[count - 1] = '\0';
+
+	if (strlen(buff) >= IFNAMSIZ) {
+		pr_err("Invalid parameter for 'mesh_iface' setting received: "
+		       "interface name too long '%s'\n", buff);
+		return -EINVAL;
+	}
+
+	if (strncmp(buff, "none", 4) == 0)
+		status_tmp = IF_NOT_IN_USE;
+	else
+		status_tmp = IF_I_WANT_YOU;
+
+	if ((batman_if->if_status == status_tmp) || ((batman_if->soft_iface) &&
+	    (strncmp(batman_if->soft_iface->name, buff, IFNAMSIZ) == 0)))
+		return count;
+
+	if (status_tmp == IF_NOT_IN_USE) {
+		rtnl_lock();
+		hardif_disable_interface(batman_if);
+		rtnl_unlock();
+		return count;
+	}
+
+	/* if the interface already is in use */
+	if (batman_if->if_status != IF_NOT_IN_USE) {
+		rtnl_lock();
+		hardif_disable_interface(batman_if);
+		rtnl_unlock();
+	}
+
+	return hardif_enable_interface(batman_if, buff);
+}
+
+static ssize_t show_iface_status(struct kobject *kobj, struct attribute *attr,
+				 char *buff)
+{
+	struct device *dev = to_dev(kobj->parent);
+	struct net_device *net_dev = to_net_dev(dev);
+	struct batman_if *batman_if = get_batman_if_by_netdev(net_dev);
+
+	if (!batman_if)
+		return 0;
+
+	switch (batman_if->if_status) {
+	case IF_TO_BE_REMOVED:
+		return sprintf(buff, "disabling\n");
+	case IF_INACTIVE:
+		return sprintf(buff, "inactive\n");
+	case IF_ACTIVE:
+		return sprintf(buff, "active\n");
+	case IF_TO_BE_ACTIVATED:
+		return sprintf(buff, "enabling\n");
+	case IF_NOT_IN_USE:
+	default:
+		return sprintf(buff, "not in use\n");
+	}
+}
+
+static BAT_ATTR(mesh_iface, S_IRUGO | S_IWUSR,
+		show_mesh_iface, store_mesh_iface);
+static BAT_ATTR(iface_status, S_IRUGO, show_iface_status, NULL);
+
+static struct bat_attribute *batman_attrs[] = {
+	&bat_attr_mesh_iface,
+	&bat_attr_iface_status,
+	NULL,
+};
+
+int sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev)
+{
+	struct kobject *hardif_kobject = &dev->dev.kobj;
+	struct bat_attribute **bat_attr;
+	int err;
+
+	*hardif_obj = kobject_create_and_add(SYSFS_IF_BAT_SUBDIR,
+						    hardif_kobject);
+
+	if (!*hardif_obj) {
+		bat_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
+			SYSFS_IF_BAT_SUBDIR);
+		goto out;
+	}
+
+	for (bat_attr = batman_attrs; *bat_attr; ++bat_attr) {
+		err = sysfs_create_file(*hardif_obj, &((*bat_attr)->attr));
+		if (err) {
+			bat_err(dev, "Can't add sysfs file: %s/%s/%s\n",
+				dev->name, SYSFS_IF_BAT_SUBDIR,
+				((*bat_attr)->attr).name);
+			goto rem_attr;
+		}
+	}
+
+	return 0;
+
+rem_attr:
+	for (bat_attr = batman_attrs; *bat_attr; ++bat_attr)
+		sysfs_remove_file(*hardif_obj, &((*bat_attr)->attr));
+out:
+	return -ENOMEM;
+}
+
+void sysfs_del_hardif(struct kobject **hardif_obj)
+{
+	kobject_put(*hardif_obj);
+	*hardif_obj = NULL;
+}
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
new file mode 100644
index 0000000..7f186c0
--- /dev/null
+++ b/net/batman-adv/bat_sysfs.h
@@ -0,0 +1,42 @@
+/*
+ * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+
+#ifndef _NET_BATMAN_ADV_SYSFS_H_
+#define _NET_BATMAN_ADV_SYSFS_H_
+
+#define SYSFS_IF_MESH_SUBDIR "mesh"
+#define SYSFS_IF_BAT_SUBDIR "batman_adv"
+
+struct bat_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct kobject *kobj, struct attribute *attr,
+			char *buf);
+	ssize_t (*store)(struct kobject *kobj, struct attribute *attr,
+			 char *buf, size_t count);
+};
+
+int sysfs_add_meshif(struct net_device *dev);
+void sysfs_del_meshif(struct net_device *dev);
+int sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev);
+void sysfs_del_hardif(struct kobject **hardif_obj);
+
+#endif /* _NET_BATMAN_ADV_SYSFS_H_ */
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
new file mode 100644
index 0000000..814274f
--- /dev/null
+++ b/net/batman-adv/bitarray.c
@@ -0,0 +1,201 @@
+/*
+ * Copyright (C) 2006-2010 B.A.T.M.A.N. contributors:
+ *
+ * Simon Wunderlich, Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "bitarray.h"
+
+#include <linux/bitops.h>
+
+/* returns true if the corresponding bit in the given seq_bits indicates true
+ * and curr_seqno is within range of last_seqno */
+uint8_t get_bit_status(TYPE_OF_WORD *seq_bits, uint32_t last_seqno,
+		       uint32_t curr_seqno)
+{
+	int32_t diff, word_offset, word_num;
+
+	diff = last_seqno - curr_seqno;
+	if (diff < 0 || diff >= TQ_LOCAL_WINDOW_SIZE) {
+		return 0;
+	} else {
+		/* which word */
+		word_num = (last_seqno - curr_seqno) / WORD_BIT_SIZE;
+		/* which position in the selected word */
+		word_offset = (last_seqno - curr_seqno) % WORD_BIT_SIZE;
+
+		if (seq_bits[word_num] & 1 << word_offset)
+			return 1;
+		else
+			return 0;
+	}
+}
+
+/* turn corresponding bit on, so we can remember that we got the packet */
+void bit_mark(TYPE_OF_WORD *seq_bits, int32_t n)
+{
+	int32_t word_offset, word_num;
+
+	/* if too old, just drop it */
+	if (n < 0 || n >= TQ_LOCAL_WINDOW_SIZE)
+		return;
+
+	/* which word */
+	word_num = n / WORD_BIT_SIZE;
+	/* which position in the selected word */
+	word_offset = n % WORD_BIT_SIZE;
+
+	seq_bits[word_num] |= 1 << word_offset;	/* turn the position on */
+}
+
+/* shift the packet array by n places. */
+static void bit_shift(TYPE_OF_WORD *seq_bits, int32_t n)
+{
+	int32_t word_offset, word_num;
+	int32_t i;
+
+	if (n <= 0 || n >= TQ_LOCAL_WINDOW_SIZE)
+		return;
+
+	word_offset = n % WORD_BIT_SIZE;/* shift how much inside each word */
+	word_num = n / WORD_BIT_SIZE;	/* shift over how much (full) words */
+
+	for (i = NUM_WORDS - 1; i > word_num; i--) {
+		/* going from old to new, so we don't overwrite the data we copy
+		 * from.
+		 *
+		 * left is high, right is low: FEDC BA98 7654 3210
+		 *					  ^^ ^^
+		 *			       vvvv
+		 * ^^^^ = from, vvvvv =to, we'd have word_num==1 and
+		 * word_offset==WORD_BIT_SIZE/2 ????? in this example.
+		 * (=24 bits)
+		 *
+		 * our desired output would be: 9876 5432 1000 0000
+		 * */
+
+		seq_bits[i] =
+			(seq_bits[i - word_num] << word_offset) +
+			/* take the lower port from the left half, shift it left
+			 * to its final position */
+			(seq_bits[i - word_num - 1] >>
+			 (WORD_BIT_SIZE-word_offset));
+		/* and the upper part of the right half and shift it left to
+		 * it's position */
+		/* for our example that would be: word[0] = 9800 + 0076 =
+		 * 9876 */
+	}
+	/* now for our last word, i==word_num, we only have the it's "left"
+	 * half. that's the 1000 word in our example.*/
+
+	seq_bits[i] = (seq_bits[i - word_num] << word_offset);
+
+	/* pad the rest with 0, if there is anything */
+	i--;
+
+	for (; i >= 0; i--)
+		seq_bits[i] = 0;
+}
+
+static void bit_reset_window(TYPE_OF_WORD *seq_bits)
+{
+	int i;
+	for (i = 0; i < NUM_WORDS; i++)
+		seq_bits[i] = 0;
+}
+
+
+/* receive and process one packet within the sequence number window.
+ *
+ * returns:
+ *  1 if the window was moved (either new or very old)
+ *  0 if the window was not moved/shifted.
+ */
+char bit_get_packet(void *priv, TYPE_OF_WORD *seq_bits,
+		    int32_t seq_num_diff, int8_t set_mark)
+{
+	struct bat_priv *bat_priv = (struct bat_priv *)priv;
+
+	/* sequence number is slightly older. We already got a sequence number
+	 * higher than this one, so we just mark it. */
+
+	if ((seq_num_diff <= 0) && (seq_num_diff > -TQ_LOCAL_WINDOW_SIZE)) {
+		if (set_mark)
+			bit_mark(seq_bits, -seq_num_diff);
+		return 0;
+	}
+
+	/* sequence number is slightly newer, so we shift the window and
+	 * set the mark if required */
+
+	if ((seq_num_diff > 0) && (seq_num_diff < TQ_LOCAL_WINDOW_SIZE)) {
+		bit_shift(seq_bits, seq_num_diff);
+
+		if (set_mark)
+			bit_mark(seq_bits, 0);
+		return 1;
+	}
+
+	/* sequence number is much newer, probably missed a lot of packets */
+
+	if ((seq_num_diff >= TQ_LOCAL_WINDOW_SIZE)
+		|| (seq_num_diff < EXPECTED_SEQNO_RANGE)) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"We missed a lot of packets (%i) !\n",
+			seq_num_diff - 1);
+		bit_reset_window(seq_bits);
+		if (set_mark)
+			bit_mark(seq_bits, 0);
+		return 1;
+	}
+
+	/* received a much older packet. The other host either restarted
+	 * or the old packet got delayed somewhere in the network. The
+	 * packet should be dropped without calling this function if the
+	 * seqno window is protected. */
+
+	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE)
+		|| (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
+
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Other host probably restarted!\n");
+
+		bit_reset_window(seq_bits);
+		if (set_mark)
+			bit_mark(seq_bits, 0);
+
+		return 1;
+	}
+
+	/* never reached */
+	return 0;
+}
+
+/* count the hamming weight, how many good packets did we receive? just count
+ * the 1's.
+ */
+int bit_packet_count(TYPE_OF_WORD *seq_bits)
+{
+	int i, hamming = 0;
+
+	for (i = 0; i < NUM_WORDS; i++)
+		hamming += hweight_long(seq_bits[i]);
+
+	return hamming;
+}
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
new file mode 100644
index 0000000..d961d56
--- /dev/null
+++ b/net/batman-adv/bitarray.h
@@ -0,0 +1,47 @@
+/*
+ * Copyright (C) 2006-2010 B.A.T.M.A.N. contributors:
+ *
+ * Simon Wunderlich, Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_BITARRAY_H_
+#define _NET_BATMAN_ADV_BITARRAY_H_
+
+/* you should choose something big, if you don't want to waste cpu
+   and keep the type in sync with bit_packet_count */
+#define TYPE_OF_WORD unsigned long
+#define WORD_BIT_SIZE (sizeof(TYPE_OF_WORD) * 8)
+
+/* returns true if the corresponding bit in the given seq_bits indicates true
+ * and curr_seqno is within range of last_seqno */
+uint8_t get_bit_status(TYPE_OF_WORD *seq_bits, uint32_t last_seqno,
+					   uint32_t curr_seqno);
+
+/* turn corresponding bit on, so we can remember that we got the packet */
+void bit_mark(TYPE_OF_WORD *seq_bits, int32_t n);
+
+
+/* receive and process one packet, returns 1 if received seq_num is considered
+ * new, 0 if old  */
+char bit_get_packet(void *priv, TYPE_OF_WORD *seq_bits,
+		    int32_t seq_num_diff, int8_t set_mark);
+
+/* count the hamming weight, how many good packets did we receive? */
+int  bit_packet_count(TYPE_OF_WORD *seq_bits);
+
+#endif /* _NET_BATMAN_ADV_BITARRAY_H_ */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
new file mode 100644
index 0000000..a587da9
--- /dev/null
+++ b/net/batman-adv/hard-interface.c
@@ -0,0 +1,596 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "hard-interface.h"
+#include "soft-interface.h"
+#include "send.h"
+#include "translation-table.h"
+#include "routing.h"
+#include "bat_sysfs.h"
+#include "originator.h"
+#include "hash.h"
+
+#include <linux/if_arp.h>
+
+#define MIN(x, y) ((x) < (y) ? (x) : (y))
+
+struct batman_if *get_batman_if_by_netdev(struct net_device *net_dev)
+{
+	struct batman_if *batman_if;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->net_dev == net_dev)
+			goto out;
+	}
+
+	batman_if = NULL;
+
+out:
+	rcu_read_unlock();
+	return batman_if;
+}
+
+static int is_valid_iface(struct net_device *net_dev)
+{
+	if (net_dev->flags & IFF_LOOPBACK)
+		return 0;
+
+	if (net_dev->type != ARPHRD_ETHER)
+		return 0;
+
+	if (net_dev->addr_len != ETH_ALEN)
+		return 0;
+
+	/* no batman over batman */
+#ifdef HAVE_NET_DEVICE_OPS
+	if (net_dev->netdev_ops->ndo_start_xmit == interface_tx)
+		return 0;
+#else
+	if (net_dev->hard_start_xmit == interface_tx)
+		return 0;
+#endif
+
+	/* Device is being bridged */
+	/* if (net_dev->priv_flags & IFF_BRIDGE_PORT)
+		return 0; */
+
+	return 1;
+}
+
+static struct batman_if *get_active_batman_if(struct net_device *soft_iface)
+{
+	struct batman_if *batman_if;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->soft_iface != soft_iface)
+			continue;
+
+		if (batman_if->if_status == IF_ACTIVE)
+			goto out;
+	}
+
+	batman_if = NULL;
+
+out:
+	rcu_read_unlock();
+	return batman_if;
+}
+
+static void set_primary_if(struct bat_priv *bat_priv,
+			   struct batman_if *batman_if)
+{
+	struct batman_packet *batman_packet;
+	struct vis_packet *vis_packet;
+
+	bat_priv->primary_if = batman_if;
+
+	if (!bat_priv->primary_if)
+		return;
+
+	batman_packet = (struct batman_packet *)(batman_if->packet_buff);
+	batman_packet->flags = PRIMARIES_FIRST_HOP;
+	batman_packet->ttl = TTL;
+
+	vis_packet = (struct vis_packet *)
+				bat_priv->my_vis_info->skb_packet->data;
+	memcpy(vis_packet->vis_orig,
+	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(vis_packet->sender_orig,
+	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+
+	/***
+	 * hacky trick to make sure that we send the HNA information via
+	 * our new primary interface
+	 */
+	atomic_set(&bat_priv->hna_local_changed, 1);
+}
+
+static bool hardif_is_iface_up(struct batman_if *batman_if)
+{
+	if (batman_if->net_dev->flags & IFF_UP)
+		return true;
+
+	return false;
+}
+
+static void update_mac_addresses(struct batman_if *batman_if)
+{
+	addr_to_string(batman_if->addr_str, batman_if->net_dev->dev_addr);
+
+	memcpy(((struct batman_packet *)(batman_if->packet_buff))->orig,
+	       batman_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(((struct batman_packet *)(batman_if->packet_buff))->prev_sender,
+	       batman_if->net_dev->dev_addr, ETH_ALEN);
+}
+
+static void check_known_mac_addr(uint8_t *addr)
+{
+	struct batman_if *batman_if;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if ((batman_if->if_status != IF_ACTIVE) &&
+		    (batman_if->if_status != IF_TO_BE_ACTIVATED))
+			continue;
+
+		if (!compare_orig(batman_if->net_dev->dev_addr, addr))
+			continue;
+
+		pr_warning("The newly added mac address (%pM) already exists "
+			   "on: %s\n", addr, batman_if->net_dev->name);
+		pr_warning("It is strongly recommended to keep mac addresses "
+			   "unique to avoid problems!\n");
+	}
+	rcu_read_unlock();
+}
+
+int hardif_min_mtu(struct net_device *soft_iface)
+{
+	struct bat_priv *bat_priv = netdev_priv(soft_iface);
+	struct batman_if *batman_if;
+	/* allow big frames if all devices are capable to do so
+	 * (have MTU > 1500 + BAT_HEADER_LEN) */
+	int min_mtu = ETH_DATA_LEN;
+
+	if (atomic_read(&bat_priv->frag_enabled))
+		goto out;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if ((batman_if->if_status != IF_ACTIVE) &&
+		    (batman_if->if_status != IF_TO_BE_ACTIVATED))
+			continue;
+
+		if (batman_if->soft_iface != soft_iface)
+			continue;
+
+		min_mtu = MIN(batman_if->net_dev->mtu - BAT_HEADER_LEN,
+			      min_mtu);
+	}
+	rcu_read_unlock();
+out:
+	return min_mtu;
+}
+
+/* adjusts the MTU if a new interface with a smaller MTU appeared. */
+void update_min_mtu(struct net_device *soft_iface)
+{
+	int min_mtu;
+
+	min_mtu = hardif_min_mtu(soft_iface);
+	if (soft_iface->mtu != min_mtu)
+		soft_iface->mtu = min_mtu;
+}
+
+static void hardif_activate_interface(struct batman_if *batman_if)
+{
+	struct bat_priv *bat_priv;
+
+	if (batman_if->if_status != IF_INACTIVE)
+		return;
+
+	bat_priv = netdev_priv(batman_if->soft_iface);
+
+	update_mac_addresses(batman_if);
+	batman_if->if_status = IF_TO_BE_ACTIVATED;
+
+	/**
+	 * the first active interface becomes our primary interface or
+	 * the next active interface after the old primay interface was removed
+	 */
+	if (!bat_priv->primary_if)
+		set_primary_if(bat_priv, batman_if);
+
+	bat_info(batman_if->soft_iface, "Interface activated: %s\n",
+		 batman_if->net_dev->name);
+
+	update_min_mtu(batman_if->soft_iface);
+	return;
+}
+
+static void hardif_deactivate_interface(struct batman_if *batman_if)
+{
+	if ((batman_if->if_status != IF_ACTIVE) &&
+	   (batman_if->if_status != IF_TO_BE_ACTIVATED))
+		return;
+
+	batman_if->if_status = IF_INACTIVE;
+
+	bat_info(batman_if->soft_iface, "Interface deactivated: %s\n",
+		 batman_if->net_dev->name);
+
+	update_min_mtu(batman_if->soft_iface);
+}
+
+int hardif_enable_interface(struct batman_if *batman_if, char *iface_name)
+{
+	struct bat_priv *bat_priv;
+	struct batman_packet *batman_packet;
+
+	if (batman_if->if_status != IF_NOT_IN_USE)
+		goto out;
+
+	batman_if->soft_iface = dev_get_by_name(&init_net, iface_name);
+
+	if (!batman_if->soft_iface) {
+		batman_if->soft_iface = softif_create(iface_name);
+
+		if (!batman_if->soft_iface)
+			goto err;
+
+		/* dev_get_by_name() increases the reference counter for us */
+		dev_hold(batman_if->soft_iface);
+	}
+
+	bat_priv = netdev_priv(batman_if->soft_iface);
+	batman_if->packet_len = BAT_PACKET_LEN;
+	batman_if->packet_buff = kmalloc(batman_if->packet_len, GFP_ATOMIC);
+
+	if (!batman_if->packet_buff) {
+		bat_err(batman_if->soft_iface, "Can't add interface packet "
+			"(%s): out of memory\n", batman_if->net_dev->name);
+		goto err;
+	}
+
+	batman_packet = (struct batman_packet *)(batman_if->packet_buff);
+	batman_packet->packet_type = BAT_PACKET;
+	batman_packet->version = COMPAT_VERSION;
+	batman_packet->flags = 0;
+	batman_packet->ttl = 2;
+	batman_packet->tq = TQ_MAX_VALUE;
+	batman_packet->num_hna = 0;
+
+	batman_if->if_num = bat_priv->num_ifaces;
+	bat_priv->num_ifaces++;
+	batman_if->if_status = IF_INACTIVE;
+	orig_hash_add_if(batman_if, bat_priv->num_ifaces);
+
+	batman_if->batman_adv_ptype.type = __constant_htons(ETH_P_BATMAN);
+	batman_if->batman_adv_ptype.func = batman_skb_recv;
+	batman_if->batman_adv_ptype.dev = batman_if->net_dev;
+	dev_add_pack(&batman_if->batman_adv_ptype);
+
+	atomic_set(&batman_if->seqno, 1);
+	atomic_set(&batman_if->frag_seqno, 1);
+	bat_info(batman_if->soft_iface, "Adding interface: %s\n",
+		 batman_if->net_dev->name);
+
+	if (atomic_read(&bat_priv->frag_enabled) && batman_if->net_dev->mtu <
+		ETH_DATA_LEN + BAT_HEADER_LEN)
+		bat_info(batman_if->soft_iface,
+			"The MTU of interface %s is too small (%i) to handle "
+			"the transport of batman-adv packets. Packets going "
+			"over this interface will be fragmented on layer2 "
+			"which could impact the performance. Setting the MTU "
+			"to %zi would solve the problem.\n",
+			batman_if->net_dev->name, batman_if->net_dev->mtu,
+			ETH_DATA_LEN + BAT_HEADER_LEN);
+
+	if (!atomic_read(&bat_priv->frag_enabled) && batman_if->net_dev->mtu <
+		ETH_DATA_LEN + BAT_HEADER_LEN)
+		bat_info(batman_if->soft_iface,
+			"The MTU of interface %s is too small (%i) to handle "
+			"the transport of batman-adv packets. If you experience"
+			" problems getting traffic through try increasing the "
+			"MTU to %zi.\n",
+			batman_if->net_dev->name, batman_if->net_dev->mtu,
+			ETH_DATA_LEN + BAT_HEADER_LEN);
+
+	if (hardif_is_iface_up(batman_if))
+		hardif_activate_interface(batman_if);
+	else
+		bat_err(batman_if->soft_iface, "Not using interface %s "
+			"(retrying later): interface not active\n",
+			batman_if->net_dev->name);
+
+	/* begin scheduling originator messages on that interface */
+	schedule_own_packet(batman_if);
+
+out:
+	return 0;
+
+err:
+	return -ENOMEM;
+}
+
+void hardif_disable_interface(struct batman_if *batman_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+
+	if (batman_if->if_status == IF_ACTIVE)
+		hardif_deactivate_interface(batman_if);
+
+	if (batman_if->if_status != IF_INACTIVE)
+		return;
+
+	bat_info(batman_if->soft_iface, "Removing interface: %s\n",
+		 batman_if->net_dev->name);
+	dev_remove_pack(&batman_if->batman_adv_ptype);
+
+	bat_priv->num_ifaces--;
+	orig_hash_del_if(batman_if, bat_priv->num_ifaces);
+
+	if (batman_if == bat_priv->primary_if)
+		set_primary_if(bat_priv,
+			       get_active_batman_if(batman_if->soft_iface));
+
+	kfree(batman_if->packet_buff);
+	batman_if->packet_buff = NULL;
+	batman_if->if_status = IF_NOT_IN_USE;
+
+	/* delete all references to this batman_if */
+	purge_orig_ref(bat_priv);
+	purge_outstanding_packets(bat_priv, batman_if);
+	dev_put(batman_if->soft_iface);
+
+	/* nobody uses this interface anymore */
+	if (!bat_priv->num_ifaces)
+		softif_destroy(batman_if->soft_iface);
+
+	batman_if->soft_iface = NULL;
+}
+
+static struct batman_if *hardif_add_interface(struct net_device *net_dev)
+{
+	struct batman_if *batman_if;
+	int ret;
+
+	ret = is_valid_iface(net_dev);
+	if (ret != 1)
+		goto out;
+
+	dev_hold(net_dev);
+
+	batman_if = kmalloc(sizeof(struct batman_if), GFP_ATOMIC);
+	if (!batman_if) {
+		pr_err("Can't add interface (%s): out of memory\n",
+		       net_dev->name);
+		goto release_dev;
+	}
+
+	ret = sysfs_add_hardif(&batman_if->hardif_obj, net_dev);
+	if (ret)
+		goto free_if;
+
+	batman_if->if_num = -1;
+	batman_if->net_dev = net_dev;
+	batman_if->soft_iface = NULL;
+	batman_if->if_status = IF_NOT_IN_USE;
+	INIT_LIST_HEAD(&batman_if->list);
+
+	check_known_mac_addr(batman_if->net_dev->dev_addr);
+	list_add_tail_rcu(&batman_if->list, &if_list);
+	return batman_if;
+
+free_if:
+	kfree(batman_if);
+release_dev:
+	dev_put(net_dev);
+out:
+	return NULL;
+}
+
+static void hardif_free_interface(struct rcu_head *rcu)
+{
+	struct batman_if *batman_if = container_of(rcu, struct batman_if, rcu);
+
+	kfree(batman_if);
+}
+
+static void hardif_remove_interface(struct batman_if *batman_if)
+{
+	/* first deactivate interface */
+	if (batman_if->if_status != IF_NOT_IN_USE)
+		hardif_disable_interface(batman_if);
+
+	if (batman_if->if_status != IF_NOT_IN_USE)
+		return;
+
+	batman_if->if_status = IF_TO_BE_REMOVED;
+	list_del_rcu(&batman_if->list);
+	sysfs_del_hardif(&batman_if->hardif_obj);
+	dev_put(batman_if->net_dev);
+	call_rcu(&batman_if->rcu, hardif_free_interface);
+}
+
+void hardif_remove_interfaces(void)
+{
+	struct batman_if *batman_if, *batman_if_tmp;
+
+	list_for_each_entry_safe(batman_if, batman_if_tmp, &if_list, list) {
+		rtnl_lock();
+		hardif_remove_interface(batman_if);
+		rtnl_unlock();
+	}
+}
+
+static int hard_if_event(struct notifier_block *this,
+			 unsigned long event, void *ptr)
+{
+	struct net_device *net_dev = (struct net_device *)ptr;
+	struct batman_if *batman_if = get_batman_if_by_netdev(net_dev);
+	struct bat_priv *bat_priv;
+
+	if (!batman_if && event == NETDEV_REGISTER)
+			batman_if = hardif_add_interface(net_dev);
+
+	if (!batman_if)
+		goto out;
+
+	switch (event) {
+	case NETDEV_UP:
+		hardif_activate_interface(batman_if);
+		break;
+	case NETDEV_GOING_DOWN:
+	case NETDEV_DOWN:
+		hardif_deactivate_interface(batman_if);
+		break;
+	case NETDEV_UNREGISTER:
+		hardif_remove_interface(batman_if);
+		break;
+	case NETDEV_CHANGEMTU:
+		if (batman_if->soft_iface)
+			update_min_mtu(batman_if->soft_iface);
+		break;
+	case NETDEV_CHANGEADDR:
+		if (batman_if->if_status == IF_NOT_IN_USE)
+			goto out;
+
+		check_known_mac_addr(batman_if->net_dev->dev_addr);
+		update_mac_addresses(batman_if);
+
+		bat_priv = netdev_priv(batman_if->soft_iface);
+		if (batman_if == bat_priv->primary_if)
+			set_primary_if(bat_priv, batman_if);
+		break;
+	default:
+		break;
+	};
+
+out:
+	return NOTIFY_DONE;
+}
+
+/* receive a packet with the batman ethertype coming on a hard
+ * interface */
+int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
+	struct packet_type *ptype, struct net_device *orig_dev)
+{
+	struct bat_priv *bat_priv;
+	struct batman_packet *batman_packet;
+	struct batman_if *batman_if;
+	int ret;
+
+	batman_if = container_of(ptype, struct batman_if, batman_adv_ptype);
+	skb = skb_share_check(skb, GFP_ATOMIC);
+
+	/* skb was released by skb_share_check() */
+	if (!skb)
+		goto err_out;
+
+	/* packet should hold at least type and version */
+	if (unlikely(!pskb_may_pull(skb, 2)))
+		goto err_free;
+
+	/* expect a valid ethernet header here. */
+	if (unlikely(skb->mac_len != sizeof(struct ethhdr)
+				|| !skb_mac_header(skb)))
+		goto err_free;
+
+	if (!batman_if->soft_iface)
+		goto err_free;
+
+	bat_priv = netdev_priv(batman_if->soft_iface);
+
+	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
+		goto err_free;
+
+	/* discard frames on not active interfaces */
+	if (batman_if->if_status != IF_ACTIVE)
+		goto err_free;
+
+	batman_packet = (struct batman_packet *)skb->data;
+
+	if (batman_packet->version != COMPAT_VERSION) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: incompatible batman version (%i)\n",
+			batman_packet->version);
+		goto err_free;
+	}
+
+	/* all receive handlers return whether they received or reused
+	 * the supplied skb. if not, we have to free the skb. */
+
+	switch (batman_packet->packet_type) {
+		/* batman originator packet */
+	case BAT_PACKET:
+		ret = recv_bat_packet(skb, batman_if);
+		break;
+
+		/* batman icmp packet */
+	case BAT_ICMP:
+		ret = recv_icmp_packet(skb, batman_if);
+		break;
+
+		/* unicast packet */
+	case BAT_UNICAST:
+		ret = recv_unicast_packet(skb, batman_if);
+		break;
+
+		/* fragmented unicast packet */
+	case BAT_UNICAST_FRAG:
+		ret = recv_ucast_frag_packet(skb, batman_if);
+		break;
+
+		/* broadcast packet */
+	case BAT_BCAST:
+		ret = recv_bcast_packet(skb, batman_if);
+		break;
+
+		/* vis packet */
+	case BAT_VIS:
+		ret = recv_vis_packet(skb, batman_if);
+		break;
+	default:
+		ret = NET_RX_DROP;
+	}
+
+	if (ret == NET_RX_DROP)
+		kfree_skb(skb);
+
+	/* return NET_RX_SUCCESS in any case as we
+	 * most probably dropped the packet for
+	 * routing-logical reasons. */
+
+	return NET_RX_SUCCESS;
+
+err_free:
+	kfree_skb(skb);
+err_out:
+	return NET_RX_DROP;
+}
+
+struct notifier_block hard_if_notifier = {
+	.notifier_call = hard_if_event,
+};
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
new file mode 100644
index 0000000..4b49527
--- /dev/null
+++ b/net/batman-adv/hard-interface.h
@@ -0,0 +1,45 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_HARD_INTERFACE_H_
+#define _NET_BATMAN_ADV_HARD_INTERFACE_H_
+
+#define IF_NOT_IN_USE 0
+#define IF_TO_BE_REMOVED 1
+#define IF_INACTIVE 2
+#define IF_ACTIVE 3
+#define IF_TO_BE_ACTIVATED 4
+#define IF_I_WANT_YOU 5
+
+extern struct notifier_block hard_if_notifier;
+
+struct batman_if *get_batman_if_by_netdev(struct net_device *net_dev);
+int hardif_enable_interface(struct batman_if *batman_if, char *iface_name);
+void hardif_disable_interface(struct batman_if *batman_if);
+void hardif_remove_interfaces(void);
+int batman_skb_recv(struct sk_buff *skb,
+				struct net_device *dev,
+				struct packet_type *ptype,
+				struct net_device *orig_dev);
+int hardif_min_mtu(struct net_device *soft_iface);
+void update_min_mtu(struct net_device *soft_iface);
+
+#endif /* _NET_BATMAN_ADV_HARD_INTERFACE_H_ */
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
new file mode 100644
index 0000000..8ef26eb
--- /dev/null
+++ b/net/batman-adv/hash.c
@@ -0,0 +1,306 @@
+/*
+ * Copyright (C) 2006-2010 B.A.T.M.A.N. contributors:
+ *
+ * Simon Wunderlich, Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "hash.h"
+
+/* clears the hash */
+static void hash_init(struct hashtable_t *hash)
+{
+	int i;
+
+	hash->elements = 0;
+
+	for (i = 0 ; i < hash->size; i++)
+		hash->table[i] = NULL;
+}
+
+/* remove the hash structure. if hashdata_free_cb != NULL, this function will be
+ * called to remove the elements inside of the hash.  if you don't remove the
+ * elements, memory might be leaked. */
+void hash_delete(struct hashtable_t *hash, hashdata_free_cb free_cb, void *arg)
+{
+	struct element_t *bucket, *last_bucket;
+	int i;
+
+	for (i = 0; i < hash->size; i++) {
+		bucket = hash->table[i];
+
+		while (bucket != NULL) {
+			if (free_cb != NULL)
+				free_cb(bucket->data, arg);
+
+			last_bucket = bucket;
+			bucket = bucket->next;
+			kfree(last_bucket);
+		}
+	}
+
+	hash_destroy(hash);
+}
+
+/* free only the hashtable and the hash itself. */
+void hash_destroy(struct hashtable_t *hash)
+{
+	kfree(hash->table);
+	kfree(hash);
+}
+
+/* iterate though the hash. First element is selected if an iterator
+ * initialized with HASHIT() is supplied as iter. Use the returned
+ * (or supplied) iterator to access the elements until hash_iterate returns
+ * NULL. */
+
+struct hash_it_t *hash_iterate(struct hashtable_t *hash,
+			       struct hash_it_t *iter)
+{
+	if (!hash)
+		return NULL;
+	if (!iter)
+		return NULL;
+
+	/* sanity checks first (if our bucket got deleted in the last
+	 * iteration): */
+	if (iter->bucket != NULL) {
+		if (iter->first_bucket != NULL) {
+			/* we're on the first element and it got removed after
+			 * the last iteration. */
+			if ((*iter->first_bucket) != iter->bucket) {
+				/* there are still other elements in the list */
+				if ((*iter->first_bucket) != NULL) {
+					iter->prev_bucket = NULL;
+					iter->bucket = (*iter->first_bucket);
+					iter->first_bucket =
+						&hash->table[iter->index];
+					return iter;
+				} else {
+					iter->bucket = NULL;
+				}
+			}
+		} else if (iter->prev_bucket != NULL) {
+			/*
+			* we're not on the first element, and the bucket got
+			* removed after the last iteration.  the last bucket's
+			* next pointer is not pointing to our actual bucket
+			* anymore.  select the next.
+			*/
+			if (iter->prev_bucket->next != iter->bucket)
+				iter->bucket = iter->prev_bucket;
+		}
+	}
+
+	/* now as we are sane, select the next one if there is some */
+	if (iter->bucket != NULL) {
+		if (iter->bucket->next != NULL) {
+			iter->prev_bucket = iter->bucket;
+			iter->bucket = iter->bucket->next;
+			iter->first_bucket = NULL;
+			return iter;
+		}
+	}
+
+	/* if not returned yet, we've reached the last one on the index and have
+	 * to search forward */
+	iter->index++;
+	/* go through the entries of the hash table */
+	while (iter->index < hash->size) {
+		if ((hash->table[iter->index]) != NULL) {
+			iter->prev_bucket = NULL;
+			iter->bucket = hash->table[iter->index];
+			iter->first_bucket = &hash->table[iter->index];
+			return iter;
+		} else {
+			iter->index++;
+		}
+	}
+
+	/* nothing to iterate over anymore */
+	return NULL;
+}
+
+/* allocates and clears the hash */
+struct hashtable_t *hash_new(int size, hashdata_compare_cb compare,
+			     hashdata_choose_cb choose)
+{
+	struct hashtable_t *hash;
+
+	hash = kmalloc(sizeof(struct hashtable_t) , GFP_ATOMIC);
+
+	if (hash == NULL)
+		return NULL;
+
+	hash->size = size;
+	hash->table = kmalloc(sizeof(struct element_t *) * size, GFP_ATOMIC);
+
+	if (hash->table == NULL) {
+		kfree(hash);
+		return NULL;
+	}
+
+	hash_init(hash);
+
+	hash->compare = compare;
+	hash->choose = choose;
+
+	return hash;
+}
+
+/* adds data to the hashtable. returns 0 on success, -1 on error */
+int hash_add(struct hashtable_t *hash, void *data)
+{
+	int index;
+	struct element_t *bucket, *prev_bucket = NULL;
+
+	if (!hash)
+		return -1;
+
+	index = hash->choose(data, hash->size);
+	bucket = hash->table[index];
+
+	while (bucket != NULL) {
+		if (hash->compare(bucket->data, data))
+			return -1;
+
+		prev_bucket = bucket;
+		bucket = bucket->next;
+	}
+
+	/* found the tail of the list, add new element */
+	bucket = kmalloc(sizeof(struct element_t), GFP_ATOMIC);
+
+	if (bucket == NULL)
+		return -1;
+
+	bucket->data = data;
+	bucket->next = NULL;
+
+	/* and link it */
+	if (prev_bucket == NULL)
+		hash->table[index] = bucket;
+	else
+		prev_bucket->next = bucket;
+
+	hash->elements++;
+	return 0;
+}
+
+/* finds data, based on the key in keydata. returns the found data on success,
+ * or NULL on error */
+void *hash_find(struct hashtable_t *hash, void *keydata)
+{
+	int index;
+	struct element_t *bucket;
+
+	if (!hash)
+		return NULL;
+
+	index = hash->choose(keydata , hash->size);
+	bucket = hash->table[index];
+
+	while (bucket != NULL) {
+		if (hash->compare(bucket->data, keydata))
+			return bucket->data;
+
+		bucket = bucket->next;
+	}
+
+	return NULL;
+}
+
+/* remove bucket (this might be used in hash_iterate() if you already found the
+ * bucket you want to delete and don't need the overhead to find it again with
+ * hash_remove(). But usually, you don't want to use this function, as it
+ * fiddles with hash-internals. */
+void *hash_remove_bucket(struct hashtable_t *hash, struct hash_it_t *hash_it_t)
+{
+	void *data_save;
+
+	data_save = hash_it_t->bucket->data;
+
+	if (hash_it_t->prev_bucket != NULL)
+		hash_it_t->prev_bucket->next = hash_it_t->bucket->next;
+	else if (hash_it_t->first_bucket != NULL)
+		(*hash_it_t->first_bucket) = hash_it_t->bucket->next;
+
+	kfree(hash_it_t->bucket);
+	hash->elements--;
+
+	return data_save;
+}
+
+/* removes data from hash, if found. returns pointer do data on success, so you
+ * can remove the used structure yourself, or NULL on error .  data could be the
+ * structure you use with just the key filled, we just need the key for
+ * comparing. */
+void *hash_remove(struct hashtable_t *hash, void *data)
+{
+	struct hash_it_t hash_it_t;
+
+	hash_it_t.index = hash->choose(data, hash->size);
+	hash_it_t.bucket = hash->table[hash_it_t.index];
+	hash_it_t.prev_bucket = NULL;
+
+	while (hash_it_t.bucket != NULL) {
+		if (hash->compare(hash_it_t.bucket->data, data)) {
+			hash_it_t.first_bucket =
+				(hash_it_t.bucket ==
+				 hash->table[hash_it_t.index] ?
+				 &hash->table[hash_it_t.index] : NULL);
+			return hash_remove_bucket(hash, &hash_it_t);
+		}
+
+		hash_it_t.prev_bucket = hash_it_t.bucket;
+		hash_it_t.bucket = hash_it_t.bucket->next;
+	}
+
+	return NULL;
+}
+
+/* resize the hash, returns the pointer to the new hash or NULL on
+ * error. removes the old hash on success. */
+struct hashtable_t *hash_resize(struct hashtable_t *hash, int size)
+{
+	struct hashtable_t *new_hash;
+	struct element_t *bucket;
+	int i;
+
+	/* initialize a new hash with the new size */
+	new_hash = hash_new(size, hash->compare, hash->choose);
+
+	if (new_hash == NULL)
+		return NULL;
+
+	/* copy the elements */
+	for (i = 0; i < hash->size; i++) {
+		bucket = hash->table[i];
+
+		while (bucket != NULL) {
+			hash_add(new_hash, bucket->data);
+			bucket = bucket->next;
+		}
+	}
+
+	/* remove hash and eventual overflow buckets but not the content
+	 * itself. */
+	hash_delete(hash, NULL, NULL);
+
+	return new_hash;
+}
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
new file mode 100644
index 0000000..2c8e176
--- /dev/null
+++ b/net/batman-adv/hash.h
@@ -0,0 +1,100 @@
+/*
+ * Copyright (C) 2006-2010 B.A.T.M.A.N. contributors:
+ *
+ * Simon Wunderlich, Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_HASH_H_
+#define _NET_BATMAN_ADV_HASH_H_
+
+#define HASHIT(name) struct hash_it_t name = { \
+		.index = -1, .bucket = NULL, \
+		.prev_bucket = NULL, \
+		.first_bucket = NULL }
+
+
+typedef int (*hashdata_compare_cb)(void *, void *);
+typedef int (*hashdata_choose_cb)(void *, int);
+typedef void (*hashdata_free_cb)(void *, void *);
+
+struct element_t {
+	void *data;		/* pointer to the data */
+	struct element_t *next;	/* overflow bucket pointer */
+};
+
+struct hash_it_t {
+	int index;
+	struct element_t *bucket;
+	struct element_t *prev_bucket;
+	struct element_t **first_bucket;
+};
+
+struct hashtable_t {
+	struct element_t **table;   /* the hashtable itself, with the buckets */
+	int elements;		    /* number of elements registered */
+	int size;		    /* size of hashtable */
+	hashdata_compare_cb compare;/* callback to a compare function.  should
+				     * compare 2 element datas for their keys,
+				     * return 0 if same and not 0 if not
+				     * same */
+	hashdata_choose_cb choose;  /* the hashfunction, should return an index
+				     * based on the key in the data of the first
+				     * argument and the size the second */
+};
+
+/* allocates and clears the hash */
+struct hashtable_t *hash_new(int size, hashdata_compare_cb compare,
+			     hashdata_choose_cb choose);
+
+/* remove bucket (this might be used in hash_iterate() if you already found the
+ * bucket you want to delete and don't need the overhead to find it again with
+ * hash_remove().  But usually, you don't want to use this function, as it
+ * fiddles with hash-internals. */
+void *hash_remove_bucket(struct hashtable_t *hash, struct hash_it_t *hash_it_t);
+
+/* remove the hash structure. if hashdata_free_cb != NULL, this function will be
+ * called to remove the elements inside of the hash.  if you don't remove the
+ * elements, memory might be leaked. */
+void hash_delete(struct hashtable_t *hash, hashdata_free_cb free_cb, void *arg);
+
+/* free only the hashtable and the hash itself. */
+void hash_destroy(struct hashtable_t *hash);
+
+/* adds data to the hashtable. returns 0 on success, -1 on error */
+int hash_add(struct hashtable_t *hash, void *data);
+
+/* removes data from hash, if found. returns pointer do data on success, so you
+ * can remove the used structure yourself, or NULL on error .  data could be the
+ * structure you use with just the key filled, we just need the key for
+ * comparing. */
+void *hash_remove(struct hashtable_t *hash, void *data);
+
+/* finds data, based on the key in keydata. returns the found data on success,
+ * or NULL on error */
+void *hash_find(struct hashtable_t *hash, void *keydata);
+
+/* resize the hash, returns the pointer to the new hash or NULL on
+ * error. removes the old hash on success */
+struct hashtable_t *hash_resize(struct hashtable_t *hash, int size);
+
+/* iterate though the hash. first element is selected with iter_in NULL.  use
+ * the returned iterator to access the elements until hash_it_t returns NULL. */
+struct hash_it_t *hash_iterate(struct hashtable_t *hash,
+			       struct hash_it_t *iter_in);
+
+#endif /* _NET_BATMAN_ADV_HASH_H_ */
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
new file mode 100644
index 0000000..24627be
--- /dev/null
+++ b/net/batman-adv/icmp_socket.c
@@ -0,0 +1,356 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include <linux/debugfs.h>
+#include <linux/slab.h>
+#include "icmp_socket.h"
+#include "send.h"
+#include "types.h"
+#include "hash.h"
+#include "hard-interface.h"
+
+
+static struct socket_client *socket_client_hash[256];
+
+static void bat_socket_add_packet(struct socket_client *socket_client,
+				  struct icmp_packet_rr *icmp_packet,
+				  size_t icmp_len);
+
+void bat_socket_init(void)
+{
+	memset(socket_client_hash, 0, sizeof(socket_client_hash));
+}
+
+static int bat_socket_open(struct inode *inode, struct file *file)
+{
+	unsigned int i;
+	struct socket_client *socket_client;
+
+	socket_client = kmalloc(sizeof(struct socket_client), GFP_KERNEL);
+
+	if (!socket_client)
+		return -ENOMEM;
+
+	for (i = 0; i < ARRAY_SIZE(socket_client_hash); i++) {
+		if (!socket_client_hash[i]) {
+			socket_client_hash[i] = socket_client;
+			break;
+		}
+	}
+
+	if (i == ARRAY_SIZE(socket_client_hash)) {
+		pr_err("Error - can't add another packet client: "
+		       "maximum number of clients reached\n");
+		kfree(socket_client);
+		return -EXFULL;
+	}
+
+	INIT_LIST_HEAD(&socket_client->queue_list);
+	socket_client->queue_len = 0;
+	socket_client->index = i;
+	socket_client->bat_priv = inode->i_private;
+	spin_lock_init(&socket_client->lock);
+	init_waitqueue_head(&socket_client->queue_wait);
+
+	file->private_data = socket_client;
+
+	inc_module_count();
+	return 0;
+}
+
+static int bat_socket_release(struct inode *inode, struct file *file)
+{
+	struct socket_client *socket_client = file->private_data;
+	struct socket_packet *socket_packet;
+	struct list_head *list_pos, *list_pos_tmp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&socket_client->lock, flags);
+
+	/* for all packets in the queue ... */
+	list_for_each_safe(list_pos, list_pos_tmp, &socket_client->queue_list) {
+		socket_packet = list_entry(list_pos,
+					   struct socket_packet, list);
+
+		list_del(list_pos);
+		kfree(socket_packet);
+	}
+
+	socket_client_hash[socket_client->index] = NULL;
+	spin_unlock_irqrestore(&socket_client->lock, flags);
+
+	kfree(socket_client);
+	dec_module_count();
+
+	return 0;
+}
+
+static ssize_t bat_socket_read(struct file *file, char __user *buf,
+			       size_t count, loff_t *ppos)
+{
+	struct socket_client *socket_client = file->private_data;
+	struct socket_packet *socket_packet;
+	size_t packet_len;
+	int error;
+	unsigned long flags;
+
+	if ((file->f_flags & O_NONBLOCK) && (socket_client->queue_len == 0))
+		return -EAGAIN;
+
+	if ((!buf) || (count < sizeof(struct icmp_packet)))
+		return -EINVAL;
+
+	if (!access_ok(VERIFY_WRITE, buf, count))
+		return -EFAULT;
+
+	error = wait_event_interruptible(socket_client->queue_wait,
+					 socket_client->queue_len);
+
+	if (error)
+		return error;
+
+	spin_lock_irqsave(&socket_client->lock, flags);
+
+	socket_packet = list_first_entry(&socket_client->queue_list,
+					 struct socket_packet, list);
+	list_del(&socket_packet->list);
+	socket_client->queue_len--;
+
+	spin_unlock_irqrestore(&socket_client->lock, flags);
+
+	error = __copy_to_user(buf, &socket_packet->icmp_packet,
+			       socket_packet->icmp_len);
+
+	packet_len = socket_packet->icmp_len;
+	kfree(socket_packet);
+
+	if (error)
+		return -EFAULT;
+
+	return packet_len;
+}
+
+static ssize_t bat_socket_write(struct file *file, const char __user *buff,
+				size_t len, loff_t *off)
+{
+	struct socket_client *socket_client = file->private_data;
+	struct bat_priv *bat_priv = socket_client->bat_priv;
+	struct sk_buff *skb;
+	struct icmp_packet_rr *icmp_packet;
+
+	struct orig_node *orig_node;
+	struct batman_if *batman_if;
+	size_t packet_len = sizeof(struct icmp_packet);
+	uint8_t dstaddr[ETH_ALEN];
+	unsigned long flags;
+
+	if (len < sizeof(struct icmp_packet)) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Error - can't send packet from char device: "
+			"invalid packet size\n");
+		return -EINVAL;
+	}
+
+	if (!bat_priv->primary_if)
+		return -EFAULT;
+
+	if (len >= sizeof(struct icmp_packet_rr))
+		packet_len = sizeof(struct icmp_packet_rr);
+
+	skb = dev_alloc_skb(packet_len + sizeof(struct ethhdr));
+	if (!skb)
+		return -ENOMEM;
+
+	skb_reserve(skb, sizeof(struct ethhdr));
+	icmp_packet = (struct icmp_packet_rr *)skb_put(skb, packet_len);
+
+	if (!access_ok(VERIFY_READ, buff, packet_len)) {
+		len = -EFAULT;
+		goto free_skb;
+	}
+
+	if (__copy_from_user(icmp_packet, buff, packet_len)) {
+		len = -EFAULT;
+		goto free_skb;
+	}
+
+	if (icmp_packet->packet_type != BAT_ICMP) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Error - can't send packet from char device: "
+			"got bogus packet type (expected: BAT_ICMP)\n");
+		len = -EINVAL;
+		goto free_skb;
+	}
+
+	if (icmp_packet->msg_type != ECHO_REQUEST) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Error - can't send packet from char device: "
+			"got bogus message type (expected: ECHO_REQUEST)\n");
+		len = -EINVAL;
+		goto free_skb;
+	}
+
+	icmp_packet->uid = socket_client->index;
+
+	if (icmp_packet->version != COMPAT_VERSION) {
+		icmp_packet->msg_type = PARAMETER_PROBLEM;
+		icmp_packet->ttl = COMPAT_VERSION;
+		bat_socket_add_packet(socket_client, icmp_packet, packet_len);
+		goto free_skb;
+	}
+
+	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
+		goto dst_unreach;
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
+						   icmp_packet->dst));
+
+	if (!orig_node)
+		goto unlock;
+
+	if (!orig_node->router)
+		goto unlock;
+
+	batman_if = orig_node->router->if_incoming;
+	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	if (!batman_if)
+		goto dst_unreach;
+
+	if (batman_if->if_status != IF_ACTIVE)
+		goto dst_unreach;
+
+	memcpy(icmp_packet->orig,
+	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+
+	if (packet_len == sizeof(struct icmp_packet_rr))
+		memcpy(icmp_packet->rr, batman_if->net_dev->dev_addr, ETH_ALEN);
+
+
+	send_skb_packet(skb, batman_if, dstaddr);
+
+	goto out;
+
+unlock:
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+dst_unreach:
+	icmp_packet->msg_type = DESTINATION_UNREACHABLE;
+	bat_socket_add_packet(socket_client, icmp_packet, packet_len);
+free_skb:
+	kfree_skb(skb);
+out:
+	return len;
+}
+
+static unsigned int bat_socket_poll(struct file *file, poll_table *wait)
+{
+	struct socket_client *socket_client = file->private_data;
+
+	poll_wait(file, &socket_client->queue_wait, wait);
+
+	if (socket_client->queue_len > 0)
+		return POLLIN | POLLRDNORM;
+
+	return 0;
+}
+
+static const struct file_operations fops = {
+	.owner = THIS_MODULE,
+	.open = bat_socket_open,
+	.release = bat_socket_release,
+	.read = bat_socket_read,
+	.write = bat_socket_write,
+	.poll = bat_socket_poll,
+};
+
+int bat_socket_setup(struct bat_priv *bat_priv)
+{
+	struct dentry *d;
+
+	if (!bat_priv->debug_dir)
+		goto err;
+
+	d = debugfs_create_file(ICMP_SOCKET, S_IFREG | S_IWUSR | S_IRUSR,
+				bat_priv->debug_dir, bat_priv, &fops);
+	if (d)
+		goto err;
+
+	return 0;
+
+err:
+	return 1;
+}
+
+static void bat_socket_add_packet(struct socket_client *socket_client,
+				  struct icmp_packet_rr *icmp_packet,
+				  size_t icmp_len)
+{
+	struct socket_packet *socket_packet;
+	unsigned long flags;
+
+	socket_packet = kmalloc(sizeof(struct socket_packet), GFP_ATOMIC);
+
+	if (!socket_packet)
+		return;
+
+	INIT_LIST_HEAD(&socket_packet->list);
+	memcpy(&socket_packet->icmp_packet, icmp_packet, icmp_len);
+	socket_packet->icmp_len = icmp_len;
+
+	spin_lock_irqsave(&socket_client->lock, flags);
+
+	/* while waiting for the lock the socket_client could have been
+	 * deleted */
+	if (!socket_client_hash[icmp_packet->uid]) {
+		spin_unlock_irqrestore(&socket_client->lock, flags);
+		kfree(socket_packet);
+		return;
+	}
+
+	list_add_tail(&socket_packet->list, &socket_client->queue_list);
+	socket_client->queue_len++;
+
+	if (socket_client->queue_len > 100) {
+		socket_packet = list_first_entry(&socket_client->queue_list,
+						 struct socket_packet, list);
+
+		list_del(&socket_packet->list);
+		kfree(socket_packet);
+		socket_client->queue_len--;
+	}
+
+	spin_unlock_irqrestore(&socket_client->lock, flags);
+
+	wake_up(&socket_client->queue_wait);
+}
+
+void bat_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
+			       size_t icmp_len)
+{
+	struct socket_client *hash = socket_client_hash[icmp_packet->uid];
+
+	if (hash)
+		bat_socket_add_packet(hash, icmp_packet, icmp_len);
+}
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
new file mode 100644
index 0000000..bf9b348
--- /dev/null
+++ b/net/batman-adv/icmp_socket.h
@@ -0,0 +1,34 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_ICMP_SOCKET_H_
+#define _NET_BATMAN_ADV_ICMP_SOCKET_H_
+
+#include "types.h"
+
+#define ICMP_SOCKET "socket"
+
+void bat_socket_init(void);
+int bat_socket_setup(struct bat_priv *bat_priv);
+void bat_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
+			       size_t icmp_len);
+
+#endif /* _NET_BATMAN_ADV_ICMP_SOCKET_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
new file mode 100644
index 0000000..498861f
--- /dev/null
+++ b/net/batman-adv/main.c
@@ -0,0 +1,225 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "bat_sysfs.h"
+#include "bat_debugfs.h"
+#include "routing.h"
+#include "send.h"
+#include "originator.h"
+#include "soft-interface.h"
+#include "icmp_socket.h"
+#include "translation-table.h"
+#include "hard-interface.h"
+#include "types.h"
+#include "vis.h"
+#include "hash.h"
+
+struct list_head if_list;
+
+unsigned char broadcast_addr[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+
+struct workqueue_struct *bat_event_workqueue;
+
+static int __init batman_init(void)
+{
+	INIT_LIST_HEAD(&if_list);
+
+	/* the name should not be longer than 10 chars - see
+	 * http://lwn.net/Articles/23634/ */
+	bat_event_workqueue = create_singlethread_workqueue("bat_events");
+
+	if (!bat_event_workqueue)
+		return -ENOMEM;
+
+	bat_socket_init();
+	debugfs_init();
+
+	register_netdevice_notifier(&hard_if_notifier);
+
+	pr_info("B.A.T.M.A.N. advanced %s%s (compatibility version %i) "
+		"loaded\n", SOURCE_VERSION, REVISION_VERSION_STR,
+		COMPAT_VERSION);
+
+	return 0;
+}
+
+static void __exit batman_exit(void)
+{
+	debugfs_destroy();
+	unregister_netdevice_notifier(&hard_if_notifier);
+	hardif_remove_interfaces();
+
+	flush_workqueue(bat_event_workqueue);
+	destroy_workqueue(bat_event_workqueue);
+	bat_event_workqueue = NULL;
+}
+
+int mesh_init(struct net_device *soft_iface)
+{
+	struct bat_priv *bat_priv = netdev_priv(soft_iface);
+
+	spin_lock_init(&bat_priv->orig_hash_lock);
+	spin_lock_init(&bat_priv->forw_bat_list_lock);
+	spin_lock_init(&bat_priv->forw_bcast_list_lock);
+	spin_lock_init(&bat_priv->hna_lhash_lock);
+	spin_lock_init(&bat_priv->hna_ghash_lock);
+	spin_lock_init(&bat_priv->gw_list_lock);
+	spin_lock_init(&bat_priv->vis_hash_lock);
+	spin_lock_init(&bat_priv->vis_list_lock);
+
+	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
+	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
+	INIT_HLIST_HEAD(&bat_priv->gw_list);
+
+	if (originator_init(bat_priv) < 1)
+		goto err;
+
+	if (hna_local_init(bat_priv) < 1)
+		goto err;
+
+	if (hna_global_init(bat_priv) < 1)
+		goto err;
+
+	hna_local_add(soft_iface, soft_iface->dev_addr);
+
+	if (vis_init(bat_priv) < 1)
+		goto err;
+
+	atomic_set(&bat_priv->mesh_state, MESH_ACTIVE);
+	goto end;
+
+err:
+	pr_err("Unable to allocate memory for mesh information structures: "
+	       "out of mem ?\n");
+	mesh_free(soft_iface);
+	return -1;
+
+end:
+	return 0;
+}
+
+void mesh_free(struct net_device *soft_iface)
+{
+	struct bat_priv *bat_priv = netdev_priv(soft_iface);
+
+	atomic_set(&bat_priv->mesh_state, MESH_DEACTIVATING);
+
+	purge_outstanding_packets(bat_priv, NULL);
+
+	vis_quit(bat_priv);
+
+	originator_free(bat_priv);
+
+	hna_local_free(bat_priv);
+	hna_global_free(bat_priv);
+
+	synchronize_net();
+
+	synchronize_rcu();
+	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
+}
+
+void inc_module_count(void)
+{
+	try_module_get(THIS_MODULE);
+}
+
+void dec_module_count(void)
+{
+	module_put(THIS_MODULE);
+}
+
+int addr_to_string(char *buff, uint8_t *addr)
+{
+	return sprintf(buff, "%pM", addr);
+}
+
+/* returns 1 if they are the same originator */
+
+int compare_orig(void *data1, void *data2)
+{
+	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
+}
+
+/* hashfunction to choose an entry in a hash table of given size */
+/* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
+int choose_orig(void *data, int32_t size)
+{
+	unsigned char *key = data;
+	uint32_t hash = 0;
+	size_t i;
+
+	for (i = 0; i < 6; i++) {
+		hash += key[i];
+		hash += (hash << 10);
+		hash ^= (hash >> 6);
+	}
+
+	hash += (hash << 3);
+	hash ^= (hash >> 11);
+	hash += (hash << 15);
+
+	return hash % size;
+}
+
+int is_my_mac(uint8_t *addr)
+{
+	struct batman_if *batman_if;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->if_status != IF_ACTIVE)
+			continue;
+
+		if (compare_orig(batman_if->net_dev->dev_addr, addr)) {
+			rcu_read_unlock();
+			return 1;
+		}
+	}
+	rcu_read_unlock();
+	return 0;
+
+}
+
+int is_bcast(uint8_t *addr)
+{
+	return (addr[0] == (uint8_t)0xff) && (addr[1] == (uint8_t)0xff);
+}
+
+int is_mcast(uint8_t *addr)
+{
+	return *addr & 0x01;
+}
+
+module_init(batman_init);
+module_exit(batman_exit);
+
+MODULE_LICENSE("GPL");
+
+MODULE_AUTHOR(DRIVER_AUTHOR);
+MODULE_DESCRIPTION(DRIVER_DESC);
+MODULE_SUPPORTED_DEVICE(DRIVER_DEVICE);
+#ifdef REVISION_VERSION
+MODULE_VERSION(SOURCE_VERSION "-" REVISION_VERSION);
+#else
+MODULE_VERSION(SOURCE_VERSION);
+#endif
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
new file mode 100644
index 0000000..ca97589
--- /dev/null
+++ b/net/batman-adv/main.h
@@ -0,0 +1,185 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_MAIN_H_
+#define _NET_BATMAN_ADV_MAIN_H_
+
+/* Kernel Programming */
+#define LINUX
+
+#define DRIVER_AUTHOR "Marek Lindner <lindner_marek@yahoo.de>, " \
+		      "Simon Wunderlich <siwu@hrz.tu-chemnitz.de>"
+#define DRIVER_DESC   "B.A.T.M.A.N. advanced"
+#define DRIVER_DEVICE "batman-adv"
+
+#define SOURCE_VERSION "next"
+
+
+/* B.A.T.M.A.N. parameters */
+
+#define TQ_MAX_VALUE 255
+#define JITTER 20
+#define TTL 50			  /* Time To Live of broadcast messages */
+
+#define PURGE_TIMEOUT 200	/* purge originators after time in seconds if no
+				   * valid packet comes in -> TODO: check
+				   * influence on TQ_LOCAL_WINDOW_SIZE */
+#define LOCAL_HNA_TIMEOUT 3600 /* in seconds */
+
+#define TQ_LOCAL_WINDOW_SIZE 64	  /* sliding packet range of received originator
+				   * messages in squence numbers (should be a
+				   * multiple of our word size) */
+#define TQ_GLOBAL_WINDOW_SIZE 5
+#define TQ_LOCAL_BIDRECT_SEND_MINIMUM 1
+#define TQ_LOCAL_BIDRECT_RECV_MINIMUM 1
+#define TQ_TOTAL_BIDRECT_LIMIT 1
+
+#define TQ_HOP_PENALTY 10
+
+#define NUM_WORDS (TQ_LOCAL_WINDOW_SIZE / WORD_BIT_SIZE)
+
+#define PACKBUFF_SIZE 2000
+#define LOG_BUF_LEN 8192	  /* has to be a power of 2 */
+#define ETH_STR_LEN 20
+
+#define VIS_INTERVAL 5000	/* 5 seconds */
+
+/* how much worse secondary interfaces may be to
+ * to be considered as bonding candidates */
+
+#define BONDING_TQ_THRESHOLD	50
+
+#define MAX_AGGREGATION_BYTES 512 /* should not be bigger than 512 bytes or
+				   * change the size of
+				   * forw_packet->direct_link_flags */
+#define MAX_AGGREGATION_MS 100
+
+#define RESET_PROTECTION_MS 30000
+#define EXPECTED_SEQNO_RANGE	65536
+/* don't reset again within 30 seconds */
+
+#define MESH_INACTIVE 0
+#define MESH_ACTIVE 1
+#define MESH_DEACTIVATING 2
+
+#define BCAST_QUEUE_LEN		256
+#define BATMAN_QUEUE_LEN	256
+
+/*
+ * Debug Messages
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt /* Append 'batman-adv: ' before
+					     * kernel messages */
+
+#define DBG_BATMAN 1	/* all messages related to routing / flooding /
+			 * broadcasting / etc */
+#define DBG_ROUTES 2	/* route or hna added / changed / deleted */
+#define DBG_ALL 3
+
+#define LOG_BUF_LEN 8192          /* has to be a power of 2 */
+
+
+/*
+ *  Vis
+ */
+
+/* #define VIS_SUBCLUSTERS_DISABLED */
+
+/*
+ * Kernel headers
+ */
+
+#include <linux/mutex.h>	/* mutex */
+#include <linux/module.h>	/* needed by all modules */
+#include <linux/netdevice.h>	/* netdevice */
+#include <linux/if_ether.h>	/* ethernet header */
+#include <linux/poll.h>		/* poll_table */
+#include <linux/kthread.h>	/* kernel threads */
+#include <linux/pkt_sched.h>	/* schedule types */
+#include <linux/workqueue.h>	/* workqueue */
+#include <linux/slab.h>
+#include <net/sock.h>		/* struct sock */
+#include <linux/jiffies.h>
+#include <linux/seq_file.h>
+#include "types.h"
+
+#ifndef REVISION_VERSION
+#define REVISION_VERSION_STR ""
+#else
+#define REVISION_VERSION_STR " "REVISION_VERSION
+#endif
+
+extern struct list_head if_list;
+
+extern unsigned char broadcast_addr[];
+extern struct workqueue_struct *bat_event_workqueue;
+
+int mesh_init(struct net_device *soft_iface);
+void mesh_free(struct net_device *soft_iface);
+void inc_module_count(void);
+void dec_module_count(void);
+int addr_to_string(char *buff, uint8_t *addr);
+int compare_orig(void *data1, void *data2);
+int choose_orig(void *data, int32_t size);
+int is_my_mac(uint8_t *addr);
+int is_bcast(uint8_t *addr);
+int is_mcast(uint8_t *addr);
+
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+int debug_log(struct bat_priv *bat_priv, char *fmt, ...);
+
+#define bat_dbg(type, bat_priv, fmt, arg...)			\
+	do {							\
+		if (atomic_read(&bat_priv->log_level) & type)	\
+			debug_log(bat_priv, fmt, ## arg);	\
+	}							\
+	while (0)
+#else /* !CONFIG_BATMAN_ADV_DEBUG */
+static inline void bat_dbg(char type __attribute__((unused)),
+			   struct bat_priv *bat_priv __attribute__((unused)),
+			   char *fmt __attribute__((unused)), ...)
+{
+}
+#endif
+
+#define bat_warning(net_dev, fmt, arg...)				\
+	do {								\
+		struct net_device *_netdev = (net_dev);                 \
+		struct bat_priv *_batpriv = netdev_priv(_netdev);       \
+		bat_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		pr_warning("%s: " fmt, _netdev->name, ## arg);		\
+	} while (0)
+#define bat_info(net_dev, fmt, arg...)					\
+	do {								\
+		struct net_device *_netdev = (net_dev);                 \
+		struct bat_priv *_batpriv = netdev_priv(_netdev);       \
+		bat_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		pr_info("%s: " fmt, _netdev->name, ## arg);		\
+	} while (0)
+#define bat_err(net_dev, fmt, arg...)					\
+	do {								\
+		struct net_device *_netdev = (net_dev);                 \
+		struct bat_priv *_batpriv = netdev_priv(_netdev);       \
+		bat_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		pr_err("%s: " fmt, _netdev->name, ## arg);		\
+	} while (0)
+
+#endif /* _NET_BATMAN_ADV_MAIN_H_ */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
new file mode 100644
index 0000000..f25d7fd
--- /dev/null
+++ b/net/batman-adv/originator.c
@@ -0,0 +1,539 @@
+/*
+ * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+/* increase the reference counter for this originator */
+
+#include "main.h"
+#include "originator.h"
+#include "hash.h"
+#include "translation-table.h"
+#include "routing.h"
+#include "hard-interface.h"
+#include "unicast.h"
+
+static void purge_orig(struct work_struct *work);
+
+static void start_purge_timer(struct bat_priv *bat_priv)
+{
+	INIT_DELAYED_WORK(&bat_priv->orig_work, purge_orig);
+	queue_delayed_work(bat_event_workqueue, &bat_priv->orig_work, 1 * HZ);
+}
+
+int originator_init(struct bat_priv *bat_priv)
+{
+	unsigned long flags;
+	if (bat_priv->orig_hash)
+		return 1;
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	bat_priv->orig_hash = hash_new(128, compare_orig, choose_orig);
+
+	if (!bat_priv->orig_hash)
+		goto err;
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+	start_purge_timer(bat_priv);
+	return 1;
+
+err:
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+	return 0;
+}
+
+struct neigh_node *
+create_neighbor(struct orig_node *orig_node, struct orig_node *orig_neigh_node,
+		uint8_t *neigh, struct batman_if *if_incoming)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct neigh_node *neigh_node;
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Creating new last-hop neighbor of originator\n");
+
+	neigh_node = kzalloc(sizeof(struct neigh_node), GFP_ATOMIC);
+	if (!neigh_node)
+		return NULL;
+
+	INIT_LIST_HEAD(&neigh_node->list);
+
+	memcpy(neigh_node->addr, neigh, ETH_ALEN);
+	neigh_node->orig_node = orig_neigh_node;
+	neigh_node->if_incoming = if_incoming;
+
+	list_add_tail(&neigh_node->list, &orig_node->neigh_list);
+	return neigh_node;
+}
+
+static void free_orig_node(void *data, void *arg)
+{
+	struct list_head *list_pos, *list_pos_tmp;
+	struct neigh_node *neigh_node;
+	struct orig_node *orig_node = (struct orig_node *)data;
+	struct bat_priv *bat_priv = (struct bat_priv *)arg;
+
+	/* for all neighbors towards this originator ... */
+	list_for_each_safe(list_pos, list_pos_tmp, &orig_node->neigh_list) {
+		neigh_node = list_entry(list_pos, struct neigh_node, list);
+
+		list_del(list_pos);
+		kfree(neigh_node);
+	}
+
+	frag_list_free(&orig_node->frag_list);
+	hna_global_del_orig(bat_priv, orig_node, "originator timed out");
+
+	kfree(orig_node->bcast_own);
+	kfree(orig_node->bcast_own_sum);
+	kfree(orig_node);
+}
+
+void originator_free(struct bat_priv *bat_priv)
+{
+	unsigned long flags;
+
+	if (!bat_priv->orig_hash)
+		return;
+
+	cancel_delayed_work_sync(&bat_priv->orig_work);
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	hash_delete(bat_priv->orig_hash, free_orig_node, bat_priv);
+	bat_priv->orig_hash = NULL;
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+}
+
+/* this function finds or creates an originator entry for the given
+ * address if it does not exits */
+struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
+{
+	struct orig_node *orig_node;
+	struct hashtable_t *swaphash;
+	int size;
+
+	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash, addr));
+
+	if (orig_node)
+		return orig_node;
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Creating new originator: %pM\n", addr);
+
+	orig_node = kzalloc(sizeof(struct orig_node), GFP_ATOMIC);
+	if (!orig_node)
+		return NULL;
+
+	INIT_LIST_HEAD(&orig_node->neigh_list);
+
+	memcpy(orig_node->orig, addr, ETH_ALEN);
+	orig_node->router = NULL;
+	orig_node->hna_buff = NULL;
+	orig_node->bcast_seqno_reset = jiffies - 1
+					- msecs_to_jiffies(RESET_PROTECTION_MS);
+	orig_node->batman_seqno_reset = jiffies - 1
+					- msecs_to_jiffies(RESET_PROTECTION_MS);
+
+	size = bat_priv->num_ifaces * sizeof(TYPE_OF_WORD) * NUM_WORDS;
+
+	orig_node->bcast_own = kzalloc(size, GFP_ATOMIC);
+	if (!orig_node->bcast_own)
+		goto free_orig_node;
+
+	size = bat_priv->num_ifaces * sizeof(uint8_t);
+	orig_node->bcast_own_sum = kzalloc(size, GFP_ATOMIC);
+
+	INIT_LIST_HEAD(&orig_node->frag_list);
+	orig_node->last_frag_packet = 0;
+
+	if (!orig_node->bcast_own_sum)
+		goto free_bcast_own;
+
+	if (hash_add(bat_priv->orig_hash, orig_node) < 0)
+		goto free_bcast_own_sum;
+
+	if (bat_priv->orig_hash->elements * 4 > bat_priv->orig_hash->size) {
+		swaphash = hash_resize(bat_priv->orig_hash,
+				       bat_priv->orig_hash->size * 2);
+
+		if (!swaphash)
+			bat_dbg(DBG_BATMAN, bat_priv,
+				"Couldn't resize orig hash table\n");
+		else
+			bat_priv->orig_hash = swaphash;
+	}
+
+	return orig_node;
+free_bcast_own_sum:
+	kfree(orig_node->bcast_own_sum);
+free_bcast_own:
+	kfree(orig_node->bcast_own);
+free_orig_node:
+	kfree(orig_node);
+	return NULL;
+}
+
+static bool purge_orig_neighbors(struct bat_priv *bat_priv,
+				 struct orig_node *orig_node,
+				 struct neigh_node **best_neigh_node)
+{
+	struct list_head *list_pos, *list_pos_tmp;
+	struct neigh_node *neigh_node;
+	bool neigh_purged = false;
+
+	*best_neigh_node = NULL;
+
+	/* for all neighbors towards this originator ... */
+	list_for_each_safe(list_pos, list_pos_tmp, &orig_node->neigh_list) {
+		neigh_node = list_entry(list_pos, struct neigh_node, list);
+
+		if ((time_after(jiffies,
+			neigh_node->last_valid + PURGE_TIMEOUT * HZ)) ||
+		    (neigh_node->if_incoming->if_status == IF_INACTIVE) ||
+		    (neigh_node->if_incoming->if_status == IF_TO_BE_REMOVED)) {
+
+			if (neigh_node->if_incoming->if_status ==
+							IF_TO_BE_REMOVED)
+				bat_dbg(DBG_BATMAN, bat_priv,
+					"neighbor purge: originator %pM, "
+					"neighbor: %pM, iface: %s\n",
+					orig_node->orig, neigh_node->addr,
+					neigh_node->if_incoming->net_dev->name);
+			else
+				bat_dbg(DBG_BATMAN, bat_priv,
+					"neighbor timeout: originator %pM, "
+					"neighbor: %pM, last_valid: %lu\n",
+					orig_node->orig, neigh_node->addr,
+					(neigh_node->last_valid / HZ));
+
+			neigh_purged = true;
+			list_del(list_pos);
+			kfree(neigh_node);
+		} else {
+			if ((*best_neigh_node == NULL) ||
+			    (neigh_node->tq_avg > (*best_neigh_node)->tq_avg))
+				*best_neigh_node = neigh_node;
+		}
+	}
+	return neigh_purged;
+}
+
+static bool purge_orig_node(struct bat_priv *bat_priv,
+			    struct orig_node *orig_node)
+{
+	struct neigh_node *best_neigh_node;
+
+	if (time_after(jiffies,
+		orig_node->last_valid + 2 * PURGE_TIMEOUT * HZ)) {
+
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Originator timeout: originator %pM, last_valid %lu\n",
+			orig_node->orig, (orig_node->last_valid / HZ));
+		return true;
+	} else {
+		if (purge_orig_neighbors(bat_priv, orig_node,
+							&best_neigh_node)) {
+			update_routes(bat_priv, orig_node,
+				      best_neigh_node,
+				      orig_node->hna_buff,
+				      orig_node->hna_buff_len);
+			/* update bonding candidates, we could have lost
+			 * some candidates. */
+			update_bonding_candidates(bat_priv, orig_node);
+		}
+	}
+
+	return false;
+}
+
+static void _purge_orig(struct bat_priv *bat_priv)
+{
+	HASHIT(hashit);
+	struct orig_node *orig_node;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+
+	/* for all origins... */
+	while (hash_iterate(bat_priv->orig_hash, &hashit)) {
+		orig_node = hashit.bucket->data;
+
+		if (purge_orig_node(bat_priv, orig_node)) {
+			hash_remove_bucket(bat_priv->orig_hash, &hashit);
+			free_orig_node(orig_node, bat_priv);
+		}
+
+		if (time_after(jiffies, (orig_node->last_frag_packet +
+					msecs_to_jiffies(FRAG_TIMEOUT))))
+			frag_list_free(&orig_node->frag_list);
+	}
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+}
+
+static void purge_orig(struct work_struct *work)
+{
+	struct delayed_work *delayed_work =
+		container_of(work, struct delayed_work, work);
+	struct bat_priv *bat_priv =
+		container_of(delayed_work, struct bat_priv, orig_work);
+
+	_purge_orig(bat_priv);
+	start_purge_timer(bat_priv);
+}
+
+void purge_orig_ref(struct bat_priv *bat_priv)
+{
+	_purge_orig(bat_priv);
+}
+
+int orig_seq_print_text(struct seq_file *seq, void *offset)
+{
+	HASHIT(hashit);
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	struct orig_node *orig_node;
+	struct neigh_node *neigh_node;
+	int batman_count = 0;
+	int last_seen_secs;
+	int last_seen_msecs;
+	unsigned long flags;
+	char orig_str[ETH_STR_LEN], router_str[ETH_STR_LEN];
+
+	if ((!bat_priv->primary_if) ||
+	    (bat_priv->primary_if->if_status != IF_ACTIVE)) {
+		if (!bat_priv->primary_if)
+			return seq_printf(seq, "BATMAN mesh %s disabled - "
+				     "please specify interfaces to enable it\n",
+				     net_dev->name);
+
+		return seq_printf(seq, "BATMAN mesh %s "
+				  "disabled - primary interface not active\n",
+				  net_dev->name);
+	}
+
+	rcu_read_lock();
+	seq_printf(seq, "[B.A.T.M.A.N. adv %s%s, MainIF/MAC: %s/%s (%s)]\n",
+		   SOURCE_VERSION, REVISION_VERSION_STR,
+		   bat_priv->primary_if->net_dev->name,
+		   bat_priv->primary_if->addr_str, net_dev->name);
+	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
+		   "Originator", "last-seen", "#", TQ_MAX_VALUE, "Nexthop",
+		   "outgoingIF", "Potential nexthops");
+	rcu_read_unlock();
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+
+	while (hash_iterate(bat_priv->orig_hash, &hashit)) {
+
+		orig_node = hashit.bucket->data;
+
+		if (!orig_node->router)
+			continue;
+
+		if (orig_node->router->tq_avg == 0)
+			continue;
+
+		addr_to_string(orig_str, orig_node->orig);
+		addr_to_string(router_str, orig_node->router->addr);
+		last_seen_secs = jiffies_to_msecs(jiffies -
+						orig_node->last_valid) / 1000;
+		last_seen_msecs = jiffies_to_msecs(jiffies -
+						orig_node->last_valid) % 1000;
+
+		seq_printf(seq, "%-17s %4i.%03is   (%3i) %17s [%10s]:",
+			   orig_str, last_seen_secs, last_seen_msecs,
+			   orig_node->router->tq_avg, router_str,
+			   orig_node->router->if_incoming->net_dev->name);
+
+		list_for_each_entry(neigh_node, &orig_node->neigh_list, list) {
+			addr_to_string(orig_str, neigh_node->addr);
+			seq_printf(seq, " %17s (%3i)", orig_str,
+					   neigh_node->tq_avg);
+		}
+
+		seq_printf(seq, "\n");
+		batman_count++;
+	}
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	if ((batman_count == 0))
+		seq_printf(seq, "No batman nodes in range ...\n");
+
+	return 0;
+}
+
+static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
+{
+	void *data_ptr;
+
+	data_ptr = kmalloc(max_if_num * sizeof(TYPE_OF_WORD) * NUM_WORDS,
+			   GFP_ATOMIC);
+	if (!data_ptr) {
+		pr_err("Can't resize orig: out of memory\n");
+		return -1;
+	}
+
+	memcpy(data_ptr, orig_node->bcast_own,
+	       (max_if_num - 1) * sizeof(TYPE_OF_WORD) * NUM_WORDS);
+	kfree(orig_node->bcast_own);
+	orig_node->bcast_own = data_ptr;
+
+	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
+	if (!data_ptr) {
+		pr_err("Can't resize orig: out of memory\n");
+		return -1;
+	}
+
+	memcpy(data_ptr, orig_node->bcast_own_sum,
+	       (max_if_num - 1) * sizeof(uint8_t));
+	kfree(orig_node->bcast_own_sum);
+	orig_node->bcast_own_sum = data_ptr;
+
+	return 0;
+}
+
+int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
+{
+	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	struct orig_node *orig_node;
+	unsigned long flags;
+	HASHIT(hashit);
+
+	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
+	 * if_num */
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+
+	while (hash_iterate(bat_priv->orig_hash, &hashit)) {
+		orig_node = hashit.bucket->data;
+
+		if (orig_node_add_if(orig_node, max_if_num) == -1)
+			goto err;
+	}
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+	return 0;
+
+err:
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+	return -ENOMEM;
+}
+
+static int orig_node_del_if(struct orig_node *orig_node,
+		     int max_if_num, int del_if_num)
+{
+	void *data_ptr = NULL;
+	int chunk_size;
+
+	/* last interface was removed */
+	if (max_if_num == 0)
+		goto free_bcast_own;
+
+	chunk_size = sizeof(TYPE_OF_WORD) * NUM_WORDS;
+	data_ptr = kmalloc(max_if_num * chunk_size, GFP_ATOMIC);
+	if (!data_ptr) {
+		pr_err("Can't resize orig: out of memory\n");
+		return -1;
+	}
+
+	/* copy first part */
+	memcpy(data_ptr, orig_node->bcast_own, del_if_num * chunk_size);
+
+	/* copy second part */
+	memcpy(data_ptr,
+	       orig_node->bcast_own + ((del_if_num + 1) * chunk_size),
+	       (max_if_num - del_if_num) * chunk_size);
+
+free_bcast_own:
+	kfree(orig_node->bcast_own);
+	orig_node->bcast_own = data_ptr;
+
+	if (max_if_num == 0)
+		goto free_own_sum;
+
+	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
+	if (!data_ptr) {
+		pr_err("Can't resize orig: out of memory\n");
+		return -1;
+	}
+
+	memcpy(data_ptr, orig_node->bcast_own_sum,
+	       del_if_num * sizeof(uint8_t));
+
+	memcpy(data_ptr,
+	       orig_node->bcast_own_sum + ((del_if_num + 1) * sizeof(uint8_t)),
+	       (max_if_num - del_if_num) * sizeof(uint8_t));
+
+free_own_sum:
+	kfree(orig_node->bcast_own_sum);
+	orig_node->bcast_own_sum = data_ptr;
+
+	return 0;
+}
+
+int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
+{
+	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	struct batman_if *batman_if_tmp;
+	struct orig_node *orig_node;
+	unsigned long flags;
+	HASHIT(hashit);
+	int ret;
+
+	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
+	 * if_num */
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+
+	while (hash_iterate(bat_priv->orig_hash, &hashit)) {
+		orig_node = hashit.bucket->data;
+
+		ret = orig_node_del_if(orig_node, max_if_num,
+				       batman_if->if_num);
+
+		if (ret == -1)
+			goto err;
+	}
+
+	/* renumber remaining batman interfaces _inside_ of orig_hash_lock */
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if_tmp, &if_list, list) {
+		if (batman_if_tmp->if_status == IF_NOT_IN_USE)
+			continue;
+
+		if (batman_if == batman_if_tmp)
+			continue;
+
+		if (batman_if->soft_iface != batman_if_tmp->soft_iface)
+			continue;
+
+		if (batman_if_tmp->if_num > batman_if->if_num)
+			batman_if_tmp->if_num--;
+	}
+	rcu_read_unlock();
+
+	batman_if->if_num = -1;
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+	return 0;
+
+err:
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+	return -ENOMEM;
+}
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
new file mode 100644
index 0000000..a97c400
--- /dev/null
+++ b/net/batman-adv/originator.h
@@ -0,0 +1,36 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_ORIGINATOR_H_
+#define _NET_BATMAN_ADV_ORIGINATOR_H_
+
+int originator_init(struct bat_priv *bat_priv);
+void originator_free(struct bat_priv *bat_priv);
+void purge_orig_ref(struct bat_priv *bat_priv);
+struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr);
+struct neigh_node *
+create_neighbor(struct orig_node *orig_node, struct orig_node *orig_neigh_node,
+		uint8_t *neigh, struct batman_if *if_incoming);
+int orig_seq_print_text(struct seq_file *seq, void *offset);
+int orig_hash_add_if(struct batman_if *batman_if, int max_if_num);
+int orig_hash_del_if(struct batman_if *batman_if, int max_if_num);
+
+#endif /* _NET_BATMAN_ADV_ORIGINATOR_H_ */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
new file mode 100644
index 0000000..44de1bf
--- /dev/null
+++ b/net/batman-adv/packet.h
@@ -0,0 +1,134 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_PACKET_H_
+#define _NET_BATMAN_ADV_PACKET_H_
+
+#define ETH_P_BATMAN  0x4305	/* unofficial/not registered Ethertype */
+
+#define BAT_PACKET       0x01
+#define BAT_ICMP         0x02
+#define BAT_UNICAST      0x03
+#define BAT_BCAST        0x04
+#define BAT_VIS          0x05
+#define BAT_UNICAST_FRAG 0x06
+
+/* this file is included by batctl which needs these defines */
+#define COMPAT_VERSION 13
+#define DIRECTLINK 0x40
+#define VIS_SERVER 0x20
+#define PRIMARIES_FIRST_HOP 0x10
+
+/* ICMP message types */
+#define ECHO_REPLY 0
+#define DESTINATION_UNREACHABLE 3
+#define ECHO_REQUEST 8
+#define TTL_EXCEEDED 11
+#define PARAMETER_PROBLEM 12
+
+/* vis defines */
+#define VIS_TYPE_SERVER_SYNC		0
+#define VIS_TYPE_CLIENT_UPDATE		1
+
+/* fragmentation defines */
+#define UNI_FRAG_HEAD 0x01
+
+struct batman_packet {
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  flags;    /* 0x40: DIRECTLINK flag, 0x20 VIS_SERVER flag... */
+	uint8_t  tq;
+	uint32_t seqno;
+	uint8_t  orig[6];
+	uint8_t  prev_sender[6];
+	uint8_t  ttl;
+	uint8_t  num_hna;
+} __attribute__((packed));
+
+#define BAT_PACKET_LEN sizeof(struct batman_packet)
+
+struct icmp_packet {
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  msg_type; /* see ICMP message types above */
+	uint8_t  ttl;
+	uint8_t  dst[6];
+	uint8_t  orig[6];
+	uint16_t seqno;
+	uint8_t  uid;
+} __attribute__((packed));
+
+#define BAT_RR_LEN 16
+
+/* icmp_packet_rr must start with all fields from imcp_packet
+   as this is assumed by code that handles ICMP packets */
+struct icmp_packet_rr {
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  msg_type; /* see ICMP message types above */
+	uint8_t  ttl;
+	uint8_t  dst[6];
+	uint8_t  orig[6];
+	uint16_t seqno;
+	uint8_t  uid;
+	uint8_t  rr_cur;
+	uint8_t  rr[BAT_RR_LEN][ETH_ALEN];
+} __attribute__((packed));
+
+struct unicast_packet {
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  dest[6];
+	uint8_t  ttl;
+} __attribute__((packed));
+
+struct unicast_frag_packet {
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  dest[6];
+	uint8_t  ttl;
+	uint8_t  flags;
+	uint8_t  orig[6];
+	uint16_t seqno;
+} __attribute__((packed));
+
+struct bcast_packet {
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  orig[6];
+	uint8_t  ttl;
+	uint32_t seqno;
+} __attribute__((packed));
+
+struct vis_packet {
+	uint8_t  packet_type;
+	uint8_t  version;        /* batman version field */
+	uint8_t  vis_type;	 /* which type of vis-participant sent this? */
+	uint8_t  entries;	 /* number of entries behind this struct */
+	uint32_t seqno;		 /* sequence number */
+	uint8_t  ttl;		 /* TTL */
+	uint8_t  vis_orig[6];	 /* originator that informs about its
+				  * neighbors */
+	uint8_t  target_orig[6]; /* who should receive this packet */
+	uint8_t  sender_orig[6]; /* who sent or rebroadcasted this packet */
+} __attribute__((packed));
+
+#endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/ring_buffer.c b/net/batman-adv/ring_buffer.c
new file mode 100644
index 0000000..defd37c
--- /dev/null
+++ b/net/batman-adv/ring_buffer.c
@@ -0,0 +1,52 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "ring_buffer.h"
+
+void ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index, uint8_t value)
+{
+	lq_recv[*lq_index] = value;
+	*lq_index = (*lq_index + 1) % TQ_GLOBAL_WINDOW_SIZE;
+}
+
+uint8_t ring_buffer_avg(uint8_t lq_recv[])
+{
+	uint8_t *ptr;
+	uint16_t count = 0, i = 0, sum = 0;
+
+	ptr = lq_recv;
+
+	while (i < TQ_GLOBAL_WINDOW_SIZE) {
+		if (*ptr != 0) {
+			count++;
+			sum += *ptr;
+		}
+
+		i++;
+		ptr++;
+	}
+
+	if (count == 0)
+		return 0;
+
+	return (uint8_t)(sum / count);
+}
diff --git a/net/batman-adv/ring_buffer.h b/net/batman-adv/ring_buffer.h
new file mode 100644
index 0000000..6b0cb9a
--- /dev/null
+++ b/net/batman-adv/ring_buffer.h
@@ -0,0 +1,28 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_RING_BUFFER_H_
+#define _NET_BATMAN_ADV_RING_BUFFER_H_
+
+void ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index, uint8_t value);
+uint8_t ring_buffer_avg(uint8_t lq_recv[]);
+
+#endif /* _NET_BATMAN_ADV_RING_BUFFER_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
new file mode 100644
index 0000000..e12fd99
--- /dev/null
+++ b/net/batman-adv/routing.c
@@ -0,0 +1,1387 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "routing.h"
+#include "send.h"
+#include "hash.h"
+#include "soft-interface.h"
+#include "hard-interface.h"
+#include "icmp_socket.h"
+#include "translation-table.h"
+#include "originator.h"
+#include "types.h"
+#include "ring_buffer.h"
+#include "vis.h"
+#include "aggregation.h"
+#include "unicast.h"
+
+void slide_own_bcast_window(struct batman_if *batman_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	HASHIT(hashit);
+	struct orig_node *orig_node;
+	TYPE_OF_WORD *word;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+
+	while (hash_iterate(bat_priv->orig_hash, &hashit)) {
+		orig_node = hashit.bucket->data;
+		word = &(orig_node->bcast_own[batman_if->if_num * NUM_WORDS]);
+
+		bit_get_packet(bat_priv, word, 1, 0);
+		orig_node->bcast_own_sum[batman_if->if_num] =
+			bit_packet_count(word);
+	}
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+}
+
+static void update_HNA(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		       unsigned char *hna_buff, int hna_buff_len)
+{
+	if ((hna_buff_len != orig_node->hna_buff_len) ||
+	    ((hna_buff_len > 0) &&
+	     (orig_node->hna_buff_len > 0) &&
+	     (memcmp(orig_node->hna_buff, hna_buff, hna_buff_len) != 0))) {
+
+		if (orig_node->hna_buff_len > 0)
+			hna_global_del_orig(bat_priv, orig_node,
+					    "originator changed hna");
+
+		if ((hna_buff_len > 0) && (hna_buff != NULL))
+			hna_global_add_orig(bat_priv, orig_node,
+					    hna_buff, hna_buff_len);
+	}
+}
+
+static void update_route(struct bat_priv *bat_priv,
+			 struct orig_node *orig_node,
+			 struct neigh_node *neigh_node,
+			 unsigned char *hna_buff, int hna_buff_len)
+{
+	/* route deleted */
+	if ((orig_node->router != NULL) && (neigh_node == NULL)) {
+
+		bat_dbg(DBG_ROUTES, bat_priv, "Deleting route towards: %pM\n",
+			orig_node->orig);
+		hna_global_del_orig(bat_priv, orig_node,
+				    "originator timed out");
+
+		/* route added */
+	} else if ((orig_node->router == NULL) && (neigh_node != NULL)) {
+
+		bat_dbg(DBG_ROUTES, bat_priv,
+			"Adding route towards: %pM (via %pM)\n",
+			orig_node->orig, neigh_node->addr);
+		hna_global_add_orig(bat_priv, orig_node,
+				    hna_buff, hna_buff_len);
+
+		/* route changed */
+	} else {
+		bat_dbg(DBG_ROUTES, bat_priv,
+			"Changing route towards: %pM "
+			"(now via %pM - was via %pM)\n",
+			orig_node->orig, neigh_node->addr,
+			orig_node->router->addr);
+	}
+
+	orig_node->router = neigh_node;
+}
+
+
+void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		   struct neigh_node *neigh_node, unsigned char *hna_buff,
+		   int hna_buff_len)
+{
+
+	if (orig_node == NULL)
+		return;
+
+	if (orig_node->router != neigh_node)
+		update_route(bat_priv, orig_node, neigh_node,
+			     hna_buff, hna_buff_len);
+	/* may be just HNA changed */
+	else
+		update_HNA(bat_priv, orig_node, hna_buff, hna_buff_len);
+}
+
+static int is_bidirectional_neigh(struct orig_node *orig_node,
+				struct orig_node *orig_neigh_node,
+				struct batman_packet *batman_packet,
+				struct batman_if *if_incoming)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
+	unsigned char total_count;
+
+	if (orig_node == orig_neigh_node) {
+		list_for_each_entry(tmp_neigh_node,
+				    &orig_node->neigh_list,
+				    list) {
+
+			if (compare_orig(tmp_neigh_node->addr,
+					 orig_neigh_node->orig) &&
+			    (tmp_neigh_node->if_incoming == if_incoming))
+				neigh_node = tmp_neigh_node;
+		}
+
+		if (!neigh_node)
+			neigh_node = create_neighbor(orig_node,
+						     orig_neigh_node,
+						     orig_neigh_node->orig,
+						     if_incoming);
+		/* create_neighbor failed, return 0 */
+		if (!neigh_node)
+			return 0;
+
+		neigh_node->last_valid = jiffies;
+	} else {
+		/* find packet count of corresponding one hop neighbor */
+		list_for_each_entry(tmp_neigh_node,
+				    &orig_neigh_node->neigh_list, list) {
+
+			if (compare_orig(tmp_neigh_node->addr,
+					 orig_neigh_node->orig) &&
+			    (tmp_neigh_node->if_incoming == if_incoming))
+				neigh_node = tmp_neigh_node;
+		}
+
+		if (!neigh_node)
+			neigh_node = create_neighbor(orig_neigh_node,
+						     orig_neigh_node,
+						     orig_neigh_node->orig,
+						     if_incoming);
+		/* create_neighbor failed, return 0 */
+		if (!neigh_node)
+			return 0;
+	}
+
+	orig_node->last_valid = jiffies;
+
+	/* pay attention to not get a value bigger than 100 % */
+	total_count = (orig_neigh_node->bcast_own_sum[if_incoming->if_num] >
+		       neigh_node->real_packet_count ?
+		       neigh_node->real_packet_count :
+		       orig_neigh_node->bcast_own_sum[if_incoming->if_num]);
+
+	/* if we have too few packets (too less data) we set tq_own to zero */
+	/* if we receive too few packets it is not considered bidirectional */
+	if ((total_count < TQ_LOCAL_BIDRECT_SEND_MINIMUM) ||
+	    (neigh_node->real_packet_count < TQ_LOCAL_BIDRECT_RECV_MINIMUM))
+		orig_neigh_node->tq_own = 0;
+	else
+		/* neigh_node->real_packet_count is never zero as we
+		 * only purge old information when getting new
+		 * information */
+		orig_neigh_node->tq_own = (TQ_MAX_VALUE * total_count) /
+			neigh_node->real_packet_count;
+
+	/*
+	 * 1 - ((1-x) ** 3), normalized to TQ_MAX_VALUE this does
+	 * affect the nearly-symmetric links only a little, but
+	 * punishes asymmetric links more.  This will give a value
+	 * between 0 and TQ_MAX_VALUE
+	 */
+	orig_neigh_node->tq_asym_penalty =
+		TQ_MAX_VALUE -
+		(TQ_MAX_VALUE *
+		 (TQ_LOCAL_WINDOW_SIZE - neigh_node->real_packet_count) *
+		 (TQ_LOCAL_WINDOW_SIZE - neigh_node->real_packet_count) *
+		 (TQ_LOCAL_WINDOW_SIZE - neigh_node->real_packet_count)) /
+		(TQ_LOCAL_WINDOW_SIZE *
+		 TQ_LOCAL_WINDOW_SIZE *
+		 TQ_LOCAL_WINDOW_SIZE);
+
+	batman_packet->tq = ((batman_packet->tq *
+			      orig_neigh_node->tq_own *
+			      orig_neigh_node->tq_asym_penalty) /
+			     (TQ_MAX_VALUE * TQ_MAX_VALUE));
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"bidirectional: "
+		"orig = %-15pM neigh = %-15pM => own_bcast = %2i, "
+		"real recv = %2i, local tq: %3i, asym_penalty: %3i, "
+		"total tq: %3i\n",
+		orig_node->orig, orig_neigh_node->orig, total_count,
+		neigh_node->real_packet_count, orig_neigh_node->tq_own,
+		orig_neigh_node->tq_asym_penalty, batman_packet->tq);
+
+	/* if link has the minimum required transmission quality
+	 * consider it bidirectional */
+	if (batman_packet->tq >= TQ_TOTAL_BIDRECT_LIMIT)
+		return 1;
+
+	return 0;
+}
+
+static void update_orig(struct bat_priv *bat_priv,
+			struct orig_node *orig_node,
+			struct ethhdr *ethhdr,
+			struct batman_packet *batman_packet,
+			struct batman_if *if_incoming,
+			unsigned char *hna_buff, int hna_buff_len,
+			char is_duplicate)
+{
+	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
+	int tmp_hna_buff_len;
+
+	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
+		"Searching and updating originator entry of received packet\n");
+
+	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+		if (compare_orig(tmp_neigh_node->addr, ethhdr->h_source) &&
+		    (tmp_neigh_node->if_incoming == if_incoming)) {
+			neigh_node = tmp_neigh_node;
+			continue;
+		}
+
+		if (is_duplicate)
+			continue;
+
+		ring_buffer_set(tmp_neigh_node->tq_recv,
+				&tmp_neigh_node->tq_index, 0);
+		tmp_neigh_node->tq_avg =
+			ring_buffer_avg(tmp_neigh_node->tq_recv);
+	}
+
+	if (!neigh_node) {
+		struct orig_node *orig_tmp;
+
+		orig_tmp = get_orig_node(bat_priv, ethhdr->h_source);
+		if (!orig_tmp)
+			return;
+
+		neigh_node = create_neighbor(orig_node, orig_tmp,
+					     ethhdr->h_source, if_incoming);
+		if (!neigh_node)
+			return;
+	} else
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Updating existing last-hop neighbor of originator\n");
+
+	orig_node->flags = batman_packet->flags;
+	neigh_node->last_valid = jiffies;
+
+	ring_buffer_set(neigh_node->tq_recv,
+			&neigh_node->tq_index,
+			batman_packet->tq);
+	neigh_node->tq_avg = ring_buffer_avg(neigh_node->tq_recv);
+
+	if (!is_duplicate) {
+		orig_node->last_ttl = batman_packet->ttl;
+		neigh_node->last_ttl = batman_packet->ttl;
+	}
+
+	tmp_hna_buff_len = (hna_buff_len > batman_packet->num_hna * ETH_ALEN ?
+			    batman_packet->num_hna * ETH_ALEN : hna_buff_len);
+
+	/* if this neighbor already is our next hop there is nothing
+	 * to change */
+	if (orig_node->router == neigh_node)
+		goto update_hna;
+
+	/* if this neighbor does not offer a better TQ we won't consider it */
+	if ((orig_node->router) &&
+	    (orig_node->router->tq_avg > neigh_node->tq_avg))
+		goto update_hna;
+
+	/* if the TQ is the same and the link not more symetric we
+	 * won't consider it either */
+	if ((orig_node->router) &&
+	     ((neigh_node->tq_avg == orig_node->router->tq_avg) &&
+	     (orig_node->router->orig_node->bcast_own_sum[if_incoming->if_num]
+	      >= neigh_node->orig_node->bcast_own_sum[if_incoming->if_num])))
+		goto update_hna;
+
+	update_routes(bat_priv, orig_node, neigh_node,
+		      hna_buff, tmp_hna_buff_len);
+	return;
+
+update_hna:
+	update_routes(bat_priv, orig_node, orig_node->router,
+		      hna_buff, tmp_hna_buff_len);
+}
+
+/* checks whether the host restarted and is in the protection time.
+ * returns:
+ *  0 if the packet is to be accepted
+ *  1 if the packet is to be ignored.
+ */
+static int window_protected(struct bat_priv *bat_priv,
+			    int32_t seq_num_diff,
+			    unsigned long *last_reset)
+{
+	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE)
+		|| (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
+		if (time_after(jiffies, *last_reset +
+			msecs_to_jiffies(RESET_PROTECTION_MS))) {
+
+			*last_reset = jiffies;
+			bat_dbg(DBG_BATMAN, bat_priv,
+				"old packet received, start protection\n");
+
+			return 0;
+		} else
+			return 1;
+	}
+	return 0;
+}
+
+/* processes a batman packet for all interfaces, adjusts the sequence number and
+ * finds out whether it is a duplicate.
+ * returns:
+ *   1 the packet is a duplicate
+ *   0 the packet has not yet been received
+ *  -1 the packet is old and has been received while the seqno window
+ *     was protected. Caller should drop it.
+ */
+static char count_real_packets(struct ethhdr *ethhdr,
+			       struct batman_packet *batman_packet,
+			       struct batman_if *if_incoming)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct orig_node *orig_node;
+	struct neigh_node *tmp_neigh_node;
+	char is_duplicate = 0;
+	int32_t seq_diff;
+	int need_update = 0;
+	int set_mark;
+
+	orig_node = get_orig_node(bat_priv, batman_packet->orig);
+	if (orig_node == NULL)
+		return 0;
+
+	seq_diff = batman_packet->seqno - orig_node->last_real_seqno;
+
+	/* signalize caller that the packet is to be dropped. */
+	if (window_protected(bat_priv, seq_diff,
+			     &orig_node->batman_seqno_reset))
+		return -1;
+
+	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+
+		is_duplicate |= get_bit_status(tmp_neigh_node->real_bits,
+					       orig_node->last_real_seqno,
+					       batman_packet->seqno);
+
+		if (compare_orig(tmp_neigh_node->addr, ethhdr->h_source) &&
+		    (tmp_neigh_node->if_incoming == if_incoming))
+			set_mark = 1;
+		else
+			set_mark = 0;
+
+		/* if the window moved, set the update flag. */
+		need_update |= bit_get_packet(bat_priv,
+					      tmp_neigh_node->real_bits,
+					      seq_diff, set_mark);
+
+		tmp_neigh_node->real_packet_count =
+			bit_packet_count(tmp_neigh_node->real_bits);
+	}
+
+	if (need_update) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"updating last_seqno: old %d, new %d\n",
+			orig_node->last_real_seqno, batman_packet->seqno);
+		orig_node->last_real_seqno = batman_packet->seqno;
+	}
+
+	return is_duplicate;
+}
+
+/* copy primary address for bonding */
+static void mark_bonding_address(struct bat_priv *bat_priv,
+				 struct orig_node *orig_node,
+				 struct orig_node *orig_neigh_node,
+				 struct batman_packet *batman_packet)
+
+{
+	if (batman_packet->flags & PRIMARIES_FIRST_HOP)
+		memcpy(orig_neigh_node->primary_addr,
+		       orig_node->orig, ETH_ALEN);
+
+	return;
+}
+
+/* mark possible bond.candidates in the neighbor list */
+void update_bonding_candidates(struct bat_priv *bat_priv,
+			       struct orig_node *orig_node)
+{
+	int candidates;
+	int interference_candidate;
+	int best_tq;
+	struct neigh_node *tmp_neigh_node, *tmp_neigh_node2;
+	struct neigh_node *first_candidate, *last_candidate;
+
+	/* update the candidates for this originator */
+	if (!orig_node->router) {
+		orig_node->bond.candidates = 0;
+		return;
+	}
+
+	best_tq = orig_node->router->tq_avg;
+
+	/* update bond.candidates */
+
+	candidates = 0;
+
+	/* mark other nodes which also received "PRIMARIES FIRST HOP" packets
+	 * as "bonding partner" */
+
+	/* first, zero the list */
+	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+		tmp_neigh_node->next_bond_candidate = NULL;
+	}
+
+	first_candidate = NULL;
+	last_candidate = NULL;
+	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+
+		/* only consider if it has the same primary address ...  */
+		if (memcmp(orig_node->orig,
+				tmp_neigh_node->orig_node->primary_addr,
+				ETH_ALEN) != 0)
+			continue;
+
+		/* ... and is good enough to be considered */
+		if (tmp_neigh_node->tq_avg < best_tq - BONDING_TQ_THRESHOLD)
+			continue;
+
+		/* check if we have another candidate with the same
+		 * mac address or interface. If we do, we won't
+		 * select this candidate because of possible interference. */
+
+		interference_candidate = 0;
+		list_for_each_entry(tmp_neigh_node2,
+				&orig_node->neigh_list, list) {
+
+			if (tmp_neigh_node2 == tmp_neigh_node)
+				continue;
+
+			/* we only care if the other candidate is even
+			 * considered as candidate. */
+			if (tmp_neigh_node2->next_bond_candidate == NULL)
+				continue;
+
+
+			if ((tmp_neigh_node->if_incoming ==
+				tmp_neigh_node2->if_incoming)
+				|| (memcmp(tmp_neigh_node->addr,
+				tmp_neigh_node2->addr, ETH_ALEN) == 0)) {
+
+				interference_candidate = 1;
+				break;
+			}
+		}
+		/* don't care further if it is an interference candidate */
+		if (interference_candidate)
+			continue;
+
+		if (first_candidate == NULL) {
+			first_candidate = tmp_neigh_node;
+			tmp_neigh_node->next_bond_candidate = first_candidate;
+		} else
+			tmp_neigh_node->next_bond_candidate = last_candidate;
+
+		last_candidate = tmp_neigh_node;
+
+		candidates++;
+	}
+
+	if (candidates > 0) {
+		first_candidate->next_bond_candidate = last_candidate;
+		orig_node->bond.selected = first_candidate;
+	}
+
+	orig_node->bond.candidates = candidates;
+}
+
+void receive_bat_packet(struct ethhdr *ethhdr,
+				struct batman_packet *batman_packet,
+				unsigned char *hna_buff, int hna_buff_len,
+				struct batman_if *if_incoming)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct batman_if *batman_if;
+	struct orig_node *orig_neigh_node, *orig_node;
+	char has_directlink_flag;
+	char is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
+	char is_broadcast = 0, is_bidirectional, is_single_hop_neigh;
+	char is_duplicate;
+	uint32_t if_incoming_seqno;
+
+	/* Silently drop when the batman packet is actually not a
+	 * correct packet.
+	 *
+	 * This might happen if a packet is padded (e.g. Ethernet has a
+	 * minimum frame length of 64 byte) and the aggregation interprets
+	 * it as an additional length.
+	 *
+	 * TODO: A more sane solution would be to have a bit in the
+	 * batman_packet to detect whether the packet is the last
+	 * packet in an aggregation.  Here we expect that the padding
+	 * is always zero (or not 0x01)
+	 */
+	if (batman_packet->packet_type != BAT_PACKET)
+		return;
+
+	/* could be changed by schedule_own_packet() */
+	if_incoming_seqno = atomic_read(&if_incoming->seqno);
+
+	has_directlink_flag = (batman_packet->flags & DIRECTLINK ? 1 : 0);
+
+	is_single_hop_neigh = (compare_orig(ethhdr->h_source,
+					    batman_packet->orig) ? 1 : 0);
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Received BATMAN packet via NB: %pM, IF: %s [%s] "
+		"(from OG: %pM, via prev OG: %pM, seqno %d, tq %d, "
+		"TTL %d, V %d, IDF %d)\n",
+		ethhdr->h_source, if_incoming->net_dev->name,
+		if_incoming->addr_str, batman_packet->orig,
+		batman_packet->prev_sender, batman_packet->seqno,
+		batman_packet->tq, batman_packet->ttl, batman_packet->version,
+		has_directlink_flag);
+
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->if_status != IF_ACTIVE)
+			continue;
+
+		if (batman_if->soft_iface != if_incoming->soft_iface)
+			continue;
+
+		if (compare_orig(ethhdr->h_source,
+				 batman_if->net_dev->dev_addr))
+			is_my_addr = 1;
+
+		if (compare_orig(batman_packet->orig,
+				 batman_if->net_dev->dev_addr))
+			is_my_orig = 1;
+
+		if (compare_orig(batman_packet->prev_sender,
+				 batman_if->net_dev->dev_addr))
+			is_my_oldorig = 1;
+
+		if (compare_orig(ethhdr->h_source, broadcast_addr))
+			is_broadcast = 1;
+	}
+
+	if (batman_packet->version != COMPAT_VERSION) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: incompatible batman version (%i)\n",
+			batman_packet->version);
+		return;
+	}
+
+	if (is_my_addr) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: received my own broadcast (sender: %pM"
+			")\n",
+			ethhdr->h_source);
+		return;
+	}
+
+	if (is_broadcast) {
+		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
+		"ignoring all packets with broadcast source addr (sender: %pM"
+		")\n", ethhdr->h_source);
+		return;
+	}
+
+	if (is_my_orig) {
+		TYPE_OF_WORD *word;
+		int offset;
+
+		orig_neigh_node = get_orig_node(bat_priv, ethhdr->h_source);
+
+		if (!orig_neigh_node)
+			return;
+
+		/* neighbor has to indicate direct link and it has to
+		 * come via the corresponding interface */
+		/* if received seqno equals last send seqno save new
+		 * seqno for bidirectional check */
+		if (has_directlink_flag &&
+		    compare_orig(if_incoming->net_dev->dev_addr,
+				 batman_packet->orig) &&
+		    (batman_packet->seqno - if_incoming_seqno + 2 == 0)) {
+			offset = if_incoming->if_num * NUM_WORDS;
+			word = &(orig_neigh_node->bcast_own[offset]);
+			bit_mark(word, 0);
+			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
+				bit_packet_count(word);
+		}
+
+		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
+			"originator packet from myself (via neighbor)\n");
+		return;
+	}
+
+	if (is_my_oldorig) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: ignoring all rebroadcast echos (sender: "
+			"%pM)\n", ethhdr->h_source);
+		return;
+	}
+
+	orig_node = get_orig_node(bat_priv, batman_packet->orig);
+	if (orig_node == NULL)
+		return;
+
+	is_duplicate = count_real_packets(ethhdr, batman_packet, if_incoming);
+
+	if (is_duplicate == -1) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: packet within seqno protection time "
+			"(sender: %pM)\n", ethhdr->h_source);
+		return;
+	}
+
+	if (batman_packet->tq == 0) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: originator packet with tq equal 0\n");
+		return;
+	}
+
+	/* avoid temporary routing loops */
+	if ((orig_node->router) &&
+	    (orig_node->router->orig_node->router) &&
+	    (compare_orig(orig_node->router->addr,
+			  batman_packet->prev_sender)) &&
+	    !(compare_orig(batman_packet->orig, batman_packet->prev_sender)) &&
+	    (compare_orig(orig_node->router->addr,
+			  orig_node->router->orig_node->router->addr))) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: ignoring all rebroadcast packets that "
+			"may make me loop (sender: %pM)\n", ethhdr->h_source);
+		return;
+	}
+
+	/* if sender is a direct neighbor the sender mac equals
+	 * originator mac */
+	orig_neigh_node = (is_single_hop_neigh ?
+			   orig_node :
+			   get_orig_node(bat_priv, ethhdr->h_source));
+	if (orig_neigh_node == NULL)
+		return;
+
+	/* drop packet if sender is not a direct neighbor and if we
+	 * don't route towards it */
+	if (!is_single_hop_neigh &&
+	    (orig_neigh_node->router == NULL)) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: OGM via unknown neighbor!\n");
+		return;
+	}
+
+	is_bidirectional = is_bidirectional_neigh(orig_node, orig_neigh_node,
+						batman_packet, if_incoming);
+
+	/* update ranking if it is not a duplicate or has the same
+	 * seqno and similar ttl as the non-duplicate */
+	if (is_bidirectional &&
+	    (!is_duplicate ||
+	     ((orig_node->last_real_seqno == batman_packet->seqno) &&
+	      (orig_node->last_ttl - 3 <= batman_packet->ttl))))
+		update_orig(bat_priv, orig_node, ethhdr, batman_packet,
+			    if_incoming, hna_buff, hna_buff_len, is_duplicate);
+
+	mark_bonding_address(bat_priv, orig_node,
+			     orig_neigh_node, batman_packet);
+	update_bonding_candidates(bat_priv, orig_node);
+
+	/* is single hop (direct) neighbor */
+	if (is_single_hop_neigh) {
+
+		/* mark direct link on incoming interface */
+		schedule_forward_packet(orig_node, ethhdr, batman_packet,
+					1, hna_buff_len, if_incoming);
+
+		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
+			"rebroadcast neighbor packet with direct link flag\n");
+		return;
+	}
+
+	/* multihop originator */
+	if (!is_bidirectional) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: not received via bidirectional link\n");
+		return;
+	}
+
+	if (is_duplicate) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: duplicate packet received\n");
+		return;
+	}
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Forwarding packet: rebroadcast originator packet\n");
+	schedule_forward_packet(orig_node, ethhdr, batman_packet,
+				0, hna_buff_len, if_incoming);
+}
+
+int recv_bat_packet(struct sk_buff *skb, struct batman_if *batman_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	struct ethhdr *ethhdr;
+	unsigned long flags;
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct batman_packet))))
+		return NET_RX_DROP;
+
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with broadcast indication but unicast recipient */
+	if (!is_bcast(ethhdr->h_dest))
+		return NET_RX_DROP;
+
+	/* packet with broadcast sender address */
+	if (is_bcast(ethhdr->h_source))
+		return NET_RX_DROP;
+
+	/* create a copy of the skb, if needed, to modify it. */
+	if (skb_cow(skb, 0) < 0)
+		return NET_RX_DROP;
+
+	/* keep skb linear */
+	if (skb_linearize(skb) < 0)
+		return NET_RX_DROP;
+
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	receive_aggr_bat_packet(ethhdr,
+				skb->data,
+				skb_headlen(skb),
+				batman_if);
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	kfree_skb(skb);
+	return NET_RX_SUCCESS;
+}
+
+static int recv_my_icmp_packet(struct bat_priv *bat_priv,
+			       struct sk_buff *skb, size_t icmp_len)
+{
+	struct orig_node *orig_node;
+	struct icmp_packet_rr *icmp_packet;
+	struct ethhdr *ethhdr;
+	struct batman_if *batman_if;
+	int ret;
+	unsigned long flags;
+	uint8_t dstaddr[ETH_ALEN];
+
+	icmp_packet = (struct icmp_packet_rr *)skb->data;
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	/* add data to device queue */
+	if (icmp_packet->msg_type != ECHO_REQUEST) {
+		bat_socket_receive_packet(icmp_packet, icmp_len);
+		return NET_RX_DROP;
+	}
+
+	if (!bat_priv->primary_if)
+		return NET_RX_DROP;
+
+	/* answer echo request (ping) */
+	/* get routing information */
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
+						   icmp_packet->orig));
+	ret = NET_RX_DROP;
+
+	if ((orig_node != NULL) &&
+	    (orig_node->router != NULL)) {
+
+		/* don't lock while sending the packets ... we therefore
+		 * copy the required data before sending */
+		batman_if = orig_node->router->if_incoming;
+		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+		/* create a copy of the skb, if needed, to modify it. */
+		if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+			return NET_RX_DROP;
+
+		icmp_packet = (struct icmp_packet_rr *)skb->data;
+		ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+		memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
+		memcpy(icmp_packet->orig,
+		       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+		icmp_packet->msg_type = ECHO_REPLY;
+		icmp_packet->ttl = TTL;
+
+		send_skb_packet(skb, batman_if, dstaddr);
+		ret = NET_RX_SUCCESS;
+
+	} else
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	return ret;
+}
+
+static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
+				  struct sk_buff *skb, size_t icmp_len)
+{
+	struct orig_node *orig_node;
+	struct icmp_packet *icmp_packet;
+	struct ethhdr *ethhdr;
+	struct batman_if *batman_if;
+	int ret;
+	unsigned long flags;
+	uint8_t dstaddr[ETH_ALEN];
+
+	icmp_packet = (struct icmp_packet *)skb->data;
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	/* send TTL exceeded if packet is an echo request (traceroute) */
+	if (icmp_packet->msg_type != ECHO_REQUEST) {
+		pr_debug("Warning - can't forward icmp packet from %pM to "
+			 "%pM: ttl exceeded\n", icmp_packet->orig,
+			 icmp_packet->dst);
+		return NET_RX_DROP;
+	}
+
+	if (!bat_priv->primary_if)
+		return NET_RX_DROP;
+
+	/* get routing information */
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	orig_node = ((struct orig_node *)
+		     hash_find(bat_priv->orig_hash, icmp_packet->orig));
+	ret = NET_RX_DROP;
+
+	if ((orig_node != NULL) &&
+	    (orig_node->router != NULL)) {
+
+		/* don't lock while sending the packets ... we therefore
+		 * copy the required data before sending */
+		batman_if = orig_node->router->if_incoming;
+		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+		/* create a copy of the skb, if needed, to modify it. */
+		if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+			return NET_RX_DROP;
+
+		icmp_packet = (struct icmp_packet *) skb->data;
+		ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+		memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
+		memcpy(icmp_packet->orig,
+		       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+		icmp_packet->msg_type = TTL_EXCEEDED;
+		icmp_packet->ttl = TTL;
+
+		send_skb_packet(skb, batman_if, dstaddr);
+		ret = NET_RX_SUCCESS;
+
+	} else
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	return ret;
+}
+
+
+int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
+	struct icmp_packet_rr *icmp_packet;
+	struct ethhdr *ethhdr;
+	struct orig_node *orig_node;
+	struct batman_if *batman_if;
+	int hdr_size = sizeof(struct icmp_packet);
+	int ret;
+	unsigned long flags;
+	uint8_t dstaddr[ETH_ALEN];
+
+	/**
+	 * we truncate all incoming icmp packets if they don't match our size
+	 */
+	if (skb->len >= sizeof(struct icmp_packet_rr))
+		hdr_size = sizeof(struct icmp_packet_rr);
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, hdr_size)))
+		return NET_RX_DROP;
+
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with unicast indication but broadcast recipient */
+	if (is_bcast(ethhdr->h_dest))
+		return NET_RX_DROP;
+
+	/* packet with broadcast sender address */
+	if (is_bcast(ethhdr->h_source))
+		return NET_RX_DROP;
+
+	/* not for me */
+	if (!is_my_mac(ethhdr->h_dest))
+		return NET_RX_DROP;
+
+	icmp_packet = (struct icmp_packet_rr *)skb->data;
+
+	/* add record route information if not full */
+	if ((hdr_size == sizeof(struct icmp_packet_rr)) &&
+	    (icmp_packet->rr_cur < BAT_RR_LEN)) {
+		memcpy(&(icmp_packet->rr[icmp_packet->rr_cur]),
+			ethhdr->h_dest, ETH_ALEN);
+		icmp_packet->rr_cur++;
+	}
+
+	/* packet for me */
+	if (is_my_mac(icmp_packet->dst))
+		return recv_my_icmp_packet(bat_priv, skb, hdr_size);
+
+	/* TTL exceeded */
+	if (icmp_packet->ttl < 2)
+		return recv_icmp_ttl_exceeded(bat_priv, skb, hdr_size);
+
+	ret = NET_RX_DROP;
+
+	/* get routing information */
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	orig_node = ((struct orig_node *)
+		     hash_find(bat_priv->orig_hash, icmp_packet->dst));
+
+	if ((orig_node != NULL) &&
+	    (orig_node->router != NULL)) {
+
+		/* don't lock while sending the packets ... we therefore
+		 * copy the required data before sending */
+		batman_if = orig_node->router->if_incoming;
+		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+		/* create a copy of the skb, if needed, to modify it. */
+		if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+			return NET_RX_DROP;
+
+		icmp_packet = (struct icmp_packet_rr *)skb->data;
+		ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+		/* decrement ttl */
+		icmp_packet->ttl--;
+
+		/* route it */
+		send_skb_packet(skb, batman_if, dstaddr);
+		ret = NET_RX_SUCCESS;
+
+	} else
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	return ret;
+}
+
+/* find a suitable router for this originator, and use
+ * bonding if possible. */
+struct neigh_node *find_router(struct orig_node *orig_node,
+			       struct batman_if *recv_if)
+{
+	struct bat_priv *bat_priv;
+	struct orig_node *primary_orig_node;
+	struct orig_node *router_orig;
+	struct neigh_node *router, *first_candidate, *best_router;
+	static uint8_t zero_mac[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
+	int bonding_enabled;
+
+	if (!orig_node)
+		return NULL;
+
+	if (!orig_node->router)
+		return NULL;
+
+	/* without bonding, the first node should
+	 * always choose the default router. */
+
+	if (!recv_if)
+		return orig_node->router;
+
+	bat_priv = netdev_priv(recv_if->soft_iface);
+	bonding_enabled = atomic_read(&bat_priv->bonding_enabled);
+
+	if (!bonding_enabled)
+		return orig_node->router;
+
+	router_orig = orig_node->router->orig_node;
+
+	/* if we have something in the primary_addr, we can search
+	 * for a potential bonding candidate. */
+	if (memcmp(router_orig->primary_addr, zero_mac, ETH_ALEN) == 0)
+		return orig_node->router;
+
+	/* find the orig_node which has the primary interface. might
+	 * even be the same as our router_orig in many cases */
+
+	if (memcmp(router_orig->primary_addr,
+				router_orig->orig, ETH_ALEN) == 0) {
+		primary_orig_node = router_orig;
+	} else {
+		primary_orig_node = hash_find(bat_priv->orig_hash,
+						router_orig->primary_addr);
+
+		if (!primary_orig_node)
+			return orig_node->router;
+	}
+
+	/* with less than 2 candidates, we can't do any
+	 * bonding and prefer the original router. */
+
+	if (primary_orig_node->bond.candidates < 2)
+		return orig_node->router;
+
+
+	/* all nodes between should choose a candidate which
+	 * is is not on the interface where the packet came
+	 * in. */
+	first_candidate = primary_orig_node->bond.selected;
+	router = first_candidate;
+
+	if (bonding_enabled) {
+		/* in the bonding case, send the packets in a round
+		 * robin fashion over the remaining interfaces. */
+		do {
+			/* recv_if == NULL on the first node. */
+			if (router->if_incoming != recv_if)
+				break;
+
+			router = router->next_bond_candidate;
+		} while (router != first_candidate);
+
+		primary_orig_node->bond.selected = router->next_bond_candidate;
+
+	} else {
+		/* if bonding is disabled, use the best of the
+		 * remaining candidates which are not using
+		 * this interface. */
+		best_router = first_candidate;
+
+		do {
+			/* recv_if == NULL on the first node. */
+			if ((router->if_incoming != recv_if) &&
+				(router->tq_avg > best_router->tq_avg))
+					best_router = router;
+
+			router = router->next_bond_candidate;
+		} while (router != first_candidate);
+
+		router = best_router;
+	}
+
+	return router;
+}
+
+static int check_unicast_packet(struct sk_buff *skb, int hdr_size)
+{
+	struct ethhdr *ethhdr;
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, hdr_size)))
+		return -1;
+
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with unicast indication but broadcast recipient */
+	if (is_bcast(ethhdr->h_dest))
+		return -1;
+
+	/* packet with broadcast sender address */
+	if (is_bcast(ethhdr->h_source))
+		return -1;
+
+	/* not for me */
+	if (!is_my_mac(ethhdr->h_dest))
+		return -1;
+
+	return 0;
+}
+
+static int route_unicast_packet(struct sk_buff *skb,
+				struct batman_if *recv_if, int hdr_size)
+{
+	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
+	struct orig_node *orig_node;
+	struct neigh_node *router;
+	struct batman_if *batman_if;
+	uint8_t dstaddr[ETH_ALEN];
+	unsigned long flags;
+	struct unicast_packet *unicast_packet;
+	struct ethhdr *ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	unicast_packet = (struct unicast_packet *)skb->data;
+
+	/* packet for me */
+	if (is_my_mac(unicast_packet->dest)) {
+		interface_rx(recv_if->soft_iface, skb, hdr_size);
+		return NET_RX_SUCCESS;
+	}
+
+	/* TTL exceeded */
+	if (unicast_packet->ttl < 2) {
+		pr_debug("Warning - can't forward unicast packet from %pM to "
+			 "%pM: ttl exceeded\n", ethhdr->h_source,
+			 unicast_packet->dest);
+		return NET_RX_DROP;
+	}
+
+	/* get routing information */
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	orig_node = ((struct orig_node *)
+		     hash_find(bat_priv->orig_hash, unicast_packet->dest));
+
+	router = find_router(orig_node, recv_if);
+
+	if (!router) {
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+		return NET_RX_DROP;
+	}
+
+	/* don't lock while sending the packets ... we therefore
+	 * copy the required data before sending */
+
+	batman_if = router->if_incoming;
+	memcpy(dstaddr, router->addr, ETH_ALEN);
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	/* create a copy of the skb, if needed, to modify it. */
+	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+		return NET_RX_DROP;
+
+	unicast_packet = (struct unicast_packet *)skb->data;
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	/* decrement ttl */
+	unicast_packet->ttl--;
+
+	/* route it */
+	send_skb_packet(skb, batman_if, dstaddr);
+
+	return NET_RX_SUCCESS;
+}
+
+int recv_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if)
+{
+	struct unicast_packet *unicast_packet;
+	int hdr_size = sizeof(struct unicast_packet);
+
+	if (check_unicast_packet(skb, hdr_size) < 0)
+		return NET_RX_DROP;
+
+	unicast_packet = (struct unicast_packet *)skb->data;
+
+	/* packet for me */
+	if (is_my_mac(unicast_packet->dest)) {
+		interface_rx(recv_if->soft_iface, skb, hdr_size);
+		return NET_RX_SUCCESS;
+	}
+
+	return route_unicast_packet(skb, recv_if, hdr_size);
+}
+
+int recv_ucast_frag_packet(struct sk_buff *skb, struct batman_if *recv_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
+	struct unicast_frag_packet *unicast_packet;
+	struct orig_node *orig_node;
+	struct frag_packet_list_entry *tmp_frag_entry;
+	int hdr_size = sizeof(struct unicast_frag_packet);
+	unsigned long flags;
+
+	if (check_unicast_packet(skb, hdr_size) < 0)
+		return NET_RX_DROP;
+
+	unicast_packet = (struct unicast_frag_packet *)skb->data;
+
+	/* packet for me */
+	if (is_my_mac(unicast_packet->dest)) {
+
+		spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+		orig_node = ((struct orig_node *)
+			hash_find(bat_priv->orig_hash, unicast_packet->orig));
+
+		if (!orig_node) {
+			pr_debug("couldn't find orig node for fragmentation\n");
+			spin_unlock_irqrestore(&bat_priv->orig_hash_lock,
+					       flags);
+			return NET_RX_DROP;
+		}
+
+		orig_node->last_frag_packet = jiffies;
+
+		if (list_empty(&orig_node->frag_list))
+			create_frag_buffer(&orig_node->frag_list);
+
+		tmp_frag_entry =
+			search_frag_packet(&orig_node->frag_list,
+					   unicast_packet);
+
+		if (!tmp_frag_entry) {
+			create_frag_entry(&orig_node->frag_list, skb);
+			spin_unlock_irqrestore(&bat_priv->orig_hash_lock,
+					       flags);
+			return NET_RX_SUCCESS;
+		}
+
+		skb = merge_frag_packet(&orig_node->frag_list,
+					tmp_frag_entry, skb);
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+		if (!skb)
+			return NET_RX_DROP;
+
+		interface_rx(recv_if->soft_iface, skb, hdr_size);
+		return NET_RX_SUCCESS;
+	}
+
+	return route_unicast_packet(skb, recv_if, hdr_size);
+}
+
+
+int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
+	struct orig_node *orig_node;
+	struct bcast_packet *bcast_packet;
+	struct ethhdr *ethhdr;
+	int hdr_size = sizeof(struct bcast_packet);
+	int32_t seq_diff;
+	unsigned long flags;
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, hdr_size)))
+		return NET_RX_DROP;
+
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with broadcast indication but unicast recipient */
+	if (!is_bcast(ethhdr->h_dest))
+		return NET_RX_DROP;
+
+	/* packet with broadcast sender address */
+	if (is_bcast(ethhdr->h_source))
+		return NET_RX_DROP;
+
+	/* ignore broadcasts sent by myself */
+	if (is_my_mac(ethhdr->h_source))
+		return NET_RX_DROP;
+
+	bcast_packet = (struct bcast_packet *)skb->data;
+
+	/* ignore broadcasts originated by myself */
+	if (is_my_mac(bcast_packet->orig))
+		return NET_RX_DROP;
+
+	if (bcast_packet->ttl < 2)
+		return NET_RX_DROP;
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	orig_node = ((struct orig_node *)
+		     hash_find(bat_priv->orig_hash, bcast_packet->orig));
+
+	if (orig_node == NULL) {
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+		return NET_RX_DROP;
+	}
+
+	/* check whether the packet is a duplicate */
+	if (get_bit_status(orig_node->bcast_bits,
+			   orig_node->last_bcast_seqno,
+			   ntohl(bcast_packet->seqno))) {
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+		return NET_RX_DROP;
+	}
+
+	seq_diff = ntohl(bcast_packet->seqno) - orig_node->last_bcast_seqno;
+
+	/* check whether the packet is old and the host just restarted. */
+	if (window_protected(bat_priv, seq_diff,
+			     &orig_node->bcast_seqno_reset)) {
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+		return NET_RX_DROP;
+	}
+
+	/* mark broadcast in flood history, update window position
+	 * if required. */
+	if (bit_get_packet(bat_priv, orig_node->bcast_bits, seq_diff, 1))
+		orig_node->last_bcast_seqno = ntohl(bcast_packet->seqno);
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+	/* rebroadcast packet */
+	add_bcast_packet_to_list(bat_priv, skb);
+
+	/* broadcast for me */
+	interface_rx(recv_if->soft_iface, skb, hdr_size);
+
+	return NET_RX_SUCCESS;
+}
+
+int recv_vis_packet(struct sk_buff *skb, struct batman_if *recv_if)
+{
+	struct vis_packet *vis_packet;
+	struct ethhdr *ethhdr;
+	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
+	int hdr_size = sizeof(struct vis_packet);
+
+	/* keep skb linear */
+	if (skb_linearize(skb) < 0)
+		return NET_RX_DROP;
+
+	if (unlikely(!pskb_may_pull(skb, hdr_size)))
+		return NET_RX_DROP;
+
+	vis_packet = (struct vis_packet *)skb->data;
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	/* not for me */
+	if (!is_my_mac(ethhdr->h_dest))
+		return NET_RX_DROP;
+
+	/* ignore own packets */
+	if (is_my_mac(vis_packet->vis_orig))
+		return NET_RX_DROP;
+
+	if (is_my_mac(vis_packet->sender_orig))
+		return NET_RX_DROP;
+
+	switch (vis_packet->vis_type) {
+	case VIS_TYPE_SERVER_SYNC:
+		receive_server_sync_packet(bat_priv, vis_packet,
+					   skb_headlen(skb));
+		break;
+
+	case VIS_TYPE_CLIENT_UPDATE:
+		receive_client_update_packet(bat_priv, vis_packet,
+					     skb_headlen(skb));
+		break;
+
+	default:	/* ignore unknown packet */
+		break;
+	}
+
+	/* We take a copy of the data in the packet, so we should
+	   always free the skbuf. */
+	return NET_RX_DROP;
+}
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
new file mode 100644
index 0000000..06ea99d
--- /dev/null
+++ b/net/batman-adv/routing.h
@@ -0,0 +1,46 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_ROUTING_H_
+#define _NET_BATMAN_ADV_ROUTING_H_
+
+#include "types.h"
+
+void slide_own_bcast_window(struct batman_if *batman_if);
+void receive_bat_packet(struct ethhdr *ethhdr,
+				struct batman_packet *batman_packet,
+				unsigned char *hna_buff, int hna_buff_len,
+				struct batman_if *if_incoming);
+void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		   struct neigh_node *neigh_node, unsigned char *hna_buff,
+		   int hna_buff_len);
+int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_ucast_frag_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_vis_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_bat_packet(struct sk_buff *skb, struct batman_if *recv_if);
+struct neigh_node *find_router(struct orig_node *orig_node,
+		struct batman_if *recv_if);
+void update_bonding_candidates(struct bat_priv *bat_priv,
+			       struct orig_node *orig_node);
+
+#endif /* _NET_BATMAN_ADV_ROUTING_H_ */
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
new file mode 100644
index 0000000..5d57ef5
--- /dev/null
+++ b/net/batman-adv/send.c
@@ -0,0 +1,577 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "send.h"
+#include "routing.h"
+#include "translation-table.h"
+#include "soft-interface.h"
+#include "hard-interface.h"
+#include "types.h"
+#include "vis.h"
+#include "aggregation.h"
+
+
+static void send_outstanding_bcast_packet(struct work_struct *work);
+
+/* apply hop penalty for a normal link */
+static uint8_t hop_penalty(const uint8_t tq)
+{
+	return (tq * (TQ_MAX_VALUE - TQ_HOP_PENALTY)) / (TQ_MAX_VALUE);
+}
+
+/* when do we schedule our own packet to be sent */
+static unsigned long own_send_time(struct bat_priv *bat_priv)
+{
+	return jiffies + msecs_to_jiffies(
+		   atomic_read(&bat_priv->orig_interval) -
+		   JITTER + (random32() % 2*JITTER));
+}
+
+/* when do we schedule a forwarded packet to be sent */
+static unsigned long forward_send_time(struct bat_priv *bat_priv)
+{
+	return jiffies + msecs_to_jiffies(random32() % (JITTER/2));
+}
+
+/* send out an already prepared packet to the given address via the
+ * specified batman interface */
+int send_skb_packet(struct sk_buff *skb,
+				struct batman_if *batman_if,
+				uint8_t *dst_addr)
+{
+	struct ethhdr *ethhdr;
+
+	if (batman_if->if_status != IF_ACTIVE)
+		goto send_skb_err;
+
+	if (unlikely(!batman_if->net_dev))
+		goto send_skb_err;
+
+	if (!(batman_if->net_dev->flags & IFF_UP)) {
+		pr_warning("Interface %s is not up - can't send packet via "
+			   "that interface!\n", batman_if->net_dev->name);
+		goto send_skb_err;
+	}
+
+	/* push to the ethernet header. */
+	if (my_skb_head_push(skb, sizeof(struct ethhdr)) < 0)
+		goto send_skb_err;
+
+	skb_reset_mac_header(skb);
+
+	ethhdr = (struct ethhdr *) skb_mac_header(skb);
+	memcpy(ethhdr->h_source, batman_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(ethhdr->h_dest, dst_addr, ETH_ALEN);
+	ethhdr->h_proto = __constant_htons(ETH_P_BATMAN);
+
+	skb_set_network_header(skb, ETH_HLEN);
+	skb->priority = TC_PRIO_CONTROL;
+	skb->protocol = __constant_htons(ETH_P_BATMAN);
+
+	skb->dev = batman_if->net_dev;
+
+	/* dev_queue_xmit() returns a negative result on error.	 However on
+	 * congestion and traffic shaping, it drops and returns NET_XMIT_DROP
+	 * (which is > 0). This will not be treated as an error. */
+
+	return dev_queue_xmit(skb);
+send_skb_err:
+	kfree_skb(skb);
+	return NET_XMIT_DROP;
+}
+
+/* Send a packet to a given interface */
+static void send_packet_to_if(struct forw_packet *forw_packet,
+			      struct batman_if *batman_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	char *fwd_str;
+	uint8_t packet_num;
+	int16_t buff_pos;
+	struct batman_packet *batman_packet;
+	struct sk_buff *skb;
+
+	if (batman_if->if_status != IF_ACTIVE)
+		return;
+
+	packet_num = 0;
+	buff_pos = 0;
+	batman_packet = (struct batman_packet *)forw_packet->skb->data;
+
+	/* adjust all flags and log packets */
+	while (aggregated_packet(buff_pos,
+				 forw_packet->packet_len,
+				 batman_packet->num_hna)) {
+
+		/* we might have aggregated direct link packets with an
+		 * ordinary base packet */
+		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
+		    (forw_packet->if_incoming == batman_if))
+			batman_packet->flags |= DIRECTLINK;
+		else
+			batman_packet->flags &= ~DIRECTLINK;
+
+		fwd_str = (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
+							    "Sending own" :
+							    "Forwarding"));
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d,"
+			" IDF %s) on interface %s [%s]\n",
+			fwd_str, (packet_num > 0 ? "aggregated " : ""),
+			batman_packet->orig, ntohl(batman_packet->seqno),
+			batman_packet->tq, batman_packet->ttl,
+			(batman_packet->flags & DIRECTLINK ?
+			 "on" : "off"),
+			batman_if->net_dev->name, batman_if->addr_str);
+
+		buff_pos += sizeof(struct batman_packet) +
+			(batman_packet->num_hna * ETH_ALEN);
+		packet_num++;
+		batman_packet = (struct batman_packet *)
+			(forw_packet->skb->data + buff_pos);
+	}
+
+	/* create clone because function is called more than once */
+	skb = skb_clone(forw_packet->skb, GFP_ATOMIC);
+	if (skb)
+		send_skb_packet(skb, batman_if, broadcast_addr);
+}
+
+/* send a batman packet */
+static void send_packet(struct forw_packet *forw_packet)
+{
+	struct batman_if *batman_if;
+	struct net_device *soft_iface = forw_packet->if_incoming->soft_iface;
+	struct bat_priv *bat_priv = netdev_priv(soft_iface);
+	struct batman_packet *batman_packet =
+		(struct batman_packet *)(forw_packet->skb->data);
+	unsigned char directlink = (batman_packet->flags & DIRECTLINK ? 1 : 0);
+
+	if (!forw_packet->if_incoming) {
+		pr_err("Error - can't forward packet: incoming iface not "
+		       "specified\n");
+		return;
+	}
+
+	if (forw_packet->if_incoming->if_status != IF_ACTIVE)
+		return;
+
+	/* multihomed peer assumed */
+	/* non-primary OGMs are only broadcasted on their interface */
+	if ((directlink && (batman_packet->ttl == 1)) ||
+	    (forw_packet->own && (forw_packet->if_incoming->if_num > 0))) {
+
+		/* FIXME: what about aggregated packets ? */
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"%s packet (originator %pM, seqno %d, TTL %d) "
+			"on interface %s [%s]\n",
+			(forw_packet->own ? "Sending own" : "Forwarding"),
+			batman_packet->orig, ntohl(batman_packet->seqno),
+			batman_packet->ttl,
+			forw_packet->if_incoming->net_dev->name,
+			forw_packet->if_incoming->addr_str);
+
+		/* skb is only used once and than forw_packet is free'd */
+		send_skb_packet(forw_packet->skb, forw_packet->if_incoming,
+				broadcast_addr);
+		forw_packet->skb = NULL;
+
+		return;
+	}
+
+	/* broadcast on every interface */
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->soft_iface != soft_iface)
+			continue;
+
+		send_packet_to_if(forw_packet, batman_if);
+	}
+	rcu_read_unlock();
+}
+
+static void rebuild_batman_packet(struct bat_priv *bat_priv,
+				  struct batman_if *batman_if)
+{
+	int new_len;
+	unsigned char *new_buff;
+	struct batman_packet *batman_packet;
+
+	new_len = sizeof(struct batman_packet) +
+			(bat_priv->num_local_hna * ETH_ALEN);
+	new_buff = kmalloc(new_len, GFP_ATOMIC);
+
+	/* keep old buffer if kmalloc should fail */
+	if (new_buff) {
+		memcpy(new_buff, batman_if->packet_buff,
+		       sizeof(struct batman_packet));
+		batman_packet = (struct batman_packet *)new_buff;
+
+		batman_packet->num_hna = hna_local_fill_buffer(bat_priv,
+				new_buff + sizeof(struct batman_packet),
+				new_len - sizeof(struct batman_packet));
+
+		kfree(batman_if->packet_buff);
+		batman_if->packet_buff = new_buff;
+		batman_if->packet_len = new_len;
+	}
+}
+
+void schedule_own_packet(struct batman_if *batman_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	unsigned long send_time;
+	struct batman_packet *batman_packet;
+	int vis_server;
+
+	if ((batman_if->if_status == IF_NOT_IN_USE) ||
+	    (batman_if->if_status == IF_TO_BE_REMOVED))
+		return;
+
+	vis_server = atomic_read(&bat_priv->vis_mode);
+
+	/**
+	 * the interface gets activated here to avoid race conditions between
+	 * the moment of activating the interface in
+	 * hardif_activate_interface() where the originator mac is set and
+	 * outdated packets (especially uninitialized mac addresses) in the
+	 * packet queue
+	 */
+	if (batman_if->if_status == IF_TO_BE_ACTIVATED)
+		batman_if->if_status = IF_ACTIVE;
+
+	/* if local hna has changed and interface is a primary interface */
+	if ((atomic_read(&bat_priv->hna_local_changed)) &&
+	    (batman_if == bat_priv->primary_if))
+		rebuild_batman_packet(bat_priv, batman_if);
+
+	/**
+	 * NOTE: packet_buff might just have been re-allocated in
+	 * rebuild_batman_packet()
+	 */
+	batman_packet = (struct batman_packet *)batman_if->packet_buff;
+
+	/* change sequence number to network order */
+	batman_packet->seqno =
+		htonl((uint32_t)atomic_read(&batman_if->seqno));
+
+	if (vis_server == VIS_TYPE_SERVER_SYNC)
+		batman_packet->flags |= VIS_SERVER;
+	else
+		batman_packet->flags &= ~VIS_SERVER;
+
+	atomic_inc(&batman_if->seqno);
+
+	slide_own_bcast_window(batman_if);
+	send_time = own_send_time(bat_priv);
+	add_bat_packet_to_list(bat_priv,
+			       batman_if->packet_buff,
+			       batman_if->packet_len,
+			       batman_if, 1, send_time);
+}
+
+void schedule_forward_packet(struct orig_node *orig_node,
+			     struct ethhdr *ethhdr,
+			     struct batman_packet *batman_packet,
+			     uint8_t directlink, int hna_buff_len,
+			     struct batman_if *if_incoming)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	unsigned char in_tq, in_ttl, tq_avg = 0;
+	unsigned long send_time;
+
+	if (batman_packet->ttl <= 1) {
+		bat_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
+		return;
+	}
+
+	in_tq = batman_packet->tq;
+	in_ttl = batman_packet->ttl;
+
+	batman_packet->ttl--;
+	memcpy(batman_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
+
+	/* rebroadcast tq of our best ranking neighbor to ensure the rebroadcast
+	 * of our best tq value */
+	if ((orig_node->router) && (orig_node->router->tq_avg != 0)) {
+
+		/* rebroadcast ogm of best ranking neighbor as is */
+		if (!compare_orig(orig_node->router->addr, ethhdr->h_source)) {
+			batman_packet->tq = orig_node->router->tq_avg;
+
+			if (orig_node->router->last_ttl)
+				batman_packet->ttl = orig_node->router->last_ttl
+							- 1;
+		}
+
+		tq_avg = orig_node->router->tq_avg;
+	}
+
+	/* apply hop penalty */
+	batman_packet->tq = hop_penalty(batman_packet->tq);
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Forwarding packet: tq_orig: %i, tq_avg: %i, "
+		"tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
+		in_tq, tq_avg, batman_packet->tq, in_ttl - 1,
+		batman_packet->ttl);
+
+	batman_packet->seqno = htonl(batman_packet->seqno);
+
+	/* switch of primaries first hop flag when forwarding */
+	batman_packet->flags &= ~PRIMARIES_FIRST_HOP;
+	if (directlink)
+		batman_packet->flags |= DIRECTLINK;
+	else
+		batman_packet->flags &= ~DIRECTLINK;
+
+	send_time = forward_send_time(bat_priv);
+	add_bat_packet_to_list(bat_priv,
+			       (unsigned char *)batman_packet,
+			       sizeof(struct batman_packet) + hna_buff_len,
+			       if_incoming, 0, send_time);
+}
+
+static void forw_packet_free(struct forw_packet *forw_packet)
+{
+	if (forw_packet->skb)
+		kfree_skb(forw_packet->skb);
+	kfree(forw_packet);
+}
+
+static void _add_bcast_packet_to_list(struct bat_priv *bat_priv,
+				      struct forw_packet *forw_packet,
+				      unsigned long send_time)
+{
+	unsigned long flags;
+	INIT_HLIST_NODE(&forw_packet->list);
+
+	/* add new packet to packet list */
+	spin_lock_irqsave(&bat_priv->forw_bcast_list_lock, flags);
+	hlist_add_head(&forw_packet->list, &bat_priv->forw_bcast_list);
+	spin_unlock_irqrestore(&bat_priv->forw_bcast_list_lock, flags);
+
+	/* start timer for this packet */
+	INIT_DELAYED_WORK(&forw_packet->delayed_work,
+			  send_outstanding_bcast_packet);
+	queue_delayed_work(bat_event_workqueue, &forw_packet->delayed_work,
+			   send_time);
+}
+
+#define atomic_dec_not_zero(v)          atomic_add_unless((v), -1, 0)
+/* add a broadcast packet to the queue and setup timers. broadcast packets
+ * are sent multiple times to increase probability for beeing received.
+ *
+ * This function returns NETDEV_TX_OK on success and NETDEV_TX_BUSY on
+ * errors.
+ *
+ * The skb is not consumed, so the caller should make sure that the
+ * skb is freed. */
+int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb)
+{
+	struct forw_packet *forw_packet;
+	struct bcast_packet *bcast_packet;
+
+	if (!atomic_dec_not_zero(&bat_priv->bcast_queue_left)) {
+		bat_dbg(DBG_BATMAN, bat_priv, "bcast packet queue full\n");
+		goto out;
+	}
+
+	if (!bat_priv->primary_if)
+		goto out;
+
+	forw_packet = kmalloc(sizeof(struct forw_packet), GFP_ATOMIC);
+
+	if (!forw_packet)
+		goto out_and_inc;
+
+	skb = skb_copy(skb, GFP_ATOMIC);
+	if (!skb)
+		goto packet_free;
+
+	/* as we have a copy now, it is safe to decrease the TTL */
+	bcast_packet = (struct bcast_packet *)skb->data;
+	bcast_packet->ttl--;
+
+	skb_reset_mac_header(skb);
+
+	forw_packet->skb = skb;
+	forw_packet->if_incoming = bat_priv->primary_if;
+
+	/* how often did we send the bcast packet ? */
+	forw_packet->num_packets = 0;
+
+	_add_bcast_packet_to_list(bat_priv, forw_packet, 1);
+	return NETDEV_TX_OK;
+
+packet_free:
+	kfree(forw_packet);
+out_and_inc:
+	atomic_inc(&bat_priv->bcast_queue_left);
+out:
+	return NETDEV_TX_BUSY;
+}
+
+static void send_outstanding_bcast_packet(struct work_struct *work)
+{
+	struct batman_if *batman_if;
+	struct delayed_work *delayed_work =
+		container_of(work, struct delayed_work, work);
+	struct forw_packet *forw_packet =
+		container_of(delayed_work, struct forw_packet, delayed_work);
+	unsigned long flags;
+	struct sk_buff *skb1;
+	struct net_device *soft_iface = forw_packet->if_incoming->soft_iface;
+	struct bat_priv *bat_priv = netdev_priv(soft_iface);
+
+	spin_lock_irqsave(&bat_priv->forw_bcast_list_lock, flags);
+	hlist_del(&forw_packet->list);
+	spin_unlock_irqrestore(&bat_priv->forw_bcast_list_lock, flags);
+
+	if (atomic_read(&bat_priv->mesh_state) == MESH_DEACTIVATING)
+		goto out;
+
+	/* rebroadcast packet */
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->soft_iface != soft_iface)
+			continue;
+
+		/* send a copy of the saved skb */
+		skb1 = skb_clone(forw_packet->skb, GFP_ATOMIC);
+		if (skb1)
+			send_skb_packet(skb1, batman_if, broadcast_addr);
+	}
+	rcu_read_unlock();
+
+	forw_packet->num_packets++;
+
+	/* if we still have some more bcasts to send */
+	if (forw_packet->num_packets < 3) {
+		_add_bcast_packet_to_list(bat_priv, forw_packet,
+					  ((5 * HZ) / 1000));
+		return;
+	}
+
+out:
+	forw_packet_free(forw_packet);
+	atomic_inc(&bat_priv->bcast_queue_left);
+}
+
+void send_outstanding_bat_packet(struct work_struct *work)
+{
+	struct delayed_work *delayed_work =
+		container_of(work, struct delayed_work, work);
+	struct forw_packet *forw_packet =
+		container_of(delayed_work, struct forw_packet, delayed_work);
+	unsigned long flags;
+	struct bat_priv *bat_priv;
+
+	bat_priv = netdev_priv(forw_packet->if_incoming->soft_iface);
+	spin_lock_irqsave(&bat_priv->forw_bat_list_lock, flags);
+	hlist_del(&forw_packet->list);
+	spin_unlock_irqrestore(&bat_priv->forw_bat_list_lock, flags);
+
+	if (atomic_read(&bat_priv->mesh_state) == MESH_DEACTIVATING)
+		goto out;
+
+	send_packet(forw_packet);
+
+	/**
+	 * we have to have at least one packet in the queue
+	 * to determine the queues wake up time unless we are
+	 * shutting down
+	 */
+	if (forw_packet->own)
+		schedule_own_packet(forw_packet->if_incoming);
+
+out:
+	/* don't count own packet */
+	if (!forw_packet->own)
+		atomic_inc(&bat_priv->batman_queue_left);
+
+	forw_packet_free(forw_packet);
+}
+
+void purge_outstanding_packets(struct bat_priv *bat_priv,
+			       struct batman_if *batman_if)
+{
+	struct forw_packet *forw_packet;
+	struct hlist_node *tmp_node, *safe_tmp_node;
+	unsigned long flags;
+
+	if (batman_if)
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"purge_outstanding_packets(): %s\n",
+			batman_if->net_dev->name);
+	else
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"purge_outstanding_packets()\n");
+
+	/* free bcast list */
+	spin_lock_irqsave(&bat_priv->forw_bcast_list_lock, flags);
+	hlist_for_each_entry_safe(forw_packet, tmp_node, safe_tmp_node,
+				  &bat_priv->forw_bcast_list, list) {
+
+		/**
+		 * if purge_outstanding_packets() was called with an argmument
+		 * we delete only packets belonging to the given interface
+		 */
+		if ((batman_if) &&
+		    (forw_packet->if_incoming != batman_if))
+			continue;
+
+		spin_unlock_irqrestore(&bat_priv->forw_bcast_list_lock, flags);
+
+		/**
+		 * send_outstanding_bcast_packet() will lock the list to
+		 * delete the item from the list
+		 */
+		cancel_delayed_work_sync(&forw_packet->delayed_work);
+		spin_lock_irqsave(&bat_priv->forw_bcast_list_lock, flags);
+	}
+	spin_unlock_irqrestore(&bat_priv->forw_bcast_list_lock, flags);
+
+	/* free batman packet list */
+	spin_lock_irqsave(&bat_priv->forw_bat_list_lock, flags);
+	hlist_for_each_entry_safe(forw_packet, tmp_node, safe_tmp_node,
+				  &bat_priv->forw_bat_list, list) {
+
+		/**
+		 * if purge_outstanding_packets() was called with an argmument
+		 * we delete only packets belonging to the given interface
+		 */
+		if ((batman_if) &&
+		    (forw_packet->if_incoming != batman_if))
+			continue;
+
+		spin_unlock_irqrestore(&bat_priv->forw_bat_list_lock, flags);
+
+		/**
+		 * send_outstanding_bat_packet() will lock the list to
+		 * delete the item from the list
+		 */
+		cancel_delayed_work_sync(&forw_packet->delayed_work);
+		spin_lock_irqsave(&bat_priv->forw_bat_list_lock, flags);
+	}
+	spin_unlock_irqrestore(&bat_priv->forw_bat_list_lock, flags);
+}
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
new file mode 100644
index 0000000..c4cefa8
--- /dev/null
+++ b/net/batman-adv/send.h
@@ -0,0 +1,41 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_SEND_H_
+#define _NET_BATMAN_ADV_SEND_H_
+
+#include "types.h"
+
+int send_skb_packet(struct sk_buff *skb,
+				struct batman_if *batman_if,
+				uint8_t *dst_addr);
+void schedule_own_packet(struct batman_if *batman_if);
+void schedule_forward_packet(struct orig_node *orig_node,
+			     struct ethhdr *ethhdr,
+			     struct batman_packet *batman_packet,
+			     uint8_t directlink, int hna_buff_len,
+			     struct batman_if *if_outgoing);
+int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb);
+void send_outstanding_bat_packet(struct work_struct *work);
+void purge_outstanding_packets(struct bat_priv *bat_priv,
+			       struct batman_if *batman_if);
+
+#endif /* _NET_BATMAN_ADV_SEND_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
new file mode 100644
index 0000000..8d14343
--- /dev/null
+++ b/net/batman-adv/soft-interface.c
@@ -0,0 +1,395 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "soft-interface.h"
+#include "hard-interface.h"
+#include "routing.h"
+#include "send.h"
+#include "bat_debugfs.h"
+#include "translation-table.h"
+#include "types.h"
+#include "hash.h"
+#include "send.h"
+#include "bat_sysfs.h"
+#include <linux/slab.h>
+#include <linux/ethtool.h>
+#include <linux/etherdevice.h>
+#include "unicast.h"
+
+
+static int bat_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
+static void bat_get_drvinfo(struct net_device *dev,
+			    struct ethtool_drvinfo *info);
+static u32 bat_get_msglevel(struct net_device *dev);
+static void bat_set_msglevel(struct net_device *dev, u32 value);
+static u32 bat_get_link(struct net_device *dev);
+static u32 bat_get_rx_csum(struct net_device *dev);
+static int bat_set_rx_csum(struct net_device *dev, u32 data);
+
+static const struct ethtool_ops bat_ethtool_ops = {
+	.get_settings = bat_get_settings,
+	.get_drvinfo = bat_get_drvinfo,
+	.get_msglevel = bat_get_msglevel,
+	.set_msglevel = bat_set_msglevel,
+	.get_link = bat_get_link,
+	.get_rx_csum = bat_get_rx_csum,
+	.set_rx_csum = bat_set_rx_csum
+};
+
+int my_skb_head_push(struct sk_buff *skb, unsigned int len)
+{
+	int result;
+
+	/**
+	 * TODO: We must check if we can release all references to non-payload
+	 * data using skb_header_release in our skbs to allow skb_cow_header to
+	 * work optimally. This means that those skbs are not allowed to read
+	 * or write any data which is before the current position of skb->data
+	 * after that call and thus allow other skbs with the same data buffer
+	 * to write freely in that area.
+	 */
+	result = skb_cow_head(skb, len);
+	if (result < 0)
+		return result;
+
+	skb_push(skb, len);
+	return 0;
+}
+
+static int interface_open(struct net_device *dev)
+{
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int interface_release(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static struct net_device_stats *interface_stats(struct net_device *dev)
+{
+	struct bat_priv *bat_priv = netdev_priv(dev);
+	return &bat_priv->stats;
+}
+
+static int interface_set_mac_addr(struct net_device *dev, void *p)
+{
+	struct bat_priv *bat_priv = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	/* only modify hna-table if it has been initialised before */
+	if (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE) {
+		hna_local_remove(bat_priv, dev->dev_addr,
+				 "mac address changed");
+		hna_local_add(dev, addr->sa_data);
+	}
+
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+
+	return 0;
+}
+
+static int interface_change_mtu(struct net_device *dev, int new_mtu)
+{
+	/* check ranges */
+	if ((new_mtu < 68) || (new_mtu > hardif_min_mtu(dev)))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	return 0;
+}
+
+int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
+{
+	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
+	struct bat_priv *bat_priv = netdev_priv(soft_iface);
+	struct bcast_packet *bcast_packet;
+	int data_len = skb->len, ret;
+
+	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
+		goto dropped;
+
+	soft_iface->trans_start = jiffies;
+
+	/* TODO: check this for locks */
+	hna_local_add(soft_iface, ethhdr->h_source);
+
+	/* ethernet packet should be broadcasted */
+	if (is_bcast(ethhdr->h_dest) || is_mcast(ethhdr->h_dest)) {
+		if (!bat_priv->primary_if)
+			goto dropped;
+
+		if (my_skb_head_push(skb, sizeof(struct bcast_packet)) < 0)
+			goto dropped;
+
+		bcast_packet = (struct bcast_packet *)skb->data;
+		bcast_packet->version = COMPAT_VERSION;
+		bcast_packet->ttl = TTL;
+
+		/* batman packet type: broadcast */
+		bcast_packet->packet_type = BAT_BCAST;
+
+		/* hw address of first interface is the orig mac because only
+		 * this mac is known throughout the mesh */
+		memcpy(bcast_packet->orig,
+		       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+
+		/* set broadcast sequence number */
+		bcast_packet->seqno =
+			htonl(atomic_inc_return(&bat_priv->bcast_seqno));
+
+		add_bcast_packet_to_list(bat_priv, skb);
+
+		/* a copy is stored in the bcast list, therefore removing
+		 * the original skb. */
+		kfree_skb(skb);
+
+	/* unicast packet */
+	} else {
+		ret = unicast_send_skb(skb, bat_priv);
+		if (ret != 0)
+			goto dropped_freed;
+	}
+
+	bat_priv->stats.tx_packets++;
+	bat_priv->stats.tx_bytes += data_len;
+	goto end;
+
+dropped:
+	kfree_skb(skb);
+dropped_freed:
+	bat_priv->stats.tx_dropped++;
+end:
+	return NETDEV_TX_OK;
+}
+
+void interface_rx(struct net_device *soft_iface,
+		  struct sk_buff *skb, int hdr_size)
+{
+	struct bat_priv *priv = netdev_priv(soft_iface);
+
+	/* check if enough space is available for pulling, and pull */
+	if (!pskb_may_pull(skb, hdr_size)) {
+		kfree_skb(skb);
+		return;
+	}
+	skb_pull_rcsum(skb, hdr_size);
+/*	skb_set_mac_header(skb, -sizeof(struct ethhdr));*/
+
+	skb->dev = soft_iface;
+	skb->protocol = eth_type_trans(skb, soft_iface);
+
+	/* should not be neccesary anymore as we use skb_pull_rcsum()
+	 * TODO: please verify this and remove this TODO
+	 * -- Dec 21st 2009, Simon Wunderlich */
+
+/*	skb->ip_summed = CHECKSUM_UNNECESSARY;*/
+
+	/* TODO: set skb->pkt_type to PACKET_BROADCAST, PACKET_MULTICAST,
+	 * PACKET_OTHERHOST or PACKET_HOST */
+
+	priv->stats.rx_packets++;
+	priv->stats.rx_bytes += skb->len + sizeof(struct ethhdr);
+
+	soft_iface->last_rx = jiffies;
+
+	netif_rx(skb);
+}
+
+#ifdef HAVE_NET_DEVICE_OPS
+static const struct net_device_ops bat_netdev_ops = {
+	.ndo_open = interface_open,
+	.ndo_stop = interface_release,
+	.ndo_get_stats = interface_stats,
+	.ndo_set_mac_address = interface_set_mac_addr,
+	.ndo_change_mtu = interface_change_mtu,
+	.ndo_start_xmit = interface_tx,
+	.ndo_validate_addr = eth_validate_addr
+};
+#endif
+
+static void interface_setup(struct net_device *dev)
+{
+	struct bat_priv *priv = netdev_priv(dev);
+	char dev_addr[ETH_ALEN];
+
+	ether_setup(dev);
+
+#ifdef HAVE_NET_DEVICE_OPS
+	dev->netdev_ops = &bat_netdev_ops;
+#else
+	dev->open = interface_open;
+	dev->stop = interface_release;
+	dev->get_stats = interface_stats;
+	dev->set_mac_address = interface_set_mac_addr;
+	dev->change_mtu = interface_change_mtu;
+	dev->hard_start_xmit = interface_tx;
+#endif
+	dev->destructor = free_netdev;
+
+	/**
+	 * can't call min_mtu, because the needed variables
+	 * have not been initialized yet
+	 */
+	dev->mtu = ETH_DATA_LEN;
+	dev->hard_header_len = BAT_HEADER_LEN; /* reserve more space in the
+						* skbuff for our header */
+
+	/* generate random address */
+	random_ether_addr(dev_addr);
+	memcpy(dev->dev_addr, dev_addr, ETH_ALEN);
+
+	SET_ETHTOOL_OPS(dev, &bat_ethtool_ops);
+
+	memset(priv, 0, sizeof(struct bat_priv));
+}
+
+struct net_device *softif_create(char *name)
+{
+	struct net_device *soft_iface;
+	struct bat_priv *bat_priv;
+	int ret;
+
+	soft_iface = alloc_netdev(sizeof(struct bat_priv) , name,
+				   interface_setup);
+
+	if (!soft_iface) {
+		pr_err("Unable to allocate the batman interface: %s\n", name);
+		goto out;
+	}
+
+	ret = register_netdev(soft_iface);
+	if (ret < 0) {
+		pr_err("Unable to register the batman interface '%s': %i\n",
+		       name, ret);
+		goto free_soft_iface;
+	}
+
+	bat_priv = netdev_priv(soft_iface);
+
+	atomic_set(&bat_priv->aggregation_enabled, 1);
+	atomic_set(&bat_priv->bonding_enabled, 0);
+	atomic_set(&bat_priv->vis_mode, VIS_TYPE_CLIENT_UPDATE);
+	atomic_set(&bat_priv->orig_interval, 1000);
+	atomic_set(&bat_priv->log_level, 0);
+	atomic_set(&bat_priv->frag_enabled, 1);
+	atomic_set(&bat_priv->bcast_queue_left, BCAST_QUEUE_LEN);
+	atomic_set(&bat_priv->batman_queue_left, BATMAN_QUEUE_LEN);
+
+	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
+	atomic_set(&bat_priv->bcast_seqno, 1);
+	atomic_set(&bat_priv->hna_local_changed, 0);
+
+	bat_priv->primary_if = NULL;
+	bat_priv->num_ifaces = 0;
+
+	ret = sysfs_add_meshif(soft_iface);
+	if (ret < 0)
+		goto unreg_soft_iface;
+
+	ret = debugfs_add_meshif(soft_iface);
+	if (ret < 0)
+		goto unreg_sysfs;
+
+	ret = mesh_init(soft_iface);
+	if (ret < 0)
+		goto unreg_debugfs;
+
+	return soft_iface;
+
+unreg_debugfs:
+	debugfs_del_meshif(soft_iface);
+unreg_sysfs:
+	sysfs_del_meshif(soft_iface);
+unreg_soft_iface:
+	unregister_netdev(soft_iface);
+	return NULL;
+
+free_soft_iface:
+	free_netdev(soft_iface);
+out:
+	return NULL;
+}
+
+void softif_destroy(struct net_device *soft_iface)
+{
+	debugfs_del_meshif(soft_iface);
+	sysfs_del_meshif(soft_iface);
+	mesh_free(soft_iface);
+	unregister_netdevice(soft_iface);
+}
+
+/* ethtool */
+static int bat_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	cmd->supported = 0;
+	cmd->advertising = 0;
+	cmd->speed = SPEED_10;
+	cmd->duplex = DUPLEX_FULL;
+	cmd->port = PORT_TP;
+	cmd->phy_address = 0;
+	cmd->transceiver = XCVR_INTERNAL;
+	cmd->autoneg = AUTONEG_DISABLE;
+	cmd->maxtxpkt = 0;
+	cmd->maxrxpkt = 0;
+
+	return 0;
+}
+
+static void bat_get_drvinfo(struct net_device *dev,
+			    struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, "B.A.T.M.A.N. advanced");
+	strcpy(info->version, SOURCE_VERSION);
+	strcpy(info->fw_version, "N/A");
+	strcpy(info->bus_info, "batman");
+}
+
+static u32 bat_get_msglevel(struct net_device *dev)
+{
+	return -EOPNOTSUPP;
+}
+
+static void bat_set_msglevel(struct net_device *dev, u32 value)
+{
+}
+
+static u32 bat_get_link(struct net_device *dev)
+{
+	return 1;
+}
+
+static u32 bat_get_rx_csum(struct net_device *dev)
+{
+	return 0;
+}
+
+static int bat_set_rx_csum(struct net_device *dev, u32 data)
+{
+	return -EOPNOTSUPP;
+}
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
new file mode 100644
index 0000000..843a7ec
--- /dev/null
+++ b/net/batman-adv/soft-interface.h
@@ -0,0 +1,32 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_SOFT_INTERFACE_H_
+#define _NET_BATMAN_ADV_SOFT_INTERFACE_H_
+
+int my_skb_head_push(struct sk_buff *skb, unsigned int len);
+int interface_tx(struct sk_buff *skb, struct net_device *soft_iface);
+void interface_rx(struct net_device *soft_iface,
+		  struct sk_buff *skb, int hdr_size);
+struct net_device *softif_create(char *name);
+void softif_destroy(struct net_device *soft_iface);
+
+#endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
new file mode 100644
index 0000000..12b2325
--- /dev/null
+++ b/net/batman-adv/translation-table.c
@@ -0,0 +1,513 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "translation-table.h"
+#include "soft-interface.h"
+#include "types.h"
+#include "hash.h"
+
+static void hna_local_purge(struct work_struct *work);
+static void _hna_global_del_orig(struct bat_priv *bat_priv,
+				 struct hna_global_entry *hna_global_entry,
+				 char *message);
+
+static void hna_local_start_timer(struct bat_priv *bat_priv)
+{
+	INIT_DELAYED_WORK(&bat_priv->hna_work, hna_local_purge);
+	queue_delayed_work(bat_event_workqueue, &bat_priv->hna_work, 10 * HZ);
+}
+
+int hna_local_init(struct bat_priv *bat_priv)
+{
+	if (bat_priv->hna_local_hash)
+		return 1;
+
+	bat_priv->hna_local_hash = hash_new(128, compare_orig, choose_orig);
+
+	if (!bat_priv->hna_local_hash)
+		return 0;
+
+	atomic_set(&bat_priv->hna_local_changed, 0);
+	hna_local_start_timer(bat_priv);
+
+	return 1;
+}
+
+void hna_local_add(struct net_device *soft_iface, uint8_t *addr)
+{
+	struct bat_priv *bat_priv = netdev_priv(soft_iface);
+	struct hna_local_entry *hna_local_entry;
+	struct hna_global_entry *hna_global_entry;
+	struct hashtable_t *swaphash;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bat_priv->hna_lhash_lock, flags);
+	hna_local_entry =
+		((struct hna_local_entry *)hash_find(bat_priv->hna_local_hash,
+						     addr));
+	spin_unlock_irqrestore(&bat_priv->hna_lhash_lock, flags);
+
+	if (hna_local_entry) {
+		hna_local_entry->last_seen = jiffies;
+		return;
+	}
+
+	/* only announce as many hosts as possible in the batman-packet and
+	   space in batman_packet->num_hna That also should give a limit to
+	   MAC-flooding. */
+	if ((bat_priv->num_local_hna + 1 > (ETH_DATA_LEN - BAT_PACKET_LEN)
+								/ ETH_ALEN) ||
+	    (bat_priv->num_local_hna + 1 > 255)) {
+		bat_dbg(DBG_ROUTES, bat_priv,
+			"Can't add new local hna entry (%pM): "
+			"number of local hna entries exceeds packet size\n",
+			addr);
+		return;
+	}
+
+	bat_dbg(DBG_ROUTES, bat_priv,
+		"Creating new local hna entry: %pM\n", addr);
+
+	hna_local_entry = kmalloc(sizeof(struct hna_local_entry), GFP_ATOMIC);
+	if (!hna_local_entry)
+		return;
+
+	memcpy(hna_local_entry->addr, addr, ETH_ALEN);
+	hna_local_entry->last_seen = jiffies;
+
+	/* the batman interface mac address should never be purged */
+	if (compare_orig(addr, soft_iface->dev_addr))
+		hna_local_entry->never_purge = 1;
+	else
+		hna_local_entry->never_purge = 0;
+
+	spin_lock_irqsave(&bat_priv->hna_lhash_lock, flags);
+
+	hash_add(bat_priv->hna_local_hash, hna_local_entry);
+	bat_priv->num_local_hna++;
+	atomic_set(&bat_priv->hna_local_changed, 1);
+
+	if (bat_priv->hna_local_hash->elements * 4 >
+					bat_priv->hna_local_hash->size) {
+		swaphash = hash_resize(bat_priv->hna_local_hash,
+				       bat_priv->hna_local_hash->size * 2);
+
+		if (!swaphash)
+			pr_err("Couldn't resize local hna hash table\n");
+		else
+			bat_priv->hna_local_hash = swaphash;
+	}
+
+	spin_unlock_irqrestore(&bat_priv->hna_lhash_lock, flags);
+
+	/* remove address from global hash if present */
+	spin_lock_irqsave(&bat_priv->hna_ghash_lock, flags);
+
+	hna_global_entry = ((struct hna_global_entry *)
+				hash_find(bat_priv->hna_global_hash, addr));
+
+	if (hna_global_entry)
+		_hna_global_del_orig(bat_priv, hna_global_entry,
+				     "local hna received");
+
+	spin_unlock_irqrestore(&bat_priv->hna_ghash_lock, flags);
+}
+
+int hna_local_fill_buffer(struct bat_priv *bat_priv,
+			  unsigned char *buff, int buff_len)
+{
+	struct hna_local_entry *hna_local_entry;
+	HASHIT(hashit);
+	int i = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bat_priv->hna_lhash_lock, flags);
+
+	while (hash_iterate(bat_priv->hna_local_hash, &hashit)) {
+
+		if (buff_len < (i + 1) * ETH_ALEN)
+			break;
+
+		hna_local_entry = hashit.bucket->data;
+		memcpy(buff + (i * ETH_ALEN), hna_local_entry->addr, ETH_ALEN);
+
+		i++;
+	}
+
+	/* if we did not get all new local hnas see you next time  ;-) */
+	if (i == bat_priv->num_local_hna)
+		atomic_set(&bat_priv->hna_local_changed, 0);
+
+	spin_unlock_irqrestore(&bat_priv->hna_lhash_lock, flags);
+	return i;
+}
+
+int hna_local_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	struct hna_local_entry *hna_local_entry;
+	HASHIT(hashit);
+	HASHIT(hashit_count);
+	unsigned long flags;
+	size_t buf_size, pos;
+	char *buff;
+
+	if (!bat_priv->primary_if) {
+		return seq_printf(seq, "BATMAN mesh %s disabled - "
+			       "please specify interfaces to enable it\n",
+			       net_dev->name);
+	}
+
+	seq_printf(seq, "Locally retrieved addresses (from %s) "
+		   "announced via HNA:\n",
+		   net_dev->name);
+
+	spin_lock_irqsave(&bat_priv->hna_lhash_lock, flags);
+
+	buf_size = 1;
+	/* Estimate length for: " * xx:xx:xx:xx:xx:xx\n" */
+	while (hash_iterate(bat_priv->hna_local_hash, &hashit_count))
+		buf_size += 21;
+
+	buff = kmalloc(buf_size, GFP_ATOMIC);
+	if (!buff) {
+		spin_unlock_irqrestore(&bat_priv->hna_lhash_lock, flags);
+		return -ENOMEM;
+	}
+	buff[0] = '\0';
+	pos = 0;
+
+	while (hash_iterate(bat_priv->hna_local_hash, &hashit)) {
+		hna_local_entry = hashit.bucket->data;
+
+		pos += snprintf(buff + pos, 22, " * %pM\n",
+				hna_local_entry->addr);
+	}
+
+	spin_unlock_irqrestore(&bat_priv->hna_lhash_lock, flags);
+
+	seq_printf(seq, "%s", buff);
+	kfree(buff);
+	return 0;
+}
+
+static void _hna_local_del(void *data, void *arg)
+{
+	struct bat_priv *bat_priv = (struct bat_priv *)arg;
+
+	kfree(data);
+	bat_priv->num_local_hna--;
+	atomic_set(&bat_priv->hna_local_changed, 1);
+}
+
+static void hna_local_del(struct bat_priv *bat_priv,
+			  struct hna_local_entry *hna_local_entry,
+			  char *message)
+{
+	bat_dbg(DBG_ROUTES, bat_priv, "Deleting local hna entry (%pM): %s\n",
+		hna_local_entry->addr, message);
+
+	hash_remove(bat_priv->hna_local_hash, hna_local_entry->addr);
+	_hna_local_del(hna_local_entry, bat_priv);
+}
+
+void hna_local_remove(struct bat_priv *bat_priv,
+		      uint8_t *addr, char *message)
+{
+	struct hna_local_entry *hna_local_entry;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bat_priv->hna_lhash_lock, flags);
+
+	hna_local_entry = (struct hna_local_entry *)
+		hash_find(bat_priv->hna_local_hash, addr);
+	if (hna_local_entry)
+		hna_local_del(bat_priv, hna_local_entry, message);
+
+	spin_unlock_irqrestore(&bat_priv->hna_lhash_lock, flags);
+}
+
+static void hna_local_purge(struct work_struct *work)
+{
+	struct delayed_work *delayed_work =
+		container_of(work, struct delayed_work, work);
+	struct bat_priv *bat_priv =
+		container_of(delayed_work, struct bat_priv, hna_work);
+	struct hna_local_entry *hna_local_entry;
+	HASHIT(hashit);
+	unsigned long flags;
+	unsigned long timeout;
+
+	spin_lock_irqsave(&bat_priv->hna_lhash_lock, flags);
+
+	while (hash_iterate(bat_priv->hna_local_hash, &hashit)) {
+		hna_local_entry = hashit.bucket->data;
+
+		timeout = hna_local_entry->last_seen + LOCAL_HNA_TIMEOUT * HZ;
+
+		if ((!hna_local_entry->never_purge) &&
+		    time_after(jiffies, timeout))
+			hna_local_del(bat_priv, hna_local_entry,
+				      "address timed out");
+	}
+
+	spin_unlock_irqrestore(&bat_priv->hna_lhash_lock, flags);
+	hna_local_start_timer(bat_priv);
+}
+
+void hna_local_free(struct bat_priv *bat_priv)
+{
+	if (!bat_priv->hna_local_hash)
+		return;
+
+	cancel_delayed_work_sync(&bat_priv->hna_work);
+	hash_delete(bat_priv->hna_local_hash, _hna_local_del, bat_priv);
+	bat_priv->hna_local_hash = NULL;
+}
+
+int hna_global_init(struct bat_priv *bat_priv)
+{
+	if (bat_priv->hna_global_hash)
+		return 1;
+
+	bat_priv->hna_global_hash = hash_new(128, compare_orig, choose_orig);
+
+	if (!bat_priv->hna_global_hash)
+		return 0;
+
+	return 1;
+}
+
+void hna_global_add_orig(struct bat_priv *bat_priv,
+			 struct orig_node *orig_node,
+			 unsigned char *hna_buff, int hna_buff_len)
+{
+	struct hna_global_entry *hna_global_entry;
+	struct hna_local_entry *hna_local_entry;
+	struct hashtable_t *swaphash;
+	int hna_buff_count = 0;
+	unsigned long flags;
+	unsigned char *hna_ptr;
+
+	while ((hna_buff_count + 1) * ETH_ALEN <= hna_buff_len) {
+		spin_lock_irqsave(&bat_priv->hna_ghash_lock, flags);
+
+		hna_ptr = hna_buff + (hna_buff_count * ETH_ALEN);
+		hna_global_entry = (struct hna_global_entry *)
+			hash_find(bat_priv->hna_global_hash, hna_ptr);
+
+		if (!hna_global_entry) {
+			spin_unlock_irqrestore(&bat_priv->hna_ghash_lock,
+					       flags);
+
+			hna_global_entry =
+				kmalloc(sizeof(struct hna_global_entry),
+					GFP_ATOMIC);
+
+			if (!hna_global_entry)
+				break;
+
+			memcpy(hna_global_entry->addr, hna_ptr, ETH_ALEN);
+
+			bat_dbg(DBG_ROUTES, bat_priv,
+				"Creating new global hna entry: "
+				"%pM (via %pM)\n",
+				hna_global_entry->addr, orig_node->orig);
+
+			spin_lock_irqsave(&bat_priv->hna_ghash_lock, flags);
+			hash_add(bat_priv->hna_global_hash, hna_global_entry);
+
+		}
+
+		hna_global_entry->orig_node = orig_node;
+		spin_unlock_irqrestore(&bat_priv->hna_ghash_lock, flags);
+
+		/* remove address from local hash if present */
+		spin_lock_irqsave(&bat_priv->hna_lhash_lock, flags);
+
+		hna_ptr = hna_buff + (hna_buff_count * ETH_ALEN);
+		hna_local_entry = (struct hna_local_entry *)
+			hash_find(bat_priv->hna_local_hash, hna_ptr);
+
+		if (hna_local_entry)
+			hna_local_del(bat_priv, hna_local_entry,
+				      "global hna received");
+
+		spin_unlock_irqrestore(&bat_priv->hna_lhash_lock, flags);
+
+		hna_buff_count++;
+	}
+
+	/* initialize, and overwrite if malloc succeeds */
+	orig_node->hna_buff = NULL;
+	orig_node->hna_buff_len = 0;
+
+	if (hna_buff_len > 0) {
+		orig_node->hna_buff = kmalloc(hna_buff_len, GFP_ATOMIC);
+		if (orig_node->hna_buff) {
+			memcpy(orig_node->hna_buff, hna_buff, hna_buff_len);
+			orig_node->hna_buff_len = hna_buff_len;
+		}
+	}
+
+	spin_lock_irqsave(&bat_priv->hna_ghash_lock, flags);
+
+	if (bat_priv->hna_global_hash->elements * 4 >
+					bat_priv->hna_global_hash->size) {
+		swaphash = hash_resize(bat_priv->hna_global_hash,
+				       bat_priv->hna_global_hash->size * 2);
+
+		if (!swaphash)
+			pr_err("Couldn't resize global hna hash table\n");
+		else
+			bat_priv->hna_global_hash = swaphash;
+	}
+
+	spin_unlock_irqrestore(&bat_priv->hna_ghash_lock, flags);
+}
+
+int hna_global_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	struct hna_global_entry *hna_global_entry;
+	HASHIT(hashit);
+	HASHIT(hashit_count);
+	unsigned long flags;
+	size_t buf_size, pos;
+	char *buff;
+
+	if (!bat_priv->primary_if) {
+		return seq_printf(seq, "BATMAN mesh %s disabled - "
+				  "please specify interfaces to enable it\n",
+				  net_dev->name);
+	}
+
+	seq_printf(seq, "Globally announced HNAs received via the mesh %s\n",
+		   net_dev->name);
+
+	spin_lock_irqsave(&bat_priv->hna_ghash_lock, flags);
+
+	buf_size = 1;
+	/* Estimate length for: " * xx:xx:xx:xx:xx:xx via xx:xx:xx:xx:xx:xx\n"*/
+	while (hash_iterate(bat_priv->hna_global_hash, &hashit_count))
+		buf_size += 43;
+
+	buff = kmalloc(buf_size, GFP_ATOMIC);
+	if (!buff) {
+		spin_unlock_irqrestore(&bat_priv->hna_ghash_lock, flags);
+		return -ENOMEM;
+	}
+	buff[0] = '\0';
+	pos = 0;
+
+	while (hash_iterate(bat_priv->hna_global_hash, &hashit)) {
+		hna_global_entry = hashit.bucket->data;
+
+		pos += snprintf(buff + pos, 44,
+				" * %pM via %pM\n", hna_global_entry->addr,
+				hna_global_entry->orig_node->orig);
+	}
+
+	spin_unlock_irqrestore(&bat_priv->hna_ghash_lock, flags);
+
+	seq_printf(seq, "%s", buff);
+	kfree(buff);
+	return 0;
+}
+
+static void _hna_global_del_orig(struct bat_priv *bat_priv,
+				 struct hna_global_entry *hna_global_entry,
+				 char *message)
+{
+	bat_dbg(DBG_ROUTES, bat_priv,
+		"Deleting global hna entry %pM (via %pM): %s\n",
+		hna_global_entry->addr, hna_global_entry->orig_node->orig,
+		message);
+
+	hash_remove(bat_priv->hna_global_hash, hna_global_entry->addr);
+	kfree(hna_global_entry);
+}
+
+void hna_global_del_orig(struct bat_priv *bat_priv,
+			 struct orig_node *orig_node, char *message)
+{
+	struct hna_global_entry *hna_global_entry;
+	int hna_buff_count = 0;
+	unsigned long flags;
+	unsigned char *hna_ptr;
+
+	if (orig_node->hna_buff_len == 0)
+		return;
+
+	spin_lock_irqsave(&bat_priv->hna_ghash_lock, flags);
+
+	while ((hna_buff_count + 1) * ETH_ALEN <= orig_node->hna_buff_len) {
+		hna_ptr = orig_node->hna_buff + (hna_buff_count * ETH_ALEN);
+		hna_global_entry = (struct hna_global_entry *)
+			hash_find(bat_priv->hna_global_hash, hna_ptr);
+
+		if ((hna_global_entry) &&
+		    (hna_global_entry->orig_node == orig_node))
+			_hna_global_del_orig(bat_priv, hna_global_entry,
+					     message);
+
+		hna_buff_count++;
+	}
+
+	spin_unlock_irqrestore(&bat_priv->hna_ghash_lock, flags);
+
+	orig_node->hna_buff_len = 0;
+	kfree(orig_node->hna_buff);
+	orig_node->hna_buff = NULL;
+}
+
+static void hna_global_del(void *data, void *arg)
+{
+	kfree(data);
+}
+
+void hna_global_free(struct bat_priv *bat_priv)
+{
+	if (!bat_priv->hna_global_hash)
+		return;
+
+	hash_delete(bat_priv->hna_global_hash, hna_global_del, NULL);
+	bat_priv->hna_global_hash = NULL;
+}
+
+struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *addr)
+{
+	struct hna_global_entry *hna_global_entry;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bat_priv->hna_ghash_lock, flags);
+	hna_global_entry = (struct hna_global_entry *)
+				hash_find(bat_priv->hna_global_hash, addr);
+	spin_unlock_irqrestore(&bat_priv->hna_ghash_lock, flags);
+
+	if (!hna_global_entry)
+		return NULL;
+
+	return hna_global_entry->orig_node;
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
new file mode 100644
index 0000000..10c4c5c
--- /dev/null
+++ b/net/batman-adv/translation-table.h
@@ -0,0 +1,45 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
+#define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
+
+#include "types.h"
+
+int hna_local_init(struct bat_priv *bat_priv);
+void hna_local_add(struct net_device *soft_iface, uint8_t *addr);
+void hna_local_remove(struct bat_priv *bat_priv,
+		      uint8_t *addr, char *message);
+int hna_local_fill_buffer(struct bat_priv *bat_priv,
+			  unsigned char *buff, int buff_len);
+int hna_local_seq_print_text(struct seq_file *seq, void *offset);
+void hna_local_free(struct bat_priv *bat_priv);
+int hna_global_init(struct bat_priv *bat_priv);
+void hna_global_add_orig(struct bat_priv *bat_priv,
+			 struct orig_node *orig_node,
+			 unsigned char *hna_buff, int hna_buff_len);
+int hna_global_seq_print_text(struct seq_file *seq, void *offset);
+void hna_global_del_orig(struct bat_priv *bat_priv,
+			 struct orig_node *orig_node, char *message);
+void hna_global_free(struct bat_priv *bat_priv);
+struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *addr);
+
+#endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
new file mode 100644
index 0000000..e779c4a
--- /dev/null
+++ b/net/batman-adv/types.h
@@ -0,0 +1,244 @@
+/*
+ * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+
+
+#ifndef _NET_BATMAN_ADV_TYPES_H_
+#define _NET_BATMAN_ADV_TYPES_H_
+
+#include "packet.h"
+#include "bitarray.h"
+
+#define BAT_HEADER_LEN (sizeof(struct ethhdr) + \
+	((sizeof(struct unicast_packet) > sizeof(struct bcast_packet) ? \
+	 sizeof(struct unicast_packet) : \
+	 sizeof(struct bcast_packet))))
+
+
+struct batman_if {
+	struct list_head list;
+	int16_t if_num;
+	char if_status;
+	char addr_str[ETH_STR_LEN];
+	struct net_device *net_dev;
+	atomic_t seqno;
+	atomic_t frag_seqno;
+	unsigned char *packet_buff;
+	int packet_len;
+	struct kobject *hardif_obj;
+	struct rcu_head rcu;
+	struct packet_type batman_adv_ptype;
+	struct net_device *soft_iface;
+};
+
+/**
+ *	orig_node - structure for orig_list maintaining nodes of mesh
+ *	@primary_addr: hosts primary interface address
+ *	@last_valid: when last packet from this node was received
+ *	@bcast_seqno_reset: time when the broadcast seqno window was reset
+ *	@batman_seqno_reset: time when the batman seqno window was reset
+ *	@flags: for now only VIS_SERVER flag
+ *	@last_real_seqno: last and best known squence number
+ *	@last_ttl: ttl of last received packet
+ *	@last_bcast_seqno: last broadcast sequence number received by this host
+ *
+ *	@candidates: how many candidates are available
+ *	@selected: next bonding candidate
+ */
+struct orig_node {
+	uint8_t orig[ETH_ALEN];
+	uint8_t primary_addr[ETH_ALEN];
+	struct neigh_node *router;
+	TYPE_OF_WORD *bcast_own;
+	uint8_t *bcast_own_sum;
+	uint8_t tq_own;
+	int tq_asym_penalty;
+	unsigned long last_valid;
+	unsigned long bcast_seqno_reset;
+	unsigned long batman_seqno_reset;
+	uint8_t  flags;
+	unsigned char *hna_buff;
+	int16_t hna_buff_len;
+	uint32_t last_real_seqno;
+	uint8_t last_ttl;
+	TYPE_OF_WORD bcast_bits[NUM_WORDS];
+	uint32_t last_bcast_seqno;
+	struct list_head neigh_list;
+	struct list_head frag_list;
+	unsigned long last_frag_packet;
+	struct {
+		uint8_t candidates;
+		struct neigh_node *selected;
+	} bond;
+};
+
+/**
+ *	neigh_node
+ *	@last_valid: when last packet via this neighbor was received
+ */
+struct neigh_node {
+	struct list_head list;
+	uint8_t addr[ETH_ALEN];
+	uint8_t real_packet_count;
+	uint8_t tq_recv[TQ_GLOBAL_WINDOW_SIZE];
+	uint8_t tq_index;
+	uint8_t tq_avg;
+	uint8_t last_ttl;
+	struct neigh_node *next_bond_candidate;
+	unsigned long last_valid;
+	TYPE_OF_WORD real_bits[NUM_WORDS];
+	struct orig_node *orig_node;
+	struct batman_if *if_incoming;
+};
+
+struct bat_priv {
+	atomic_t mesh_state;
+	struct net_device_stats stats;
+	atomic_t aggregation_enabled;
+	atomic_t bonding_enabled;
+	atomic_t frag_enabled;
+	atomic_t vis_mode;
+	atomic_t orig_interval;
+	atomic_t log_level;
+	atomic_t bcast_seqno;
+	atomic_t bcast_queue_left;
+	atomic_t batman_queue_left;
+	char num_ifaces;
+	struct debug_log *debug_log;
+	struct batman_if *primary_if;
+	struct kobject *mesh_obj;
+	struct dentry *debug_dir;
+	struct hlist_head forw_bat_list;
+	struct hlist_head forw_bcast_list;
+	struct hlist_head gw_list;
+	struct list_head vis_send_list;
+	struct hashtable_t *orig_hash;
+	struct hashtable_t *hna_local_hash;
+	struct hashtable_t *hna_global_hash;
+	struct hashtable_t *vis_hash;
+	spinlock_t orig_hash_lock;
+	spinlock_t forw_bat_list_lock;
+	spinlock_t forw_bcast_list_lock;
+	spinlock_t hna_lhash_lock;
+	spinlock_t hna_ghash_lock;
+	spinlock_t gw_list_lock;
+	spinlock_t vis_hash_lock;
+	spinlock_t vis_list_lock;
+	int16_t num_local_hna;
+	atomic_t hna_local_changed;
+	struct delayed_work hna_work;
+	struct delayed_work orig_work;
+	struct delayed_work vis_work;
+	struct gw_node *curr_gw;
+	struct vis_info *my_vis_info;
+};
+
+struct socket_client {
+	struct list_head queue_list;
+	unsigned int queue_len;
+	unsigned char index;
+	spinlock_t lock;
+	wait_queue_head_t queue_wait;
+	struct bat_priv *bat_priv;
+};
+
+struct socket_packet {
+	struct list_head list;
+	size_t icmp_len;
+	struct icmp_packet_rr icmp_packet;
+};
+
+struct hna_local_entry {
+	uint8_t addr[ETH_ALEN];
+	unsigned long last_seen;
+	char never_purge;
+};
+
+struct hna_global_entry {
+	uint8_t addr[ETH_ALEN];
+	struct orig_node *orig_node;
+};
+
+/**
+ *	forw_packet - structure for forw_list maintaining packets to be
+ *	              send/forwarded
+ */
+struct forw_packet {
+	struct hlist_node list;
+	unsigned long send_time;
+	uint8_t own;
+	struct sk_buff *skb;
+	uint16_t packet_len;
+	uint32_t direct_link_flags;
+	uint8_t num_packets;
+	struct delayed_work delayed_work;
+	struct batman_if *if_incoming;
+};
+
+/* While scanning for vis-entries of a particular vis-originator
+ * this list collects its interfaces to create a subgraph/cluster
+ * out of them later
+ */
+struct if_list_entry {
+	uint8_t addr[ETH_ALEN];
+	bool primary;
+	struct hlist_node list;
+};
+
+struct debug_log {
+	char log_buff[LOG_BUF_LEN];
+	unsigned long log_start;
+	unsigned long log_end;
+	spinlock_t lock;
+	wait_queue_head_t queue_wait;
+};
+
+struct frag_packet_list_entry {
+	struct list_head list;
+	uint16_t seqno;
+	struct sk_buff *skb;
+};
+
+struct vis_info {
+	unsigned long       first_seen;
+	struct list_head    recv_list;
+			    /* list of server-neighbors we received a vis-packet
+			     * from.  we should not reply to them. */
+	struct list_head send_list;
+	struct kref refcount;
+	struct bat_priv *bat_priv;
+	/* this packet might be part of the vis send queue. */
+	struct sk_buff *skb_packet;
+	/* vis_info may follow here*/
+} __attribute__((packed));
+
+struct vis_info_entry {
+	uint8_t  src[ETH_ALEN];
+	uint8_t  dest[ETH_ALEN];
+	uint8_t  quality;	/* quality = 0 means HNA */
+} __attribute__((packed));
+
+struct recvlist_node {
+	struct list_head list;
+	uint8_t mac[ETH_ALEN];
+};
+
+#endif /* _NET_BATMAN_ADV_TYPES_H_ */
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
new file mode 100644
index 0000000..f951abc
--- /dev/null
+++ b/net/batman-adv/unicast.c
@@ -0,0 +1,265 @@
+/*
+ * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ *
+ * Andreas Langer
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "unicast.h"
+#include "send.h"
+#include "soft-interface.h"
+#include "hash.h"
+#include "translation-table.h"
+#include "routing.h"
+#include "hard-interface.h"
+
+
+struct sk_buff *merge_frag_packet(struct list_head *head,
+				  struct frag_packet_list_entry *tfp,
+				  struct sk_buff *skb)
+{
+	struct unicast_frag_packet *up =
+		(struct unicast_frag_packet *)skb->data;
+	struct sk_buff *tmp_skb;
+
+	/* set skb to the first part and tmp_skb to the second part */
+	if (up->flags & UNI_FRAG_HEAD) {
+		tmp_skb = tfp->skb;
+	} else {
+		tmp_skb = skb;
+		skb = tfp->skb;
+	}
+
+	skb_pull(tmp_skb, sizeof(struct unicast_frag_packet));
+	if (pskb_expand_head(skb, 0, tmp_skb->len, GFP_ATOMIC) < 0) {
+		/* free buffered skb, skb will be freed later */
+		kfree_skb(tfp->skb);
+		return NULL;
+	}
+
+	/* move free entry to end */
+	tfp->skb = NULL;
+	tfp->seqno = 0;
+	list_move_tail(&tfp->list, head);
+
+	memcpy(skb_put(skb, tmp_skb->len), tmp_skb->data, tmp_skb->len);
+	kfree_skb(tmp_skb);
+	return skb;
+}
+
+void create_frag_entry(struct list_head *head, struct sk_buff *skb)
+{
+	struct frag_packet_list_entry *tfp;
+	struct unicast_frag_packet *up =
+		(struct unicast_frag_packet *)skb->data;
+
+	/* free and oldest packets stand at the end */
+	tfp = list_entry((head)->prev, typeof(*tfp), list);
+	kfree_skb(tfp->skb);
+
+	tfp->seqno = ntohs(up->seqno);
+	tfp->skb = skb;
+	list_move(&tfp->list, head);
+	return;
+}
+
+void create_frag_buffer(struct list_head *head)
+{
+	int i;
+	struct frag_packet_list_entry *tfp;
+
+	for (i = 0; i < FRAG_BUFFER_SIZE; i++) {
+		tfp = kmalloc(sizeof(struct frag_packet_list_entry),
+			GFP_ATOMIC);
+		tfp->skb = NULL;
+		tfp->seqno = 0;
+		INIT_LIST_HEAD(&tfp->list);
+		list_add(&tfp->list, head);
+	}
+
+	return;
+}
+
+struct frag_packet_list_entry *search_frag_packet(struct list_head *head,
+						 struct unicast_frag_packet *up)
+{
+	struct frag_packet_list_entry *tfp;
+	struct unicast_frag_packet *tmp_up = NULL;
+	uint16_t search_seqno;
+
+	if (up->flags & UNI_FRAG_HEAD)
+		search_seqno = ntohs(up->seqno)+1;
+	else
+		search_seqno = ntohs(up->seqno)-1;
+
+	list_for_each_entry(tfp, head, list) {
+
+		if (!tfp->skb)
+			continue;
+
+		if (tfp->seqno == ntohs(up->seqno))
+			goto mov_tail;
+
+		tmp_up = (struct unicast_frag_packet *)tfp->skb->data;
+
+		if (tfp->seqno == search_seqno) {
+
+			if ((tmp_up->flags & UNI_FRAG_HEAD) !=
+			    (up->flags & UNI_FRAG_HEAD))
+				return tfp;
+			else
+				goto mov_tail;
+		}
+	}
+	return NULL;
+
+mov_tail:
+	list_move_tail(&tfp->list, head);
+	return NULL;
+}
+
+void frag_list_free(struct list_head *head)
+{
+	struct frag_packet_list_entry *pf, *tmp_pf;
+
+	if (!list_empty(head)) {
+
+		list_for_each_entry_safe(pf, tmp_pf, head, list) {
+			kfree_skb(pf->skb);
+			list_del(&pf->list);
+			kfree(pf);
+		}
+	}
+	return;
+}
+
+static int unicast_send_frag_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
+			  struct batman_if *batman_if, uint8_t dstaddr[],
+			  struct orig_node *orig_node)
+{
+	struct unicast_frag_packet *ucast_frag1, *ucast_frag2;
+	int hdr_len = sizeof(struct unicast_frag_packet);
+	struct sk_buff *frag_skb;
+	int data_len = skb->len;
+
+	if (!bat_priv->primary_if)
+		goto dropped;
+
+	frag_skb = dev_alloc_skb(data_len - (data_len / 2) + hdr_len);
+	skb_split(skb, frag_skb, data_len / 2);
+
+	if (my_skb_head_push(frag_skb, hdr_len) < 0 ||
+	    my_skb_head_push(skb, hdr_len) < 0)
+		goto drop_frag;
+
+	ucast_frag1 = (struct unicast_frag_packet *)skb->data;
+	ucast_frag2 = (struct unicast_frag_packet *)frag_skb->data;
+
+	ucast_frag1->version = COMPAT_VERSION;
+	ucast_frag1->packet_type = BAT_UNICAST_FRAG;
+	ucast_frag1->ttl = TTL;
+	memcpy(ucast_frag1->orig,
+	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(ucast_frag1->dest, orig_node->orig, ETH_ALEN);
+
+	memcpy(ucast_frag2, ucast_frag1, sizeof(struct unicast_frag_packet));
+
+	ucast_frag1->flags |= UNI_FRAG_HEAD;
+	ucast_frag2->flags &= ~UNI_FRAG_HEAD;
+
+	ucast_frag1->seqno = htons((uint16_t)atomic_inc_return(
+						&batman_if->frag_seqno));
+
+	ucast_frag2->seqno = htons((uint16_t)atomic_inc_return(
+						&batman_if->frag_seqno));
+
+	send_skb_packet(skb, batman_if, dstaddr);
+	send_skb_packet(frag_skb, batman_if, dstaddr);
+	return 0;
+
+drop_frag:
+	kfree_skb(frag_skb);
+dropped:
+	kfree_skb(skb);
+	return 1;
+}
+
+int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
+{
+	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
+	struct unicast_packet *unicast_packet;
+	struct orig_node *orig_node;
+	struct batman_if *batman_if;
+	struct neigh_node *router;
+	int data_len = skb->len;
+	uint8_t dstaddr[6];
+	unsigned long flags;
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+
+	/* get routing information */
+	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
+						   ethhdr->h_dest));
+
+	/* check for hna host */
+	if (!orig_node)
+		orig_node = transtable_search(bat_priv, ethhdr->h_dest);
+
+	router = find_router(orig_node, NULL);
+
+	if (!router)
+		goto unlock;
+
+	/* don't lock while sending the packets ... we therefore
+		* copy the required data before sending */
+
+	batman_if = router->if_incoming;
+	memcpy(dstaddr, router->addr, ETH_ALEN);
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	if (batman_if->if_status != IF_ACTIVE)
+		goto dropped;
+
+	if (atomic_read(&bat_priv->frag_enabled) &&
+	    data_len + sizeof(struct unicast_packet) > batman_if->net_dev->mtu)
+		return unicast_send_frag_skb(skb, bat_priv, batman_if,
+					     dstaddr, orig_node);
+
+	if (my_skb_head_push(skb, sizeof(struct unicast_packet)) < 0)
+		goto dropped;
+
+	unicast_packet = (struct unicast_packet *)skb->data;
+
+	unicast_packet->version = COMPAT_VERSION;
+	/* batman packet type: unicast */
+	unicast_packet->packet_type = BAT_UNICAST;
+	/* set unicast ttl */
+	unicast_packet->ttl = TTL;
+	/* copy the destination for faster routing */
+	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
+
+	send_skb_packet(skb, batman_if, dstaddr);
+	return 0;
+
+unlock:
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+dropped:
+	kfree_skb(skb);
+	return 1;
+}
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
new file mode 100644
index 0000000..1d5cbeb
--- /dev/null
+++ b/net/batman-adv/unicast.h
@@ -0,0 +1,39 @@
+/*
+ * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ *
+ * Andreas Langer
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_UNICAST_H_
+#define _NET_BATMAN_ADV_UNICAST_H_
+
+#define FRAG_TIMEOUT 10000	/* purge frag list entrys after time in ms */
+#define FRAG_BUFFER_SIZE 6	/* number of list elements in buffer */
+
+struct sk_buff *merge_frag_packet(struct list_head *head,
+	struct frag_packet_list_entry *tfp,
+	struct sk_buff *skb);
+
+void create_frag_entry(struct list_head *head, struct sk_buff *skb);
+void create_frag_buffer(struct list_head *head);
+struct frag_packet_list_entry *search_frag_packet(struct list_head *head,
+	struct unicast_frag_packet *up);
+void frag_list_free(struct list_head *head);
+int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv);
+
+#endif /* _NET_BATMAN_ADV_UNICAST_H_ */
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
new file mode 100644
index 0000000..b2cec8e
--- /dev/null
+++ b/net/batman-adv/vis.c
@@ -0,0 +1,901 @@
+/*
+ * Copyright (C) 2008-2010 B.A.T.M.A.N. contributors:
+ *
+ * Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "send.h"
+#include "translation-table.h"
+#include "vis.h"
+#include "soft-interface.h"
+#include "hard-interface.h"
+#include "hash.h"
+
+#define MAX_VIS_PACKET_SIZE 1000
+
+/* Returns the smallest signed integer in two's complement with the sizeof x */
+#define smallest_signed_int(x) (1u << (7u + 8u * (sizeof(x) - 1u)))
+
+/* Checks if a sequence number x is a predecessor/successor of y.
+   they handle overflows/underflows and can correctly check for a
+   predecessor/successor unless the variable sequence number has grown by
+   more then 2**(bitwidth(x)-1)-1.
+   This means that for a uint8_t with the maximum value 255, it would think:
+    * when adding nothing - it is neither a predecessor nor a successor
+    * before adding more than 127 to the starting value - it is a predecessor,
+    * when adding 128 - it is neither a predecessor nor a successor,
+    * after adding more than 127 to the starting value - it is a successor */
+#define seq_before(x, y) ({typeof(x) _dummy = (x - y); \
+			_dummy > smallest_signed_int(_dummy); })
+#define seq_after(x, y) seq_before(y, x)
+
+static void start_vis_timer(struct bat_priv *bat_priv);
+
+/* free the info */
+static void free_info(struct kref *ref)
+{
+	struct vis_info *info = container_of(ref, struct vis_info, refcount);
+	struct bat_priv *bat_priv = info->bat_priv;
+	struct recvlist_node *entry, *tmp;
+	unsigned long flags;
+
+	list_del_init(&info->send_list);
+	spin_lock_irqsave(&bat_priv->vis_list_lock, flags);
+	list_for_each_entry_safe(entry, tmp, &info->recv_list, list) {
+		list_del(&entry->list);
+		kfree(entry);
+	}
+
+	spin_unlock_irqrestore(&bat_priv->vis_list_lock, flags);
+	kfree_skb(info->skb_packet);
+}
+
+/* Compare two vis packets, used by the hashing algorithm */
+static int vis_info_cmp(void *data1, void *data2)
+{
+	struct vis_info *d1, *d2;
+	struct vis_packet *p1, *p2;
+	d1 = data1;
+	d2 = data2;
+	p1 = (struct vis_packet *)d1->skb_packet->data;
+	p2 = (struct vis_packet *)d2->skb_packet->data;
+	return compare_orig(p1->vis_orig, p2->vis_orig);
+}
+
+/* hash function to choose an entry in a hash table of given size */
+/* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
+static int vis_info_choose(void *data, int size)
+{
+	struct vis_info *vis_info = data;
+	struct vis_packet *packet;
+	unsigned char *key;
+	uint32_t hash = 0;
+	size_t i;
+
+	packet = (struct vis_packet *)vis_info->skb_packet->data;
+	key = packet->vis_orig;
+	for (i = 0; i < ETH_ALEN; i++) {
+		hash += key[i];
+		hash += (hash << 10);
+		hash ^= (hash >> 6);
+	}
+
+	hash += (hash << 3);
+	hash ^= (hash >> 11);
+	hash += (hash << 15);
+
+	return hash % size;
+}
+
+/* insert interface to the list of interfaces of one originator, if it
+ * does not already exist in the list */
+static void vis_data_insert_interface(const uint8_t *interface,
+				      struct hlist_head *if_list,
+				      bool primary)
+{
+	struct if_list_entry *entry;
+	struct hlist_node *pos;
+
+	hlist_for_each_entry(entry, pos, if_list, list) {
+		if (compare_orig(entry->addr, (void *)interface))
+			return;
+	}
+
+	/* its a new address, add it to the list */
+	entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
+	if (!entry)
+		return;
+	memcpy(entry->addr, interface, ETH_ALEN);
+	entry->primary = primary;
+	hlist_add_head(&entry->list, if_list);
+}
+
+static ssize_t vis_data_read_prim_sec(char *buff, struct hlist_head *if_list)
+{
+	struct if_list_entry *entry;
+	struct hlist_node *pos;
+	char tmp_addr_str[ETH_STR_LEN];
+	size_t len = 0;
+
+	hlist_for_each_entry(entry, pos, if_list, list) {
+		if (entry->primary)
+			len += sprintf(buff + len, "PRIMARY, ");
+		else {
+			addr_to_string(tmp_addr_str, entry->addr);
+			len += sprintf(buff + len,  "SEC %s, ", tmp_addr_str);
+		}
+	}
+
+	return len;
+}
+
+static size_t vis_data_count_prim_sec(struct hlist_head *if_list)
+{
+	struct if_list_entry *entry;
+	struct hlist_node *pos;
+	size_t count = 0;
+
+	hlist_for_each_entry(entry, pos, if_list, list) {
+		if (entry->primary)
+			count += 9;
+		else
+			count += 23;
+	}
+
+	return count;
+}
+
+/* read an entry  */
+static ssize_t vis_data_read_entry(char *buff, struct vis_info_entry *entry,
+				   uint8_t *src, bool primary)
+{
+	char to[18];
+
+	/* maximal length: max(4+17+2, 3+17+1+3+2) == 26 */
+	addr_to_string(to, entry->dest);
+	if (primary && entry->quality == 0)
+		return sprintf(buff, "HNA %s, ", to);
+	else if (compare_orig(entry->src, src))
+		return sprintf(buff, "TQ %s %d, ", to, entry->quality);
+
+	return 0;
+}
+
+int vis_seq_print_text(struct seq_file *seq, void *offset)
+{
+	HASHIT(hashit);
+	HASHIT(hashit_count);
+	struct vis_info *info;
+	struct vis_packet *packet;
+	struct vis_info_entry *entries;
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	HLIST_HEAD(vis_if_list);
+	struct if_list_entry *entry;
+	struct hlist_node *pos, *n;
+	int i;
+	char tmp_addr_str[ETH_STR_LEN];
+	unsigned long flags;
+	int vis_server = atomic_read(&bat_priv->vis_mode);
+	size_t buff_pos, buf_size;
+	char *buff;
+
+	if ((!bat_priv->primary_if) ||
+	    (vis_server == VIS_TYPE_CLIENT_UPDATE))
+		return 0;
+
+	buf_size = 1;
+	/* Estimate length */
+	spin_lock_irqsave(&bat_priv->vis_hash_lock, flags);
+	while (hash_iterate(bat_priv->vis_hash, &hashit_count)) {
+		info = hashit_count.bucket->data;
+		packet = (struct vis_packet *)info->skb_packet->data;
+		entries = (struct vis_info_entry *)
+			  ((char *)packet + sizeof(struct vis_packet));
+
+		for (i = 0; i < packet->entries; i++) {
+			if (entries[i].quality == 0)
+				continue;
+			vis_data_insert_interface(entries[i].src, &vis_if_list,
+				compare_orig(entries[i].src, packet->vis_orig));
+		}
+
+		hlist_for_each_entry(entry, pos, &vis_if_list, list) {
+			buf_size += 18 + 26 * packet->entries;
+
+			/* add primary/secondary records */
+			if (compare_orig(entry->addr, packet->vis_orig))
+				buf_size +=
+					vis_data_count_prim_sec(&vis_if_list);
+
+			buf_size += 1;
+		}
+
+		hlist_for_each_entry_safe(entry, pos, n, &vis_if_list, list) {
+			hlist_del(&entry->list);
+			kfree(entry);
+		}
+	}
+
+	buff = kmalloc(buf_size, GFP_ATOMIC);
+	if (!buff) {
+		spin_unlock_irqrestore(&bat_priv->vis_hash_lock, flags);
+		return -ENOMEM;
+	}
+	buff[0] = '\0';
+	buff_pos = 0;
+
+	while (hash_iterate(bat_priv->vis_hash, &hashit)) {
+		info = hashit.bucket->data;
+		packet = (struct vis_packet *)info->skb_packet->data;
+		entries = (struct vis_info_entry *)
+			  ((char *)packet + sizeof(struct vis_packet));
+
+		for (i = 0; i < packet->entries; i++) {
+			if (entries[i].quality == 0)
+				continue;
+			vis_data_insert_interface(entries[i].src, &vis_if_list,
+				compare_orig(entries[i].src, packet->vis_orig));
+		}
+
+		hlist_for_each_entry(entry, pos, &vis_if_list, list) {
+			addr_to_string(tmp_addr_str, entry->addr);
+			buff_pos += sprintf(buff + buff_pos, "%s,",
+					    tmp_addr_str);
+
+			for (i = 0; i < packet->entries; i++)
+				buff_pos += vis_data_read_entry(buff + buff_pos,
+								&entries[i],
+								entry->addr,
+								entry->primary);
+
+			/* add primary/secondary records */
+			if (compare_orig(entry->addr, packet->vis_orig))
+				buff_pos +=
+					vis_data_read_prim_sec(buff + buff_pos,
+							       &vis_if_list);
+
+			buff_pos += sprintf(buff + buff_pos, "\n");
+		}
+
+		hlist_for_each_entry_safe(entry, pos, n, &vis_if_list, list) {
+			hlist_del(&entry->list);
+			kfree(entry);
+		}
+	}
+
+	spin_unlock_irqrestore(&bat_priv->vis_hash_lock, flags);
+
+	seq_printf(seq, "%s", buff);
+	kfree(buff);
+
+	return 0;
+}
+
+/* add the info packet to the send list, if it was not
+ * already linked in. */
+static void send_list_add(struct bat_priv *bat_priv, struct vis_info *info)
+{
+	if (list_empty(&info->send_list)) {
+		kref_get(&info->refcount);
+		list_add_tail(&info->send_list, &bat_priv->vis_send_list);
+	}
+}
+
+/* delete the info packet from the send list, if it was
+ * linked in. */
+static void send_list_del(struct vis_info *info)
+{
+	if (!list_empty(&info->send_list)) {
+		list_del_init(&info->send_list);
+		kref_put(&info->refcount, free_info);
+	}
+}
+
+/* tries to add one entry to the receive list. */
+static void recv_list_add(struct bat_priv *bat_priv,
+			  struct list_head *recv_list, char *mac)
+{
+	struct recvlist_node *entry;
+	unsigned long flags;
+
+	entry = kmalloc(sizeof(struct recvlist_node), GFP_ATOMIC);
+	if (!entry)
+		return;
+
+	memcpy(entry->mac, mac, ETH_ALEN);
+	spin_lock_irqsave(&bat_priv->vis_list_lock, flags);
+	list_add_tail(&entry->list, recv_list);
+	spin_unlock_irqrestore(&bat_priv->vis_list_lock, flags);
+}
+
+/* returns 1 if this mac is in the recv_list */
+static int recv_list_is_in(struct bat_priv *bat_priv,
+			   struct list_head *recv_list, char *mac)
+{
+	struct recvlist_node *entry;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bat_priv->vis_list_lock, flags);
+	list_for_each_entry(entry, recv_list, list) {
+		if (memcmp(entry->mac, mac, ETH_ALEN) == 0) {
+			spin_unlock_irqrestore(&bat_priv->vis_list_lock,
+					       flags);
+			return 1;
+		}
+	}
+	spin_unlock_irqrestore(&bat_priv->vis_list_lock, flags);
+	return 0;
+}
+
+/* try to add the packet to the vis_hash. return NULL if invalid (e.g. too old,
+ * broken.. ).	vis hash must be locked outside.  is_new is set when the packet
+ * is newer than old entries in the hash. */
+static struct vis_info *add_packet(struct bat_priv *bat_priv,
+				   struct vis_packet *vis_packet,
+				   int vis_info_len, int *is_new,
+				   int make_broadcast)
+{
+	struct vis_info *info, *old_info;
+	struct vis_packet *search_packet, *old_packet;
+	struct vis_info search_elem;
+	struct vis_packet *packet;
+
+	*is_new = 0;
+	/* sanity check */
+	if (!bat_priv->vis_hash)
+		return NULL;
+
+	/* see if the packet is already in vis_hash */
+	search_elem.skb_packet = dev_alloc_skb(sizeof(struct vis_packet));
+	if (!search_elem.skb_packet)
+		return NULL;
+	search_packet = (struct vis_packet *)skb_put(search_elem.skb_packet,
+						     sizeof(struct vis_packet));
+
+	memcpy(search_packet->vis_orig, vis_packet->vis_orig, ETH_ALEN);
+	old_info = hash_find(bat_priv->vis_hash, &search_elem);
+	kfree_skb(search_elem.skb_packet);
+
+	if (old_info != NULL) {
+		old_packet = (struct vis_packet *)old_info->skb_packet->data;
+		if (!seq_after(ntohl(vis_packet->seqno),
+			       ntohl(old_packet->seqno))) {
+			if (old_packet->seqno == vis_packet->seqno) {
+				recv_list_add(bat_priv, &old_info->recv_list,
+					      vis_packet->sender_orig);
+				return old_info;
+			} else {
+				/* newer packet is already in hash. */
+				return NULL;
+			}
+		}
+		/* remove old entry */
+		hash_remove(bat_priv->vis_hash, old_info);
+		send_list_del(old_info);
+		kref_put(&old_info->refcount, free_info);
+	}
+
+	info = kmalloc(sizeof(struct vis_info), GFP_ATOMIC);
+	if (!info)
+		return NULL;
+
+	info->skb_packet = dev_alloc_skb(sizeof(struct vis_packet) +
+					 vis_info_len + sizeof(struct ethhdr));
+	if (!info->skb_packet) {
+		kfree(info);
+		return NULL;
+	}
+	skb_reserve(info->skb_packet, sizeof(struct ethhdr));
+	packet = (struct vis_packet *)skb_put(info->skb_packet,
+					      sizeof(struct vis_packet) +
+					      vis_info_len);
+
+	kref_init(&info->refcount);
+	INIT_LIST_HEAD(&info->send_list);
+	INIT_LIST_HEAD(&info->recv_list);
+	info->first_seen = jiffies;
+	info->bat_priv = bat_priv;
+	memcpy(packet, vis_packet, sizeof(struct vis_packet) + vis_info_len);
+
+	/* initialize and add new packet. */
+	*is_new = 1;
+
+	/* Make it a broadcast packet, if required */
+	if (make_broadcast)
+		memcpy(packet->target_orig, broadcast_addr, ETH_ALEN);
+
+	/* repair if entries is longer than packet. */
+	if (packet->entries * sizeof(struct vis_info_entry) > vis_info_len)
+		packet->entries = vis_info_len / sizeof(struct vis_info_entry);
+
+	recv_list_add(bat_priv, &info->recv_list, packet->sender_orig);
+
+	/* try to add it */
+	if (hash_add(bat_priv->vis_hash, info) < 0) {
+		/* did not work (for some reason) */
+		kref_put(&old_info->refcount, free_info);
+		info = NULL;
+	}
+
+	return info;
+}
+
+/* handle the server sync packet, forward if needed. */
+void receive_server_sync_packet(struct bat_priv *bat_priv,
+				struct vis_packet *vis_packet,
+				int vis_info_len)
+{
+	struct vis_info *info;
+	int is_new, make_broadcast;
+	unsigned long flags;
+	int vis_server = atomic_read(&bat_priv->vis_mode);
+
+	make_broadcast = (vis_server == VIS_TYPE_SERVER_SYNC);
+
+	spin_lock_irqsave(&bat_priv->vis_hash_lock, flags);
+	info = add_packet(bat_priv, vis_packet, vis_info_len,
+			  &is_new, make_broadcast);
+	if (!info)
+		goto end;
+
+	/* only if we are server ourselves and packet is newer than the one in
+	 * hash.*/
+	if (vis_server == VIS_TYPE_SERVER_SYNC && is_new)
+		send_list_add(bat_priv, info);
+end:
+	spin_unlock_irqrestore(&bat_priv->vis_hash_lock, flags);
+}
+
+/* handle an incoming client update packet and schedule forward if needed. */
+void receive_client_update_packet(struct bat_priv *bat_priv,
+				  struct vis_packet *vis_packet,
+				  int vis_info_len)
+{
+	struct vis_info *info;
+	struct vis_packet *packet;
+	int is_new;
+	unsigned long flags;
+	int vis_server = atomic_read(&bat_priv->vis_mode);
+	int are_target = 0;
+
+	/* clients shall not broadcast. */
+	if (is_bcast(vis_packet->target_orig))
+		return;
+
+	/* Are we the target for this VIS packet? */
+	if (vis_server == VIS_TYPE_SERVER_SYNC	&&
+	    is_my_mac(vis_packet->target_orig))
+		are_target = 1;
+
+	spin_lock_irqsave(&bat_priv->vis_hash_lock, flags);
+	info = add_packet(bat_priv, vis_packet, vis_info_len,
+			  &is_new, are_target);
+
+	if (!info)
+		goto end;
+	/* note that outdated packets will be dropped at this point. */
+
+	packet = (struct vis_packet *)info->skb_packet->data;
+
+	/* send only if we're the target server or ... */
+	if (are_target && is_new) {
+		packet->vis_type = VIS_TYPE_SERVER_SYNC;	/* upgrade! */
+		send_list_add(bat_priv, info);
+
+		/* ... we're not the recipient (and thus need to forward). */
+	} else if (!is_my_mac(packet->target_orig)) {
+		send_list_add(bat_priv, info);
+	}
+
+end:
+	spin_unlock_irqrestore(&bat_priv->vis_hash_lock, flags);
+}
+
+/* Walk the originators and find the VIS server with the best tq. Set the packet
+ * address to its address and return the best_tq.
+ *
+ * Must be called with the originator hash locked */
+static int find_best_vis_server(struct bat_priv *bat_priv,
+				struct vis_info *info)
+{
+	HASHIT(hashit);
+	struct orig_node *orig_node;
+	struct vis_packet *packet;
+	int best_tq = -1;
+
+	packet = (struct vis_packet *)info->skb_packet->data;
+
+	while (hash_iterate(bat_priv->orig_hash, &hashit)) {
+		orig_node = hashit.bucket->data;
+		if ((orig_node) && (orig_node->router) &&
+		    (orig_node->flags & VIS_SERVER) &&
+		    (orig_node->router->tq_avg > best_tq)) {
+			best_tq = orig_node->router->tq_avg;
+			memcpy(packet->target_orig, orig_node->orig, ETH_ALEN);
+		}
+	}
+	return best_tq;
+}
+
+/* Return true if the vis packet is full. */
+static bool vis_packet_full(struct vis_info *info)
+{
+	struct vis_packet *packet;
+	packet = (struct vis_packet *)info->skb_packet->data;
+
+	if (MAX_VIS_PACKET_SIZE / sizeof(struct vis_info_entry)
+		< packet->entries + 1)
+		return true;
+	return false;
+}
+
+/* generates a packet of own vis data,
+ * returns 0 on success, -1 if no packet could be generated */
+static int generate_vis_packet(struct bat_priv *bat_priv)
+{
+	HASHIT(hashit_local);
+	HASHIT(hashit_global);
+	struct orig_node *orig_node;
+	struct vis_info *info = (struct vis_info *)bat_priv->my_vis_info;
+	struct vis_packet *packet = (struct vis_packet *)info->skb_packet->data;
+	struct vis_info_entry *entry;
+	struct hna_local_entry *hna_local_entry;
+	int best_tq = -1;
+	unsigned long flags;
+
+	info->first_seen = jiffies;
+	packet->vis_type = atomic_read(&bat_priv->vis_mode);
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	memcpy(packet->target_orig, broadcast_addr, ETH_ALEN);
+	packet->ttl = TTL;
+	packet->seqno = htonl(ntohl(packet->seqno) + 1);
+	packet->entries = 0;
+	skb_trim(info->skb_packet, sizeof(struct vis_packet));
+
+	if (packet->vis_type == VIS_TYPE_CLIENT_UPDATE) {
+		best_tq = find_best_vis_server(bat_priv, info);
+
+		if (best_tq < 0) {
+			spin_unlock_irqrestore(&bat_priv->orig_hash_lock,
+					       flags);
+			return -1;
+		}
+	}
+
+	while (hash_iterate(bat_priv->orig_hash, &hashit_global)) {
+		orig_node = hashit_global.bucket->data;
+
+		if (!orig_node->router)
+			continue;
+
+		if (!compare_orig(orig_node->router->addr, orig_node->orig))
+			continue;
+
+		if (orig_node->router->if_incoming->if_status != IF_ACTIVE)
+			continue;
+
+		if (orig_node->router->tq_avg < 1)
+			continue;
+
+		/* fill one entry into buffer. */
+		entry = (struct vis_info_entry *)
+				skb_put(info->skb_packet, sizeof(*entry));
+		memcpy(entry->src,
+		       orig_node->router->if_incoming->net_dev->dev_addr,
+		       ETH_ALEN);
+		memcpy(entry->dest, orig_node->orig, ETH_ALEN);
+		entry->quality = orig_node->router->tq_avg;
+		packet->entries++;
+
+		if (vis_packet_full(info)) {
+			spin_unlock_irqrestore(
+					&bat_priv->orig_hash_lock, flags);
+			return 0;
+		}
+	}
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	spin_lock_irqsave(&bat_priv->hna_lhash_lock, flags);
+	while (hash_iterate(bat_priv->hna_local_hash, &hashit_local)) {
+		hna_local_entry = hashit_local.bucket->data;
+		entry = (struct vis_info_entry *)skb_put(info->skb_packet,
+							 sizeof(*entry));
+		memset(entry->src, 0, ETH_ALEN);
+		memcpy(entry->dest, hna_local_entry->addr, ETH_ALEN);
+		entry->quality = 0; /* 0 means HNA */
+		packet->entries++;
+
+		if (vis_packet_full(info)) {
+			spin_unlock_irqrestore(&bat_priv->hna_lhash_lock,
+					       flags);
+			return 0;
+		}
+	}
+
+	spin_unlock_irqrestore(&bat_priv->hna_lhash_lock, flags);
+	return 0;
+}
+
+/* free old vis packets. Must be called with this vis_hash_lock
+ * held */
+static void purge_vis_packets(struct bat_priv *bat_priv)
+{
+	HASHIT(hashit);
+	struct vis_info *info;
+
+	while (hash_iterate(bat_priv->vis_hash, &hashit)) {
+		info = hashit.bucket->data;
+
+		/* never purge own data. */
+		if (info == bat_priv->my_vis_info)
+			continue;
+
+		if (time_after(jiffies,
+			       info->first_seen + VIS_TIMEOUT * HZ)) {
+			hash_remove_bucket(bat_priv->vis_hash, &hashit);
+			send_list_del(info);
+			kref_put(&info->refcount, free_info);
+		}
+	}
+}
+
+static void broadcast_vis_packet(struct bat_priv *bat_priv,
+				 struct vis_info *info)
+{
+	HASHIT(hashit);
+	struct orig_node *orig_node;
+	struct vis_packet *packet;
+	struct sk_buff *skb;
+	unsigned long flags;
+	struct batman_if *batman_if;
+	uint8_t dstaddr[ETH_ALEN];
+
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	packet = (struct vis_packet *)info->skb_packet->data;
+
+	/* send to all routers in range. */
+	while (hash_iterate(bat_priv->orig_hash, &hashit)) {
+		orig_node = hashit.bucket->data;
+
+		/* if it's a vis server and reachable, send it. */
+		if ((!orig_node) || (!orig_node->router))
+			continue;
+		if (!(orig_node->flags & VIS_SERVER))
+			continue;
+		/* don't send it if we already received the packet from
+		 * this node. */
+		if (recv_list_is_in(bat_priv, &info->recv_list,
+							orig_node->orig))
+			continue;
+
+		memcpy(packet->target_orig, orig_node->orig, ETH_ALEN);
+		batman_if = orig_node->router->if_incoming;
+		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+		spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+		skb = skb_clone(info->skb_packet, GFP_ATOMIC);
+		if (skb)
+			send_skb_packet(skb, batman_if, dstaddr);
+
+		spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+
+	}
+
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+}
+
+static void unicast_vis_packet(struct bat_priv *bat_priv,
+			       struct vis_info *info)
+{
+	struct orig_node *orig_node;
+	struct sk_buff *skb;
+	struct vis_packet *packet;
+	unsigned long flags;
+	struct batman_if *batman_if;
+	uint8_t dstaddr[ETH_ALEN];
+
+	spin_lock_irqsave(&bat_priv->orig_hash_lock, flags);
+	packet = (struct vis_packet *)info->skb_packet->data;
+	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
+						   packet->target_orig));
+
+	if ((!orig_node) || (!orig_node->router))
+		goto out;
+
+	/* don't lock while sending the packets ... we therefore
+	 * copy the required data before sending */
+	batman_if = orig_node->router->if_incoming;
+	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+
+	skb = skb_clone(info->skb_packet, GFP_ATOMIC);
+	if (skb)
+		send_skb_packet(skb, batman_if, dstaddr);
+
+	return;
+
+out:
+	spin_unlock_irqrestore(&bat_priv->orig_hash_lock, flags);
+}
+
+/* only send one vis packet. called from send_vis_packets() */
+static void send_vis_packet(struct bat_priv *bat_priv, struct vis_info *info)
+{
+	struct vis_packet *packet;
+
+	packet = (struct vis_packet *)info->skb_packet->data;
+	if (packet->ttl < 2) {
+		pr_debug("Error - can't send vis packet: ttl exceeded\n");
+		return;
+	}
+
+	memcpy(packet->sender_orig, bat_priv->primary_if->net_dev->dev_addr,
+	       ETH_ALEN);
+	packet->ttl--;
+
+	if (is_bcast(packet->target_orig))
+		broadcast_vis_packet(bat_priv, info);
+	else
+		unicast_vis_packet(bat_priv, info);
+	packet->ttl++; /* restore TTL */
+}
+
+/* called from timer; send (and maybe generate) vis packet. */
+static void send_vis_packets(struct work_struct *work)
+{
+	struct delayed_work *delayed_work =
+		container_of(work, struct delayed_work, work);
+	struct bat_priv *bat_priv =
+		container_of(delayed_work, struct bat_priv, vis_work);
+	struct vis_info *info, *temp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bat_priv->vis_hash_lock, flags);
+	purge_vis_packets(bat_priv);
+
+	if (generate_vis_packet(bat_priv) == 0) {
+		/* schedule if generation was successful */
+		send_list_add(bat_priv, bat_priv->my_vis_info);
+	}
+
+	list_for_each_entry_safe(info, temp, &bat_priv->vis_send_list,
+				 send_list) {
+
+		kref_get(&info->refcount);
+		spin_unlock_irqrestore(&bat_priv->vis_hash_lock, flags);
+
+		if (bat_priv->primary_if)
+			send_vis_packet(bat_priv, info);
+
+		spin_lock_irqsave(&bat_priv->vis_hash_lock, flags);
+		send_list_del(info);
+		kref_put(&info->refcount, free_info);
+	}
+	spin_unlock_irqrestore(&bat_priv->vis_hash_lock, flags);
+	start_vis_timer(bat_priv);
+}
+
+/* init the vis server. this may only be called when if_list is already
+ * initialized (e.g. bat0 is initialized, interfaces have been added) */
+int vis_init(struct bat_priv *bat_priv)
+{
+	struct vis_packet *packet;
+	unsigned long flags;
+
+	if (bat_priv->vis_hash)
+		return 1;
+
+	spin_lock_irqsave(&bat_priv->vis_hash_lock, flags);
+
+	bat_priv->vis_hash = hash_new(256, vis_info_cmp, vis_info_choose);
+	if (!bat_priv->vis_hash) {
+		pr_err("Can't initialize vis_hash\n");
+		goto err;
+	}
+
+	bat_priv->my_vis_info = kmalloc(MAX_VIS_PACKET_SIZE, GFP_ATOMIC);
+	if (!bat_priv->my_vis_info) {
+		pr_err("Can't initialize vis packet\n");
+		goto err;
+	}
+
+	bat_priv->my_vis_info->skb_packet = dev_alloc_skb(
+						sizeof(struct vis_packet) +
+						MAX_VIS_PACKET_SIZE +
+						sizeof(struct ethhdr));
+	if (!bat_priv->my_vis_info->skb_packet)
+		goto free_info;
+
+	skb_reserve(bat_priv->my_vis_info->skb_packet, sizeof(struct ethhdr));
+	packet = (struct vis_packet *)skb_put(
+					bat_priv->my_vis_info->skb_packet,
+					sizeof(struct vis_packet));
+
+	/* prefill the vis info */
+	bat_priv->my_vis_info->first_seen = jiffies -
+						msecs_to_jiffies(VIS_INTERVAL);
+	INIT_LIST_HEAD(&bat_priv->my_vis_info->recv_list);
+	INIT_LIST_HEAD(&bat_priv->my_vis_info->send_list);
+	kref_init(&bat_priv->my_vis_info->refcount);
+	bat_priv->my_vis_info->bat_priv = bat_priv;
+	packet->version = COMPAT_VERSION;
+	packet->packet_type = BAT_VIS;
+	packet->ttl = TTL;
+	packet->seqno = 0;
+	packet->entries = 0;
+
+	INIT_LIST_HEAD(&bat_priv->vis_send_list);
+
+	if (hash_add(bat_priv->vis_hash, bat_priv->my_vis_info) < 0) {
+		pr_err("Can't add own vis packet into hash\n");
+		/* not in hash, need to remove it manually. */
+		kref_put(&bat_priv->my_vis_info->refcount, free_info);
+		goto err;
+	}
+
+	spin_unlock_irqrestore(&bat_priv->vis_hash_lock, flags);
+	start_vis_timer(bat_priv);
+	return 1;
+
+free_info:
+	kfree(bat_priv->my_vis_info);
+	bat_priv->my_vis_info = NULL;
+err:
+	spin_unlock_irqrestore(&bat_priv->vis_hash_lock, flags);
+	vis_quit(bat_priv);
+	return 0;
+}
+
+/* Decrease the reference count on a hash item info */
+static void free_info_ref(void *data, void *arg)
+{
+	struct vis_info *info = data;
+
+	send_list_del(info);
+	kref_put(&info->refcount, free_info);
+}
+
+/* shutdown vis-server */
+void vis_quit(struct bat_priv *bat_priv)
+{
+	unsigned long flags;
+	if (!bat_priv->vis_hash)
+		return;
+
+	cancel_delayed_work_sync(&bat_priv->vis_work);
+
+	spin_lock_irqsave(&bat_priv->vis_hash_lock, flags);
+	/* properly remove, kill timers ... */
+	hash_delete(bat_priv->vis_hash, free_info_ref, NULL);
+	bat_priv->vis_hash = NULL;
+	bat_priv->my_vis_info = NULL;
+	spin_unlock_irqrestore(&bat_priv->vis_hash_lock, flags);
+}
+
+/* schedule packets for (re)transmission */
+static void start_vis_timer(struct bat_priv *bat_priv)
+{
+	INIT_DELAYED_WORK(&bat_priv->vis_work, send_vis_packets);
+	queue_delayed_work(bat_event_workqueue, &bat_priv->vis_work,
+			   msecs_to_jiffies(VIS_INTERVAL));
+}
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
new file mode 100644
index 0000000..2c3b330
--- /dev/null
+++ b/net/batman-adv/vis.h
@@ -0,0 +1,37 @@
+/*
+ * Copyright (C) 2008-2010 B.A.T.M.A.N. contributors:
+ *
+ * Simon Wunderlich, Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_VIS_H_
+#define _NET_BATMAN_ADV_VIS_H_
+
+#define VIS_TIMEOUT		200	/* timeout of vis packets in seconds */
+
+int vis_seq_print_text(struct seq_file *seq, void *offset);
+void receive_server_sync_packet(struct bat_priv *bat_priv,
+				struct vis_packet *vis_packet,
+				int vis_info_len);
+void receive_client_update_packet(struct bat_priv *bat_priv,
+				  struct vis_packet *vis_packet,
+				  int vis_info_len);
+int vis_init(struct bat_priv *bat_priv);
+void vis_quit(struct bat_priv *bat_priv);
+
+#endif /* _NET_BATMAN_ADV_VIS_H_ */
-- 
1.7.1

