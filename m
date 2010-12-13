From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: =?utf-8?q?=5BPATCHv8=5D_net=3A_Add_batman-adv_mesh?=
	=?utf-8?q?ing_protocol?=
Date: Mon, 13 Dec 2010 22:19:28 +0100
Message-ID: <1292275168-19882-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a routing
protocol for multi-hop ad-hoc mesh networks. The networks may be wired or
wireless. See http://www.open-mesh.org/ for more information and user spa=
ce
tools.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

Following patches were integrated since the last submission:

Marek Lindner (2):
      batman-adv: remove hash resize functions
      batman-adv: adjust NULL pointer check style

Sven Eckelmann (3):
      batman-adv: Remove hash_iterate
      batman-adv: Use kernel facilities for bit operations
      batman-adv: Remove TYPE_OF_WORD define

[1] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2010-June/002881.ht=
ml
[2] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2010-June/002968.ht=
ml
[3] http://www.open-mesh.org
[4] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2010-November/00374=
3.html

 .../ABI/testing/sysfs-class-net-batman-adv         |   14 +
 Documentation/ABI/testing/sysfs-class-net-mesh     |   69 +
 Documentation/networking/batman-adv.txt            |  240 ++++
 MAINTAINERS                                        |    9 +
 net/Kconfig                                        |    1 +
 net/Makefile                                       |    1 +
 net/batman-adv/Kconfig                             |   25 +
 net/batman-adv/Makefile                            |   39 +
 net/batman-adv/aggregation.c                       |  273 ++++
 net/batman-adv/aggregation.h                       |   43 +
 net/batman-adv/bat_debugfs.c                       |  360 +++++
 net/batman-adv/bat_debugfs.h                       |   33 +
 net/batman-adv/bat_sysfs.c                         |  593 +++++++++
 net/batman-adv/bat_sysfs.h                         |   42 +
 net/batman-adv/bitarray.c                          |  201 +++
 net/batman-adv/bitarray.h                          |   44 +
 net/batman-adv/gateway_client.c                    |  477 +++++++
 net/batman-adv/gateway_client.h                    |   36 +
 net/batman-adv/gateway_common.c                    |  177 +++
 net/batman-adv/gateway_common.h                    |   38 +
 net/batman-adv/hard-interface.c                    |  651 +++++++++
 net/batman-adv/hard-interface.h                    |   53 +
 net/batman-adv/hash.c                              |   62 +
 net/batman-adv/hash.h                              |  176 +++
 net/batman-adv/icmp_socket.c                       |  356 +++++
 net/batman-adv/icmp_socket.h                       |   34 +
 net/batman-adv/main.c                              |  187 +++
 net/batman-adv/main.h                              |  183 +++
 net/batman-adv/originator.c                        |  564 ++++++++
 net/batman-adv/originator.h                        |   64 +
 net/batman-adv/packet.h                            |  136 ++
 net/batman-adv/ring_buffer.c                       |   52 +
 net/batman-adv/ring_buffer.h                       |   28 +
 net/batman-adv/routing.c                           | 1397 ++++++++++++++=
++++++
 net/batman-adv/routing.h                           |   48 +
 net/batman-adv/send.c                              |  585 ++++++++
 net/batman-adv/send.h                              |   41 +
 net/batman-adv/soft-interface.c                    |  697 ++++++++++
 net/batman-adv/soft-interface.h                    |   35 +
 net/batman-adv/translation-table.c                 |  534 ++++++++
 net/batman-adv/translation-table.h                 |   45 +
 net/batman-adv/types.h                             |  271 ++++
 net/batman-adv/unicast.c                           |  343 +++++
 net/batman-adv/unicast.h                           |   35 +
 net/batman-adv/vis.c                               |  949 +++++++++++++
 net/batman-adv/vis.h                               |   37 +
 46 files changed, 10278 insertions(+), 0 deletions(-)
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
 create mode 100644 net/batman-adv/gateway_client.c
 create mode 100644 net/batman-adv/gateway_client.h
 create mode 100644 net/batman-adv/gateway_common.c
 create mode 100644 net/batman-adv/gateway_common.h
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

diff --git a/Documentation/ABI/testing/sysfs-class-net-batman-adv b/Docum=
entation/ABI/testing/sysfs-class-net-batman-adv
new file mode 100644
index 0000000..38dd762
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-batman-adv
@@ -0,0 +1,14 @@
+
+What:           /sys/class/net/<iface>/batman-adv/mesh_iface
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Description:
+                The /sys/class/net/<iface>/batman-adv/mesh_iface file
+                displays the batman mesh interface this <iface>
+                currently is associated with.
+
+What:           /sys/class/net/<iface>/batman-adv/iface_status
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Description:
+                Indicates the status of <iface> as it is seen by batman.
diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentati=
on/ABI/testing/sysfs-class-net-mesh
new file mode 100644
index 0000000..748fe17
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -0,0 +1,69 @@
+
+What:           /sys/class/net/<mesh_iface>/mesh/aggregated_ogms
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Description:
+                Indicates whether the batman protocol messages of the
+                mesh <mesh_iface> shall be aggregated or not.
+
+What:           /sys/class/net/<mesh_iface>/mesh/bonding
+Date:           June 2010
+Contact:        Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
+Description:
+                Indicates whether the data traffic going through the
+                mesh will be sent using multiple interfaces at the
+                same time (if available).
+
+What:           /sys/class/net/<mesh_iface>/mesh/fragmentation
+Date:           October 2010
+Contact:        Andreas Langer <an.langer-Mmb7MZpHnFY@public.gmane.org>
+Description:
+                Indicates whether the data traffic going through the
+                mesh will be fragmented or silently discarded if the
+                packet size exceeds the outgoing interface MTU.
+
+What:           /sys/class/net/<mesh_iface>/mesh/gw_bandwidth
+Date:           October 2010
+Contact:        Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Description:
+                Defines the bandwidth which is propagated by this
+                node if gw_mode was set to 'server'.
+
+What:           /sys/class/net/<mesh_iface>/mesh/gw_mode
+Date:           October 2010
+Contact:        Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Description:
+                Defines the state of the gateway features. Can be
+                either 'off', 'client' or 'server'.
+
+What:           /sys/class/net/<mesh_iface>/mesh/gw_sel_class
+Date:           October 2010
+Contact:        Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Description:
+                Defines the selection criteria this node will use
+                to choose a gateway if gw_mode was set to 'client'.
+
+What:           /sys/class/net/<mesh_iface>/mesh/orig_interval
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Description:
+                Defines the interval in milliseconds in which batman
+                sends its protocol messages.
+
+What:           /sys/class/net/<mesh_iface>/mesh/hop_penalty
+Date:           Oct 2010
+Contact:        Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
+Description:
+		Defines the penalty which will be applied to an
+		originator message's tq-field on every hop.
+
+What:           /sys/class/net/<mesh_iface>/mesh/vis_mode
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Description:
+                Each batman node only maintains information about its
+                own local neighborhood, therefore generating graphs
+                showing the topology of the entire mesh is not easily
+                feasible without having a central instance to collect
+                the local topologies from all nodes. This file allows
+                to activate the collecting (server) mode.
diff --git a/Documentation/networking/batman-adv.txt b/Documentation/netw=
orking/batman-adv.txt
new file mode 100644
index 0000000..77f0cdd
--- /dev/null
+++ b/Documentation/networking/batman-adv.txt
@@ -0,0 +1,240 @@
+[state: 21-11-2010]
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
+#  aggregated_ogms  bonding  fragmentation  orig_interval
+#  vis_mode
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
+Mailing-list:   b.a.t.m.a.n@b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
+                (optional   subscription   at
+                 https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n)
+
+You can also contact the Authors:
+
+Marek  Lindner  <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+Simon  Wunderlich  <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
diff --git a/MAINTAINERS b/MAINTAINERS
index 802eb16..00afd26 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1264,6 +1264,15 @@ S:	Maintained
 F:	drivers/video/backlight/
 F:	include/linux/backlight.h
=20
+BATMAN ADVANCED
+M:	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
+M:	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
+M:	Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
+L:	b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
+W:	http://www.open-mesh.org/
+S:	Maintained
+F:	net/batman-adv/
+
 BAYCOM/HDLCDRV DRIVERS FOR AX.25
 M:	Thomas Sailer <t.sailer-aAjG49QhEdKVRmA6MYkXiA@public.gmane.org>
 L:	linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
diff --git a/net/Kconfig b/net/Kconfig
index 40b9bba..7284062 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -214,6 +214,7 @@ source "net/ieee802154/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
 source "net/dns_resolver/Kconfig"
+source "net/batman-adv/Kconfig"
=20
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index 6b7bfd7..a3330eb 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -69,3 +69,4 @@ endif
 obj-$(CONFIG_WIMAX)		+=3D wimax/
 obj-$(CONFIG_DNS_RESOLVER)	+=3D dns_resolver/
 obj-$(CONFIG_CEPH_LIB)		+=3D ceph/
+obj-$(CONFIG_BATMAN_ADV)	+=3D batman-adv/
diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
new file mode 100644
index 0000000..6c051ad
--- /dev/null
+++ b/net/batman-adv/Kconfig
@@ -0,0 +1,25 @@
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
+	depends on BATMAN_ADV !=3D n
+	---help---
+
+	  This is an option for use by developers; most people should
+	  say N here. This enables compilation of support for
+	  outputting debugging information to the kernel log. The
+	  output is controlled via the module parameter debug.
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
new file mode 100644
index 0000000..d936aec
--- /dev/null
+++ b/net/batman-adv/Makefile
@@ -0,0 +1,39 @@
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
+obj-$(CONFIG_BATMAN_ADV) +=3D batman-adv.o
+batman-adv-y +=3D aggregation.o
+batman-adv-y +=3D bat_debugfs.o
+batman-adv-y +=3D bat_sysfs.o
+batman-adv-y +=3D bitarray.o
+batman-adv-y +=3D gateway_client.o
+batman-adv-y +=3D gateway_common.o
+batman-adv-y +=3D hard-interface.o
+batman-adv-y +=3D hash.o
+batman-adv-y +=3D icmp_socket.o
+batman-adv-y +=3D main.o
+batman-adv-y +=3D originator.o
+batman-adv-y +=3D ring_buffer.o
+batman-adv-y +=3D routing.o
+batman-adv-y +=3D send.o
+batman-adv-y +=3D soft-interface.o
+batman-adv-y +=3D translation-table.o
+batman-adv-y +=3D unicast.o
+batman-adv-y +=3D vis.o
diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
new file mode 100644
index 0000000..3850a3e
--- /dev/null
+++ b/net/batman-adv/aggregation.c
@@ -0,0 +1,273 @@
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
+	struct batman_packet *batman_packet =3D
+		(struct batman_packet *)forw_packet->skb->data;
+	int aggregated_bytes =3D forw_packet->packet_len + packet_len;
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
+	    (aggregated_bytes <=3D MAX_AGGREGATION_BYTES)) {
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
+		    (batman_packet->ttl !=3D 1) &&
+
+		    /* own packets originating non-primary
+		     * interfaces leave only that interface */
+		    ((!forw_packet->own) ||
+		     (forw_packet->if_incoming->if_num =3D=3D 0)))
+			return true;
+
+		/* if the incoming packet is sent via this one
+		 * interface only - we still can aggregate */
+		if ((directlink) &&
+		    (new_batman_packet->ttl =3D=3D 1) &&
+		    (forw_packet->if_incoming =3D=3D if_incoming) &&
+
+		    /* packets from direct neighbors or
+		     * own secondary interface packets
+		     * (=3D secondary interface packets in general) */
+		    (batman_packet->flags & DIRECTLINK ||
+		     (forw_packet->own &&
+		      forw_packet->if_incoming->if_num !=3D 0)))
+			return true;
+	}
+
+	return false;
+}
+
+#define atomic_dec_not_zero(v)          atomic_add_unless((v), -1, 0)
+/* create a new aggregated packet and add this packet to it */
+static void new_aggregated_packet(unsigned char *packet_buff, int packet=
_len,
+				  unsigned long send_time, bool direct_link,
+				  struct batman_if *if_incoming,
+				  int own_packet)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
+	struct forw_packet *forw_packet_aggr;
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
+	forw_packet_aggr =3D kmalloc(sizeof(struct forw_packet), GFP_ATOMIC);
+	if (!forw_packet_aggr) {
+		if (!own_packet)
+			atomic_inc(&bat_priv->batman_queue_left);
+		return;
+	}
+
+	if ((atomic_read(&bat_priv->aggregated_ogms)) &&
+	    (packet_len < MAX_AGGREGATION_BYTES))
+		forw_packet_aggr->skb =3D dev_alloc_skb(MAX_AGGREGATION_BYTES +
+						      sizeof(struct ethhdr));
+	else
+		forw_packet_aggr->skb =3D dev_alloc_skb(packet_len +
+						      sizeof(struct ethhdr));
+
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
+	skb_buff =3D skb_put(forw_packet_aggr->skb, packet_len);
+	forw_packet_aggr->packet_len =3D packet_len;
+	memcpy(skb_buff, packet_buff, packet_len);
+
+	forw_packet_aggr->own =3D own_packet;
+	forw_packet_aggr->if_incoming =3D if_incoming;
+	forw_packet_aggr->num_packets =3D 0;
+	forw_packet_aggr->direct_link_flags =3D 0;
+	forw_packet_aggr->send_time =3D send_time;
+
+	/* save packet direct link flag status */
+	if (direct_link)
+		forw_packet_aggr->direct_link_flags |=3D 1;
+
+	/* add new packet to packet list */
+	spin_lock_bh(&bat_priv->forw_bat_list_lock);
+	hlist_add_head(&forw_packet_aggr->list, &bat_priv->forw_bat_list);
+	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
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
+	skb_buff =3D skb_put(forw_packet_aggr->skb, packet_len);
+	memcpy(skb_buff, packet_buff, packet_len);
+	forw_packet_aggr->packet_len +=3D packet_len;
+	forw_packet_aggr->num_packets++;
+
+	/* save packet direct link flag status */
+	if (direct_link)
+		forw_packet_aggr->direct_link_flags |=3D
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
+	struct forw_packet *forw_packet_aggr =3D NULL, *forw_packet_pos =3D NUL=
L;
+	struct hlist_node *tmp_node;
+	struct batman_packet *batman_packet =3D
+		(struct batman_packet *)packet_buff;
+	bool direct_link =3D batman_packet->flags & DIRECTLINK ? 1 : 0;
+
+	/* find position for the packet in the forward queue */
+	spin_lock_bh(&bat_priv->forw_bat_list_lock);
+	/* own packets are not to be aggregated */
+	if ((atomic_read(&bat_priv->aggregated_ogms)) && (!own_packet)) {
+		hlist_for_each_entry(forw_packet_pos, tmp_node,
+				     &bat_priv->forw_bat_list, list) {
+			if (can_aggregate_with(batman_packet,
+					       packet_len,
+					       send_time,
+					       direct_link,
+					       if_incoming,
+					       forw_packet_pos)) {
+				forw_packet_aggr =3D forw_packet_pos;
+				break;
+			}
+		}
+	}
+
+	/* nothing to aggregate with - either aggregation disabled or no
+	 * suitable aggregation packet found */
+	if (!forw_packet_aggr) {
+		/* the following section can run without the lock */
+		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
+
+		/**
+		 * if we could not aggregate this packet with one of the others
+		 * we hold it back for a while, so that it might be aggregated
+		 * later on
+		 */
+		if ((!own_packet) &&
+		    (atomic_read(&bat_priv->aggregated_ogms)))
+			send_time +=3D msecs_to_jiffies(MAX_AGGREGATION_MS);
+
+		new_aggregated_packet(packet_buff, packet_len,
+				      send_time, direct_link,
+				      if_incoming, own_packet);
+	} else {
+		aggregate(forw_packet_aggr,
+			  packet_buff, packet_len,
+			  direct_link);
+		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
+	}
+}
+
+/* unpack the aggregated packets and process them one by one */
+void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packe=
t_buff,
+			     int packet_len, struct batman_if *if_incoming)
+{
+	struct batman_packet *batman_packet;
+	int buff_pos =3D 0;
+	unsigned char *hna_buff;
+
+	batman_packet =3D (struct batman_packet *)packet_buff;
+
+	do {
+		/* network to host order for our 32bit seqno, and the
+		   orig_interval. */
+		batman_packet->seqno =3D ntohl(batman_packet->seqno);
+
+		hna_buff =3D packet_buff + buff_pos + BAT_PACKET_LEN;
+		receive_bat_packet(ethhdr, batman_packet,
+				   hna_buff, hna_len(batman_packet),
+				   if_incoming);
+
+		buff_pos +=3D BAT_PACKET_LEN + hna_len(batman_packet);
+		batman_packet =3D (struct batman_packet *)
+			(packet_buff + buff_pos);
+	} while (aggregated_packet(buff_pos, packet_len,
+				   batman_packet->num_hna));
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
+static inline int aggregated_packet(int buff_pos, int packet_len, int nu=
m_hna)
+{
+	int next_buff_pos =3D buff_pos + BAT_PACKET_LEN + (num_hna * ETH_ALEN);
+
+	return (next_buff_pos <=3D packet_len) &&
+		(next_buff_pos <=3D MAX_AGGREGATION_BYTES);
+}
+
+void add_bat_packet_to_list(struct bat_priv *bat_priv,
+			    unsigned char *packet_buff, int packet_len,
+			    struct batman_if *if_incoming, char own_packet,
+			    unsigned long send_time);
+void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packe=
t_buff,
+			     int packet_len, struct batman_if *if_incoming);
+
+#endif /* _NET_BATMAN_ADV_AGGREGATION_H_ */
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
new file mode 100644
index 0000000..0ae81d0
--- /dev/null
+++ b/net/batman-adv/bat_debugfs.c
@@ -0,0 +1,360 @@
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
+#include "gateway_common.h"
+#include "gateway_client.h"
+#include "soft-interface.h"
+#include "vis.h"
+#include "icmp_socket.h"
+
+static struct dentry *bat_debugfs;
+
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+#define LOG_BUFF_MASK (log_buff_len-1)
+#define LOG_BUFF(idx) (debug_log->log_buff[(idx) & LOG_BUFF_MASK])
+
+static int log_buff_len =3D LOG_BUF_LEN;
+
+static void emit_log_char(struct debug_log *debug_log, char c)
+{
+	LOG_BUFF(debug_log->log_end) =3D c;
+	debug_log->log_end++;
+
+	if (debug_log->log_end - debug_log->log_start > log_buff_len)
+		debug_log->log_start =3D debug_log->log_end - log_buff_len;
+}
+
+static int fdebug_log(struct debug_log *debug_log, char *fmt, ...)
+{
+	int printed_len;
+	va_list args;
+	static char debug_log_buf[256];
+	char *p;
+
+	if (!debug_log)
+		return 0;
+
+	spin_lock_bh(&debug_log->lock);
+	va_start(args, fmt);
+	printed_len =3D vscnprintf(debug_log_buf, sizeof(debug_log_buf),
+				 fmt, args);
+	va_end(args);
+
+	for (p =3D debug_log_buf; *p !=3D 0; p++)
+		emit_log_char(debug_log, *p);
+
+	spin_unlock_bh(&debug_log->lock);
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
+	nonseekable_open(inode, file);
+	file->private_data =3D inode->i_private;
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
+	struct bat_priv *bat_priv =3D file->private_data;
+	struct debug_log *debug_log =3D bat_priv->debug_log;
+	int error, i =3D 0;
+	char c;
+
+	if ((file->f_flags & O_NONBLOCK) &&
+	    !(debug_log->log_end - debug_log->log_start))
+		return -EAGAIN;
+
+	if ((!buf) || (count < 0))
+		return -EINVAL;
+
+	if (count =3D=3D 0)
+		return 0;
+
+	if (!access_ok(VERIFY_WRITE, buf, count))
+		return -EFAULT;
+
+	error =3D wait_event_interruptible(debug_log->queue_wait,
+				(debug_log->log_start - debug_log->log_end));
+
+	if (error)
+		return error;
+
+	spin_lock_bh(&debug_log->lock);
+
+	while ((!error) && (i < count) &&
+	       (debug_log->log_start !=3D debug_log->log_end)) {
+		c =3D LOG_BUFF(debug_log->log_start);
+
+		debug_log->log_start++;
+
+		spin_unlock_bh(&debug_log->lock);
+
+		error =3D __put_user(c, buf);
+
+		spin_lock_bh(&debug_log->lock);
+
+		buf++;
+		i++;
+
+	}
+
+	spin_unlock_bh(&debug_log->lock);
+
+	if (!error)
+		return i;
+
+	return error;
+}
+
+static unsigned int log_poll(struct file *file, poll_table *wait)
+{
+	struct bat_priv *bat_priv =3D file->private_data;
+	struct debug_log *debug_log =3D bat_priv->debug_log;
+
+	poll_wait(file, &debug_log->queue_wait, wait);
+
+	if (debug_log->log_end - debug_log->log_start)
+		return POLLIN | POLLRDNORM;
+
+	return 0;
+}
+
+static const struct file_operations log_fops =3D {
+	.open           =3D log_open,
+	.release        =3D log_release,
+	.read           =3D log_read,
+	.poll           =3D log_poll,
+	.llseek         =3D no_llseek,
+};
+
+static int debug_log_setup(struct bat_priv *bat_priv)
+{
+	struct dentry *d;
+
+	if (!bat_priv->debug_dir)
+		goto err;
+
+	bat_priv->debug_log =3D kzalloc(sizeof(struct debug_log), GFP_ATOMIC);
+	if (!bat_priv->debug_log)
+		goto err;
+
+	spin_lock_init(&bat_priv->debug_log->lock);
+	init_waitqueue_head(&bat_priv->debug_log->queue_wait);
+
+	d =3D debugfs_create_file("log", S_IFREG | S_IRUSR,
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
+	bat_priv->debug_log =3D NULL;
+}
+#else /* CONFIG_BATMAN_ADV_DEBUG */
+static int debug_log_setup(struct bat_priv *bat_priv)
+{
+	bat_priv->debug_log =3D NULL;
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
+	struct net_device *net_dev =3D (struct net_device *)inode->i_private;
+	return single_open(file, orig_seq_print_text, net_dev);
+}
+
+static int gateways_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev =3D (struct net_device *)inode->i_private;
+	return single_open(file, gw_client_seq_print_text, net_dev);
+}
+
+static int softif_neigh_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev =3D (struct net_device *)inode->i_private;
+	return single_open(file, softif_neigh_seq_print_text, net_dev);
+}
+
+static int transtable_global_open(struct inode *inode, struct file *file=
)
+{
+	struct net_device *net_dev =3D (struct net_device *)inode->i_private;
+	return single_open(file, hna_global_seq_print_text, net_dev);
+}
+
+static int transtable_local_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev =3D (struct net_device *)inode->i_private;
+	return single_open(file, hna_local_seq_print_text, net_dev);
+}
+
+static int vis_data_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev =3D (struct net_device *)inode->i_private;
+	return single_open(file, vis_seq_print_text, net_dev);
+}
+
+struct bat_debuginfo {
+	struct attribute attr;
+	const struct file_operations fops;
+};
+
+#define BAT_DEBUGINFO(_name, _mode, _open)	\
+struct bat_debuginfo bat_debuginfo_##_name =3D {	\
+	.attr =3D { .name =3D __stringify(_name),	\
+		  .mode =3D _mode, },		\
+	.fops =3D { .owner =3D THIS_MODULE,		\
+		  .open =3D _open,		\
+		  .read	=3D seq_read,		\
+		  .llseek =3D seq_lseek,		\
+		  .release =3D single_release,	\
+		}				\
+};
+
+static BAT_DEBUGINFO(originators, S_IRUGO, originators_open);
+static BAT_DEBUGINFO(gateways, S_IRUGO, gateways_open);
+static BAT_DEBUGINFO(softif_neigh, S_IRUGO, softif_neigh_open);
+static BAT_DEBUGINFO(transtable_global, S_IRUGO, transtable_global_open)=
;
+static BAT_DEBUGINFO(transtable_local, S_IRUGO, transtable_local_open);
+static BAT_DEBUGINFO(vis_data, S_IRUGO, vis_data_open);
+
+static struct bat_debuginfo *mesh_debuginfos[] =3D {
+	&bat_debuginfo_originators,
+	&bat_debuginfo_gateways,
+	&bat_debuginfo_softif_neigh,
+	&bat_debuginfo_transtable_global,
+	&bat_debuginfo_transtable_local,
+	&bat_debuginfo_vis_data,
+	NULL,
+};
+
+void debugfs_init(void)
+{
+	bat_debugfs =3D debugfs_create_dir(DEBUGFS_BAT_SUBDIR, NULL);
+	if (bat_debugfs =3D=3D ERR_PTR(-ENODEV))
+		bat_debugfs =3D NULL;
+}
+
+void debugfs_destroy(void)
+{
+	if (bat_debugfs) {
+		debugfs_remove_recursive(bat_debugfs);
+		bat_debugfs =3D NULL;
+	}
+}
+
+int debugfs_add_meshif(struct net_device *dev)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct bat_debuginfo **bat_debug;
+	struct dentry *file;
+
+	if (!bat_debugfs)
+		goto out;
+
+	bat_priv->debug_dir =3D debugfs_create_dir(dev->name, bat_debugfs);
+	if (!bat_priv->debug_dir)
+		goto out;
+
+	bat_socket_setup(bat_priv);
+	debug_log_setup(bat_priv);
+
+	for (bat_debug =3D mesh_debuginfos; *bat_debug; ++bat_debug) {
+		file =3D debugfs_create_file(((*bat_debug)->attr).name,
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
+	bat_priv->debug_dir =3D NULL;
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
+	struct bat_priv *bat_priv =3D netdev_priv(dev);
+
+	debug_log_cleanup(bat_priv);
+
+	if (bat_debugfs) {
+		debugfs_remove_recursive(bat_priv->debug_dir);
+		bat_priv->debug_dir =3D NULL;
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
index 0000000..cd7bb51
--- /dev/null
+++ b/net/batman-adv/bat_sysfs.c
@@ -0,0 +1,593 @@
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
+#include "gateway_common.h"
+#include "gateway_client.h"
+#include "vis.h"
+
+#define to_dev(obj)		container_of(obj, struct device, kobj)
+#define kobj_to_netdev(obj)	to_net_dev(to_dev(obj->parent))
+#define kobj_to_batpriv(obj)	netdev_priv(kobj_to_netdev(obj))
+
+/* Use this, if you have customized show and store functions */
+#define BAT_ATTR(_name, _mode, _show, _store)	\
+struct bat_attribute bat_attr_##_name =3D {	\
+	.attr =3D {.name =3D __stringify(_name),	\
+		 .mode =3D _mode },		\
+	.show   =3D _show,			\
+	.store  =3D _store,			\
+};
+
+#define BAT_ATTR_STORE_BOOL(_name, _post_func)				\
+ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
+		      char *buff, size_t count)				\
+{									\
+	struct net_device *net_dev =3D kobj_to_netdev(kobj);		\
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);		\
+	return __store_bool_attr(buff, count, _post_func, attr,		\
+				 &bat_priv->_name, net_dev);		\
+}
+
+#define BAT_ATTR_SHOW_BOOL(_name)					\
+ssize_t show_##_name(struct kobject *kobj, struct attribute *attr,	\
+			    char *buff)					\
+{									\
+	struct bat_priv *bat_priv =3D kobj_to_batpriv(kobj);		\
+	return sprintf(buff, "%s\n",					\
+		       atomic_read(&bat_priv->_name) =3D=3D 0 ?		\
+		       "disabled" : "enabled");				\
+}									\
+
+/* Use this, if you are going to turn a [name] in bat_priv on or off */
+#define BAT_ATTR_BOOL(_name, _mode, _post_func)				\
+	static BAT_ATTR_STORE_BOOL(_name, _post_func)			\
+	static BAT_ATTR_SHOW_BOOL(_name)				\
+	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
+
+
+#define BAT_ATTR_STORE_UINT(_name, _min, _max, _post_func)		\
+ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
+			     char *buff, size_t count)			\
+{									\
+	struct net_device *net_dev =3D kobj_to_netdev(kobj);		\
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);		\
+	return __store_uint_attr(buff, count, _min, _max, _post_func,	\
+				 attr, &bat_priv->_name, net_dev);	\
+}
+
+#define BAT_ATTR_SHOW_UINT(_name)					\
+ssize_t show_##_name(struct kobject *kobj, struct attribute *attr,	\
+			    char *buff)					\
+{									\
+	struct bat_priv *bat_priv =3D kobj_to_batpriv(kobj);		\
+	return sprintf(buff, "%i\n", atomic_read(&bat_priv->_name));	\
+}									\
+
+/* Use this, if you are going to set [name] in bat_priv to unsigned inte=
ger
+ * values only */
+#define BAT_ATTR_UINT(_name, _mode, _min, _max, _post_func)		\
+	static BAT_ATTR_STORE_UINT(_name, _min, _max, _post_func)	\
+	static BAT_ATTR_SHOW_UINT(_name)				\
+	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
+
+
+static int store_bool_attr(char *buff, size_t count,
+			   struct net_device *net_dev,
+			   char *attr_name, atomic_t *attr)
+{
+	int enabled =3D -1;
+
+	if (buff[count - 1] =3D=3D '\n')
+		buff[count - 1] =3D '\0';
+
+	if ((strncmp(buff, "1", 2) =3D=3D 0) ||
+	    (strncmp(buff, "enable", 7) =3D=3D 0) ||
+	    (strncmp(buff, "enabled", 8) =3D=3D 0))
+		enabled =3D 1;
+
+	if ((strncmp(buff, "0", 2) =3D=3D 0) ||
+	    (strncmp(buff, "disable", 8) =3D=3D 0) ||
+	    (strncmp(buff, "disabled", 9) =3D=3D 0))
+		enabled =3D 0;
+
+	if (enabled < 0) {
+		bat_info(net_dev,
+			 "%s: Invalid parameter received: %s\n",
+			 attr_name, buff);
+		return -EINVAL;
+	}
+
+	if (atomic_read(attr) =3D=3D enabled)
+		return count;
+
+	bat_info(net_dev, "%s: Changing from: %s to: %s\n", attr_name,
+		 atomic_read(attr) =3D=3D 1 ? "enabled" : "disabled",
+		 enabled =3D=3D 1 ? "enabled" : "disabled");
+
+	atomic_set(attr, (unsigned)enabled);
+	return count;
+}
+
+static inline ssize_t __store_bool_attr(char *buff, size_t count,
+			void (*post_func)(struct net_device *),
+			struct attribute *attr,
+			atomic_t *attr_store, struct net_device *net_dev)
+{
+	int ret;
+
+	ret =3D store_bool_attr(buff, count, net_dev, (char *)attr->name,
+			      attr_store);
+	if (post_func && ret)
+		post_func(net_dev);
+
+	return ret;
+}
+
+static int store_uint_attr(char *buff, size_t count,
+			   struct net_device *net_dev, char *attr_name,
+			   unsigned int min, unsigned int max, atomic_t *attr)
+{
+	unsigned long uint_val;
+	int ret;
+
+	ret =3D strict_strtoul(buff, 10, &uint_val);
+	if (ret) {
+		bat_info(net_dev,
+			 "%s: Invalid parameter received: %s\n",
+			 attr_name, buff);
+		return -EINVAL;
+	}
+
+	if (uint_val < min) {
+		bat_info(net_dev, "%s: Value is too small: %lu min: %u\n",
+			 attr_name, uint_val, min);
+		return -EINVAL;
+	}
+
+	if (uint_val > max) {
+		bat_info(net_dev, "%s: Value is too big: %lu max: %u\n",
+			 attr_name, uint_val, max);
+		return -EINVAL;
+	}
+
+	if (atomic_read(attr) =3D=3D uint_val)
+		return count;
+
+	bat_info(net_dev, "%s: Changing from: %i to: %lu\n",
+		 attr_name, atomic_read(attr), uint_val);
+
+	atomic_set(attr, uint_val);
+	return count;
+}
+
+static inline ssize_t __store_uint_attr(char *buff, size_t count,
+			int min, int max,
+			void (*post_func)(struct net_device *),
+			struct attribute *attr,
+			atomic_t *attr_store, struct net_device *net_dev)
+{
+	int ret;
+
+	ret =3D store_uint_attr(buff, count, net_dev, (char *)attr->name,
+			      min, max, attr_store);
+	if (post_func && ret)
+		post_func(net_dev);
+
+	return ret;
+}
+
+static ssize_t show_vis_mode(struct kobject *kobj, struct attribute *att=
r,
+			     char *buff)
+{
+	struct bat_priv *bat_priv =3D kobj_to_batpriv(kobj);
+	int vis_mode =3D atomic_read(&bat_priv->vis_mode);
+
+	return sprintf(buff, "%s\n",
+		       vis_mode =3D=3D VIS_TYPE_CLIENT_UPDATE ?
+							"client" : "server");
+}
+
+static ssize_t store_vis_mode(struct kobject *kobj, struct attribute *at=
tr,
+			      char *buff, size_t count)
+{
+	struct net_device *net_dev =3D kobj_to_netdev(kobj);
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	unsigned long val;
+	int ret, vis_mode_tmp =3D -1;
+
+	ret =3D strict_strtoul(buff, 10, &val);
+
+	if (((count =3D=3D 2) && (!ret) && (val =3D=3D VIS_TYPE_CLIENT_UPDATE))=
 ||
+	    (strncmp(buff, "client", 6) =3D=3D 0) ||
+	    (strncmp(buff, "off", 3) =3D=3D 0))
+		vis_mode_tmp =3D VIS_TYPE_CLIENT_UPDATE;
+
+	if (((count =3D=3D 2) && (!ret) && (val =3D=3D VIS_TYPE_SERVER_SYNC)) |=
|
+	    (strncmp(buff, "server", 6) =3D=3D 0))
+		vis_mode_tmp =3D VIS_TYPE_SERVER_SYNC;
+
+	if (vis_mode_tmp < 0) {
+		if (buff[count - 1] =3D=3D '\n')
+			buff[count - 1] =3D '\0';
+
+		bat_info(net_dev,
+			 "Invalid parameter for 'vis mode' setting received: "
+			 "%s\n", buff);
+		return -EINVAL;
+	}
+
+	if (atomic_read(&bat_priv->vis_mode) =3D=3D vis_mode_tmp)
+		return count;
+
+	bat_info(net_dev, "Changing vis mode from: %s to: %s\n",
+		 atomic_read(&bat_priv->vis_mode) =3D=3D VIS_TYPE_CLIENT_UPDATE ?
+		 "client" : "server", vis_mode_tmp =3D=3D VIS_TYPE_CLIENT_UPDATE ?
+		 "client" : "server");
+
+	atomic_set(&bat_priv->vis_mode, (unsigned)vis_mode_tmp);
+	return count;
+}
+
+static void post_gw_deselect(struct net_device *net_dev)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	gw_deselect(bat_priv);
+}
+
+static ssize_t show_gw_mode(struct kobject *kobj, struct attribute *attr=
,
+			    char *buff)
+{
+	struct bat_priv *bat_priv =3D kobj_to_batpriv(kobj);
+	int bytes_written;
+
+	switch (atomic_read(&bat_priv->gw_mode)) {
+	case GW_MODE_CLIENT:
+		bytes_written =3D sprintf(buff, "%s\n", GW_MODE_CLIENT_NAME);
+		break;
+	case GW_MODE_SERVER:
+		bytes_written =3D sprintf(buff, "%s\n", GW_MODE_SERVER_NAME);
+		break;
+	default:
+		bytes_written =3D sprintf(buff, "%s\n", GW_MODE_OFF_NAME);
+		break;
+	}
+
+	return bytes_written;
+}
+
+static ssize_t store_gw_mode(struct kobject *kobj, struct attribute *att=
r,
+			     char *buff, size_t count)
+{
+	struct net_device *net_dev =3D kobj_to_netdev(kobj);
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	char *curr_gw_mode_str;
+	int gw_mode_tmp =3D -1;
+
+	if (buff[count - 1] =3D=3D '\n')
+		buff[count - 1] =3D '\0';
+
+	if (strncmp(buff, GW_MODE_OFF_NAME, strlen(GW_MODE_OFF_NAME)) =3D=3D 0)
+		gw_mode_tmp =3D GW_MODE_OFF;
+
+	if (strncmp(buff, GW_MODE_CLIENT_NAME,
+		   strlen(GW_MODE_CLIENT_NAME)) =3D=3D 0)
+		gw_mode_tmp =3D GW_MODE_CLIENT;
+
+	if (strncmp(buff, GW_MODE_SERVER_NAME,
+		   strlen(GW_MODE_SERVER_NAME)) =3D=3D 0)
+		gw_mode_tmp =3D GW_MODE_SERVER;
+
+	if (gw_mode_tmp < 0) {
+		bat_info(net_dev,
+			 "Invalid parameter for 'gw mode' setting received: "
+			 "%s\n", buff);
+		return -EINVAL;
+	}
+
+	if (atomic_read(&bat_priv->gw_mode) =3D=3D gw_mode_tmp)
+		return count;
+
+	switch (atomic_read(&bat_priv->gw_mode)) {
+	case GW_MODE_CLIENT:
+		curr_gw_mode_str =3D GW_MODE_CLIENT_NAME;
+		break;
+	case GW_MODE_SERVER:
+		curr_gw_mode_str =3D GW_MODE_SERVER_NAME;
+		break;
+	default:
+		curr_gw_mode_str =3D GW_MODE_OFF_NAME;
+		break;
+	}
+
+	bat_info(net_dev, "Changing gw mode from: %s to: %s\n",
+		 curr_gw_mode_str, buff);
+
+	gw_deselect(bat_priv);
+	atomic_set(&bat_priv->gw_mode, (unsigned)gw_mode_tmp);
+	return count;
+}
+
+static ssize_t show_gw_bwidth(struct kobject *kobj, struct attribute *at=
tr,
+			      char *buff)
+{
+	struct bat_priv *bat_priv =3D kobj_to_batpriv(kobj);
+	int down, up;
+	int gw_bandwidth =3D atomic_read(&bat_priv->gw_bandwidth);
+
+	gw_bandwidth_to_kbit(gw_bandwidth, &down, &up);
+	return sprintf(buff, "%i%s/%i%s\n",
+		       (down > 2048 ? down / 1024 : down),
+		       (down > 2048 ? "MBit" : "KBit"),
+		       (up > 2048 ? up / 1024 : up),
+		       (up > 2048 ? "MBit" : "KBit"));
+}
+
+static ssize_t store_gw_bwidth(struct kobject *kobj, struct attribute *a=
ttr,
+			       char *buff, size_t count)
+{
+	struct net_device *net_dev =3D kobj_to_netdev(kobj);
+
+	if (buff[count - 1] =3D=3D '\n')
+		buff[count - 1] =3D '\0';
+
+	return gw_bandwidth_set(net_dev, buff, count);
+}
+
+BAT_ATTR_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
+BAT_ATTR_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
+BAT_ATTR_BOOL(fragmentation, S_IRUGO | S_IWUSR, update_min_mtu);
+static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, show_vis_mode, store_vis_mo=
de);
+static BAT_ATTR(gw_mode, S_IRUGO | S_IWUSR, show_gw_mode, store_gw_mode)=
;
+BAT_ATTR_UINT(orig_interval, S_IRUGO | S_IWUSR, 2 * JITTER, INT_MAX, NUL=
L);
+BAT_ATTR_UINT(hop_penalty, S_IRUGO | S_IWUSR, 0, TQ_MAX_VALUE, NULL);
+BAT_ATTR_UINT(gw_sel_class, S_IRUGO | S_IWUSR, 1, TQ_MAX_VALUE,
+	      post_gw_deselect);
+static BAT_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, show_gw_bwidth,
+		store_gw_bwidth);
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 3, NULL);
+#endif
+
+static struct bat_attribute *mesh_attrs[] =3D {
+	&bat_attr_aggregated_ogms,
+	&bat_attr_bonding,
+	&bat_attr_fragmentation,
+	&bat_attr_vis_mode,
+	&bat_attr_gw_mode,
+	&bat_attr_orig_interval,
+	&bat_attr_hop_penalty,
+	&bat_attr_gw_sel_class,
+	&bat_attr_gw_bandwidth,
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+	&bat_attr_log_level,
+#endif
+	NULL,
+};
+
+int sysfs_add_meshif(struct net_device *dev)
+{
+	struct kobject *batif_kobject =3D &dev->dev.kobj;
+	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct bat_attribute **bat_attr;
+	int err;
+
+	bat_priv->mesh_obj =3D kobject_create_and_add(SYSFS_IF_MESH_SUBDIR,
+						    batif_kobject);
+	if (!bat_priv->mesh_obj) {
+		bat_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
+			SYSFS_IF_MESH_SUBDIR);
+		goto out;
+	}
+
+	for (bat_attr =3D mesh_attrs; *bat_attr; ++bat_attr) {
+		err =3D sysfs_create_file(bat_priv->mesh_obj,
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
+	for (bat_attr =3D mesh_attrs; *bat_attr; ++bat_attr)
+		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
+
+	kobject_put(bat_priv->mesh_obj);
+	bat_priv->mesh_obj =3D NULL;
+out:
+	return -ENOMEM;
+}
+
+void sysfs_del_meshif(struct net_device *dev)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct bat_attribute **bat_attr;
+
+	for (bat_attr =3D mesh_attrs; *bat_attr; ++bat_attr)
+		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
+
+	kobject_put(bat_priv->mesh_obj);
+	bat_priv->mesh_obj =3D NULL;
+}
+
+static ssize_t show_mesh_iface(struct kobject *kobj, struct attribute *a=
ttr,
+			       char *buff)
+{
+	struct net_device *net_dev =3D kobj_to_netdev(kobj);
+	struct batman_if *batman_if =3D get_batman_if_by_netdev(net_dev);
+	ssize_t length;
+
+	if (!batman_if)
+		return 0;
+
+	length =3D sprintf(buff, "%s\n", batman_if->if_status =3D=3D IF_NOT_IN_=
USE ?
+			 "none" : batman_if->soft_iface->name);
+
+	kref_put(&batman_if->refcount, hardif_free_ref);
+
+	return length;
+}
+
+static ssize_t store_mesh_iface(struct kobject *kobj, struct attribute *=
attr,
+				char *buff, size_t count)
+{
+	struct net_device *net_dev =3D kobj_to_netdev(kobj);
+	struct batman_if *batman_if =3D get_batman_if_by_netdev(net_dev);
+	int status_tmp =3D -1;
+	int ret;
+
+	if (!batman_if)
+		return count;
+
+	if (buff[count - 1] =3D=3D '\n')
+		buff[count - 1] =3D '\0';
+
+	if (strlen(buff) >=3D IFNAMSIZ) {
+		pr_err("Invalid parameter for 'mesh_iface' setting received: "
+		       "interface name too long '%s'\n", buff);
+		kref_put(&batman_if->refcount, hardif_free_ref);
+		return -EINVAL;
+	}
+
+	if (strncmp(buff, "none", 4) =3D=3D 0)
+		status_tmp =3D IF_NOT_IN_USE;
+	else
+		status_tmp =3D IF_I_WANT_YOU;
+
+	if ((batman_if->if_status =3D=3D status_tmp) || ((batman_if->soft_iface=
) &&
+	    (strncmp(batman_if->soft_iface->name, buff, IFNAMSIZ) =3D=3D 0))) {
+		kref_put(&batman_if->refcount, hardif_free_ref);
+		return count;
+	}
+
+	if (status_tmp =3D=3D IF_NOT_IN_USE) {
+		rtnl_lock();
+		hardif_disable_interface(batman_if);
+		rtnl_unlock();
+		kref_put(&batman_if->refcount, hardif_free_ref);
+		return count;
+	}
+
+	/* if the interface already is in use */
+	if (batman_if->if_status !=3D IF_NOT_IN_USE) {
+		rtnl_lock();
+		hardif_disable_interface(batman_if);
+		rtnl_unlock();
+	}
+
+	ret =3D hardif_enable_interface(batman_if, buff);
+	kref_put(&batman_if->refcount, hardif_free_ref);
+
+	return ret;
+}
+
+static ssize_t show_iface_status(struct kobject *kobj, struct attribute =
*attr,
+				 char *buff)
+{
+	struct net_device *net_dev =3D kobj_to_netdev(kobj);
+	struct batman_if *batman_if =3D get_batman_if_by_netdev(net_dev);
+	ssize_t length;
+
+	if (!batman_if)
+		return 0;
+
+	switch (batman_if->if_status) {
+	case IF_TO_BE_REMOVED:
+		length =3D sprintf(buff, "disabling\n");
+		break;
+	case IF_INACTIVE:
+		length =3D sprintf(buff, "inactive\n");
+		break;
+	case IF_ACTIVE:
+		length =3D sprintf(buff, "active\n");
+		break;
+	case IF_TO_BE_ACTIVATED:
+		length =3D sprintf(buff, "enabling\n");
+		break;
+	case IF_NOT_IN_USE:
+	default:
+		length =3D sprintf(buff, "not in use\n");
+		break;
+	}
+
+	kref_put(&batman_if->refcount, hardif_free_ref);
+
+	return length;
+}
+
+static BAT_ATTR(mesh_iface, S_IRUGO | S_IWUSR,
+		show_mesh_iface, store_mesh_iface);
+static BAT_ATTR(iface_status, S_IRUGO, show_iface_status, NULL);
+
+static struct bat_attribute *batman_attrs[] =3D {
+	&bat_attr_mesh_iface,
+	&bat_attr_iface_status,
+	NULL,
+};
+
+int sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev=
)
+{
+	struct kobject *hardif_kobject =3D &dev->dev.kobj;
+	struct bat_attribute **bat_attr;
+	int err;
+
+	*hardif_obj =3D kobject_create_and_add(SYSFS_IF_BAT_SUBDIR,
+						    hardif_kobject);
+
+	if (!*hardif_obj) {
+		bat_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
+			SYSFS_IF_BAT_SUBDIR);
+		goto out;
+	}
+
+	for (bat_attr =3D batman_attrs; *bat_attr; ++bat_attr) {
+		err =3D sysfs_create_file(*hardif_obj, &((*bat_attr)->attr));
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
+	for (bat_attr =3D batman_attrs; *bat_attr; ++bat_attr)
+		sysfs_remove_file(*hardif_obj, &((*bat_attr)->attr));
+out:
+	return -ENOMEM;
+}
+
+void sysfs_del_hardif(struct kobject **hardif_obj)
+{
+	kobject_put(*hardif_obj);
+	*hardif_obj =3D NULL;
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
+int sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev=
);
+void sysfs_del_hardif(struct kobject **hardif_obj);
+
+#endif /* _NET_BATMAN_ADV_SYSFS_H_ */
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
new file mode 100644
index 0000000..bbcd8f7
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
+/* returns true if the corresponding bit in the given seq_bits indicates=
 true
+ * and curr_seqno is within range of last_seqno */
+uint8_t get_bit_status(unsigned long *seq_bits, uint32_t last_seqno,
+		       uint32_t curr_seqno)
+{
+	int32_t diff, word_offset, word_num;
+
+	diff =3D last_seqno - curr_seqno;
+	if (diff < 0 || diff >=3D TQ_LOCAL_WINDOW_SIZE) {
+		return 0;
+	} else {
+		/* which word */
+		word_num =3D (last_seqno - curr_seqno) / WORD_BIT_SIZE;
+		/* which position in the selected word */
+		word_offset =3D (last_seqno - curr_seqno) % WORD_BIT_SIZE;
+
+		if (test_bit(word_offset, &seq_bits[word_num]))
+			return 1;
+		else
+			return 0;
+	}
+}
+
+/* turn corresponding bit on, so we can remember that we got the packet =
*/
+void bit_mark(unsigned long *seq_bits, int32_t n)
+{
+	int32_t word_offset, word_num;
+
+	/* if too old, just drop it */
+	if (n < 0 || n >=3D TQ_LOCAL_WINDOW_SIZE)
+		return;
+
+	/* which word */
+	word_num =3D n / WORD_BIT_SIZE;
+	/* which position in the selected word */
+	word_offset =3D n % WORD_BIT_SIZE;
+
+	set_bit(word_offset, &seq_bits[word_num]); /* turn the position on */
+}
+
+/* shift the packet array by n places. */
+static void bit_shift(unsigned long *seq_bits, int32_t n)
+{
+	int32_t word_offset, word_num;
+	int32_t i;
+
+	if (n <=3D 0 || n >=3D TQ_LOCAL_WINDOW_SIZE)
+		return;
+
+	word_offset =3D n % WORD_BIT_SIZE;/* shift how much inside each word */
+	word_num =3D n / WORD_BIT_SIZE;	/* shift over how much (full) words */
+
+	for (i =3D NUM_WORDS - 1; i > word_num; i--) {
+		/* going from old to new, so we don't overwrite the data we copy
+		 * from.
+		 *
+		 * left is high, right is low: FEDC BA98 7654 3210
+		 *					  ^^ ^^
+		 *			       vvvv
+		 * ^^^^ =3D from, vvvvv =3Dto, we'd have word_num=3D=3D1 and
+		 * word_offset=3D=3DWORD_BIT_SIZE/2 ????? in this example.
+		 * (=3D24 bits)
+		 *
+		 * our desired output would be: 9876 5432 1000 0000
+		 * */
+
+		seq_bits[i] =3D
+			(seq_bits[i - word_num] << word_offset) +
+			/* take the lower port from the left half, shift it left
+			 * to its final position */
+			(seq_bits[i - word_num - 1] >>
+			 (WORD_BIT_SIZE-word_offset));
+		/* and the upper part of the right half and shift it left to
+		 * it's position */
+		/* for our example that would be: word[0] =3D 9800 + 0076 =3D
+		 * 9876 */
+	}
+	/* now for our last word, i=3D=3Dword_num, we only have the it's "left"
+	 * half. that's the 1000 word in our example.*/
+
+	seq_bits[i] =3D (seq_bits[i - word_num] << word_offset);
+
+	/* pad the rest with 0, if there is anything */
+	i--;
+
+	for (; i >=3D 0; i--)
+		seq_bits[i] =3D 0;
+}
+
+static void bit_reset_window(unsigned long *seq_bits)
+{
+	int i;
+	for (i =3D 0; i < NUM_WORDS; i++)
+		seq_bits[i] =3D 0;
+}
+
+
+/* receive and process one packet within the sequence number window.
+ *
+ * returns:
+ *  1 if the window was moved (either new or very old)
+ *  0 if the window was not moved/shifted.
+ */
+char bit_get_packet(void *priv, unsigned long *seq_bits,
+		    int32_t seq_num_diff, int8_t set_mark)
+{
+	struct bat_priv *bat_priv =3D (struct bat_priv *)priv;
+
+	/* sequence number is slightly older. We already got a sequence number
+	 * higher than this one, so we just mark it. */
+
+	if ((seq_num_diff <=3D 0) && (seq_num_diff > -TQ_LOCAL_WINDOW_SIZE)) {
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
+	if ((seq_num_diff >=3D TQ_LOCAL_WINDOW_SIZE)
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
+	if ((seq_num_diff <=3D -TQ_LOCAL_WINDOW_SIZE)
+		|| (seq_num_diff >=3D EXPECTED_SEQNO_RANGE)) {
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
+/* count the hamming weight, how many good packets did we receive? just =
count
+ * the 1's.
+ */
+int bit_packet_count(unsigned long *seq_bits)
+{
+	int i, hamming =3D 0;
+
+	for (i =3D 0; i < NUM_WORDS; i++)
+		hamming +=3D hweight_long(seq_bits[i]);
+
+	return hamming;
+}
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
new file mode 100644
index 0000000..ac54017
--- /dev/null
+++ b/net/batman-adv/bitarray.h
@@ -0,0 +1,44 @@
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
+#define WORD_BIT_SIZE (sizeof(unsigned long) * 8)
+
+/* returns true if the corresponding bit in the given seq_bits indicates=
 true
+ * and curr_seqno is within range of last_seqno */
+uint8_t get_bit_status(unsigned long *seq_bits, uint32_t last_seqno,
+					   uint32_t curr_seqno);
+
+/* turn corresponding bit on, so we can remember that we got the packet =
*/
+void bit_mark(unsigned long *seq_bits, int32_t n);
+
+
+/* receive and process one packet, returns 1 if received seq_num is cons=
idered
+ * new, 0 if old  */
+char bit_get_packet(void *priv, unsigned long *seq_bits,
+		    int32_t seq_num_diff, int8_t set_mark);
+
+/* count the hamming weight, how many good packets did we receive? */
+int  bit_packet_count(unsigned long *seq_bits);
+
+#endif /* _NET_BATMAN_ADV_BITARRAY_H_ */
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_cli=
ent.c
new file mode 100644
index 0000000..0065ffb
--- /dev/null
+++ b/net/batman-adv/gateway_client.c
@@ -0,0 +1,477 @@
+/*
+ * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
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
+#include "gateway_client.h"
+#include "gateway_common.h"
+#include "hard-interface.h"
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/udp.h>
+#include <linux/if_vlan.h>
+
+static void gw_node_free_ref(struct kref *refcount)
+{
+	struct gw_node *gw_node;
+
+	gw_node =3D container_of(refcount, struct gw_node, refcount);
+	kfree(gw_node);
+}
+
+static void gw_node_free_rcu(struct rcu_head *rcu)
+{
+	struct gw_node *gw_node;
+
+	gw_node =3D container_of(rcu, struct gw_node, rcu);
+	kref_put(&gw_node->refcount, gw_node_free_ref);
+}
+
+void *gw_get_selected(struct bat_priv *bat_priv)
+{
+	struct gw_node *curr_gateway_tmp =3D bat_priv->curr_gw;
+
+	if (!curr_gateway_tmp)
+		return NULL;
+
+	return curr_gateway_tmp->orig_node;
+}
+
+void gw_deselect(struct bat_priv *bat_priv)
+{
+	struct gw_node *gw_node =3D bat_priv->curr_gw;
+
+	bat_priv->curr_gw =3D NULL;
+
+	if (gw_node)
+		kref_put(&gw_node->refcount, gw_node_free_ref);
+}
+
+static struct gw_node *gw_select(struct bat_priv *bat_priv,
+			  struct gw_node *new_gw_node)
+{
+	struct gw_node *curr_gw_node =3D bat_priv->curr_gw;
+
+	if (new_gw_node)
+		kref_get(&new_gw_node->refcount);
+
+	bat_priv->curr_gw =3D new_gw_node;
+	return curr_gw_node;
+}
+
+void gw_election(struct bat_priv *bat_priv)
+{
+	struct hlist_node *node;
+	struct gw_node *gw_node, *curr_gw_tmp =3D NULL, *old_gw_node =3D NULL;
+	uint8_t max_tq =3D 0;
+	uint32_t max_gw_factor =3D 0, tmp_gw_factor =3D 0;
+	int down, up;
+
+	/**
+	 * The batman daemon checks here if we already passed a full originator
+	 * cycle in order to make sure we don't choose the first gateway we
+	 * hear about. This check is based on the daemon's uptime which we
+	 * don't have.
+	 **/
+	if (atomic_read(&bat_priv->gw_mode) !=3D GW_MODE_CLIENT)
+		return;
+
+	if (bat_priv->curr_gw)
+		return;
+
+	rcu_read_lock();
+	if (hlist_empty(&bat_priv->gw_list)) {
+		rcu_read_unlock();
+
+		if (bat_priv->curr_gw) {
+			bat_dbg(DBG_BATMAN, bat_priv,
+				"Removing selected gateway - "
+				"no gateway in range\n");
+			gw_deselect(bat_priv);
+		}
+
+		return;
+	}
+
+	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
+		if (!gw_node->orig_node->router)
+			continue;
+
+		if (gw_node->deleted)
+			continue;
+
+		switch (atomic_read(&bat_priv->gw_sel_class)) {
+		case 1: /* fast connection */
+			gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags,
+					     &down, &up);
+
+			tmp_gw_factor =3D (gw_node->orig_node->router->tq_avg *
+					 gw_node->orig_node->router->tq_avg *
+					 down * 100 * 100) /
+					 (TQ_LOCAL_WINDOW_SIZE *
+					 TQ_LOCAL_WINDOW_SIZE * 64);
+
+			if ((tmp_gw_factor > max_gw_factor) ||
+			    ((tmp_gw_factor =3D=3D max_gw_factor) &&
+			     (gw_node->orig_node->router->tq_avg > max_tq)))
+				curr_gw_tmp =3D gw_node;
+			break;
+
+		default: /**
+			  * 2:  stable connection (use best statistic)
+			  * 3:  fast-switch (use best statistic but change as
+			  *     soon as a better gateway appears)
+			  * XX: late-switch (use best statistic but change as
+			  *     soon as a better gateway appears which has
+			  *     $routing_class more tq points)
+			  **/
+			if (gw_node->orig_node->router->tq_avg > max_tq)
+				curr_gw_tmp =3D gw_node;
+			break;
+		}
+
+		if (gw_node->orig_node->router->tq_avg > max_tq)
+			max_tq =3D gw_node->orig_node->router->tq_avg;
+
+		if (tmp_gw_factor > max_gw_factor)
+			max_gw_factor =3D tmp_gw_factor;
+	}
+
+	if (bat_priv->curr_gw !=3D curr_gw_tmp) {
+		if ((bat_priv->curr_gw) && (!curr_gw_tmp))
+			bat_dbg(DBG_BATMAN, bat_priv,
+				"Removing selected gateway - "
+				"no gateway in range\n");
+		else if ((!bat_priv->curr_gw) && (curr_gw_tmp))
+			bat_dbg(DBG_BATMAN, bat_priv,
+				"Adding route to gateway %pM "
+				"(gw_flags: %i, tq: %i)\n",
+				curr_gw_tmp->orig_node->orig,
+				curr_gw_tmp->orig_node->gw_flags,
+				curr_gw_tmp->orig_node->router->tq_avg);
+		else
+			bat_dbg(DBG_BATMAN, bat_priv,
+				"Changing route to gateway %pM "
+				"(gw_flags: %i, tq: %i)\n",
+				curr_gw_tmp->orig_node->orig,
+				curr_gw_tmp->orig_node->gw_flags,
+				curr_gw_tmp->orig_node->router->tq_avg);
+
+		old_gw_node =3D gw_select(bat_priv, curr_gw_tmp);
+	}
+
+	rcu_read_unlock();
+
+	/* the kfree() has to be outside of the rcu lock */
+	if (old_gw_node)
+		kref_put(&old_gw_node->refcount, gw_node_free_ref);
+}
+
+void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig=
_node)
+{
+	struct gw_node *curr_gateway_tmp =3D bat_priv->curr_gw;
+	uint8_t gw_tq_avg, orig_tq_avg;
+
+	if (!curr_gateway_tmp)
+		return;
+
+	if (!curr_gateway_tmp->orig_node)
+		goto deselect;
+
+	if (!curr_gateway_tmp->orig_node->router)
+		goto deselect;
+
+	/* this node already is the gateway */
+	if (curr_gateway_tmp->orig_node =3D=3D orig_node)
+		return;
+
+	if (!orig_node->router)
+		return;
+
+	gw_tq_avg =3D curr_gateway_tmp->orig_node->router->tq_avg;
+	orig_tq_avg =3D orig_node->router->tq_avg;
+
+	/* the TQ value has to be better */
+	if (orig_tq_avg < gw_tq_avg)
+		return;
+
+	/**
+	 * if the routing class is greater than 3 the value tells us how much
+	 * greater the TQ value of the new gateway must be
+	 **/
+	if ((atomic_read(&bat_priv->gw_sel_class) > 3) &&
+	    (orig_tq_avg - gw_tq_avg < atomic_read(&bat_priv->gw_sel_class)))
+		return;
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Restarting gateway selection: better gateway found (tq curr: "
+		"%i, tq new: %i)\n",
+		gw_tq_avg, orig_tq_avg);
+
+deselect:
+	gw_deselect(bat_priv);
+}
+
+static void gw_node_add(struct bat_priv *bat_priv,
+			struct orig_node *orig_node, uint8_t new_gwflags)
+{
+	struct gw_node *gw_node;
+	int down, up;
+
+	gw_node =3D kmalloc(sizeof(struct gw_node), GFP_ATOMIC);
+	if (!gw_node)
+		return;
+
+	memset(gw_node, 0, sizeof(struct gw_node));
+	INIT_HLIST_NODE(&gw_node->list);
+	gw_node->orig_node =3D orig_node;
+	kref_init(&gw_node->refcount);
+
+	spin_lock_bh(&bat_priv->gw_list_lock);
+	hlist_add_head_rcu(&gw_node->list, &bat_priv->gw_list);
+	spin_unlock_bh(&bat_priv->gw_list_lock);
+
+	gw_bandwidth_to_kbit(new_gwflags, &down, &up);
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Found new gateway %pM -> gw_class: %i - %i%s/%i%s\n",
+		orig_node->orig, new_gwflags,
+		(down > 2048 ? down / 1024 : down),
+		(down > 2048 ? "MBit" : "KBit"),
+		(up > 2048 ? up / 1024 : up),
+		(up > 2048 ? "MBit" : "KBit"));
+}
+
+void gw_node_update(struct bat_priv *bat_priv,
+		    struct orig_node *orig_node, uint8_t new_gwflags)
+{
+	struct hlist_node *node;
+	struct gw_node *gw_node;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
+		if (gw_node->orig_node !=3D orig_node)
+			continue;
+
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Gateway class of originator %pM changed from "
+			"%i to %i\n",
+			orig_node->orig, gw_node->orig_node->gw_flags,
+			new_gwflags);
+
+		gw_node->deleted =3D 0;
+
+		if (new_gwflags =3D=3D 0) {
+			gw_node->deleted =3D jiffies;
+			bat_dbg(DBG_BATMAN, bat_priv,
+				"Gateway %pM removed from gateway list\n",
+				orig_node->orig);
+
+			if (gw_node =3D=3D bat_priv->curr_gw) {
+				rcu_read_unlock();
+				gw_deselect(bat_priv);
+				return;
+			}
+		}
+
+		rcu_read_unlock();
+		return;
+	}
+	rcu_read_unlock();
+
+	if (new_gwflags =3D=3D 0)
+		return;
+
+	gw_node_add(bat_priv, orig_node, new_gwflags);
+}
+
+void gw_node_delete(struct bat_priv *bat_priv, struct orig_node *orig_no=
de)
+{
+	return gw_node_update(bat_priv, orig_node, 0);
+}
+
+void gw_node_purge(struct bat_priv *bat_priv)
+{
+	struct gw_node *gw_node;
+	struct hlist_node *node, *node_tmp;
+	unsigned long timeout =3D 2 * PURGE_TIMEOUT * HZ;
+
+	spin_lock_bh(&bat_priv->gw_list_lock);
+
+	hlist_for_each_entry_safe(gw_node, node, node_tmp,
+				  &bat_priv->gw_list, list) {
+		if (((!gw_node->deleted) ||
+		     (time_before(jiffies, gw_node->deleted + timeout))) &&
+		    atomic_read(&bat_priv->mesh_state) =3D=3D MESH_ACTIVE)
+			continue;
+
+		if (bat_priv->curr_gw =3D=3D gw_node)
+			gw_deselect(bat_priv);
+
+		hlist_del_rcu(&gw_node->list);
+		call_rcu(&gw_node->rcu, gw_node_free_rcu);
+	}
+
+
+	spin_unlock_bh(&bat_priv->gw_list_lock);
+}
+
+static int _write_buffer_text(struct bat_priv *bat_priv,
+			      struct seq_file *seq, struct gw_node *gw_node)
+{
+	int down, up;
+
+	gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags, &down, &up);
+
+	return seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %3i - %i%s/%i%s\n",
+		       (bat_priv->curr_gw =3D=3D gw_node ? "=3D>" : "  "),
+		       gw_node->orig_node->orig,
+		       gw_node->orig_node->router->tq_avg,
+		       gw_node->orig_node->router->addr,
+		       gw_node->orig_node->router->if_incoming->net_dev->name,
+		       gw_node->orig_node->gw_flags,
+		       (down > 2048 ? down / 1024 : down),
+		       (down > 2048 ? "MBit" : "KBit"),
+		       (up > 2048 ? up / 1024 : up),
+		       (up > 2048 ? "MBit" : "KBit"));
+}
+
+int gw_client_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev =3D (struct net_device *)seq->private;
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct gw_node *gw_node;
+	struct hlist_node *node;
+	int gw_count =3D 0;
+
+	if (!bat_priv->primary_if) {
+
+		return seq_printf(seq, "BATMAN mesh %s disabled - please "
+				  "specify interfaces to enable it\n",
+				  net_dev->name);
+	}
+
+	if (bat_priv->primary_if->if_status !=3D IF_ACTIVE) {
+
+		return seq_printf(seq, "BATMAN mesh %s disabled - "
+				       "primary interface not active\n",
+				       net_dev->name);
+	}
+
+	seq_printf(seq, "      %-12s (%s/%i) %17s [%10s]: gw_class ... "
+		   "[B.A.T.M.A.N. adv %s%s, MainIF/MAC: %s/%pM (%s)]\n",
+		   "Gateway", "#", TQ_MAX_VALUE, "Nexthop",
+		   "outgoingIF", SOURCE_VERSION, REVISION_VERSION_STR,
+		   bat_priv->primary_if->net_dev->name,
+		   bat_priv->primary_if->net_dev->dev_addr, net_dev->name);
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
+		if (gw_node->deleted)
+			continue;
+
+		if (!gw_node->orig_node->router)
+			continue;
+
+		_write_buffer_text(bat_priv, seq, gw_node);
+		gw_count++;
+	}
+	rcu_read_unlock();
+
+	if (gw_count =3D=3D 0)
+		seq_printf(seq, "No gateways in range ...\n");
+
+	return 0;
+}
+
+int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb)
+{
+	struct ethhdr *ethhdr;
+	struct iphdr *iphdr;
+	struct ipv6hdr *ipv6hdr;
+	struct udphdr *udphdr;
+	unsigned int header_len =3D 0;
+
+	if (atomic_read(&bat_priv->gw_mode) =3D=3D GW_MODE_OFF)
+		return 0;
+
+	/* check for ethernet header */
+	if (!pskb_may_pull(skb, header_len + ETH_HLEN))
+		return 0;
+	ethhdr =3D (struct ethhdr *)skb->data;
+	header_len +=3D ETH_HLEN;
+
+	/* check for initial vlan header */
+	if (ntohs(ethhdr->h_proto) =3D=3D ETH_P_8021Q) {
+		if (!pskb_may_pull(skb, header_len + VLAN_HLEN))
+			return 0;
+		ethhdr =3D (struct ethhdr *)(skb->data + VLAN_HLEN);
+		header_len +=3D VLAN_HLEN;
+	}
+
+	/* check for ip header */
+	switch (ntohs(ethhdr->h_proto)) {
+	case ETH_P_IP:
+		if (!pskb_may_pull(skb, header_len + sizeof(struct iphdr)))
+			return 0;
+		iphdr =3D (struct iphdr *)(skb->data + header_len);
+		header_len +=3D iphdr->ihl * 4;
+
+		/* check for udp header */
+		if (iphdr->protocol !=3D IPPROTO_UDP)
+			return 0;
+
+		break;
+	case ETH_P_IPV6:
+		if (!pskb_may_pull(skb, header_len + sizeof(struct ipv6hdr)))
+			return 0;
+		ipv6hdr =3D (struct ipv6hdr *)(skb->data + header_len);
+		header_len +=3D sizeof(struct ipv6hdr);
+
+		/* check for udp header */
+		if (ipv6hdr->nexthdr !=3D IPPROTO_UDP)
+			return 0;
+
+		break;
+	default:
+		return 0;
+	}
+
+	if (!pskb_may_pull(skb, header_len + sizeof(struct udphdr)))
+		return 0;
+	udphdr =3D (struct udphdr *)(skb->data + header_len);
+	header_len +=3D sizeof(struct udphdr);
+
+	/* check for bootp port */
+	if ((ntohs(ethhdr->h_proto) =3D=3D ETH_P_IP) &&
+	     (ntohs(udphdr->dest) !=3D 67))
+		return 0;
+
+	if ((ntohs(ethhdr->h_proto) =3D=3D ETH_P_IPV6) &&
+	    (ntohs(udphdr->dest) !=3D 547))
+		return 0;
+
+	if (atomic_read(&bat_priv->gw_mode) =3D=3D GW_MODE_SERVER)
+		return -1;
+
+	if (!bat_priv->curr_gw)
+		return 0;
+
+	return 1;
+}
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_cli=
ent.h
new file mode 100644
index 0000000..4585e65
--- /dev/null
+++ b/net/batman-adv/gateway_client.h
@@ -0,0 +1,36 @@
+/*
+ * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
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
+#ifndef _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
+#define _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
+
+void gw_deselect(struct bat_priv *bat_priv);
+void gw_election(struct bat_priv *bat_priv);
+void *gw_get_selected(struct bat_priv *bat_priv);
+void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig=
_node);
+void gw_node_update(struct bat_priv *bat_priv,
+		    struct orig_node *orig_node, uint8_t new_gwflags);
+void gw_node_delete(struct bat_priv *bat_priv, struct orig_node *orig_no=
de);
+void gw_node_purge(struct bat_priv *bat_priv);
+int gw_client_seq_print_text(struct seq_file *seq, void *offset);
+int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb);
+
+#endif /* _NET_BATMAN_ADV_GATEWAY_CLIENT_H_ */
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_com=
mon.c
new file mode 100644
index 0000000..b962982
--- /dev/null
+++ b/net/batman-adv/gateway_common.c
@@ -0,0 +1,177 @@
+/*
+ * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
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
+#include "gateway_common.h"
+#include "gateway_client.h"
+
+/* calculates the gateway class from kbit */
+static void kbit_to_gw_bandwidth(int down, int up, long *gw_srv_class)
+{
+	int mdown =3D 0, tdown, tup, difference;
+	uint8_t sbit, part;
+
+	*gw_srv_class =3D 0;
+	difference =3D 0x0FFFFFFF;
+
+	/* test all downspeeds */
+	for (sbit =3D 0; sbit < 2; sbit++) {
+		for (part =3D 0; part < 16; part++) {
+			tdown =3D 32 * (sbit + 2) * (1 << part);
+
+			if (abs(tdown - down) < difference) {
+				*gw_srv_class =3D (sbit << 7) + (part << 3);
+				difference =3D abs(tdown - down);
+				mdown =3D tdown;
+			}
+		}
+	}
+
+	/* test all upspeeds */
+	difference =3D 0x0FFFFFFF;
+
+	for (part =3D 0; part < 8; part++) {
+		tup =3D ((part + 1) * (mdown)) / 8;
+
+		if (abs(tup - up) < difference) {
+			*gw_srv_class =3D (*gw_srv_class & 0xF8) | part;
+			difference =3D abs(tup - up);
+		}
+	}
+}
+
+/* returns the up and downspeeds in kbit, calculated from the class */
+void gw_bandwidth_to_kbit(uint8_t gw_srv_class, int *down, int *up)
+{
+	char sbit =3D (gw_srv_class & 0x80) >> 7;
+	char dpart =3D (gw_srv_class & 0x78) >> 3;
+	char upart =3D (gw_srv_class & 0x07);
+
+	if (!gw_srv_class) {
+		*down =3D 0;
+		*up =3D 0;
+		return;
+	}
+
+	*down =3D 32 * (sbit + 2) * (1 << dpart);
+	*up =3D ((upart + 1) * (*down)) / 8;
+}
+
+static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
+			       long *up, long *down)
+{
+	int ret, multi =3D 1;
+	char *slash_ptr, *tmp_ptr;
+
+	slash_ptr =3D strchr(buff, '/');
+	if (slash_ptr)
+		*slash_ptr =3D 0;
+
+	if (strlen(buff) > 4) {
+		tmp_ptr =3D buff + strlen(buff) - 4;
+
+		if (strnicmp(tmp_ptr, "mbit", 4) =3D=3D 0)
+			multi =3D 1024;
+
+		if ((strnicmp(tmp_ptr, "kbit", 4) =3D=3D 0) ||
+			(multi > 1))
+			*tmp_ptr =3D '\0';
+	}
+
+	ret =3D strict_strtoul(buff, 10, down);
+	if (ret) {
+		bat_err(net_dev,
+			"Download speed of gateway mode invalid: %s\n",
+			buff);
+		return false;
+	}
+
+	*down *=3D multi;
+
+	/* we also got some upload info */
+	if (slash_ptr) {
+		multi =3D 1;
+
+		if (strlen(slash_ptr + 1) > 4) {
+			tmp_ptr =3D slash_ptr + 1 - 4 + strlen(slash_ptr + 1);
+
+			if (strnicmp(tmp_ptr, "mbit", 4) =3D=3D 0)
+				multi =3D 1024;
+
+			if ((strnicmp(tmp_ptr, "kbit", 4) =3D=3D 0) ||
+				(multi > 1))
+				*tmp_ptr =3D '\0';
+		}
+
+		ret =3D strict_strtoul(slash_ptr + 1, 10, up);
+		if (ret) {
+			bat_err(net_dev,
+				"Upload speed of gateway mode invalid: "
+				"%s\n", slash_ptr + 1);
+			return false;
+		}
+
+		*up *=3D multi;
+	}
+
+	return true;
+}
+
+ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t =
count)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	long gw_bandwidth_tmp =3D 0, up =3D 0, down =3D 0;
+	bool ret;
+
+	ret =3D parse_gw_bandwidth(net_dev, buff, &up, &down);
+	if (!ret)
+		goto end;
+
+	if ((!down) || (down < 256))
+		down =3D 2000;
+
+	if (!up)
+		up =3D down / 5;
+
+	kbit_to_gw_bandwidth(down, up, &gw_bandwidth_tmp);
+
+	/**
+	 * the gw bandwidth we guessed above might not match the given
+	 * speeds, hence we need to calculate it back to show the number
+	 * that is going to be propagated
+	 **/
+	gw_bandwidth_to_kbit((uint8_t)gw_bandwidth_tmp,
+			     (int *)&down, (int *)&up);
+
+	gw_deselect(bat_priv);
+	bat_info(net_dev, "Changing gateway bandwidth from: '%i' to: '%ld' "
+		 "(propagating: %ld%s/%ld%s)\n",
+		 atomic_read(&bat_priv->gw_bandwidth), gw_bandwidth_tmp,
+		 (down > 2048 ? down / 1024 : down),
+		 (down > 2048 ? "MBit" : "KBit"),
+		 (up > 2048 ? up / 1024 : up),
+		 (up > 2048 ? "MBit" : "KBit"));
+
+	atomic_set(&bat_priv->gw_bandwidth, gw_bandwidth_tmp);
+
+end:
+	return count;
+}
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_com=
mon.h
new file mode 100644
index 0000000..5e728d0
--- /dev/null
+++ b/net/batman-adv/gateway_common.h
@@ -0,0 +1,38 @@
+/*
+ * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
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
+#ifndef _NET_BATMAN_ADV_GATEWAY_COMMON_H_
+#define _NET_BATMAN_ADV_GATEWAY_COMMON_H_
+
+enum gw_modes {
+	GW_MODE_OFF,
+	GW_MODE_CLIENT,
+	GW_MODE_SERVER,
+};
+
+#define GW_MODE_OFF_NAME	"off"
+#define GW_MODE_CLIENT_NAME	"client"
+#define GW_MODE_SERVER_NAME	"server"
+
+void gw_bandwidth_to_kbit(uint8_t gw_class, int *down, int *up);
+ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t =
count);
+
+#endif /* _NET_BATMAN_ADV_GATEWAY_COMMON_H_ */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interf=
ace.c
new file mode 100644
index 0000000..4f95777
--- /dev/null
+++ b/net/batman-adv/hard-interface.c
@@ -0,0 +1,651 @@
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
+/* protect update critical side of if_list - but not the content */
+static DEFINE_SPINLOCK(if_list_lock);
+
+static void hardif_free_rcu(struct rcu_head *rcu)
+{
+	struct batman_if *batman_if;
+
+	batman_if =3D container_of(rcu, struct batman_if, rcu);
+	dev_put(batman_if->net_dev);
+	kref_put(&batman_if->refcount, hardif_free_ref);
+}
+
+struct batman_if *get_batman_if_by_netdev(struct net_device *net_dev)
+{
+	struct batman_if *batman_if;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->net_dev =3D=3D net_dev)
+			goto out;
+	}
+
+	batman_if =3D NULL;
+
+out:
+	if (batman_if)
+		kref_get(&batman_if->refcount);
+
+	rcu_read_unlock();
+	return batman_if;
+}
+
+static int is_valid_iface(struct net_device *net_dev)
+{
+	if (net_dev->flags & IFF_LOOPBACK)
+		return 0;
+
+	if (net_dev->type !=3D ARPHRD_ETHER)
+		return 0;
+
+	if (net_dev->addr_len !=3D ETH_ALEN)
+		return 0;
+
+	/* no batman over batman */
+#ifdef HAVE_NET_DEVICE_OPS
+	if (net_dev->netdev_ops->ndo_start_xmit =3D=3D interface_tx)
+		return 0;
+#else
+	if (net_dev->hard_start_xmit =3D=3D interface_tx)
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
+static struct batman_if *get_active_batman_if(struct net_device *soft_if=
ace)
+{
+	struct batman_if *batman_if;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->soft_iface !=3D soft_iface)
+			continue;
+
+		if (batman_if->if_status =3D=3D IF_ACTIVE)
+			goto out;
+	}
+
+	batman_if =3D NULL;
+
+out:
+	if (batman_if)
+		kref_get(&batman_if->refcount);
+
+	rcu_read_unlock();
+	return batman_if;
+}
+
+static void update_primary_addr(struct bat_priv *bat_priv)
+{
+	struct vis_packet *vis_packet;
+
+	vis_packet =3D (struct vis_packet *)
+				bat_priv->my_vis_info->skb_packet->data;
+	memcpy(vis_packet->vis_orig,
+	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(vis_packet->sender_orig,
+	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+}
+
+static void set_primary_if(struct bat_priv *bat_priv,
+			   struct batman_if *batman_if)
+{
+	struct batman_packet *batman_packet;
+	struct batman_if *old_if;
+
+	if (batman_if)
+		kref_get(&batman_if->refcount);
+
+	old_if =3D bat_priv->primary_if;
+	bat_priv->primary_if =3D batman_if;
+
+	if (old_if)
+		kref_put(&old_if->refcount, hardif_free_ref);
+
+	if (!bat_priv->primary_if)
+		return;
+
+	batman_packet =3D (struct batman_packet *)(batman_if->packet_buff);
+	batman_packet->flags =3D PRIMARIES_FIRST_HOP;
+	batman_packet->ttl =3D TTL;
+
+	update_primary_addr(bat_priv);
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
+	memcpy(((struct batman_packet *)(batman_if->packet_buff))->orig,
+	       batman_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(((struct batman_packet *)(batman_if->packet_buff))->prev_sender,
+	       batman_if->net_dev->dev_addr, ETH_ALEN);
+}
+
+static void check_known_mac_addr(struct net_device *net_dev)
+{
+	struct batman_if *batman_if;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if ((batman_if->if_status !=3D IF_ACTIVE) &&
+		    (batman_if->if_status !=3D IF_TO_BE_ACTIVATED))
+			continue;
+
+		if (batman_if->net_dev =3D=3D net_dev)
+			continue;
+
+		if (!compare_orig(batman_if->net_dev->dev_addr,
+				  net_dev->dev_addr))
+			continue;
+
+		pr_warning("The newly added mac address (%pM) already exists "
+			   "on: %s\n", net_dev->dev_addr,
+			   batman_if->net_dev->name);
+		pr_warning("It is strongly recommended to keep mac addresses "
+			   "unique to avoid problems!\n");
+	}
+	rcu_read_unlock();
+}
+
+int hardif_min_mtu(struct net_device *soft_iface)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct batman_if *batman_if;
+	/* allow big frames if all devices are capable to do so
+	 * (have MTU > 1500 + BAT_HEADER_LEN) */
+	int min_mtu =3D ETH_DATA_LEN;
+
+	if (atomic_read(&bat_priv->fragmentation))
+		goto out;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if ((batman_if->if_status !=3D IF_ACTIVE) &&
+		    (batman_if->if_status !=3D IF_TO_BE_ACTIVATED))
+			continue;
+
+		if (batman_if->soft_iface !=3D soft_iface)
+			continue;
+
+		min_mtu =3D min_t(int, batman_if->net_dev->mtu - BAT_HEADER_LEN,
+				min_mtu);
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
+	min_mtu =3D hardif_min_mtu(soft_iface);
+	if (soft_iface->mtu !=3D min_mtu)
+		soft_iface->mtu =3D min_mtu;
+}
+
+static void hardif_activate_interface(struct batman_if *batman_if)
+{
+	struct bat_priv *bat_priv;
+
+	if (batman_if->if_status !=3D IF_INACTIVE)
+		return;
+
+	bat_priv =3D netdev_priv(batman_if->soft_iface);
+
+	update_mac_addresses(batman_if);
+	batman_if->if_status =3D IF_TO_BE_ACTIVATED;
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
+	if ((batman_if->if_status !=3D IF_ACTIVE) &&
+	   (batman_if->if_status !=3D IF_TO_BE_ACTIVATED))
+		return;
+
+	batman_if->if_status =3D IF_INACTIVE;
+
+	bat_info(batman_if->soft_iface, "Interface deactivated: %s\n",
+		 batman_if->net_dev->name);
+
+	update_min_mtu(batman_if->soft_iface);
+}
+
+int hardif_enable_interface(struct batman_if *batman_if, char *iface_nam=
e)
+{
+	struct bat_priv *bat_priv;
+	struct batman_packet *batman_packet;
+
+	if (batman_if->if_status !=3D IF_NOT_IN_USE)
+		goto out;
+
+	batman_if->soft_iface =3D dev_get_by_name(&init_net, iface_name);
+
+	if (!batman_if->soft_iface) {
+		batman_if->soft_iface =3D softif_create(iface_name);
+
+		if (!batman_if->soft_iface)
+			goto err;
+
+		/* dev_get_by_name() increases the reference counter for us */
+		dev_hold(batman_if->soft_iface);
+	}
+
+	bat_priv =3D netdev_priv(batman_if->soft_iface);
+	batman_if->packet_len =3D BAT_PACKET_LEN;
+	batman_if->packet_buff =3D kmalloc(batman_if->packet_len, GFP_ATOMIC);
+
+	if (!batman_if->packet_buff) {
+		bat_err(batman_if->soft_iface, "Can't add interface packet "
+			"(%s): out of memory\n", batman_if->net_dev->name);
+		goto err;
+	}
+
+	batman_packet =3D (struct batman_packet *)(batman_if->packet_buff);
+	batman_packet->packet_type =3D BAT_PACKET;
+	batman_packet->version =3D COMPAT_VERSION;
+	batman_packet->flags =3D 0;
+	batman_packet->ttl =3D 2;
+	batman_packet->tq =3D TQ_MAX_VALUE;
+	batman_packet->num_hna =3D 0;
+
+	batman_if->if_num =3D bat_priv->num_ifaces;
+	bat_priv->num_ifaces++;
+	batman_if->if_status =3D IF_INACTIVE;
+	orig_hash_add_if(batman_if, bat_priv->num_ifaces);
+
+	batman_if->batman_adv_ptype.type =3D __constant_htons(ETH_P_BATMAN);
+	batman_if->batman_adv_ptype.func =3D batman_skb_recv;
+	batman_if->batman_adv_ptype.dev =3D batman_if->net_dev;
+	kref_get(&batman_if->refcount);
+	dev_add_pack(&batman_if->batman_adv_ptype);
+
+	atomic_set(&batman_if->seqno, 1);
+	atomic_set(&batman_if->frag_seqno, 1);
+	bat_info(batman_if->soft_iface, "Adding interface: %s\n",
+		 batman_if->net_dev->name);
+
+	if (atomic_read(&bat_priv->fragmentation) && batman_if->net_dev->mtu <
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
+	if (!atomic_read(&bat_priv->fragmentation) && batman_if->net_dev->mtu <
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
+	struct bat_priv *bat_priv =3D netdev_priv(batman_if->soft_iface);
+
+	if (batman_if->if_status =3D=3D IF_ACTIVE)
+		hardif_deactivate_interface(batman_if);
+
+	if (batman_if->if_status !=3D IF_INACTIVE)
+		return;
+
+	bat_info(batman_if->soft_iface, "Removing interface: %s\n",
+		 batman_if->net_dev->name);
+	dev_remove_pack(&batman_if->batman_adv_ptype);
+	kref_put(&batman_if->refcount, hardif_free_ref);
+
+	bat_priv->num_ifaces--;
+	orig_hash_del_if(batman_if, bat_priv->num_ifaces);
+
+	if (batman_if =3D=3D bat_priv->primary_if) {
+		struct batman_if *new_if;
+
+		new_if =3D get_active_batman_if(batman_if->soft_iface);
+		set_primary_if(bat_priv, new_if);
+
+		if (new_if)
+			kref_put(&new_if->refcount, hardif_free_ref);
+	}
+
+	kfree(batman_if->packet_buff);
+	batman_if->packet_buff =3D NULL;
+	batman_if->if_status =3D IF_NOT_IN_USE;
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
+	batman_if->soft_iface =3D NULL;
+}
+
+static struct batman_if *hardif_add_interface(struct net_device *net_dev=
)
+{
+	struct batman_if *batman_if;
+	int ret;
+
+	ret =3D is_valid_iface(net_dev);
+	if (ret !=3D 1)
+		goto out;
+
+	dev_hold(net_dev);
+
+	batman_if =3D kmalloc(sizeof(struct batman_if), GFP_ATOMIC);
+	if (!batman_if) {
+		pr_err("Can't add interface (%s): out of memory\n",
+		       net_dev->name);
+		goto release_dev;
+	}
+
+	ret =3D sysfs_add_hardif(&batman_if->hardif_obj, net_dev);
+	if (ret)
+		goto free_if;
+
+	batman_if->if_num =3D -1;
+	batman_if->net_dev =3D net_dev;
+	batman_if->soft_iface =3D NULL;
+	batman_if->if_status =3D IF_NOT_IN_USE;
+	INIT_LIST_HEAD(&batman_if->list);
+	kref_init(&batman_if->refcount);
+
+	check_known_mac_addr(batman_if->net_dev);
+
+	spin_lock(&if_list_lock);
+	list_add_tail_rcu(&batman_if->list, &if_list);
+	spin_unlock(&if_list_lock);
+
+	/* extra reference for return */
+	kref_get(&batman_if->refcount);
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
+static void hardif_remove_interface(struct batman_if *batman_if)
+{
+	/* first deactivate interface */
+	if (batman_if->if_status !=3D IF_NOT_IN_USE)
+		hardif_disable_interface(batman_if);
+
+	if (batman_if->if_status !=3D IF_NOT_IN_USE)
+		return;
+
+	batman_if->if_status =3D IF_TO_BE_REMOVED;
+	sysfs_del_hardif(&batman_if->hardif_obj);
+	call_rcu(&batman_if->rcu, hardif_free_rcu);
+}
+
+void hardif_remove_interfaces(void)
+{
+	struct batman_if *batman_if, *batman_if_tmp;
+	struct list_head if_queue;
+
+	INIT_LIST_HEAD(&if_queue);
+
+	spin_lock(&if_list_lock);
+	list_for_each_entry_safe(batman_if, batman_if_tmp, &if_list, list) {
+		list_del_rcu(&batman_if->list);
+		list_add_tail(&batman_if->list, &if_queue);
+	}
+	spin_unlock(&if_list_lock);
+
+	rtnl_lock();
+	list_for_each_entry_safe(batman_if, batman_if_tmp, &if_queue, list) {
+		hardif_remove_interface(batman_if);
+	}
+	rtnl_unlock();
+}
+
+static int hard_if_event(struct notifier_block *this,
+			 unsigned long event, void *ptr)
+{
+	struct net_device *net_dev =3D (struct net_device *)ptr;
+	struct batman_if *batman_if =3D get_batman_if_by_netdev(net_dev);
+	struct bat_priv *bat_priv;
+
+	if (!batman_if && event =3D=3D NETDEV_REGISTER)
+		batman_if =3D hardif_add_interface(net_dev);
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
+		spin_lock(&if_list_lock);
+		list_del_rcu(&batman_if->list);
+		spin_unlock(&if_list_lock);
+
+		hardif_remove_interface(batman_if);
+		break;
+	case NETDEV_CHANGEMTU:
+		if (batman_if->soft_iface)
+			update_min_mtu(batman_if->soft_iface);
+		break;
+	case NETDEV_CHANGEADDR:
+		if (batman_if->if_status =3D=3D IF_NOT_IN_USE)
+			goto hardif_put;
+
+		check_known_mac_addr(batman_if->net_dev);
+		update_mac_addresses(batman_if);
+
+		bat_priv =3D netdev_priv(batman_if->soft_iface);
+		if (batman_if =3D=3D bat_priv->primary_if)
+			update_primary_addr(bat_priv);
+		break;
+	default:
+		break;
+	};
+
+hardif_put:
+	kref_put(&batman_if->refcount, hardif_free_ref);
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
+	batman_if =3D container_of(ptype, struct batman_if, batman_adv_ptype);
+	skb =3D skb_share_check(skb, GFP_ATOMIC);
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
+	if (unlikely(skb->mac_len !=3D sizeof(struct ethhdr)
+				|| !skb_mac_header(skb)))
+		goto err_free;
+
+	if (!batman_if->soft_iface)
+		goto err_free;
+
+	bat_priv =3D netdev_priv(batman_if->soft_iface);
+
+	if (atomic_read(&bat_priv->mesh_state) !=3D MESH_ACTIVE)
+		goto err_free;
+
+	/* discard frames on not active interfaces */
+	if (batman_if->if_status !=3D IF_ACTIVE)
+		goto err_free;
+
+	batman_packet =3D (struct batman_packet *)skb->data;
+
+	if (batman_packet->version !=3D COMPAT_VERSION) {
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
+		ret =3D recv_bat_packet(skb, batman_if);
+		break;
+
+		/* batman icmp packet */
+	case BAT_ICMP:
+		ret =3D recv_icmp_packet(skb, batman_if);
+		break;
+
+		/* unicast packet */
+	case BAT_UNICAST:
+		ret =3D recv_unicast_packet(skb, batman_if);
+		break;
+
+		/* fragmented unicast packet */
+	case BAT_UNICAST_FRAG:
+		ret =3D recv_ucast_frag_packet(skb, batman_if);
+		break;
+
+		/* broadcast packet */
+	case BAT_BCAST:
+		ret =3D recv_bcast_packet(skb, batman_if);
+		break;
+
+		/* vis packet */
+	case BAT_VIS:
+		ret =3D recv_vis_packet(skb, batman_if);
+		break;
+	default:
+		ret =3D NET_RX_DROP;
+	}
+
+	if (ret =3D=3D NET_RX_DROP)
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
+struct notifier_block hard_if_notifier =3D {
+	.notifier_call =3D hard_if_event,
+};
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interf=
ace.h
new file mode 100644
index 0000000..30ec3b8
--- /dev/null
+++ b/net/batman-adv/hard-interface.h
@@ -0,0 +1,53 @@
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
+int hardif_enable_interface(struct batman_if *batman_if, char *iface_nam=
e);
+void hardif_disable_interface(struct batman_if *batman_if);
+void hardif_remove_interfaces(void);
+int batman_skb_recv(struct sk_buff *skb,
+				struct net_device *dev,
+				struct packet_type *ptype,
+				struct net_device *orig_dev);
+int hardif_min_mtu(struct net_device *soft_iface);
+void update_min_mtu(struct net_device *soft_iface);
+
+static inline void hardif_free_ref(struct kref *refcount)
+{
+	struct batman_if *batman_if;
+
+	batman_if =3D container_of(refcount, struct batman_if, refcount);
+	kfree(batman_if);
+}
+
+#endif /* _NET_BATMAN_ADV_HARD_INTERFACE_H_ */
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
new file mode 100644
index 0000000..26e623e
--- /dev/null
+++ b/net/batman-adv/hash.c
@@ -0,0 +1,62 @@
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
+	for (i =3D 0 ; i < hash->size; i++)
+		INIT_HLIST_HEAD(&hash->table[i]);
+}
+
+/* free only the hashtable and the hash itself. */
+void hash_destroy(struct hashtable_t *hash)
+{
+	kfree(hash->table);
+	kfree(hash);
+}
+
+/* allocates and clears the hash */
+struct hashtable_t *hash_new(int size)
+{
+	struct hashtable_t *hash;
+
+	hash =3D kmalloc(sizeof(struct hashtable_t) , GFP_ATOMIC);
+
+	if (!hash)
+		return NULL;
+
+	hash->size =3D size;
+	hash->table =3D kmalloc(sizeof(struct element_t *) * size, GFP_ATOMIC);
+
+	if (!hash->table) {
+		kfree(hash);
+		return NULL;
+	}
+
+	hash_init(hash);
+
+	return hash;
+}
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
new file mode 100644
index 0000000..09216ad
--- /dev/null
+++ b/net/batman-adv/hash.h
@@ -0,0 +1,176 @@
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
+#include <linux/list.h>
+
+/* callback to a compare function.  should
+ * compare 2 element datas for their keys,
+ * return 0 if same and not 0 if not
+ * same */
+typedef int (*hashdata_compare_cb)(void *, void *);
+
+/* the hashfunction, should return an index
+ * based on the key in the data of the first
+ * argument and the size the second */
+typedef int (*hashdata_choose_cb)(void *, int);
+typedef void (*hashdata_free_cb)(void *, void *);
+
+struct element_t {
+	void *data;		/* pointer to the data */
+	struct hlist_node hlist;	/* bucket list pointer */
+};
+
+struct hashtable_t {
+	struct hlist_head *table;   /* the hashtable itself, with the buckets *=
/
+	int size;		    /* size of hashtable */
+};
+
+/* allocates and clears the hash */
+struct hashtable_t *hash_new(int size);
+
+/* remove element if you already found the element you want to delete an=
d don't
+ * need the overhead to find it again with hash_remove().  But usually, =
you
+ * don't want to use this function, as it fiddles with hash-internals. *=
/
+void *hash_remove_element(struct hashtable_t *hash, struct element_t *el=
em);
+
+/* free only the hashtable and the hash itself. */
+void hash_destroy(struct hashtable_t *hash);
+
+/* remove the hash structure. if hashdata_free_cb !=3D NULL, this functi=
on will be
+ * called to remove the elements inside of the hash.  if you don't remov=
e the
+ * elements, memory might be leaked. */
+static inline void hash_delete(struct hashtable_t *hash,
+			       hashdata_free_cb free_cb, void *arg)
+{
+	struct hlist_head *head;
+	struct hlist_node *walk, *safe;
+	struct element_t *bucket;
+	int i;
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_safe(walk, safe, head) {
+			bucket =3D hlist_entry(walk, struct element_t, hlist);
+			if (free_cb)
+				free_cb(bucket->data, arg);
+
+			hlist_del(walk);
+			kfree(bucket);
+		}
+	}
+
+	hash_destroy(hash);
+}
+
+/* adds data to the hashtable. returns 0 on success, -1 on error */
+static inline int hash_add(struct hashtable_t *hash,
+			   hashdata_compare_cb compare,
+			   hashdata_choose_cb choose, void *data)
+{
+	int index;
+	struct hlist_head *head;
+	struct hlist_node *walk, *safe;
+	struct element_t *bucket;
+
+	if (!hash)
+		return -1;
+
+	index =3D choose(data, hash->size);
+	head =3D &hash->table[index];
+
+	hlist_for_each_safe(walk, safe, head) {
+		bucket =3D hlist_entry(walk, struct element_t, hlist);
+		if (compare(bucket->data, data))
+			return -1;
+	}
+
+	/* no duplicate found in list, add new element */
+	bucket =3D kmalloc(sizeof(struct element_t), GFP_ATOMIC);
+
+	if (!bucket)
+		return -1;
+
+	bucket->data =3D data;
+	hlist_add_head(&bucket->hlist, head);
+
+	return 0;
+}
+
+/* removes data from hash, if found. returns pointer do data on success,=
 so you
+ * can remove the used structure yourself, or NULL on error .  data coul=
d be the
+ * structure you use with just the key filled, we just need the key for
+ * comparing. */
+static inline void *hash_remove(struct hashtable_t *hash,
+				hashdata_compare_cb compare,
+				hashdata_choose_cb choose, void *data)
+{
+	size_t index;
+	struct hlist_node *walk;
+	struct element_t *bucket;
+	struct hlist_head *head;
+	void *data_save;
+
+	index =3D choose(data, hash->size);
+	head =3D &hash->table[index];
+
+	hlist_for_each_entry(bucket, walk, head, hlist) {
+		if (compare(bucket->data, data)) {
+			data_save =3D bucket->data;
+			hlist_del(walk);
+			kfree(bucket);
+			return data_save;
+		}
+	}
+
+	return NULL;
+}
+
+/* finds data, based on the key in keydata. returns the found data on su=
ccess,
+ * or NULL on error */
+static inline void *hash_find(struct hashtable_t *hash,
+			      hashdata_compare_cb compare,
+			      hashdata_choose_cb choose, void *keydata)
+{
+	int index;
+	struct hlist_head *head;
+	struct hlist_node *walk;
+	struct element_t *bucket;
+
+	if (!hash)
+		return NULL;
+
+	index =3D choose(keydata , hash->size);
+	head =3D &hash->table[index];
+
+	hlist_for_each(walk, head) {
+		bucket =3D hlist_entry(walk, struct element_t, hlist);
+		if (compare(bucket->data, keydata))
+			return bucket->data;
+	}
+
+	return NULL;
+}
+
+#endif /* _NET_BATMAN_ADV_HASH_H_ */
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
new file mode 100644
index 0000000..ecf6d7f
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
+#include "originator.h"
+#include "hard-interface.h"
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
+	nonseekable_open(inode, file);
+
+	socket_client =3D kmalloc(sizeof(struct socket_client), GFP_KERNEL);
+
+	if (!socket_client)
+		return -ENOMEM;
+
+	for (i =3D 0; i < ARRAY_SIZE(socket_client_hash); i++) {
+		if (!socket_client_hash[i]) {
+			socket_client_hash[i] =3D socket_client;
+			break;
+		}
+	}
+
+	if (i =3D=3D ARRAY_SIZE(socket_client_hash)) {
+		pr_err("Error - can't add another packet client: "
+		       "maximum number of clients reached\n");
+		kfree(socket_client);
+		return -EXFULL;
+	}
+
+	INIT_LIST_HEAD(&socket_client->queue_list);
+	socket_client->queue_len =3D 0;
+	socket_client->index =3D i;
+	socket_client->bat_priv =3D inode->i_private;
+	spin_lock_init(&socket_client->lock);
+	init_waitqueue_head(&socket_client->queue_wait);
+
+	file->private_data =3D socket_client;
+
+	inc_module_count();
+	return 0;
+}
+
+static int bat_socket_release(struct inode *inode, struct file *file)
+{
+	struct socket_client *socket_client =3D file->private_data;
+	struct socket_packet *socket_packet;
+	struct list_head *list_pos, *list_pos_tmp;
+
+	spin_lock_bh(&socket_client->lock);
+
+	/* for all packets in the queue ... */
+	list_for_each_safe(list_pos, list_pos_tmp, &socket_client->queue_list) =
{
+		socket_packet =3D list_entry(list_pos,
+					   struct socket_packet, list);
+
+		list_del(list_pos);
+		kfree(socket_packet);
+	}
+
+	socket_client_hash[socket_client->index] =3D NULL;
+	spin_unlock_bh(&socket_client->lock);
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
+	struct socket_client *socket_client =3D file->private_data;
+	struct socket_packet *socket_packet;
+	size_t packet_len;
+	int error;
+
+	if ((file->f_flags & O_NONBLOCK) && (socket_client->queue_len =3D=3D 0)=
)
+		return -EAGAIN;
+
+	if ((!buf) || (count < sizeof(struct icmp_packet)))
+		return -EINVAL;
+
+	if (!access_ok(VERIFY_WRITE, buf, count))
+		return -EFAULT;
+
+	error =3D wait_event_interruptible(socket_client->queue_wait,
+					 socket_client->queue_len);
+
+	if (error)
+		return error;
+
+	spin_lock_bh(&socket_client->lock);
+
+	socket_packet =3D list_first_entry(&socket_client->queue_list,
+					 struct socket_packet, list);
+	list_del(&socket_packet->list);
+	socket_client->queue_len--;
+
+	spin_unlock_bh(&socket_client->lock);
+
+	error =3D __copy_to_user(buf, &socket_packet->icmp_packet,
+			       socket_packet->icmp_len);
+
+	packet_len =3D socket_packet->icmp_len;
+	kfree(socket_packet);
+
+	if (error)
+		return -EFAULT;
+
+	return packet_len;
+}
+
+static ssize_t bat_socket_write(struct file *file, const char __user *bu=
ff,
+				size_t len, loff_t *off)
+{
+	struct socket_client *socket_client =3D file->private_data;
+	struct bat_priv *bat_priv =3D socket_client->bat_priv;
+	struct sk_buff *skb;
+	struct icmp_packet_rr *icmp_packet;
+
+	struct orig_node *orig_node;
+	struct batman_if *batman_if;
+	size_t packet_len =3D sizeof(struct icmp_packet);
+	uint8_t dstaddr[ETH_ALEN];
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
+	if (len >=3D sizeof(struct icmp_packet_rr))
+		packet_len =3D sizeof(struct icmp_packet_rr);
+
+	skb =3D dev_alloc_skb(packet_len + sizeof(struct ethhdr));
+	if (!skb)
+		return -ENOMEM;
+
+	skb_reserve(skb, sizeof(struct ethhdr));
+	icmp_packet =3D (struct icmp_packet_rr *)skb_put(skb, packet_len);
+
+	if (!access_ok(VERIFY_READ, buff, packet_len)) {
+		len =3D -EFAULT;
+		goto free_skb;
+	}
+
+	if (__copy_from_user(icmp_packet, buff, packet_len)) {
+		len =3D -EFAULT;
+		goto free_skb;
+	}
+
+	if (icmp_packet->packet_type !=3D BAT_ICMP) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Error - can't send packet from char device: "
+			"got bogus packet type (expected: BAT_ICMP)\n");
+		len =3D -EINVAL;
+		goto free_skb;
+	}
+
+	if (icmp_packet->msg_type !=3D ECHO_REQUEST) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Error - can't send packet from char device: "
+			"got bogus message type (expected: ECHO_REQUEST)\n");
+		len =3D -EINVAL;
+		goto free_skb;
+	}
+
+	icmp_packet->uid =3D socket_client->index;
+
+	if (icmp_packet->version !=3D COMPAT_VERSION) {
+		icmp_packet->msg_type =3D PARAMETER_PROBLEM;
+		icmp_packet->ttl =3D COMPAT_VERSION;
+		bat_socket_add_packet(socket_client, icmp_packet, packet_len);
+		goto free_skb;
+	}
+
+	if (atomic_read(&bat_priv->mesh_state) !=3D MESH_ACTIVE)
+		goto dst_unreach;
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	orig_node =3D ((struct orig_node *)hash_find(bat_priv->orig_hash,
+						   compare_orig, choose_orig,
+						   icmp_packet->dst));
+
+	if (!orig_node)
+		goto unlock;
+
+	if (!orig_node->router)
+		goto unlock;
+
+	batman_if =3D orig_node->router->if_incoming;
+	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	if (!batman_if)
+		goto dst_unreach;
+
+	if (batman_if->if_status !=3D IF_ACTIVE)
+		goto dst_unreach;
+
+	memcpy(icmp_packet->orig,
+	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+
+	if (packet_len =3D=3D sizeof(struct icmp_packet_rr))
+		memcpy(icmp_packet->rr, batman_if->net_dev->dev_addr, ETH_ALEN);
+
+
+	send_skb_packet(skb, batman_if, dstaddr);
+
+	goto out;
+
+unlock:
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+dst_unreach:
+	icmp_packet->msg_type =3D DESTINATION_UNREACHABLE;
+	bat_socket_add_packet(socket_client, icmp_packet, packet_len);
+free_skb:
+	kfree_skb(skb);
+out:
+	return len;
+}
+
+static unsigned int bat_socket_poll(struct file *file, poll_table *wait)
+{
+	struct socket_client *socket_client =3D file->private_data;
+
+	poll_wait(file, &socket_client->queue_wait, wait);
+
+	if (socket_client->queue_len > 0)
+		return POLLIN | POLLRDNORM;
+
+	return 0;
+}
+
+static const struct file_operations fops =3D {
+	.owner =3D THIS_MODULE,
+	.open =3D bat_socket_open,
+	.release =3D bat_socket_release,
+	.read =3D bat_socket_read,
+	.write =3D bat_socket_write,
+	.poll =3D bat_socket_poll,
+	.llseek =3D no_llseek,
+};
+
+int bat_socket_setup(struct bat_priv *bat_priv)
+{
+	struct dentry *d;
+
+	if (!bat_priv->debug_dir)
+		goto err;
+
+	d =3D debugfs_create_file(ICMP_SOCKET, S_IFREG | S_IWUSR | S_IRUSR,
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
+
+	socket_packet =3D kmalloc(sizeof(struct socket_packet), GFP_ATOMIC);
+
+	if (!socket_packet)
+		return;
+
+	INIT_LIST_HEAD(&socket_packet->list);
+	memcpy(&socket_packet->icmp_packet, icmp_packet, icmp_len);
+	socket_packet->icmp_len =3D icmp_len;
+
+	spin_lock_bh(&socket_client->lock);
+
+	/* while waiting for the lock the socket_client could have been
+	 * deleted */
+	if (!socket_client_hash[icmp_packet->uid]) {
+		spin_unlock_bh(&socket_client->lock);
+		kfree(socket_packet);
+		return;
+	}
+
+	list_add_tail(&socket_packet->list, &socket_client->queue_list);
+	socket_client->queue_len++;
+
+	if (socket_client->queue_len > 100) {
+		socket_packet =3D list_first_entry(&socket_client->queue_list,
+						 struct socket_packet, list);
+
+		list_del(&socket_packet->list);
+		kfree(socket_packet);
+		socket_client->queue_len--;
+	}
+
+	spin_unlock_bh(&socket_client->lock);
+
+	wake_up(&socket_client->queue_wait);
+}
+
+void bat_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
+			       size_t icmp_len)
+{
+	struct socket_client *hash =3D socket_client_hash[icmp_packet->uid];
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
index 0000000..b827f6a
--- /dev/null
+++ b/net/batman-adv/main.c
@@ -0,0 +1,187 @@
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
+#include "gateway_client.h"
+#include "types.h"
+#include "vis.h"
+#include "hash.h"
+
+struct list_head if_list;
+
+unsigned char broadcast_addr[] =3D {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+
+struct workqueue_struct *bat_event_workqueue;
+
+static int __init batman_init(void)
+{
+	INIT_LIST_HEAD(&if_list);
+
+	/* the name should not be longer than 10 chars - see
+	 * http://lwn.net/Articles/23634/ */
+	bat_event_workqueue =3D create_singlethread_workqueue("bat_events");
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
+	bat_event_workqueue =3D NULL;
+
+	rcu_barrier();
+}
+
+int mesh_init(struct net_device *soft_iface)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+
+	spin_lock_init(&bat_priv->orig_hash_lock);
+	spin_lock_init(&bat_priv->forw_bat_list_lock);
+	spin_lock_init(&bat_priv->forw_bcast_list_lock);
+	spin_lock_init(&bat_priv->hna_lhash_lock);
+	spin_lock_init(&bat_priv->hna_ghash_lock);
+	spin_lock_init(&bat_priv->gw_list_lock);
+	spin_lock_init(&bat_priv->vis_hash_lock);
+	spin_lock_init(&bat_priv->vis_list_lock);
+	spin_lock_init(&bat_priv->softif_neigh_lock);
+
+	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
+	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
+	INIT_HLIST_HEAD(&bat_priv->gw_list);
+	INIT_HLIST_HEAD(&bat_priv->softif_neigh_list);
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
+	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+
+	atomic_set(&bat_priv->mesh_state, MESH_DEACTIVATING);
+
+	purge_outstanding_packets(bat_priv, NULL);
+
+	vis_quit(bat_priv);
+
+	gw_node_purge(bat_priv);
+	originator_free(bat_priv);
+
+	hna_local_free(bat_priv);
+	hna_global_free(bat_priv);
+
+	softif_neigh_purge(bat_priv);
+
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
+int is_my_mac(uint8_t *addr)
+{
+	struct batman_if *batman_if;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->if_status !=3D IF_ACTIVE)
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
index 0000000..d4d9926
--- /dev/null
+++ b/net/batman-adv/main.h
@@ -0,0 +1,183 @@
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
+#define DRIVER_AUTHOR "Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>, " \
+		      "Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>"
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
+#define PURGE_TIMEOUT 200	/* purge originators after time in seconds if =
no
+				   * valid packet comes in -> TODO: check
+				   * influence on TQ_LOCAL_WINDOW_SIZE */
+#define LOCAL_HNA_TIMEOUT 3600 /* in seconds */
+
+#define TQ_LOCAL_WINDOW_SIZE 64	  /* sliding packet range of received or=
iginator
+				   * messages in squence numbers (should be a
+				   * multiple of our word size) */
+#define TQ_GLOBAL_WINDOW_SIZE 5
+#define TQ_LOCAL_BIDRECT_SEND_MINIMUM 1
+#define TQ_LOCAL_BIDRECT_RECV_MINIMUM 1
+#define TQ_TOTAL_BIDRECT_LIMIT 1
+
+#define NUM_WORDS (TQ_LOCAL_WINDOW_SIZE / WORD_BIT_SIZE)
+
+#define PACKBUFF_SIZE 2000
+#define LOG_BUF_LEN 8192	  /* has to be a power of 2 */
+
+#define VIS_INTERVAL 5000	/* 5 seconds */
+
+/* how much worse secondary interfaces may be to
+ * to be considered as bonding candidates */
+
+#define BONDING_TQ_THRESHOLD	50
+
+#define MAX_AGGREGATION_BYTES 512 /* should not be bigger than 512 bytes=
 or
+				   * change the size of
+				   * forw_packet->direct_link_flags */
+#define MAX_AGGREGATION_MS 100
+
+#define SOFTIF_NEIGH_TIMEOUT 180000 /* 3 minutes */
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
+#ifdef pr_fmt
+#undef pr_fmt
+#endif
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt /* Append 'batman-adv: ' bef=
ore
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
+#include <linux/etherdevice.h>  /* ethernet address classifaction */
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
+int is_my_mac(uint8_t *addr);
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
+		struct net_device *_netdev =3D (net_dev);                 \
+		struct bat_priv *_batpriv =3D netdev_priv(_netdev);       \
+		bat_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		pr_warning("%s: " fmt, _netdev->name, ## arg);		\
+	} while (0)
+#define bat_info(net_dev, fmt, arg...)					\
+	do {								\
+		struct net_device *_netdev =3D (net_dev);                 \
+		struct bat_priv *_batpriv =3D netdev_priv(_netdev);       \
+		bat_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		pr_info("%s: " fmt, _netdev->name, ## arg);		\
+	} while (0)
+#define bat_err(net_dev, fmt, arg...)					\
+	do {								\
+		struct net_device *_netdev =3D (net_dev);                 \
+		struct bat_priv *_batpriv =3D netdev_priv(_netdev);       \
+		bat_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		pr_err("%s: " fmt, _netdev->name, ## arg);		\
+	} while (0)
+
+#endif /* _NET_BATMAN_ADV_MAIN_H_ */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
new file mode 100644
index 0000000..6b7fb6b
--- /dev/null
+++ b/net/batman-adv/originator.c
@@ -0,0 +1,564 @@
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
+#include "gateway_client.h"
+#include "hard-interface.h"
+#include "unicast.h"
+#include "soft-interface.h"
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
+	if (bat_priv->orig_hash)
+		return 1;
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	bat_priv->orig_hash =3D hash_new(1024);
+
+	if (!bat_priv->orig_hash)
+		goto err;
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+	start_purge_timer(bat_priv);
+	return 1;
+
+err:
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+	return 0;
+}
+
+struct neigh_node *
+create_neighbor(struct orig_node *orig_node, struct orig_node *orig_neig=
h_node,
+		uint8_t *neigh, struct batman_if *if_incoming)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
+	struct neigh_node *neigh_node;
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Creating new last-hop neighbor of originator\n");
+
+	neigh_node =3D kzalloc(sizeof(struct neigh_node), GFP_ATOMIC);
+	if (!neigh_node)
+		return NULL;
+
+	INIT_LIST_HEAD(&neigh_node->list);
+
+	memcpy(neigh_node->addr, neigh, ETH_ALEN);
+	neigh_node->orig_node =3D orig_neigh_node;
+	neigh_node->if_incoming =3D if_incoming;
+
+	list_add_tail(&neigh_node->list, &orig_node->neigh_list);
+	return neigh_node;
+}
+
+static void free_orig_node(void *data, void *arg)
+{
+	struct list_head *list_pos, *list_pos_tmp;
+	struct neigh_node *neigh_node;
+	struct orig_node *orig_node =3D (struct orig_node *)data;
+	struct bat_priv *bat_priv =3D (struct bat_priv *)arg;
+
+	/* for all neighbors towards this originator ... */
+	list_for_each_safe(list_pos, list_pos_tmp, &orig_node->neigh_list) {
+		neigh_node =3D list_entry(list_pos, struct neigh_node, list);
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
+	if (!bat_priv->orig_hash)
+		return;
+
+	cancel_delayed_work_sync(&bat_priv->orig_work);
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	hash_delete(bat_priv->orig_hash, free_orig_node, bat_priv);
+	bat_priv->orig_hash =3D NULL;
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+}
+
+/* this function finds or creates an originator entry for the given
+ * address if it does not exits */
+struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr=
)
+{
+	struct orig_node *orig_node;
+	int size;
+	int hash_added;
+
+	orig_node =3D ((struct orig_node *)hash_find(bat_priv->orig_hash,
+						   compare_orig, choose_orig,
+						   addr));
+
+	if (orig_node)
+		return orig_node;
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Creating new originator: %pM\n", addr);
+
+	orig_node =3D kzalloc(sizeof(struct orig_node), GFP_ATOMIC);
+	if (!orig_node)
+		return NULL;
+
+	INIT_LIST_HEAD(&orig_node->neigh_list);
+
+	memcpy(orig_node->orig, addr, ETH_ALEN);
+	orig_node->router =3D NULL;
+	orig_node->hna_buff =3D NULL;
+	orig_node->bcast_seqno_reset =3D jiffies - 1
+					- msecs_to_jiffies(RESET_PROTECTION_MS);
+	orig_node->batman_seqno_reset =3D jiffies - 1
+					- msecs_to_jiffies(RESET_PROTECTION_MS);
+
+	size =3D bat_priv->num_ifaces * sizeof(unsigned long) * NUM_WORDS;
+
+	orig_node->bcast_own =3D kzalloc(size, GFP_ATOMIC);
+	if (!orig_node->bcast_own)
+		goto free_orig_node;
+
+	size =3D bat_priv->num_ifaces * sizeof(uint8_t);
+	orig_node->bcast_own_sum =3D kzalloc(size, GFP_ATOMIC);
+
+	INIT_LIST_HEAD(&orig_node->frag_list);
+	orig_node->last_frag_packet =3D 0;
+
+	if (!orig_node->bcast_own_sum)
+		goto free_bcast_own;
+
+	hash_added =3D hash_add(bat_priv->orig_hash, compare_orig, choose_orig,
+			      orig_node);
+	if (hash_added < 0)
+		goto free_bcast_own_sum;
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
+	bool neigh_purged =3D false;
+
+	*best_neigh_node =3D NULL;
+
+	/* for all neighbors towards this originator ... */
+	list_for_each_safe(list_pos, list_pos_tmp, &orig_node->neigh_list) {
+		neigh_node =3D list_entry(list_pos, struct neigh_node, list);
+
+		if ((time_after(jiffies,
+			neigh_node->last_valid + PURGE_TIMEOUT * HZ)) ||
+		    (neigh_node->if_incoming->if_status =3D=3D IF_INACTIVE) ||
+		    (neigh_node->if_incoming->if_status =3D=3D IF_TO_BE_REMOVED)) {
+
+			if (neigh_node->if_incoming->if_status =3D=3D
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
+			neigh_purged =3D true;
+			list_del(list_pos);
+			kfree(neigh_node);
+		} else {
+			if ((!*best_neigh_node) ||
+			    (neigh_node->tq_avg > (*best_neigh_node)->tq_avg))
+				*best_neigh_node =3D neigh_node;
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
+	struct hashtable_t *hash =3D bat_priv->orig_hash;
+	struct hlist_node *walk, *safe;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct orig_node *orig_node;
+	int i;
+
+	if (!hash)
+		return;
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+
+	/* for all origins... */
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
+			orig_node =3D bucket->data;
+
+			if (purge_orig_node(bat_priv, orig_node)) {
+				if (orig_node->gw_flags)
+					gw_node_delete(bat_priv, orig_node);
+				hlist_del(walk);
+				kfree(bucket);
+				free_orig_node(orig_node, bat_priv);
+			}
+
+			if (time_after(jiffies, orig_node->last_frag_packet +
+						msecs_to_jiffies(FRAG_TIMEOUT)))
+				frag_list_free(&orig_node->frag_list);
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	gw_node_purge(bat_priv);
+	gw_election(bat_priv);
+
+	softif_neigh_purge(bat_priv);
+}
+
+static void purge_orig(struct work_struct *work)
+{
+	struct delayed_work *delayed_work =3D
+		container_of(work, struct delayed_work, work);
+	struct bat_priv *bat_priv =3D
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
+	struct net_device *net_dev =3D (struct net_device *)seq->private;
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct hashtable_t *hash =3D bat_priv->orig_hash;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct orig_node *orig_node;
+	struct neigh_node *neigh_node;
+	int batman_count =3D 0;
+	int last_seen_secs;
+	int last_seen_msecs;
+	int i;
+
+	if ((!bat_priv->primary_if) ||
+	    (bat_priv->primary_if->if_status !=3D IF_ACTIVE)) {
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
+	seq_printf(seq, "[B.A.T.M.A.N. adv %s%s, MainIF/MAC: %s/%pM (%s)]\n",
+		   SOURCE_VERSION, REVISION_VERSION_STR,
+		   bat_priv->primary_if->net_dev->name,
+		   bat_priv->primary_if->net_dev->dev_addr, net_dev->name);
+	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
+		   "Originator", "last-seen", "#", TQ_MAX_VALUE, "Nexthop",
+		   "outgoingIF", "Potential nexthops");
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			orig_node =3D bucket->data;
+
+			if (!orig_node->router)
+				continue;
+
+			if (orig_node->router->tq_avg =3D=3D 0)
+				continue;
+
+			last_seen_secs =3D jiffies_to_msecs(jiffies -
+						orig_node->last_valid) / 1000;
+			last_seen_msecs =3D jiffies_to_msecs(jiffies -
+						orig_node->last_valid) % 1000;
+
+			neigh_node =3D orig_node->router;
+			seq_printf(seq, "%pM %4i.%03is   (%3i) %pM [%10s]:",
+				   orig_node->orig, last_seen_secs,
+				   last_seen_msecs, neigh_node->tq_avg,
+				   neigh_node->addr,
+				   neigh_node->if_incoming->net_dev->name);
+
+			list_for_each_entry(neigh_node, &orig_node->neigh_list,
+					    list) {
+				seq_printf(seq, " %pM (%3i)", neigh_node->addr,
+						neigh_node->tq_avg);
+			}
+
+			seq_printf(seq, "\n");
+			batman_count++;
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	if ((batman_count =3D=3D 0))
+		seq_printf(seq, "No batman nodes in range ...\n");
+
+	return 0;
+}
+
+static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
+{
+	void *data_ptr;
+
+	data_ptr =3D kmalloc(max_if_num * sizeof(unsigned long) * NUM_WORDS,
+			   GFP_ATOMIC);
+	if (!data_ptr) {
+		pr_err("Can't resize orig: out of memory\n");
+		return -1;
+	}
+
+	memcpy(data_ptr, orig_node->bcast_own,
+	       (max_if_num - 1) * sizeof(unsigned long) * NUM_WORDS);
+	kfree(orig_node->bcast_own);
+	orig_node->bcast_own =3D data_ptr;
+
+	data_ptr =3D kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
+	if (!data_ptr) {
+		pr_err("Can't resize orig: out of memory\n");
+		return -1;
+	}
+
+	memcpy(data_ptr, orig_node->bcast_own_sum,
+	       (max_if_num - 1) * sizeof(uint8_t));
+	kfree(orig_node->bcast_own_sum);
+	orig_node->bcast_own_sum =3D data_ptr;
+
+	return 0;
+}
+
+int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(batman_if->soft_iface);
+	struct hashtable_t *hash =3D bat_priv->orig_hash;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct orig_node *orig_node;
+	int i;
+
+	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
+	 * if_num */
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			orig_node =3D bucket->data;
+
+			if (orig_node_add_if(orig_node, max_if_num) =3D=3D -1)
+				goto err;
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+	return 0;
+
+err:
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+	return -ENOMEM;
+}
+
+static int orig_node_del_if(struct orig_node *orig_node,
+		     int max_if_num, int del_if_num)
+{
+	void *data_ptr =3D NULL;
+	int chunk_size;
+
+	/* last interface was removed */
+	if (max_if_num =3D=3D 0)
+		goto free_bcast_own;
+
+	chunk_size =3D sizeof(unsigned long) * NUM_WORDS;
+	data_ptr =3D kmalloc(max_if_num * chunk_size, GFP_ATOMIC);
+	if (!data_ptr) {
+		pr_err("Can't resize orig: out of memory\n");
+		return -1;
+	}
+
+	/* copy first part */
+	memcpy(data_ptr, orig_node->bcast_own, del_if_num * chunk_size);
+
+	/* copy second part */
+	memcpy(data_ptr + del_if_num * chunk_size,
+	       orig_node->bcast_own + ((del_if_num + 1) * chunk_size),
+	       (max_if_num - del_if_num) * chunk_size);
+
+free_bcast_own:
+	kfree(orig_node->bcast_own);
+	orig_node->bcast_own =3D data_ptr;
+
+	if (max_if_num =3D=3D 0)
+		goto free_own_sum;
+
+	data_ptr =3D kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
+	if (!data_ptr) {
+		pr_err("Can't resize orig: out of memory\n");
+		return -1;
+	}
+
+	memcpy(data_ptr, orig_node->bcast_own_sum,
+	       del_if_num * sizeof(uint8_t));
+
+	memcpy(data_ptr + del_if_num * sizeof(uint8_t),
+	       orig_node->bcast_own_sum + ((del_if_num + 1) * sizeof(uint8_t)),
+	       (max_if_num - del_if_num) * sizeof(uint8_t));
+
+free_own_sum:
+	kfree(orig_node->bcast_own_sum);
+	orig_node->bcast_own_sum =3D data_ptr;
+
+	return 0;
+}
+
+int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(batman_if->soft_iface);
+	struct hashtable_t *hash =3D bat_priv->orig_hash;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct batman_if *batman_if_tmp;
+	struct orig_node *orig_node;
+	int i, ret;
+
+	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
+	 * if_num */
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			orig_node =3D bucket->data;
+
+			ret =3D orig_node_del_if(orig_node, max_if_num,
+					batman_if->if_num);
+
+			if (ret =3D=3D -1)
+				goto err;
+		}
+	}
+
+	/* renumber remaining batman interfaces _inside_ of orig_hash_lock */
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if_tmp, &if_list, list) {
+		if (batman_if_tmp->if_status =3D=3D IF_NOT_IN_USE)
+			continue;
+
+		if (batman_if =3D=3D batman_if_tmp)
+			continue;
+
+		if (batman_if->soft_iface !=3D batman_if_tmp->soft_iface)
+			continue;
+
+		if (batman_if_tmp->if_num > batman_if->if_num)
+			batman_if_tmp->if_num--;
+	}
+	rcu_read_unlock();
+
+	batman_if->if_num =3D -1;
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+	return 0;
+
+err:
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+	return -ENOMEM;
+}
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
new file mode 100644
index 0000000..d474ceb
--- /dev/null
+++ b/net/batman-adv/originator.h
@@ -0,0 +1,64 @@
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
+struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr=
);
+struct neigh_node *
+create_neighbor(struct orig_node *orig_node, struct orig_node *orig_neig=
h_node,
+		uint8_t *neigh, struct batman_if *if_incoming);
+int orig_seq_print_text(struct seq_file *seq, void *offset);
+int orig_hash_add_if(struct batman_if *batman_if, int max_if_num);
+int orig_hash_del_if(struct batman_if *batman_if, int max_if_num);
+
+
+/* returns 1 if they are the same originator */
+static inline int compare_orig(void *data1, void *data2)
+{
+	return (memcmp(data1, data2, ETH_ALEN) =3D=3D 0 ? 1 : 0);
+}
+
+/* hashfunction to choose an entry in a hash table of given size */
+/* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
+static inline int choose_orig(void *data, int32_t size)
+{
+	unsigned char *key =3D data;
+	uint32_t hash =3D 0;
+	size_t i;
+
+	for (i =3D 0; i < 6; i++) {
+		hash +=3D key[i];
+		hash +=3D (hash << 10);
+		hash ^=3D (hash >> 6);
+	}
+
+	hash +=3D (hash << 3);
+	hash ^=3D (hash >> 11);
+	hash +=3D (hash << 15);
+
+	return hash % size;
+}
+
+#endif /* _NET_BATMAN_ADV_ORIGINATOR_H_ */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
new file mode 100644
index 0000000..b49fdf7
--- /dev/null
+++ b/net/batman-adv/packet.h
@@ -0,0 +1,136 @@
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
+#define COMPAT_VERSION 12
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
+	uint8_t  gw_flags;  /* flags related to gateway class */
+	uint8_t  align;
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
+ * as this is assumed by code that handles ICMP packets */
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
+void ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index, uint8_t value=
)
+{
+	lq_recv[*lq_index] =3D value;
+	*lq_index =3D (*lq_index + 1) % TQ_GLOBAL_WINDOW_SIZE;
+}
+
+uint8_t ring_buffer_avg(uint8_t lq_recv[])
+{
+	uint8_t *ptr;
+	uint16_t count =3D 0, i =3D 0, sum =3D 0;
+
+	ptr =3D lq_recv;
+
+	while (i < TQ_GLOBAL_WINDOW_SIZE) {
+		if (*ptr !=3D 0) {
+			count++;
+			sum +=3D *ptr;
+		}
+
+		i++;
+		ptr++;
+	}
+
+	if (count =3D=3D 0)
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
+void ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index, uint8_t value=
);
+uint8_t ring_buffer_avg(uint8_t lq_recv[]);
+
+#endif /* _NET_BATMAN_ADV_RING_BUFFER_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
new file mode 100644
index 0000000..8828edd
--- /dev/null
+++ b/net/batman-adv/routing.c
@@ -0,0 +1,1397 @@
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
+#include "gateway_common.h"
+#include "gateway_client.h"
+#include "unicast.h"
+
+void slide_own_bcast_window(struct batman_if *batman_if)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(batman_if->soft_iface);
+	struct hashtable_t *hash =3D bat_priv->orig_hash;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct orig_node *orig_node;
+	unsigned long *word;
+	int i;
+	size_t word_index;
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			orig_node =3D bucket->data;
+			word_index =3D batman_if->if_num * NUM_WORDS;
+			word =3D &(orig_node->bcast_own[word_index]);
+
+			bit_get_packet(bat_priv, word, 1, 0);
+			orig_node->bcast_own_sum[batman_if->if_num] =3D
+				bit_packet_count(word);
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+}
+
+static void update_HNA(struct bat_priv *bat_priv, struct orig_node *orig=
_node,
+		       unsigned char *hna_buff, int hna_buff_len)
+{
+	if ((hna_buff_len !=3D orig_node->hna_buff_len) ||
+	    ((hna_buff_len > 0) &&
+	     (orig_node->hna_buff_len > 0) &&
+	     (memcmp(orig_node->hna_buff, hna_buff, hna_buff_len) !=3D 0))) {
+
+		if (orig_node->hna_buff_len > 0)
+			hna_global_del_orig(bat_priv, orig_node,
+					    "originator changed hna");
+
+		if ((hna_buff_len > 0) && (hna_buff))
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
+	if ((orig_node->router) && (!neigh_node)) {
+
+		bat_dbg(DBG_ROUTES, bat_priv, "Deleting route towards: %pM\n",
+			orig_node->orig);
+		hna_global_del_orig(bat_priv, orig_node,
+				    "originator timed out");
+
+		/* route added */
+	} else if ((!orig_node->router) && (neigh_node)) {
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
+	orig_node->router =3D neigh_node;
+}
+
+
+void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_nod=
e,
+		   struct neigh_node *neigh_node, unsigned char *hna_buff,
+		   int hna_buff_len)
+{
+
+	if (!orig_node)
+		return;
+
+	if (orig_node->router !=3D neigh_node)
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
+	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
+	struct neigh_node *neigh_node =3D NULL, *tmp_neigh_node =3D NULL;
+	unsigned char total_count;
+
+	if (orig_node =3D=3D orig_neigh_node) {
+		list_for_each_entry(tmp_neigh_node,
+				    &orig_node->neigh_list,
+				    list) {
+
+			if (compare_orig(tmp_neigh_node->addr,
+					 orig_neigh_node->orig) &&
+			    (tmp_neigh_node->if_incoming =3D=3D if_incoming))
+				neigh_node =3D tmp_neigh_node;
+		}
+
+		if (!neigh_node)
+			neigh_node =3D create_neighbor(orig_node,
+						     orig_neigh_node,
+						     orig_neigh_node->orig,
+						     if_incoming);
+		/* create_neighbor failed, return 0 */
+		if (!neigh_node)
+			return 0;
+
+		neigh_node->last_valid =3D jiffies;
+	} else {
+		/* find packet count of corresponding one hop neighbor */
+		list_for_each_entry(tmp_neigh_node,
+				    &orig_neigh_node->neigh_list, list) {
+
+			if (compare_orig(tmp_neigh_node->addr,
+					 orig_neigh_node->orig) &&
+			    (tmp_neigh_node->if_incoming =3D=3D if_incoming))
+				neigh_node =3D tmp_neigh_node;
+		}
+
+		if (!neigh_node)
+			neigh_node =3D create_neighbor(orig_neigh_node,
+						     orig_neigh_node,
+						     orig_neigh_node->orig,
+						     if_incoming);
+		/* create_neighbor failed, return 0 */
+		if (!neigh_node)
+			return 0;
+	}
+
+	orig_node->last_valid =3D jiffies;
+
+	/* pay attention to not get a value bigger than 100 % */
+	total_count =3D (orig_neigh_node->bcast_own_sum[if_incoming->if_num] >
+		       neigh_node->real_packet_count ?
+		       neigh_node->real_packet_count :
+		       orig_neigh_node->bcast_own_sum[if_incoming->if_num]);
+
+	/* if we have too few packets (too less data) we set tq_own to zero */
+	/* if we receive too few packets it is not considered bidirectional */
+	if ((total_count < TQ_LOCAL_BIDRECT_SEND_MINIMUM) ||
+	    (neigh_node->real_packet_count < TQ_LOCAL_BIDRECT_RECV_MINIMUM))
+		orig_neigh_node->tq_own =3D 0;
+	else
+		/* neigh_node->real_packet_count is never zero as we
+		 * only purge old information when getting new
+		 * information */
+		orig_neigh_node->tq_own =3D (TQ_MAX_VALUE * total_count) /
+			neigh_node->real_packet_count;
+
+	/*
+	 * 1 - ((1-x) ** 3), normalized to TQ_MAX_VALUE this does
+	 * affect the nearly-symmetric links only a little, but
+	 * punishes asymmetric links more.  This will give a value
+	 * between 0 and TQ_MAX_VALUE
+	 */
+	orig_neigh_node->tq_asym_penalty =3D
+		TQ_MAX_VALUE -
+		(TQ_MAX_VALUE *
+		 (TQ_LOCAL_WINDOW_SIZE - neigh_node->real_packet_count) *
+		 (TQ_LOCAL_WINDOW_SIZE - neigh_node->real_packet_count) *
+		 (TQ_LOCAL_WINDOW_SIZE - neigh_node->real_packet_count)) /
+		(TQ_LOCAL_WINDOW_SIZE *
+		 TQ_LOCAL_WINDOW_SIZE *
+		 TQ_LOCAL_WINDOW_SIZE);
+
+	batman_packet->tq =3D ((batman_packet->tq *
+			      orig_neigh_node->tq_own *
+			      orig_neigh_node->tq_asym_penalty) /
+			     (TQ_MAX_VALUE * TQ_MAX_VALUE));
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"bidirectional: "
+		"orig =3D %-15pM neigh =3D %-15pM =3D> own_bcast =3D %2i, "
+		"real recv =3D %2i, local tq: %3i, asym_penalty: %3i, "
+		"total tq: %3i\n",
+		orig_node->orig, orig_neigh_node->orig, total_count,
+		neigh_node->real_packet_count, orig_neigh_node->tq_own,
+		orig_neigh_node->tq_asym_penalty, batman_packet->tq);
+
+	/* if link has the minimum required transmission quality
+	 * consider it bidirectional */
+	if (batman_packet->tq >=3D TQ_TOTAL_BIDRECT_LIMIT)
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
+	struct neigh_node *neigh_node =3D NULL, *tmp_neigh_node =3D NULL;
+	int tmp_hna_buff_len;
+
+	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
+		"Searching and updating originator entry of received packet\n");
+
+	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+		if (compare_orig(tmp_neigh_node->addr, ethhdr->h_source) &&
+		    (tmp_neigh_node->if_incoming =3D=3D if_incoming)) {
+			neigh_node =3D tmp_neigh_node;
+			continue;
+		}
+
+		if (is_duplicate)
+			continue;
+
+		ring_buffer_set(tmp_neigh_node->tq_recv,
+				&tmp_neigh_node->tq_index, 0);
+		tmp_neigh_node->tq_avg =3D
+			ring_buffer_avg(tmp_neigh_node->tq_recv);
+	}
+
+	if (!neigh_node) {
+		struct orig_node *orig_tmp;
+
+		orig_tmp =3D get_orig_node(bat_priv, ethhdr->h_source);
+		if (!orig_tmp)
+			return;
+
+		neigh_node =3D create_neighbor(orig_node, orig_tmp,
+					     ethhdr->h_source, if_incoming);
+		if (!neigh_node)
+			return;
+	} else
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Updating existing last-hop neighbor of originator\n");
+
+	orig_node->flags =3D batman_packet->flags;
+	neigh_node->last_valid =3D jiffies;
+
+	ring_buffer_set(neigh_node->tq_recv,
+			&neigh_node->tq_index,
+			batman_packet->tq);
+	neigh_node->tq_avg =3D ring_buffer_avg(neigh_node->tq_recv);
+
+	if (!is_duplicate) {
+		orig_node->last_ttl =3D batman_packet->ttl;
+		neigh_node->last_ttl =3D batman_packet->ttl;
+	}
+
+	tmp_hna_buff_len =3D (hna_buff_len > batman_packet->num_hna * ETH_ALEN =
?
+			    batman_packet->num_hna * ETH_ALEN : hna_buff_len);
+
+	/* if this neighbor already is our next hop there is nothing
+	 * to change */
+	if (orig_node->router =3D=3D neigh_node)
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
+	     ((neigh_node->tq_avg =3D=3D orig_node->router->tq_avg) &&
+	     (orig_node->router->orig_node->bcast_own_sum[if_incoming->if_num]
+	      >=3D neigh_node->orig_node->bcast_own_sum[if_incoming->if_num])))
+		goto update_hna;
+
+	update_routes(bat_priv, orig_node, neigh_node,
+		      hna_buff, tmp_hna_buff_len);
+	goto update_gw;
+
+update_hna:
+	update_routes(bat_priv, orig_node, orig_node->router,
+		      hna_buff, tmp_hna_buff_len);
+
+update_gw:
+	if (orig_node->gw_flags !=3D batman_packet->gw_flags)
+		gw_node_update(bat_priv, orig_node, batman_packet->gw_flags);
+
+	orig_node->gw_flags =3D batman_packet->gw_flags;
+
+	/* restart gateway selection if fast or late switching was enabled */
+	if ((orig_node->gw_flags) &&
+	    (atomic_read(&bat_priv->gw_mode) =3D=3D GW_MODE_CLIENT) &&
+	    (atomic_read(&bat_priv->gw_sel_class) > 2))
+		gw_check_election(bat_priv, orig_node);
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
+	if ((seq_num_diff <=3D -TQ_LOCAL_WINDOW_SIZE)
+		|| (seq_num_diff >=3D EXPECTED_SEQNO_RANGE)) {
+		if (time_after(jiffies, *last_reset +
+			msecs_to_jiffies(RESET_PROTECTION_MS))) {
+
+			*last_reset =3D jiffies;
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
+/* processes a batman packet for all interfaces, adjusts the sequence nu=
mber and
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
+	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
+	struct orig_node *orig_node;
+	struct neigh_node *tmp_neigh_node;
+	char is_duplicate =3D 0;
+	int32_t seq_diff;
+	int need_update =3D 0;
+	int set_mark;
+
+	orig_node =3D get_orig_node(bat_priv, batman_packet->orig);
+	if (!orig_node)
+		return 0;
+
+	seq_diff =3D batman_packet->seqno - orig_node->last_real_seqno;
+
+	/* signalize caller that the packet is to be dropped. */
+	if (window_protected(bat_priv, seq_diff,
+			     &orig_node->batman_seqno_reset))
+		return -1;
+
+	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+
+		is_duplicate |=3D get_bit_status(tmp_neigh_node->real_bits,
+					       orig_node->last_real_seqno,
+					       batman_packet->seqno);
+
+		if (compare_orig(tmp_neigh_node->addr, ethhdr->h_source) &&
+		    (tmp_neigh_node->if_incoming =3D=3D if_incoming))
+			set_mark =3D 1;
+		else
+			set_mark =3D 0;
+
+		/* if the window moved, set the update flag. */
+		need_update |=3D bit_get_packet(bat_priv,
+					      tmp_neigh_node->real_bits,
+					      seq_diff, set_mark);
+
+		tmp_neigh_node->real_packet_count =3D
+			bit_packet_count(tmp_neigh_node->real_bits);
+	}
+
+	if (need_update) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"updating last_seqno: old %d, new %d\n",
+			orig_node->last_real_seqno, batman_packet->seqno);
+		orig_node->last_real_seqno =3D batman_packet->seqno;
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
+		orig_node->bond.candidates =3D 0;
+		return;
+	}
+
+	best_tq =3D orig_node->router->tq_avg;
+
+	/* update bond.candidates */
+
+	candidates =3D 0;
+
+	/* mark other nodes which also received "PRIMARIES FIRST HOP" packets
+	 * as "bonding partner" */
+
+	/* first, zero the list */
+	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+		tmp_neigh_node->next_bond_candidate =3D NULL;
+	}
+
+	first_candidate =3D NULL;
+	last_candidate =3D NULL;
+	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+
+		/* only consider if it has the same primary address ...  */
+		if (memcmp(orig_node->orig,
+				tmp_neigh_node->orig_node->primary_addr,
+				ETH_ALEN) !=3D 0)
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
+		interference_candidate =3D 0;
+		list_for_each_entry(tmp_neigh_node2,
+				&orig_node->neigh_list, list) {
+
+			if (tmp_neigh_node2 =3D=3D tmp_neigh_node)
+				continue;
+
+			/* we only care if the other candidate is even
+			 * considered as candidate. */
+			if (!tmp_neigh_node2->next_bond_candidate)
+				continue;
+
+
+			if ((tmp_neigh_node->if_incoming =3D=3D
+				tmp_neigh_node2->if_incoming)
+				|| (memcmp(tmp_neigh_node->addr,
+				tmp_neigh_node2->addr, ETH_ALEN) =3D=3D 0)) {
+
+				interference_candidate =3D 1;
+				break;
+			}
+		}
+		/* don't care further if it is an interference candidate */
+		if (interference_candidate)
+			continue;
+
+		if (!first_candidate) {
+			first_candidate =3D tmp_neigh_node;
+			tmp_neigh_node->next_bond_candidate =3D first_candidate;
+		} else
+			tmp_neigh_node->next_bond_candidate =3D last_candidate;
+
+		last_candidate =3D tmp_neigh_node;
+
+		candidates++;
+	}
+
+	if (candidates > 0) {
+		first_candidate->next_bond_candidate =3D last_candidate;
+		orig_node->bond.selected =3D first_candidate;
+	}
+
+	orig_node->bond.candidates =3D candidates;
+}
+
+void receive_bat_packet(struct ethhdr *ethhdr,
+				struct batman_packet *batman_packet,
+				unsigned char *hna_buff, int hna_buff_len,
+				struct batman_if *if_incoming)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
+	struct batman_if *batman_if;
+	struct orig_node *orig_neigh_node, *orig_node;
+	char has_directlink_flag;
+	char is_my_addr =3D 0, is_my_orig =3D 0, is_my_oldorig =3D 0;
+	char is_broadcast =3D 0, is_bidirectional, is_single_hop_neigh;
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
+	if (batman_packet->packet_type !=3D BAT_PACKET)
+		return;
+
+	/* could be changed by schedule_own_packet() */
+	if_incoming_seqno =3D atomic_read(&if_incoming->seqno);
+
+	has_directlink_flag =3D (batman_packet->flags & DIRECTLINK ? 1 : 0);
+
+	is_single_hop_neigh =3D (compare_orig(ethhdr->h_source,
+					    batman_packet->orig) ? 1 : 0);
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Received BATMAN packet via NB: %pM, IF: %s [%pM] "
+		"(from OG: %pM, via prev OG: %pM, seqno %d, tq %d, "
+		"TTL %d, V %d, IDF %d)\n",
+		ethhdr->h_source, if_incoming->net_dev->name,
+		if_incoming->net_dev->dev_addr, batman_packet->orig,
+		batman_packet->prev_sender, batman_packet->seqno,
+		batman_packet->tq, batman_packet->ttl, batman_packet->version,
+		has_directlink_flag);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->if_status !=3D IF_ACTIVE)
+			continue;
+
+		if (batman_if->soft_iface !=3D if_incoming->soft_iface)
+			continue;
+
+		if (compare_orig(ethhdr->h_source,
+				 batman_if->net_dev->dev_addr))
+			is_my_addr =3D 1;
+
+		if (compare_orig(batman_packet->orig,
+				 batman_if->net_dev->dev_addr))
+			is_my_orig =3D 1;
+
+		if (compare_orig(batman_packet->prev_sender,
+				 batman_if->net_dev->dev_addr))
+			is_my_oldorig =3D 1;
+
+		if (compare_orig(ethhdr->h_source, broadcast_addr))
+			is_broadcast =3D 1;
+	}
+	rcu_read_unlock();
+
+	if (batman_packet->version !=3D COMPAT_VERSION) {
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
+		unsigned long *word;
+		int offset;
+
+		orig_neigh_node =3D get_orig_node(bat_priv, ethhdr->h_source);
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
+		    (batman_packet->seqno - if_incoming_seqno + 2 =3D=3D 0)) {
+			offset =3D if_incoming->if_num * NUM_WORDS;
+			word =3D &(orig_neigh_node->bcast_own[offset]);
+			bit_mark(word, 0);
+			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =3D
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
+	orig_node =3D get_orig_node(bat_priv, batman_packet->orig);
+	if (!orig_node)
+		return;
+
+	is_duplicate =3D count_real_packets(ethhdr, batman_packet, if_incoming)=
;
+
+	if (is_duplicate =3D=3D -1) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: packet within seqno protection time "
+			"(sender: %pM)\n", ethhdr->h_source);
+		return;
+	}
+
+	if (batman_packet->tq =3D=3D 0) {
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
+	orig_neigh_node =3D (is_single_hop_neigh ?
+			   orig_node :
+			   get_orig_node(bat_priv, ethhdr->h_source));
+	if (!orig_neigh_node)
+		return;
+
+	/* drop packet if sender is not a direct neighbor and if we
+	 * don't route towards it */
+	if (!is_single_hop_neigh && (!orig_neigh_node->router)) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: OGM via unknown neighbor!\n");
+		return;
+	}
+
+	is_bidirectional =3D is_bidirectional_neigh(orig_node, orig_neigh_node,
+						batman_packet, if_incoming);
+
+	/* update ranking if it is not a duplicate or has the same
+	 * seqno and similar ttl as the non-duplicate */
+	if (is_bidirectional &&
+	    (!is_duplicate ||
+	     ((orig_node->last_real_seqno =3D=3D batman_packet->seqno) &&
+	      (orig_node->last_ttl - 3 <=3D batman_packet->ttl))))
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
+	struct bat_priv *bat_priv =3D netdev_priv(batman_if->soft_iface);
+	struct ethhdr *ethhdr;
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct batman_packet))))
+		return NET_RX_DROP;
+
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with broadcast indication but unicast recipient */
+	if (!is_broadcast_ether_addr(ethhdr->h_dest))
+		return NET_RX_DROP;
+
+	/* packet with broadcast sender address */
+	if (is_broadcast_ether_addr(ethhdr->h_source))
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
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	receive_aggr_bat_packet(ethhdr,
+				skb->data,
+				skb_headlen(skb),
+				batman_if);
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
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
+	uint8_t dstaddr[ETH_ALEN];
+
+	icmp_packet =3D (struct icmp_packet_rr *)skb->data;
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	/* add data to device queue */
+	if (icmp_packet->msg_type !=3D ECHO_REQUEST) {
+		bat_socket_receive_packet(icmp_packet, icmp_len);
+		return NET_RX_DROP;
+	}
+
+	if (!bat_priv->primary_if)
+		return NET_RX_DROP;
+
+	/* answer echo request (ping) */
+	/* get routing information */
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	orig_node =3D ((struct orig_node *)hash_find(bat_priv->orig_hash,
+						   compare_orig, choose_orig,
+						   icmp_packet->orig));
+	ret =3D NET_RX_DROP;
+
+	if ((orig_node) && (orig_node->router)) {
+
+		/* don't lock while sending the packets ... we therefore
+		 * copy the required data before sending */
+		batman_if =3D orig_node->router->if_incoming;
+		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+		/* create a copy of the skb, if needed, to modify it. */
+		if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+			return NET_RX_DROP;
+
+		icmp_packet =3D (struct icmp_packet_rr *)skb->data;
+		ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+		memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
+		memcpy(icmp_packet->orig,
+		       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+		icmp_packet->msg_type =3D ECHO_REPLY;
+		icmp_packet->ttl =3D TTL;
+
+		send_skb_packet(skb, batman_if, dstaddr);
+		ret =3D NET_RX_SUCCESS;
+
+	} else
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
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
+	uint8_t dstaddr[ETH_ALEN];
+
+	icmp_packet =3D (struct icmp_packet *)skb->data;
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	/* send TTL exceeded if packet is an echo request (traceroute) */
+	if (icmp_packet->msg_type !=3D ECHO_REQUEST) {
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
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	orig_node =3D ((struct orig_node *)
+		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
+			       icmp_packet->orig));
+	ret =3D NET_RX_DROP;
+
+	if ((orig_node) && (orig_node->router)) {
+
+		/* don't lock while sending the packets ... we therefore
+		 * copy the required data before sending */
+		batman_if =3D orig_node->router->if_incoming;
+		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+		/* create a copy of the skb, if needed, to modify it. */
+		if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+			return NET_RX_DROP;
+
+		icmp_packet =3D (struct icmp_packet *) skb->data;
+		ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+		memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
+		memcpy(icmp_packet->orig,
+		       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+		icmp_packet->msg_type =3D TTL_EXCEEDED;
+		icmp_packet->ttl =3D TTL;
+
+		send_skb_packet(skb, batman_if, dstaddr);
+		ret =3D NET_RX_SUCCESS;
+
+	} else
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	return ret;
+}
+
+
+int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct icmp_packet_rr *icmp_packet;
+	struct ethhdr *ethhdr;
+	struct orig_node *orig_node;
+	struct batman_if *batman_if;
+	int hdr_size =3D sizeof(struct icmp_packet);
+	int ret;
+	uint8_t dstaddr[ETH_ALEN];
+
+	/**
+	 * we truncate all incoming icmp packets if they don't match our size
+	 */
+	if (skb->len >=3D sizeof(struct icmp_packet_rr))
+		hdr_size =3D sizeof(struct icmp_packet_rr);
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, hdr_size)))
+		return NET_RX_DROP;
+
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with unicast indication but broadcast recipient */
+	if (is_broadcast_ether_addr(ethhdr->h_dest))
+		return NET_RX_DROP;
+
+	/* packet with broadcast sender address */
+	if (is_broadcast_ether_addr(ethhdr->h_source))
+		return NET_RX_DROP;
+
+	/* not for me */
+	if (!is_my_mac(ethhdr->h_dest))
+		return NET_RX_DROP;
+
+	icmp_packet =3D (struct icmp_packet_rr *)skb->data;
+
+	/* add record route information if not full */
+	if ((hdr_size =3D=3D sizeof(struct icmp_packet_rr)) &&
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
+	ret =3D NET_RX_DROP;
+
+	/* get routing information */
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	orig_node =3D ((struct orig_node *)
+		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
+			       icmp_packet->dst));
+
+	if ((orig_node) && (orig_node->router)) {
+
+		/* don't lock while sending the packets ... we therefore
+		 * copy the required data before sending */
+		batman_if =3D orig_node->router->if_incoming;
+		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+		/* create a copy of the skb, if needed, to modify it. */
+		if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+			return NET_RX_DROP;
+
+		icmp_packet =3D (struct icmp_packet_rr *)skb->data;
+		ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+		/* decrement ttl */
+		icmp_packet->ttl--;
+
+		/* route it */
+		send_skb_packet(skb, batman_if, dstaddr);
+		ret =3D NET_RX_SUCCESS;
+
+	} else
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	return ret;
+}
+
+/* find a suitable router for this originator, and use
+ * bonding if possible. */
+struct neigh_node *find_router(struct bat_priv *bat_priv,
+			       struct orig_node *orig_node,
+			       struct batman_if *recv_if)
+{
+	struct orig_node *primary_orig_node;
+	struct orig_node *router_orig;
+	struct neigh_node *router, *first_candidate, *best_router;
+	static uint8_t zero_mac[ETH_ALEN] =3D {0, 0, 0, 0, 0, 0};
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
+	bonding_enabled =3D atomic_read(&bat_priv->bonding);
+
+	if ((!recv_if) && (!bonding_enabled))
+		return orig_node->router;
+
+	router_orig =3D orig_node->router->orig_node;
+
+	/* if we have something in the primary_addr, we can search
+	 * for a potential bonding candidate. */
+	if (memcmp(router_orig->primary_addr, zero_mac, ETH_ALEN) =3D=3D 0)
+		return orig_node->router;
+
+	/* find the orig_node which has the primary interface. might
+	 * even be the same as our router_orig in many cases */
+
+	if (memcmp(router_orig->primary_addr,
+				router_orig->orig, ETH_ALEN) =3D=3D 0) {
+		primary_orig_node =3D router_orig;
+	} else {
+		primary_orig_node =3D hash_find(bat_priv->orig_hash, compare_orig,
+					       choose_orig,
+					       router_orig->primary_addr);
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
+	first_candidate =3D primary_orig_node->bond.selected;
+	router =3D first_candidate;
+
+	if (bonding_enabled) {
+		/* in the bonding case, send the packets in a round
+		 * robin fashion over the remaining interfaces. */
+		do {
+			/* recv_if =3D=3D NULL on the first node. */
+			if (router->if_incoming !=3D recv_if)
+				break;
+
+			router =3D router->next_bond_candidate;
+		} while (router !=3D first_candidate);
+
+		primary_orig_node->bond.selected =3D router->next_bond_candidate;
+
+	} else {
+		/* if bonding is disabled, use the best of the
+		 * remaining candidates which are not using
+		 * this interface. */
+		best_router =3D first_candidate;
+
+		do {
+			/* recv_if =3D=3D NULL on the first node. */
+			if ((router->if_incoming !=3D recv_if) &&
+				(router->tq_avg > best_router->tq_avg))
+					best_router =3D router;
+
+			router =3D router->next_bond_candidate;
+		} while (router !=3D first_candidate);
+
+		router =3D best_router;
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
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with unicast indication but broadcast recipient */
+	if (is_broadcast_ether_addr(ethhdr->h_dest))
+		return -1;
+
+	/* packet with broadcast sender address */
+	if (is_broadcast_ether_addr(ethhdr->h_source))
+		return -1;
+
+	/* not for me */
+	if (!is_my_mac(ethhdr->h_dest))
+		return -1;
+
+	return 0;
+}
+
+int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
+			 int hdr_size)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct orig_node *orig_node;
+	struct neigh_node *router;
+	struct batman_if *batman_if;
+	uint8_t dstaddr[ETH_ALEN];
+	struct unicast_packet *unicast_packet;
+	struct ethhdr *ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+	int ret;
+	struct sk_buff *new_skb;
+
+	unicast_packet =3D (struct unicast_packet *)skb->data;
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
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	orig_node =3D ((struct orig_node *)
+		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
+			       unicast_packet->dest));
+
+	router =3D find_router(bat_priv, orig_node, recv_if);
+
+	if (!router) {
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
+		return NET_RX_DROP;
+	}
+
+	/* don't lock while sending the packets ... we therefore
+	 * copy the required data before sending */
+
+	batman_if =3D router->if_incoming;
+	memcpy(dstaddr, router->addr, ETH_ALEN);
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	/* create a copy of the skb, if needed, to modify it. */
+	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+		return NET_RX_DROP;
+
+	unicast_packet =3D (struct unicast_packet *)skb->data;
+
+	if (unicast_packet->packet_type =3D=3D BAT_UNICAST &&
+	    atomic_read(&bat_priv->fragmentation) &&
+	    skb->len > batman_if->net_dev->mtu)
+		return frag_send_skb(skb, bat_priv, batman_if,
+				     dstaddr);
+
+	if (unicast_packet->packet_type =3D=3D BAT_UNICAST_FRAG &&
+	    2 * skb->len - hdr_size <=3D batman_if->net_dev->mtu) {
+
+		ret =3D frag_reassemble_skb(skb, bat_priv, &new_skb);
+
+		if (ret =3D=3D NET_RX_DROP)
+			return NET_RX_DROP;
+
+		/* packet was buffered for late merge */
+		if (!new_skb)
+			return NET_RX_SUCCESS;
+
+		skb =3D new_skb;
+		unicast_packet =3D (struct unicast_packet *)skb->data;
+	}
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
+	int hdr_size =3D sizeof(struct unicast_packet);
+
+	if (check_unicast_packet(skb, hdr_size) < 0)
+		return NET_RX_DROP;
+
+	unicast_packet =3D (struct unicast_packet *)skb->data;
+
+	/* packet for me */
+	if (is_my_mac(unicast_packet->dest)) {
+		interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size);
+		return NET_RX_SUCCESS;
+	}
+
+	return route_unicast_packet(skb, recv_if, hdr_size);
+}
+
+int recv_ucast_frag_packet(struct sk_buff *skb, struct batman_if *recv_i=
f)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct unicast_frag_packet *unicast_packet;
+	int hdr_size =3D sizeof(struct unicast_frag_packet);
+	struct sk_buff *new_skb =3D NULL;
+	int ret;
+
+	if (check_unicast_packet(skb, hdr_size) < 0)
+		return NET_RX_DROP;
+
+	unicast_packet =3D (struct unicast_frag_packet *)skb->data;
+
+	/* packet for me */
+	if (is_my_mac(unicast_packet->dest)) {
+
+		ret =3D frag_reassemble_skb(skb, bat_priv, &new_skb);
+
+		if (ret =3D=3D NET_RX_DROP)
+			return NET_RX_DROP;
+
+		/* packet was buffered for late merge */
+		if (!new_skb)
+			return NET_RX_SUCCESS;
+
+		interface_rx(recv_if->soft_iface, new_skb, recv_if,
+			     sizeof(struct unicast_packet));
+		return NET_RX_SUCCESS;
+	}
+
+	return route_unicast_packet(skb, recv_if, hdr_size);
+}
+
+
+int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct orig_node *orig_node;
+	struct bcast_packet *bcast_packet;
+	struct ethhdr *ethhdr;
+	int hdr_size =3D sizeof(struct bcast_packet);
+	int32_t seq_diff;
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, hdr_size)))
+		return NET_RX_DROP;
+
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with broadcast indication but unicast recipient */
+	if (!is_broadcast_ether_addr(ethhdr->h_dest))
+		return NET_RX_DROP;
+
+	/* packet with broadcast sender address */
+	if (is_broadcast_ether_addr(ethhdr->h_source))
+		return NET_RX_DROP;
+
+	/* ignore broadcasts sent by myself */
+	if (is_my_mac(ethhdr->h_source))
+		return NET_RX_DROP;
+
+	bcast_packet =3D (struct bcast_packet *)skb->data;
+
+	/* ignore broadcasts originated by myself */
+	if (is_my_mac(bcast_packet->orig))
+		return NET_RX_DROP;
+
+	if (bcast_packet->ttl < 2)
+		return NET_RX_DROP;
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	orig_node =3D ((struct orig_node *)
+		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
+			       bcast_packet->orig));
+
+	if (!orig_node) {
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
+		return NET_RX_DROP;
+	}
+
+	/* check whether the packet is a duplicate */
+	if (get_bit_status(orig_node->bcast_bits,
+			   orig_node->last_bcast_seqno,
+			   ntohl(bcast_packet->seqno))) {
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
+		return NET_RX_DROP;
+	}
+
+	seq_diff =3D ntohl(bcast_packet->seqno) - orig_node->last_bcast_seqno;
+
+	/* check whether the packet is old and the host just restarted. */
+	if (window_protected(bat_priv, seq_diff,
+			     &orig_node->bcast_seqno_reset)) {
+		spin_unlock_bh(&bat_priv->orig_hash_lock);
+		return NET_RX_DROP;
+	}
+
+	/* mark broadcast in flood history, update window position
+	 * if required. */
+	if (bit_get_packet(bat_priv, orig_node->bcast_bits, seq_diff, 1))
+		orig_node->last_bcast_seqno =3D ntohl(bcast_packet->seqno);
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+	/* rebroadcast packet */
+	add_bcast_packet_to_list(bat_priv, skb);
+
+	/* broadcast for me */
+	interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size);
+
+	return NET_RX_SUCCESS;
+}
+
+int recv_vis_packet(struct sk_buff *skb, struct batman_if *recv_if)
+{
+	struct vis_packet *vis_packet;
+	struct ethhdr *ethhdr;
+	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	int hdr_size =3D sizeof(struct vis_packet);
+
+	/* keep skb linear */
+	if (skb_linearize(skb) < 0)
+		return NET_RX_DROP;
+
+	if (unlikely(!pskb_may_pull(skb, hdr_size)))
+		return NET_RX_DROP;
+
+	vis_packet =3D (struct vis_packet *)skb->data;
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
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
index 0000000..f108f23
--- /dev/null
+++ b/net/batman-adv/routing.h
@@ -0,0 +1,48 @@
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
+void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_nod=
e,
+		   struct neigh_node *neigh_node, unsigned char *hna_buff,
+		   int hna_buff_len);
+int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
+			 int hdr_size);
+int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_ucast_frag_packet(struct sk_buff *skb, struct batman_if *recv_i=
f);
+int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_vis_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_bat_packet(struct sk_buff *skb, struct batman_if *recv_if);
+struct neigh_node *find_router(struct bat_priv *bat_priv,
+		struct orig_node *orig_node, struct batman_if *recv_if);
+void update_bonding_candidates(struct bat_priv *bat_priv,
+			       struct orig_node *orig_node);
+
+#endif /* _NET_BATMAN_ADV_ROUTING_H_ */
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
new file mode 100644
index 0000000..b89b9f7
--- /dev/null
+++ b/net/batman-adv/send.c
@@ -0,0 +1,585 @@
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
+#include "gateway_common.h"
+#include "originator.h"
+
+static void send_outstanding_bcast_packet(struct work_struct *work);
+
+/* apply hop penalty for a normal link */
+static uint8_t hop_penalty(const uint8_t tq, struct bat_priv *bat_priv)
+{
+	int hop_penalty =3D atomic_read(&bat_priv->hop_penalty);
+	return (tq * (TQ_MAX_VALUE - hop_penalty)) / (TQ_MAX_VALUE);
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
+	if (batman_if->if_status !=3D IF_ACTIVE)
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
+	ethhdr =3D (struct ethhdr *) skb_mac_header(skb);
+	memcpy(ethhdr->h_source, batman_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(ethhdr->h_dest, dst_addr, ETH_ALEN);
+	ethhdr->h_proto =3D __constant_htons(ETH_P_BATMAN);
+
+	skb_set_network_header(skb, ETH_HLEN);
+	skb->priority =3D TC_PRIO_CONTROL;
+	skb->protocol =3D __constant_htons(ETH_P_BATMAN);
+
+	skb->dev =3D batman_if->net_dev;
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
+	struct bat_priv *bat_priv =3D netdev_priv(batman_if->soft_iface);
+	char *fwd_str;
+	uint8_t packet_num;
+	int16_t buff_pos;
+	struct batman_packet *batman_packet;
+	struct sk_buff *skb;
+
+	if (batman_if->if_status !=3D IF_ACTIVE)
+		return;
+
+	packet_num =3D 0;
+	buff_pos =3D 0;
+	batman_packet =3D (struct batman_packet *)forw_packet->skb->data;
+
+	/* adjust all flags and log packets */
+	while (aggregated_packet(buff_pos,
+				 forw_packet->packet_len,
+				 batman_packet->num_hna)) {
+
+		/* we might have aggregated direct link packets with an
+		 * ordinary base packet */
+		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
+		    (forw_packet->if_incoming =3D=3D batman_if))
+			batman_packet->flags |=3D DIRECTLINK;
+		else
+			batman_packet->flags &=3D ~DIRECTLINK;
+
+		fwd_str =3D (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
+							    "Sending own" :
+							    "Forwarding"));
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d,"
+			" IDF %s) on interface %s [%pM]\n",
+			fwd_str, (packet_num > 0 ? "aggregated " : ""),
+			batman_packet->orig, ntohl(batman_packet->seqno),
+			batman_packet->tq, batman_packet->ttl,
+			(batman_packet->flags & DIRECTLINK ?
+			 "on" : "off"),
+			batman_if->net_dev->name, batman_if->net_dev->dev_addr);
+
+		buff_pos +=3D sizeof(struct batman_packet) +
+			(batman_packet->num_hna * ETH_ALEN);
+		packet_num++;
+		batman_packet =3D (struct batman_packet *)
+			(forw_packet->skb->data + buff_pos);
+	}
+
+	/* create clone because function is called more than once */
+	skb =3D skb_clone(forw_packet->skb, GFP_ATOMIC);
+	if (skb)
+		send_skb_packet(skb, batman_if, broadcast_addr);
+}
+
+/* send a batman packet */
+static void send_packet(struct forw_packet *forw_packet)
+{
+	struct batman_if *batman_if;
+	struct net_device *soft_iface;
+	struct bat_priv *bat_priv;
+	struct batman_packet *batman_packet =3D
+		(struct batman_packet *)(forw_packet->skb->data);
+	unsigned char directlink =3D (batman_packet->flags & DIRECTLINK ? 1 : 0=
);
+
+	if (!forw_packet->if_incoming) {
+		pr_err("Error - can't forward packet: incoming iface not "
+		       "specified\n");
+		return;
+	}
+
+	soft_iface =3D forw_packet->if_incoming->soft_iface;
+	bat_priv =3D netdev_priv(soft_iface);
+
+	if (forw_packet->if_incoming->if_status !=3D IF_ACTIVE)
+		return;
+
+	/* multihomed peer assumed */
+	/* non-primary OGMs are only broadcasted on their interface */
+	if ((directlink && (batman_packet->ttl =3D=3D 1)) ||
+	    (forw_packet->own && (forw_packet->if_incoming->if_num > 0))) {
+
+		/* FIXME: what about aggregated packets ? */
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"%s packet (originator %pM, seqno %d, TTL %d) "
+			"on interface %s [%pM]\n",
+			(forw_packet->own ? "Sending own" : "Forwarding"),
+			batman_packet->orig, ntohl(batman_packet->seqno),
+			batman_packet->ttl,
+			forw_packet->if_incoming->net_dev->name,
+			forw_packet->if_incoming->net_dev->dev_addr);
+
+		/* skb is only used once and than forw_packet is free'd */
+		send_skb_packet(forw_packet->skb, forw_packet->if_incoming,
+				broadcast_addr);
+		forw_packet->skb =3D NULL;
+
+		return;
+	}
+
+	/* broadcast on every interface */
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->soft_iface !=3D soft_iface)
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
+	new_len =3D sizeof(struct batman_packet) +
+			(bat_priv->num_local_hna * ETH_ALEN);
+	new_buff =3D kmalloc(new_len, GFP_ATOMIC);
+
+	/* keep old buffer if kmalloc should fail */
+	if (new_buff) {
+		memcpy(new_buff, batman_if->packet_buff,
+		       sizeof(struct batman_packet));
+		batman_packet =3D (struct batman_packet *)new_buff;
+
+		batman_packet->num_hna =3D hna_local_fill_buffer(bat_priv,
+				new_buff + sizeof(struct batman_packet),
+				new_len - sizeof(struct batman_packet));
+
+		kfree(batman_if->packet_buff);
+		batman_if->packet_buff =3D new_buff;
+		batman_if->packet_len =3D new_len;
+	}
+}
+
+void schedule_own_packet(struct batman_if *batman_if)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(batman_if->soft_iface);
+	unsigned long send_time;
+	struct batman_packet *batman_packet;
+	int vis_server;
+
+	if ((batman_if->if_status =3D=3D IF_NOT_IN_USE) ||
+	    (batman_if->if_status =3D=3D IF_TO_BE_REMOVED))
+		return;
+
+	vis_server =3D atomic_read(&bat_priv->vis_mode);
+
+	/**
+	 * the interface gets activated here to avoid race conditions between
+	 * the moment of activating the interface in
+	 * hardif_activate_interface() where the originator mac is set and
+	 * outdated packets (especially uninitialized mac addresses) in the
+	 * packet queue
+	 */
+	if (batman_if->if_status =3D=3D IF_TO_BE_ACTIVATED)
+		batman_if->if_status =3D IF_ACTIVE;
+
+	/* if local hna has changed and interface is a primary interface */
+	if ((atomic_read(&bat_priv->hna_local_changed)) &&
+	    (batman_if =3D=3D bat_priv->primary_if))
+		rebuild_batman_packet(bat_priv, batman_if);
+
+	/**
+	 * NOTE: packet_buff might just have been re-allocated in
+	 * rebuild_batman_packet()
+	 */
+	batman_packet =3D (struct batman_packet *)batman_if->packet_buff;
+
+	/* change sequence number to network order */
+	batman_packet->seqno =3D
+		htonl((uint32_t)atomic_read(&batman_if->seqno));
+
+	if (vis_server =3D=3D VIS_TYPE_SERVER_SYNC)
+		batman_packet->flags |=3D VIS_SERVER;
+	else
+		batman_packet->flags &=3D ~VIS_SERVER;
+
+	if ((batman_if =3D=3D bat_priv->primary_if) &&
+	    (atomic_read(&bat_priv->gw_mode) =3D=3D GW_MODE_SERVER))
+		batman_packet->gw_flags =3D
+				(uint8_t)atomic_read(&bat_priv->gw_bandwidth);
+	else
+		batman_packet->gw_flags =3D 0;
+
+	atomic_inc(&batman_if->seqno);
+
+	slide_own_bcast_window(batman_if);
+	send_time =3D own_send_time(bat_priv);
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
+	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
+	unsigned char in_tq, in_ttl, tq_avg =3D 0;
+	unsigned long send_time;
+
+	if (batman_packet->ttl <=3D 1) {
+		bat_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
+		return;
+	}
+
+	in_tq =3D batman_packet->tq;
+	in_ttl =3D batman_packet->ttl;
+
+	batman_packet->ttl--;
+	memcpy(batman_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
+
+	/* rebroadcast tq of our best ranking neighbor to ensure the rebroadcas=
t
+	 * of our best tq value */
+	if ((orig_node->router) && (orig_node->router->tq_avg !=3D 0)) {
+
+		/* rebroadcast ogm of best ranking neighbor as is */
+		if (!compare_orig(orig_node->router->addr, ethhdr->h_source)) {
+			batman_packet->tq =3D orig_node->router->tq_avg;
+
+			if (orig_node->router->last_ttl)
+				batman_packet->ttl =3D orig_node->router->last_ttl
+							- 1;
+		}
+
+		tq_avg =3D orig_node->router->tq_avg;
+	}
+
+	/* apply hop penalty */
+	batman_packet->tq =3D hop_penalty(batman_packet->tq, bat_priv);
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Forwarding packet: tq_orig: %i, tq_avg: %i, "
+		"tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
+		in_tq, tq_avg, batman_packet->tq, in_ttl - 1,
+		batman_packet->ttl);
+
+	batman_packet->seqno =3D htonl(batman_packet->seqno);
+
+	/* switch of primaries first hop flag when forwarding */
+	batman_packet->flags &=3D ~PRIMARIES_FIRST_HOP;
+	if (directlink)
+		batman_packet->flags |=3D DIRECTLINK;
+	else
+		batman_packet->flags &=3D ~DIRECTLINK;
+
+	send_time =3D forward_send_time(bat_priv);
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
+	INIT_HLIST_NODE(&forw_packet->list);
+
+	/* add new packet to packet list */
+	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
+	hlist_add_head(&forw_packet->list, &bat_priv->forw_bcast_list);
+	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
+
+	/* start timer for this packet */
+	INIT_DELAYED_WORK(&forw_packet->delayed_work,
+			  send_outstanding_bcast_packet);
+	queue_delayed_work(bat_event_workqueue, &forw_packet->delayed_work,
+			   send_time);
+}
+
+#define atomic_dec_not_zero(v)          atomic_add_unless((v), -1, 0)
+/* add a broadcast packet to the queue and setup timers. broadcast packe=
ts
+ * are sent multiple times to increase probability for beeing received.
+ *
+ * This function returns NETDEV_TX_OK on success and NETDEV_TX_BUSY on
+ * errors.
+ *
+ * The skb is not consumed, so the caller should make sure that the
+ * skb is freed. */
+int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *=
skb)
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
+	forw_packet =3D kmalloc(sizeof(struct forw_packet), GFP_ATOMIC);
+
+	if (!forw_packet)
+		goto out_and_inc;
+
+	skb =3D skb_copy(skb, GFP_ATOMIC);
+	if (!skb)
+		goto packet_free;
+
+	/* as we have a copy now, it is safe to decrease the TTL */
+	bcast_packet =3D (struct bcast_packet *)skb->data;
+	bcast_packet->ttl--;
+
+	skb_reset_mac_header(skb);
+
+	forw_packet->skb =3D skb;
+	forw_packet->if_incoming =3D bat_priv->primary_if;
+
+	/* how often did we send the bcast packet ? */
+	forw_packet->num_packets =3D 0;
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
+	struct delayed_work *delayed_work =3D
+		container_of(work, struct delayed_work, work);
+	struct forw_packet *forw_packet =3D
+		container_of(delayed_work, struct forw_packet, delayed_work);
+	struct sk_buff *skb1;
+	struct net_device *soft_iface =3D forw_packet->if_incoming->soft_iface;
+	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+
+	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
+	hlist_del(&forw_packet->list);
+	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
+
+	if (atomic_read(&bat_priv->mesh_state) =3D=3D MESH_DEACTIVATING)
+		goto out;
+
+	/* rebroadcast packet */
+	rcu_read_lock();
+	list_for_each_entry_rcu(batman_if, &if_list, list) {
+		if (batman_if->soft_iface !=3D soft_iface)
+			continue;
+
+		/* send a copy of the saved skb */
+		skb1 =3D skb_clone(forw_packet->skb, GFP_ATOMIC);
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
+	struct delayed_work *delayed_work =3D
+		container_of(work, struct delayed_work, work);
+	struct forw_packet *forw_packet =3D
+		container_of(delayed_work, struct forw_packet, delayed_work);
+	struct bat_priv *bat_priv;
+
+	bat_priv =3D netdev_priv(forw_packet->if_incoming->soft_iface);
+	spin_lock_bh(&bat_priv->forw_bat_list_lock);
+	hlist_del(&forw_packet->list);
+	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
+
+	if (atomic_read(&bat_priv->mesh_state) =3D=3D MESH_DEACTIVATING)
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
+	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
+	hlist_for_each_entry_safe(forw_packet, tmp_node, safe_tmp_node,
+				  &bat_priv->forw_bcast_list, list) {
+
+		/**
+		 * if purge_outstanding_packets() was called with an argmument
+		 * we delete only packets belonging to the given interface
+		 */
+		if ((batman_if) &&
+		    (forw_packet->if_incoming !=3D batman_if))
+			continue;
+
+		spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
+
+		/**
+		 * send_outstanding_bcast_packet() will lock the list to
+		 * delete the item from the list
+		 */
+		cancel_delayed_work_sync(&forw_packet->delayed_work);
+		spin_lock_bh(&bat_priv->forw_bcast_list_lock);
+	}
+	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
+
+	/* free batman packet list */
+	spin_lock_bh(&bat_priv->forw_bat_list_lock);
+	hlist_for_each_entry_safe(forw_packet, tmp_node, safe_tmp_node,
+				  &bat_priv->forw_bat_list, list) {
+
+		/**
+		 * if purge_outstanding_packets() was called with an argmument
+		 * we delete only packets belonging to the given interface
+		 */
+		if ((batman_if) &&
+		    (forw_packet->if_incoming !=3D batman_if))
+			continue;
+
+		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
+
+		/**
+		 * send_outstanding_bat_packet() will lock the list to
+		 * delete the item from the list
+		 */
+		cancel_delayed_work_sync(&forw_packet->delayed_work);
+		spin_lock_bh(&bat_priv->forw_bat_list_lock);
+	}
+	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
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
+int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *=
skb);
+void send_outstanding_bat_packet(struct work_struct *work);
+void purge_outstanding_packets(struct bat_priv *bat_priv,
+			       struct batman_if *batman_if);
+
+#endif /* _NET_BATMAN_ADV_SEND_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interf=
ace.c
new file mode 100644
index 0000000..e89ede1
--- /dev/null
+++ b/net/batman-adv/soft-interface.c
@@ -0,0 +1,697 @@
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
+#include "gateway_common.h"
+#include "gateway_client.h"
+#include "send.h"
+#include "bat_sysfs.h"
+#include <linux/slab.h>
+#include <linux/ethtool.h>
+#include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
+#include "unicast.h"
+#include "routing.h"
+
+
+static int bat_get_settings(struct net_device *dev, struct ethtool_cmd *=
cmd);
+static void bat_get_drvinfo(struct net_device *dev,
+			    struct ethtool_drvinfo *info);
+static u32 bat_get_msglevel(struct net_device *dev);
+static void bat_set_msglevel(struct net_device *dev, u32 value);
+static u32 bat_get_link(struct net_device *dev);
+static u32 bat_get_rx_csum(struct net_device *dev);
+static int bat_set_rx_csum(struct net_device *dev, u32 data);
+
+static const struct ethtool_ops bat_ethtool_ops =3D {
+	.get_settings =3D bat_get_settings,
+	.get_drvinfo =3D bat_get_drvinfo,
+	.get_msglevel =3D bat_get_msglevel,
+	.set_msglevel =3D bat_set_msglevel,
+	.get_link =3D bat_get_link,
+	.get_rx_csum =3D bat_get_rx_csum,
+	.set_rx_csum =3D bat_set_rx_csum
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
+	result =3D skb_cow_head(skb, len);
+	if (result < 0)
+		return result;
+
+	skb_push(skb, len);
+	return 0;
+}
+
+static void softif_neigh_free_ref(struct kref *refcount)
+{
+	struct softif_neigh *softif_neigh;
+
+	softif_neigh =3D container_of(refcount, struct softif_neigh, refcount);
+	kfree(softif_neigh);
+}
+
+static void softif_neigh_free_rcu(struct rcu_head *rcu)
+{
+	struct softif_neigh *softif_neigh;
+
+	softif_neigh =3D container_of(rcu, struct softif_neigh, rcu);
+	kref_put(&softif_neigh->refcount, softif_neigh_free_ref);
+}
+
+void softif_neigh_purge(struct bat_priv *bat_priv)
+{
+	struct softif_neigh *softif_neigh, *softif_neigh_tmp;
+	struct hlist_node *node, *node_tmp;
+
+	spin_lock_bh(&bat_priv->softif_neigh_lock);
+
+	hlist_for_each_entry_safe(softif_neigh, node, node_tmp,
+				  &bat_priv->softif_neigh_list, list) {
+
+		if ((!time_after(jiffies, softif_neigh->last_seen +
+				msecs_to_jiffies(SOFTIF_NEIGH_TIMEOUT))) &&
+		    (atomic_read(&bat_priv->mesh_state) =3D=3D MESH_ACTIVE))
+			continue;
+
+		hlist_del_rcu(&softif_neigh->list);
+
+		if (bat_priv->softif_neigh =3D=3D softif_neigh) {
+			bat_dbg(DBG_ROUTES, bat_priv,
+				 "Current mesh exit point '%pM' vanished "
+				 "(vid: %d).\n",
+				 softif_neigh->addr, softif_neigh->vid);
+			softif_neigh_tmp =3D bat_priv->softif_neigh;
+			bat_priv->softif_neigh =3D NULL;
+			kref_put(&softif_neigh_tmp->refcount,
+				 softif_neigh_free_ref);
+		}
+
+		call_rcu(&softif_neigh->rcu, softif_neigh_free_rcu);
+	}
+
+	spin_unlock_bh(&bat_priv->softif_neigh_lock);
+}
+
+static struct softif_neigh *softif_neigh_get(struct bat_priv *bat_priv,
+					     uint8_t *addr, short vid)
+{
+	struct softif_neigh *softif_neigh;
+	struct hlist_node *node;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(softif_neigh, node,
+				 &bat_priv->softif_neigh_list, list) {
+		if (memcmp(softif_neigh->addr, addr, ETH_ALEN) !=3D 0)
+			continue;
+
+		if (softif_neigh->vid !=3D vid)
+			continue;
+
+		softif_neigh->last_seen =3D jiffies;
+		goto found;
+	}
+
+	softif_neigh =3D kzalloc(sizeof(struct softif_neigh), GFP_ATOMIC);
+	if (!softif_neigh)
+		goto out;
+
+	memcpy(softif_neigh->addr, addr, ETH_ALEN);
+	softif_neigh->vid =3D vid;
+	softif_neigh->last_seen =3D jiffies;
+	kref_init(&softif_neigh->refcount);
+
+	INIT_HLIST_NODE(&softif_neigh->list);
+	spin_lock_bh(&bat_priv->softif_neigh_lock);
+	hlist_add_head_rcu(&softif_neigh->list, &bat_priv->softif_neigh_list);
+	spin_unlock_bh(&bat_priv->softif_neigh_lock);
+
+found:
+	kref_get(&softif_neigh->refcount);
+out:
+	rcu_read_unlock();
+	return softif_neigh;
+}
+
+int softif_neigh_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev =3D (struct net_device *)seq->private;
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct softif_neigh *softif_neigh;
+	struct hlist_node *node;
+	size_t buf_size, pos;
+	char *buff;
+
+	if (!bat_priv->primary_if) {
+		return seq_printf(seq, "BATMAN mesh %s disabled - "
+			       "please specify interfaces to enable it\n",
+			       net_dev->name);
+	}
+
+	seq_printf(seq, "Softif neighbor list (%s)\n", net_dev->name);
+
+	buf_size =3D 1;
+	/* Estimate length for: "   xx:xx:xx:xx:xx:xx\n" */
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(softif_neigh, node,
+				 &bat_priv->softif_neigh_list, list)
+		buf_size +=3D 30;
+	rcu_read_unlock();
+
+	buff =3D kmalloc(buf_size, GFP_ATOMIC);
+	if (!buff)
+		return -ENOMEM;
+
+	buff[0] =3D '\0';
+	pos =3D 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(softif_neigh, node,
+				 &bat_priv->softif_neigh_list, list) {
+		pos +=3D snprintf(buff + pos, 31, "%s %pM (vid: %d)\n",
+				bat_priv->softif_neigh =3D=3D softif_neigh
+				? "=3D>" : "  ", softif_neigh->addr,
+				softif_neigh->vid);
+	}
+	rcu_read_unlock();
+
+	seq_printf(seq, "%s", buff);
+	kfree(buff);
+	return 0;
+}
+
+static void softif_batman_recv(struct sk_buff *skb, struct net_device *d=
ev,
+			       short vid)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
+	struct batman_packet *batman_packet;
+	struct softif_neigh *softif_neigh, *softif_neigh_tmp;
+
+	if (ntohs(ethhdr->h_proto) =3D=3D ETH_P_8021Q)
+		batman_packet =3D (struct batman_packet *)
+					(skb->data + ETH_HLEN + VLAN_HLEN);
+	else
+		batman_packet =3D (struct batman_packet *)(skb->data + ETH_HLEN);
+
+	if (batman_packet->version !=3D COMPAT_VERSION)
+		goto err;
+
+	if (batman_packet->packet_type !=3D BAT_PACKET)
+		goto err;
+
+	if (!(batman_packet->flags & PRIMARIES_FIRST_HOP))
+		goto err;
+
+	if (is_my_mac(batman_packet->orig))
+		goto err;
+
+	softif_neigh =3D softif_neigh_get(bat_priv, batman_packet->orig, vid);
+
+	if (!softif_neigh)
+		goto err;
+
+	if (bat_priv->softif_neigh =3D=3D softif_neigh)
+		goto out;
+
+	/* we got a neighbor but its mac is 'bigger' than ours  */
+	if (memcmp(bat_priv->primary_if->net_dev->dev_addr,
+		   softif_neigh->addr, ETH_ALEN) < 0)
+		goto out;
+
+	/* switch to new 'smallest neighbor' */
+	if ((bat_priv->softif_neigh) &&
+	    (memcmp(softif_neigh->addr, bat_priv->softif_neigh->addr,
+							ETH_ALEN) < 0)) {
+		bat_dbg(DBG_ROUTES, bat_priv,
+			"Changing mesh exit point from %pM (vid: %d) "
+			"to %pM (vid: %d).\n",
+			 bat_priv->softif_neigh->addr,
+			 bat_priv->softif_neigh->vid,
+			 softif_neigh->addr, softif_neigh->vid);
+		softif_neigh_tmp =3D bat_priv->softif_neigh;
+		bat_priv->softif_neigh =3D softif_neigh;
+		kref_put(&softif_neigh_tmp->refcount, softif_neigh_free_ref);
+		/* we need to hold the additional reference */
+		goto err;
+	}
+
+	/* close own batX device and use softif_neigh as exit node */
+	if ((!bat_priv->softif_neigh) &&
+	    (memcmp(softif_neigh->addr,
+		    bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN) < 0)) {
+		bat_dbg(DBG_ROUTES, bat_priv,
+			"Setting mesh exit point to %pM (vid: %d).\n",
+			softif_neigh->addr, softif_neigh->vid);
+		bat_priv->softif_neigh =3D softif_neigh;
+		/* we need to hold the additional reference */
+		goto err;
+	}
+
+out:
+	kref_put(&softif_neigh->refcount, softif_neigh_free_ref);
+err:
+	kfree_skb(skb);
+	return;
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
+	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	return &bat_priv->stats;
+}
+
+static int interface_set_mac_addr(struct net_device *dev, void *p)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct sockaddr *addr =3D p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	/* only modify hna-table if it has been initialised before */
+	if (atomic_read(&bat_priv->mesh_state) =3D=3D MESH_ACTIVE) {
+		hna_local_remove(bat_priv, dev->dev_addr,
+				 "mac address changed");
+		hna_local_add(dev, addr->sa_data);
+	}
+
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	return 0;
+}
+
+static int interface_change_mtu(struct net_device *dev, int new_mtu)
+{
+	/* check ranges */
+	if ((new_mtu < 68) || (new_mtu > hardif_min_mtu(dev)))
+		return -EINVAL;
+
+	dev->mtu =3D new_mtu;
+
+	return 0;
+}
+
+int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
+{
+	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
+	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct bcast_packet *bcast_packet;
+	struct vlan_ethhdr *vhdr;
+	int data_len =3D skb->len, ret;
+	short vid =3D -1;
+	bool do_bcast =3D false;
+
+	if (atomic_read(&bat_priv->mesh_state) !=3D MESH_ACTIVE)
+		goto dropped;
+
+	soft_iface->trans_start =3D jiffies;
+
+	switch (ntohs(ethhdr->h_proto)) {
+	case ETH_P_8021Q:
+		vhdr =3D (struct vlan_ethhdr *)skb->data;
+		vid =3D ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
+
+		if (ntohs(vhdr->h_vlan_encapsulated_proto) !=3D ETH_P_BATMAN)
+			break;
+
+		/* fall through */
+	case ETH_P_BATMAN:
+		softif_batman_recv(skb, soft_iface, vid);
+		goto end;
+	}
+
+	/**
+	 * if we have a another chosen mesh exit node in range
+	 * it will transport the packets to the mesh
+	 */
+	if ((bat_priv->softif_neigh) && (bat_priv->softif_neigh->vid =3D=3D vid=
))
+		goto dropped;
+
+	/* TODO: check this for locks */
+	hna_local_add(soft_iface, ethhdr->h_source);
+
+	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+		ret =3D gw_is_target(bat_priv, skb);
+
+		if (ret < 0)
+			goto dropped;
+
+		if (ret =3D=3D 0)
+			do_bcast =3D true;
+	}
+
+	/* ethernet packet should be broadcasted */
+	if (do_bcast) {
+		if (!bat_priv->primary_if)
+			goto dropped;
+
+		if (my_skb_head_push(skb, sizeof(struct bcast_packet)) < 0)
+			goto dropped;
+
+		bcast_packet =3D (struct bcast_packet *)skb->data;
+		bcast_packet->version =3D COMPAT_VERSION;
+		bcast_packet->ttl =3D TTL;
+
+		/* batman packet type: broadcast */
+		bcast_packet->packet_type =3D BAT_BCAST;
+
+		/* hw address of first interface is the orig mac because only
+		 * this mac is known throughout the mesh */
+		memcpy(bcast_packet->orig,
+		       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+
+		/* set broadcast sequence number */
+		bcast_packet->seqno =3D
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
+		ret =3D unicast_send_skb(skb, bat_priv);
+		if (ret !=3D 0)
+			goto dropped_freed;
+	}
+
+	bat_priv->stats.tx_packets++;
+	bat_priv->stats.tx_bytes +=3D data_len;
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
+		  struct sk_buff *skb, struct batman_if *recv_if,
+		  int hdr_size)
+{
+	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct unicast_packet *unicast_packet;
+	struct ethhdr *ethhdr;
+	struct vlan_ethhdr *vhdr;
+	short vid =3D -1;
+	int ret;
+
+	/* check if enough space is available for pulling, and pull */
+	if (!pskb_may_pull(skb, hdr_size))
+		goto dropped;
+
+	skb_pull_rcsum(skb, hdr_size);
+	skb_reset_mac_header(skb);
+
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	switch (ntohs(ethhdr->h_proto)) {
+	case ETH_P_8021Q:
+		vhdr =3D (struct vlan_ethhdr *)skb->data;
+		vid =3D ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
+
+		if (ntohs(vhdr->h_vlan_encapsulated_proto) !=3D ETH_P_BATMAN)
+			break;
+
+		/* fall through */
+	case ETH_P_BATMAN:
+		goto dropped;
+	}
+
+	/**
+	 * if we have a another chosen mesh exit node in range
+	 * it will transport the packets to the non-mesh network
+	 */
+	if ((bat_priv->softif_neigh) && (bat_priv->softif_neigh->vid =3D=3D vid=
)) {
+		skb_push(skb, hdr_size);
+		unicast_packet =3D (struct unicast_packet *)skb->data;
+
+		if ((unicast_packet->packet_type !=3D BAT_UNICAST) &&
+		    (unicast_packet->packet_type !=3D BAT_UNICAST_FRAG))
+			goto dropped;
+
+		skb_reset_mac_header(skb);
+
+		memcpy(unicast_packet->dest,
+		       bat_priv->softif_neigh->addr, ETH_ALEN);
+		ret =3D route_unicast_packet(skb, recv_if, hdr_size);
+		if (ret =3D=3D NET_RX_DROP)
+			goto dropped;
+
+		goto out;
+	}
+
+	/* skb->dev & skb->pkt_type are set here */
+	if (unlikely(!pskb_may_pull(skb, ETH_HLEN)))
+		goto dropped;
+	skb->protocol =3D eth_type_trans(skb, soft_iface);
+
+	/* should not be neccesary anymore as we use skb_pull_rcsum()
+	 * TODO: please verify this and remove this TODO
+	 * -- Dec 21st 2009, Simon Wunderlich */
+
+/*	skb->ip_summed =3D CHECKSUM_UNNECESSARY;*/
+
+	bat_priv->stats.rx_packets++;
+	bat_priv->stats.rx_bytes +=3D skb->len + sizeof(struct ethhdr);
+
+	soft_iface->last_rx =3D jiffies;
+
+	netif_rx(skb);
+	return;
+
+dropped:
+	kfree_skb(skb);
+out:
+	return;
+}
+
+#ifdef HAVE_NET_DEVICE_OPS
+static const struct net_device_ops bat_netdev_ops =3D {
+	.ndo_open =3D interface_open,
+	.ndo_stop =3D interface_release,
+	.ndo_get_stats =3D interface_stats,
+	.ndo_set_mac_address =3D interface_set_mac_addr,
+	.ndo_change_mtu =3D interface_change_mtu,
+	.ndo_start_xmit =3D interface_tx,
+	.ndo_validate_addr =3D eth_validate_addr
+};
+#endif
+
+static void interface_setup(struct net_device *dev)
+{
+	struct bat_priv *priv =3D netdev_priv(dev);
+	char dev_addr[ETH_ALEN];
+
+	ether_setup(dev);
+
+#ifdef HAVE_NET_DEVICE_OPS
+	dev->netdev_ops =3D &bat_netdev_ops;
+#else
+	dev->open =3D interface_open;
+	dev->stop =3D interface_release;
+	dev->get_stats =3D interface_stats;
+	dev->set_mac_address =3D interface_set_mac_addr;
+	dev->change_mtu =3D interface_change_mtu;
+	dev->hard_start_xmit =3D interface_tx;
+#endif
+	dev->destructor =3D free_netdev;
+
+	/**
+	 * can't call min_mtu, because the needed variables
+	 * have not been initialized yet
+	 */
+	dev->mtu =3D ETH_DATA_LEN;
+	dev->hard_header_len =3D BAT_HEADER_LEN; /* reserve more space in the
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
+	soft_iface =3D alloc_netdev(sizeof(struct bat_priv) , name,
+				   interface_setup);
+
+	if (!soft_iface) {
+		pr_err("Unable to allocate the batman interface: %s\n", name);
+		goto out;
+	}
+
+	ret =3D register_netdev(soft_iface);
+	if (ret < 0) {
+		pr_err("Unable to register the batman interface '%s': %i\n",
+		       name, ret);
+		goto free_soft_iface;
+	}
+
+	bat_priv =3D netdev_priv(soft_iface);
+
+	atomic_set(&bat_priv->aggregated_ogms, 1);
+	atomic_set(&bat_priv->bonding, 0);
+	atomic_set(&bat_priv->vis_mode, VIS_TYPE_CLIENT_UPDATE);
+	atomic_set(&bat_priv->gw_mode, GW_MODE_OFF);
+	atomic_set(&bat_priv->gw_sel_class, 20);
+	atomic_set(&bat_priv->gw_bandwidth, 41);
+	atomic_set(&bat_priv->orig_interval, 1000);
+	atomic_set(&bat_priv->hop_penalty, 10);
+	atomic_set(&bat_priv->log_level, 0);
+	atomic_set(&bat_priv->fragmentation, 1);
+	atomic_set(&bat_priv->bcast_queue_left, BCAST_QUEUE_LEN);
+	atomic_set(&bat_priv->batman_queue_left, BATMAN_QUEUE_LEN);
+
+	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
+	atomic_set(&bat_priv->bcast_seqno, 1);
+	atomic_set(&bat_priv->hna_local_changed, 0);
+
+	bat_priv->primary_if =3D NULL;
+	bat_priv->num_ifaces =3D 0;
+	bat_priv->softif_neigh =3D NULL;
+
+	ret =3D sysfs_add_meshif(soft_iface);
+	if (ret < 0)
+		goto unreg_soft_iface;
+
+	ret =3D debugfs_add_meshif(soft_iface);
+	if (ret < 0)
+		goto unreg_sysfs;
+
+	ret =3D mesh_init(soft_iface);
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
+static int bat_get_settings(struct net_device *dev, struct ethtool_cmd *=
cmd)
+{
+	cmd->supported =3D 0;
+	cmd->advertising =3D 0;
+	cmd->speed =3D SPEED_10;
+	cmd->duplex =3D DUPLEX_FULL;
+	cmd->port =3D PORT_TP;
+	cmd->phy_address =3D 0;
+	cmd->transceiver =3D XCVR_INTERNAL;
+	cmd->autoneg =3D AUTONEG_DISABLE;
+	cmd->maxtxpkt =3D 0;
+	cmd->maxrxpkt =3D 0;
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
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interf=
ace.h
new file mode 100644
index 0000000..02b7733
--- /dev/null
+++ b/net/batman-adv/soft-interface.h
@@ -0,0 +1,35 @@
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
+int softif_neigh_seq_print_text(struct seq_file *seq, void *offset);
+void softif_neigh_purge(struct bat_priv *bat_priv);
+int interface_tx(struct sk_buff *skb, struct net_device *soft_iface);
+void interface_rx(struct net_device *soft_iface,
+		  struct sk_buff *skb, struct batman_if *recv_if,
+		  int hdr_size);
+struct net_device *softif_create(char *name);
+void softif_destroy(struct net_device *soft_iface);
+
+#endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translat=
ion-table.c
new file mode 100644
index 0000000..a19e16c
--- /dev/null
+++ b/net/batman-adv/translation-table.c
@@ -0,0 +1,534 @@
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
+#include "originator.h"
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
+	bat_priv->hna_local_hash =3D hash_new(1024);
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
+	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct hna_local_entry *hna_local_entry;
+	struct hna_global_entry *hna_global_entry;
+	int required_bytes;
+
+	spin_lock_bh(&bat_priv->hna_lhash_lock);
+	hna_local_entry =3D
+		((struct hna_local_entry *)hash_find(bat_priv->hna_local_hash,
+						     compare_orig, choose_orig,
+						     addr));
+	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+
+	if (hna_local_entry) {
+		hna_local_entry->last_seen =3D jiffies;
+		return;
+	}
+
+	/* only announce as many hosts as possible in the batman-packet and
+	   space in batman_packet->num_hna That also should give a limit to
+	   MAC-flooding. */
+	required_bytes =3D (bat_priv->num_local_hna + 1) * ETH_ALEN;
+	required_bytes +=3D BAT_PACKET_LEN;
+
+	if ((required_bytes > ETH_DATA_LEN) ||
+	    (atomic_read(&bat_priv->aggregated_ogms) &&
+	     required_bytes > MAX_AGGREGATION_BYTES) ||
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
+	hna_local_entry =3D kmalloc(sizeof(struct hna_local_entry), GFP_ATOMIC)=
;
+	if (!hna_local_entry)
+		return;
+
+	memcpy(hna_local_entry->addr, addr, ETH_ALEN);
+	hna_local_entry->last_seen =3D jiffies;
+
+	/* the batman interface mac address should never be purged */
+	if (compare_orig(addr, soft_iface->dev_addr))
+		hna_local_entry->never_purge =3D 1;
+	else
+		hna_local_entry->never_purge =3D 0;
+
+	spin_lock_bh(&bat_priv->hna_lhash_lock);
+
+	hash_add(bat_priv->hna_local_hash, compare_orig, choose_orig,
+		 hna_local_entry);
+	bat_priv->num_local_hna++;
+	atomic_set(&bat_priv->hna_local_changed, 1);
+
+	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+
+	/* remove address from global hash if present */
+	spin_lock_bh(&bat_priv->hna_ghash_lock);
+
+	hna_global_entry =3D ((struct hna_global_entry *)
+				hash_find(bat_priv->hna_global_hash,
+					  compare_orig, choose_orig, addr));
+
+	if (hna_global_entry)
+		_hna_global_del_orig(bat_priv, hna_global_entry,
+				     "local hna received");
+
+	spin_unlock_bh(&bat_priv->hna_ghash_lock);
+}
+
+int hna_local_fill_buffer(struct bat_priv *bat_priv,
+			  unsigned char *buff, int buff_len)
+{
+	struct hashtable_t *hash =3D bat_priv->hna_local_hash;
+	struct hna_local_entry *hna_local_entry;
+	struct element_t *bucket;
+	int i;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	int count =3D 0;
+
+	spin_lock_bh(&bat_priv->hna_lhash_lock);
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+
+			if (buff_len < (count + 1) * ETH_ALEN)
+				break;
+
+			hna_local_entry =3D bucket->data;
+			memcpy(buff + (count * ETH_ALEN), hna_local_entry->addr,
+			       ETH_ALEN);
+
+			count++;
+		}
+	}
+
+	/* if we did not get all new local hnas see you next time  ;-) */
+	if (count =3D=3D bat_priv->num_local_hna)
+		atomic_set(&bat_priv->hna_local_changed, 0);
+
+	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+	return i;
+}
+
+int hna_local_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev =3D (struct net_device *)seq->private;
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct hashtable_t *hash =3D bat_priv->hna_local_hash;
+	struct hna_local_entry *hna_local_entry;
+	int i;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
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
+	spin_lock_bh(&bat_priv->hna_lhash_lock);
+
+	buf_size =3D 1;
+	/* Estimate length for: " * xx:xx:xx:xx:xx:xx\n" */
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each(walk, head)
+			buf_size +=3D 21;
+	}
+
+	buff =3D kmalloc(buf_size, GFP_ATOMIC);
+	if (!buff) {
+		spin_unlock_bh(&bat_priv->hna_lhash_lock);
+		return -ENOMEM;
+	}
+	buff[0] =3D '\0';
+	pos =3D 0;
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			hna_local_entry =3D bucket->data;
+
+			pos +=3D snprintf(buff + pos, 22, " * %pM\n",
+					hna_local_entry->addr);
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+
+	seq_printf(seq, "%s", buff);
+	kfree(buff);
+	return 0;
+}
+
+static void _hna_local_del(void *data, void *arg)
+{
+	struct bat_priv *bat_priv =3D (struct bat_priv *)arg;
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
+	hash_remove(bat_priv->hna_local_hash, compare_orig, choose_orig,
+		    hna_local_entry->addr);
+	_hna_local_del(hna_local_entry, bat_priv);
+}
+
+void hna_local_remove(struct bat_priv *bat_priv,
+		      uint8_t *addr, char *message)
+{
+	struct hna_local_entry *hna_local_entry;
+
+	spin_lock_bh(&bat_priv->hna_lhash_lock);
+
+	hna_local_entry =3D (struct hna_local_entry *)
+		hash_find(bat_priv->hna_local_hash, compare_orig, choose_orig,
+			  addr);
+
+	if (hna_local_entry)
+		hna_local_del(bat_priv, hna_local_entry, message);
+
+	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+}
+
+static void hna_local_purge(struct work_struct *work)
+{
+	struct delayed_work *delayed_work =3D
+		container_of(work, struct delayed_work, work);
+	struct bat_priv *bat_priv =3D
+		container_of(delayed_work, struct bat_priv, hna_work);
+	struct hashtable_t *hash =3D bat_priv->hna_local_hash;
+	struct hna_local_entry *hna_local_entry;
+	int i;
+	struct hlist_node *walk, *safe;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	unsigned long timeout;
+
+	spin_lock_bh(&bat_priv->hna_lhash_lock);
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
+			hna_local_entry =3D bucket->data;
+
+			timeout =3D hna_local_entry->last_seen;
+			timeout +=3D LOCAL_HNA_TIMEOUT * HZ;
+
+			if ((!hna_local_entry->never_purge) &&
+			    time_after(jiffies, timeout))
+				hna_local_del(bat_priv, hna_local_entry,
+					"address timed out");
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->hna_lhash_lock);
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
+	bat_priv->hna_local_hash =3D NULL;
+}
+
+int hna_global_init(struct bat_priv *bat_priv)
+{
+	if (bat_priv->hna_global_hash)
+		return 1;
+
+	bat_priv->hna_global_hash =3D hash_new(1024);
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
+	int hna_buff_count =3D 0;
+	unsigned char *hna_ptr;
+
+	while ((hna_buff_count + 1) * ETH_ALEN <=3D hna_buff_len) {
+		spin_lock_bh(&bat_priv->hna_ghash_lock);
+
+		hna_ptr =3D hna_buff + (hna_buff_count * ETH_ALEN);
+		hna_global_entry =3D (struct hna_global_entry *)
+			hash_find(bat_priv->hna_global_hash, compare_orig,
+				  choose_orig, hna_ptr);
+
+		if (!hna_global_entry) {
+			spin_unlock_bh(&bat_priv->hna_ghash_lock);
+
+			hna_global_entry =3D
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
+			spin_lock_bh(&bat_priv->hna_ghash_lock);
+			hash_add(bat_priv->hna_global_hash, compare_orig,
+				 choose_orig, hna_global_entry);
+
+		}
+
+		hna_global_entry->orig_node =3D orig_node;
+		spin_unlock_bh(&bat_priv->hna_ghash_lock);
+
+		/* remove address from local hash if present */
+		spin_lock_bh(&bat_priv->hna_lhash_lock);
+
+		hna_ptr =3D hna_buff + (hna_buff_count * ETH_ALEN);
+		hna_local_entry =3D (struct hna_local_entry *)
+			hash_find(bat_priv->hna_local_hash, compare_orig,
+				  choose_orig, hna_ptr);
+
+		if (hna_local_entry)
+			hna_local_del(bat_priv, hna_local_entry,
+				      "global hna received");
+
+		spin_unlock_bh(&bat_priv->hna_lhash_lock);
+
+		hna_buff_count++;
+	}
+
+	/* initialize, and overwrite if malloc succeeds */
+	orig_node->hna_buff =3D NULL;
+	orig_node->hna_buff_len =3D 0;
+
+	if (hna_buff_len > 0) {
+		orig_node->hna_buff =3D kmalloc(hna_buff_len, GFP_ATOMIC);
+		if (orig_node->hna_buff) {
+			memcpy(orig_node->hna_buff, hna_buff, hna_buff_len);
+			orig_node->hna_buff_len =3D hna_buff_len;
+		}
+	}
+}
+
+int hna_global_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev =3D (struct net_device *)seq->private;
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct hashtable_t *hash =3D bat_priv->hna_global_hash;
+	struct hna_global_entry *hna_global_entry;
+	int i;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
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
+	spin_lock_bh(&bat_priv->hna_ghash_lock);
+
+	buf_size =3D 1;
+	/* Estimate length for: " * xx:xx:xx:xx:xx:xx via xx:xx:xx:xx:xx:xx\n"*=
/
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each(walk, head)
+			buf_size +=3D 43;
+	}
+
+	buff =3D kmalloc(buf_size, GFP_ATOMIC);
+	if (!buff) {
+		spin_unlock_bh(&bat_priv->hna_ghash_lock);
+		return -ENOMEM;
+	}
+	buff[0] =3D '\0';
+	pos =3D 0;
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			hna_global_entry =3D bucket->data;
+
+			pos +=3D snprintf(buff + pos, 44,
+					" * %pM via %pM\n",
+					hna_global_entry->addr,
+					hna_global_entry->orig_node->orig);
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->hna_ghash_lock);
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
+	hash_remove(bat_priv->hna_global_hash, compare_orig, choose_orig,
+		    hna_global_entry->addr);
+	kfree(hna_global_entry);
+}
+
+void hna_global_del_orig(struct bat_priv *bat_priv,
+			 struct orig_node *orig_node, char *message)
+{
+	struct hna_global_entry *hna_global_entry;
+	int hna_buff_count =3D 0;
+	unsigned char *hna_ptr;
+
+	if (orig_node->hna_buff_len =3D=3D 0)
+		return;
+
+	spin_lock_bh(&bat_priv->hna_ghash_lock);
+
+	while ((hna_buff_count + 1) * ETH_ALEN <=3D orig_node->hna_buff_len) {
+		hna_ptr =3D orig_node->hna_buff + (hna_buff_count * ETH_ALEN);
+		hna_global_entry =3D (struct hna_global_entry *)
+			hash_find(bat_priv->hna_global_hash, compare_orig,
+				  choose_orig, hna_ptr);
+
+		if ((hna_global_entry) &&
+		    (hna_global_entry->orig_node =3D=3D orig_node))
+			_hna_global_del_orig(bat_priv, hna_global_entry,
+					     message);
+
+		hna_buff_count++;
+	}
+
+	spin_unlock_bh(&bat_priv->hna_ghash_lock);
+
+	orig_node->hna_buff_len =3D 0;
+	kfree(orig_node->hna_buff);
+	orig_node->hna_buff =3D NULL;
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
+	bat_priv->hna_global_hash =3D NULL;
+}
+
+struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *=
addr)
+{
+	struct hna_global_entry *hna_global_entry;
+
+	spin_lock_bh(&bat_priv->hna_ghash_lock);
+	hna_global_entry =3D (struct hna_global_entry *)
+				hash_find(bat_priv->hna_global_hash,
+					  compare_orig, choose_orig, addr);
+	spin_unlock_bh(&bat_priv->hna_ghash_lock);
+
+	if (!hna_global_entry)
+		return NULL;
+
+	return hna_global_entry->orig_node;
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translat=
ion-table.h
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
+struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *=
addr);
+
+#endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
new file mode 100644
index 0000000..97cb23d
--- /dev/null
+++ b/net/batman-adv/types.h
@@ -0,0 +1,271 @@
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
+	struct net_device *net_dev;
+	atomic_t seqno;
+	atomic_t frag_seqno;
+	unsigned char *packet_buff;
+	int packet_len;
+	struct kobject *hardif_obj;
+	struct kref refcount;
+	struct packet_type batman_adv_ptype;
+	struct net_device *soft_iface;
+	struct rcu_head rcu;
+};
+
+/**
+ *	orig_node - structure for orig_list maintaining nodes of mesh
+ *	@primary_addr: hosts primary interface address
+ *	@last_valid: when last packet from this node was received
+ *	@bcast_seqno_reset: time when the broadcast seqno window was reset
+ *	@batman_seqno_reset: time when the batman seqno window was reset
+ *	@gw_flags: flags related to gateway class
+ *	@flags: for now only VIS_SERVER flag
+ *	@last_real_seqno: last and best known squence number
+ *	@last_ttl: ttl of last received packet
+ *	@last_bcast_seqno: last broadcast sequence number received by this ho=
st
+ *
+ *	@candidates: how many candidates are available
+ *	@selected: next bonding candidate
+ */
+struct orig_node {
+	uint8_t orig[ETH_ALEN];
+	uint8_t primary_addr[ETH_ALEN];
+	struct neigh_node *router;
+	unsigned long *bcast_own;
+	uint8_t *bcast_own_sum;
+	uint8_t tq_own;
+	int tq_asym_penalty;
+	unsigned long last_valid;
+	unsigned long bcast_seqno_reset;
+	unsigned long batman_seqno_reset;
+	uint8_t gw_flags;
+	uint8_t flags;
+	unsigned char *hna_buff;
+	int16_t hna_buff_len;
+	uint32_t last_real_seqno;
+	uint8_t last_ttl;
+	unsigned long bcast_bits[NUM_WORDS];
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
+struct gw_node {
+	struct hlist_node list;
+	struct orig_node *orig_node;
+	unsigned long deleted;
+	struct kref refcount;
+	struct rcu_head rcu;
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
+	unsigned long real_bits[NUM_WORDS];
+	struct orig_node *orig_node;
+	struct batman_if *if_incoming;
+};
+
+
+struct bat_priv {
+	atomic_t mesh_state;
+	struct net_device_stats stats;
+	atomic_t aggregated_ogms;	/* boolean */
+	atomic_t bonding;		/* boolean */
+	atomic_t fragmentation;		/* boolean */
+	atomic_t vis_mode;		/* VIS_TYPE_* */
+	atomic_t gw_mode;		/* GW_MODE_* */
+	atomic_t gw_sel_class;		/* uint */
+	atomic_t gw_bandwidth;		/* gw bandwidth */
+	atomic_t orig_interval;		/* uint */
+	atomic_t hop_penalty;		/* uint */
+	atomic_t log_level;		/* uint */
+	atomic_t bcast_seqno;
+	atomic_t bcast_queue_left;
+	atomic_t batman_queue_left;
+	char num_ifaces;
+	struct hlist_head softif_neigh_list;
+	struct softif_neigh *softif_neigh;
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
+	spinlock_t orig_hash_lock; /* protects orig_hash */
+	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
+	spinlock_t forw_bcast_list_lock; /* protects  */
+	spinlock_t hna_lhash_lock; /* protects hna_local_hash */
+	spinlock_t hna_ghash_lock; /* protects hna_global_hash */
+	spinlock_t gw_list_lock; /* protects gw_list */
+	spinlock_t vis_hash_lock; /* protects vis_hash */
+	spinlock_t vis_list_lock; /* protects vis_info::recv_list */
+	spinlock_t softif_neigh_lock; /* protects soft-interface neigh list */
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
+	spinlock_t lock; /* protects queue_list, queue_len, index */
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
+	spinlock_t lock; /* protects log_buff, log_start and log_end */
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
+	uint8_t  quality;	/* quality =3D 0 means HNA */
+} __attribute__((packed));
+
+struct recvlist_node {
+	struct list_head list;
+	uint8_t mac[ETH_ALEN];
+};
+
+struct softif_neigh {
+	struct hlist_node list;
+	uint8_t addr[ETH_ALEN];
+	unsigned long last_seen;
+	short vid;
+	struct kref refcount;
+	struct rcu_head rcu;
+};
+
+#endif /* _NET_BATMAN_ADV_TYPES_H_ */
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
new file mode 100644
index 0000000..dc2e28b
--- /dev/null
+++ b/net/batman-adv/unicast.c
@@ -0,0 +1,343 @@
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
+#include "gateway_client.h"
+#include "originator.h"
+#include "hash.h"
+#include "translation-table.h"
+#include "routing.h"
+#include "hard-interface.h"
+
+
+static struct sk_buff *frag_merge_packet(struct list_head *head,
+					 struct frag_packet_list_entry *tfp,
+					 struct sk_buff *skb)
+{
+	struct unicast_frag_packet *up =3D
+		(struct unicast_frag_packet *)skb->data;
+	struct sk_buff *tmp_skb;
+	struct unicast_packet *unicast_packet;
+	int hdr_len =3D sizeof(struct unicast_packet),
+	    uni_diff =3D sizeof(struct unicast_frag_packet) - hdr_len;
+
+	/* set skb to the first part and tmp_skb to the second part */
+	if (up->flags & UNI_FRAG_HEAD) {
+		tmp_skb =3D tfp->skb;
+	} else {
+		tmp_skb =3D skb;
+		skb =3D tfp->skb;
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
+	tfp->skb =3D NULL;
+	tfp->seqno =3D 0;
+	list_move_tail(&tfp->list, head);
+
+	memcpy(skb_put(skb, tmp_skb->len), tmp_skb->data, tmp_skb->len);
+	kfree_skb(tmp_skb);
+
+	memmove(skb->data + uni_diff, skb->data, hdr_len);
+	unicast_packet =3D (struct unicast_packet *) skb_pull(skb, uni_diff);
+	unicast_packet->packet_type =3D BAT_UNICAST;
+
+	return skb;
+}
+
+static void frag_create_entry(struct list_head *head, struct sk_buff *sk=
b)
+{
+	struct frag_packet_list_entry *tfp;
+	struct unicast_frag_packet *up =3D
+		(struct unicast_frag_packet *)skb->data;
+
+	/* free and oldest packets stand at the end */
+	tfp =3D list_entry((head)->prev, typeof(*tfp), list);
+	kfree_skb(tfp->skb);
+
+	tfp->seqno =3D ntohs(up->seqno);
+	tfp->skb =3D skb;
+	list_move(&tfp->list, head);
+	return;
+}
+
+static int frag_create_buffer(struct list_head *head)
+{
+	int i;
+	struct frag_packet_list_entry *tfp;
+
+	for (i =3D 0; i < FRAG_BUFFER_SIZE; i++) {
+		tfp =3D kmalloc(sizeof(struct frag_packet_list_entry),
+			GFP_ATOMIC);
+		if (!tfp) {
+			frag_list_free(head);
+			return -ENOMEM;
+		}
+		tfp->skb =3D NULL;
+		tfp->seqno =3D 0;
+		INIT_LIST_HEAD(&tfp->list);
+		list_add(&tfp->list, head);
+	}
+
+	return 0;
+}
+
+static struct frag_packet_list_entry *frag_search_packet(struct list_hea=
d *head,
+						 struct unicast_frag_packet *up)
+{
+	struct frag_packet_list_entry *tfp;
+	struct unicast_frag_packet *tmp_up =3D NULL;
+	uint16_t search_seqno;
+
+	if (up->flags & UNI_FRAG_HEAD)
+		search_seqno =3D ntohs(up->seqno)+1;
+	else
+		search_seqno =3D ntohs(up->seqno)-1;
+
+	list_for_each_entry(tfp, head, list) {
+
+		if (!tfp->skb)
+			continue;
+
+		if (tfp->seqno =3D=3D ntohs(up->seqno))
+			goto mov_tail;
+
+		tmp_up =3D (struct unicast_frag_packet *)tfp->skb->data;
+
+		if (tfp->seqno =3D=3D search_seqno) {
+
+			if ((tmp_up->flags & UNI_FRAG_HEAD) !=3D
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
+/* frag_reassemble_skb():
+ * returns NET_RX_DROP if the operation failed - skb is left intact
+ * returns NET_RX_SUCCESS if the fragment was buffered (skb_new will be =
NULL)
+ * or the skb could be reassembled (skb_new will point to the new packet=
 and
+ * skb was freed)
+ */
+int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
+			struct sk_buff **new_skb)
+{
+	struct orig_node *orig_node;
+	struct frag_packet_list_entry *tmp_frag_entry;
+	int ret =3D NET_RX_DROP;
+	struct unicast_frag_packet *unicast_packet =3D
+		(struct unicast_frag_packet *)skb->data;
+
+	*new_skb =3D NULL;
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	orig_node =3D ((struct orig_node *)
+		    hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
+			      unicast_packet->orig));
+
+	if (!orig_node) {
+		pr_debug("couldn't find originator in orig_hash\n");
+		goto out;
+	}
+
+	orig_node->last_frag_packet =3D jiffies;
+
+	if (list_empty(&orig_node->frag_list) &&
+	    frag_create_buffer(&orig_node->frag_list)) {
+		pr_debug("couldn't create frag buffer\n");
+		goto out;
+	}
+
+	tmp_frag_entry =3D frag_search_packet(&orig_node->frag_list,
+					    unicast_packet);
+
+	if (!tmp_frag_entry) {
+		frag_create_entry(&orig_node->frag_list, skb);
+		ret =3D NET_RX_SUCCESS;
+		goto out;
+	}
+
+	*new_skb =3D frag_merge_packet(&orig_node->frag_list, tmp_frag_entry,
+				     skb);
+	/* if not, merge failed */
+	if (*new_skb)
+		ret =3D NET_RX_SUCCESS;
+out:
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	return ret;
+}
+
+int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
+		  struct batman_if *batman_if, uint8_t dstaddr[])
+{
+	struct unicast_packet tmp_uc, *unicast_packet;
+	struct sk_buff *frag_skb;
+	struct unicast_frag_packet *frag1, *frag2;
+	int uc_hdr_len =3D sizeof(struct unicast_packet);
+	int ucf_hdr_len =3D sizeof(struct unicast_frag_packet);
+	int data_len =3D skb->len;
+
+	if (!bat_priv->primary_if)
+		goto dropped;
+
+	unicast_packet =3D (struct unicast_packet *) skb->data;
+
+	memcpy(&tmp_uc, unicast_packet, uc_hdr_len);
+	frag_skb =3D dev_alloc_skb(data_len - (data_len / 2) + ucf_hdr_len);
+	skb_split(skb, frag_skb, data_len / 2);
+
+	if (my_skb_head_push(skb, ucf_hdr_len - uc_hdr_len) < 0 ||
+	    my_skb_head_push(frag_skb, ucf_hdr_len) < 0)
+		goto drop_frag;
+
+	frag1 =3D (struct unicast_frag_packet *)skb->data;
+	frag2 =3D (struct unicast_frag_packet *)frag_skb->data;
+
+	memcpy(frag1, &tmp_uc, sizeof(struct unicast_packet));
+
+	frag1->ttl--;
+	frag1->version =3D COMPAT_VERSION;
+	frag1->packet_type =3D BAT_UNICAST_FRAG;
+
+	memcpy(frag1->orig, bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(frag2, frag1, sizeof(struct unicast_frag_packet));
+
+	frag1->flags |=3D UNI_FRAG_HEAD;
+	frag2->flags &=3D ~UNI_FRAG_HEAD;
+
+	frag1->seqno =3D htons((uint16_t)atomic_inc_return(
+			     &batman_if->frag_seqno));
+	frag2->seqno =3D htons((uint16_t)atomic_inc_return(
+			     &batman_if->frag_seqno));
+
+	send_skb_packet(skb, batman_if, dstaddr);
+	send_skb_packet(frag_skb, batman_if, dstaddr);
+	return NET_RX_SUCCESS;
+
+drop_frag:
+	kfree_skb(frag_skb);
+dropped:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
+{
+	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
+	struct unicast_packet *unicast_packet;
+	struct orig_node *orig_node;
+	struct batman_if *batman_if;
+	struct neigh_node *router;
+	int data_len =3D skb->len;
+	uint8_t dstaddr[6];
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+
+	/* get routing information */
+	if (is_multicast_ether_addr(ethhdr->h_dest))
+		orig_node =3D (struct orig_node *)gw_get_selected(bat_priv);
+	else
+		orig_node =3D ((struct orig_node *)hash_find(bat_priv->orig_hash,
+							   compare_orig,
+							   choose_orig,
+							   ethhdr->h_dest));
+
+	/* check for hna host */
+	if (!orig_node)
+		orig_node =3D transtable_search(bat_priv, ethhdr->h_dest);
+
+	router =3D find_router(bat_priv, orig_node, NULL);
+
+	if (!router)
+		goto unlock;
+
+	/* don't lock while sending the packets ... we therefore
+		* copy the required data before sending */
+
+	batman_if =3D router->if_incoming;
+	memcpy(dstaddr, router->addr, ETH_ALEN);
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	if (batman_if->if_status !=3D IF_ACTIVE)
+		goto dropped;
+
+	if (my_skb_head_push(skb, sizeof(struct unicast_packet)) < 0)
+		goto dropped;
+
+	unicast_packet =3D (struct unicast_packet *)skb->data;
+
+	unicast_packet->version =3D COMPAT_VERSION;
+	/* batman packet type: unicast */
+	unicast_packet->packet_type =3D BAT_UNICAST;
+	/* set unicast ttl */
+	unicast_packet->ttl =3D TTL;
+	/* copy the destination for faster routing */
+	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
+
+	if (atomic_read(&bat_priv->fragmentation) &&
+	    data_len + sizeof(struct unicast_packet) >
+	    batman_if->net_dev->mtu) {
+		/* send frag skb decreases ttl */
+		unicast_packet->ttl++;
+		return frag_send_skb(skb, bat_priv, batman_if,
+				     dstaddr);
+	}
+	send_skb_packet(skb, batman_if, dstaddr);
+	return 0;
+
+unlock:
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+dropped:
+	kfree_skb(skb);
+	return 1;
+}
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
new file mode 100644
index 0000000..e32b786
--- /dev/null
+++ b/net/batman-adv/unicast.h
@@ -0,0 +1,35 @@
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
+int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
+			struct sk_buff **new_skb);
+void frag_list_free(struct list_head *head);
+int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv);
+int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
+		  struct batman_if *batman_if, uint8_t dstaddr[]);
+
+#endif /* _NET_BATMAN_ADV_UNICAST_H_ */
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
new file mode 100644
index 0000000..cd4c423
--- /dev/null
+++ b/net/batman-adv/vis.c
@@ -0,0 +1,949 @@
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
+#include "originator.h"
+
+#define MAX_VIS_PACKET_SIZE 1000
+
+/* Returns the smallest signed integer in two's complement with the size=
of x */
+#define smallest_signed_int(x) (1u << (7u + 8u * (sizeof(x) - 1u)))
+
+/* Checks if a sequence number x is a predecessor/successor of y.
+ * they handle overflows/underflows and can correctly check for a
+ * predecessor/successor unless the variable sequence number has grown b=
y
+ * more then 2**(bitwidth(x)-1)-1.
+ * This means that for a uint8_t with the maximum value 255, it would th=
ink:
+ *  - when adding nothing - it is neither a predecessor nor a successor
+ *  - before adding more than 127 to the starting value - it is a predec=
essor,
+ *  - when adding 128 - it is neither a predecessor nor a successor,
+ *  - after adding more than 127 to the starting value - it is a success=
or */
+#define seq_before(x, y) ({typeof(x) _dummy =3D (x - y); \
+			_dummy > smallest_signed_int(_dummy); })
+#define seq_after(x, y) seq_before(y, x)
+
+static void start_vis_timer(struct bat_priv *bat_priv);
+
+/* free the info */
+static void free_info(struct kref *ref)
+{
+	struct vis_info *info =3D container_of(ref, struct vis_info, refcount);
+	struct bat_priv *bat_priv =3D info->bat_priv;
+	struct recvlist_node *entry, *tmp;
+
+	list_del_init(&info->send_list);
+	spin_lock_bh(&bat_priv->vis_list_lock);
+	list_for_each_entry_safe(entry, tmp, &info->recv_list, list) {
+		list_del(&entry->list);
+		kfree(entry);
+	}
+
+	spin_unlock_bh(&bat_priv->vis_list_lock);
+	kfree_skb(info->skb_packet);
+}
+
+/* Compare two vis packets, used by the hashing algorithm */
+static int vis_info_cmp(void *data1, void *data2)
+{
+	struct vis_info *d1, *d2;
+	struct vis_packet *p1, *p2;
+	d1 =3D data1;
+	d2 =3D data2;
+	p1 =3D (struct vis_packet *)d1->skb_packet->data;
+	p2 =3D (struct vis_packet *)d2->skb_packet->data;
+	return compare_orig(p1->vis_orig, p2->vis_orig);
+}
+
+/* hash function to choose an entry in a hash table of given size */
+/* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
+static int vis_info_choose(void *data, int size)
+{
+	struct vis_info *vis_info =3D data;
+	struct vis_packet *packet;
+	unsigned char *key;
+	uint32_t hash =3D 0;
+	size_t i;
+
+	packet =3D (struct vis_packet *)vis_info->skb_packet->data;
+	key =3D packet->vis_orig;
+	for (i =3D 0; i < ETH_ALEN; i++) {
+		hash +=3D key[i];
+		hash +=3D (hash << 10);
+		hash ^=3D (hash >> 6);
+	}
+
+	hash +=3D (hash << 3);
+	hash ^=3D (hash >> 11);
+	hash +=3D (hash << 15);
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
+	entry =3D kmalloc(sizeof(*entry), GFP_ATOMIC);
+	if (!entry)
+		return;
+	memcpy(entry->addr, interface, ETH_ALEN);
+	entry->primary =3D primary;
+	hlist_add_head(&entry->list, if_list);
+}
+
+static ssize_t vis_data_read_prim_sec(char *buff, struct hlist_head *if_=
list)
+{
+	struct if_list_entry *entry;
+	struct hlist_node *pos;
+	size_t len =3D 0;
+
+	hlist_for_each_entry(entry, pos, if_list, list) {
+		if (entry->primary)
+			len +=3D sprintf(buff + len, "PRIMARY, ");
+		else
+			len +=3D sprintf(buff + len,  "SEC %pM, ", entry->addr);
+	}
+
+	return len;
+}
+
+static size_t vis_data_count_prim_sec(struct hlist_head *if_list)
+{
+	struct if_list_entry *entry;
+	struct hlist_node *pos;
+	size_t count =3D 0;
+
+	hlist_for_each_entry(entry, pos, if_list, list) {
+		if (entry->primary)
+			count +=3D 9;
+		else
+			count +=3D 23;
+	}
+
+	return count;
+}
+
+/* read an entry  */
+static ssize_t vis_data_read_entry(char *buff, struct vis_info_entry *en=
try,
+				   uint8_t *src, bool primary)
+{
+	/* maximal length: max(4+17+2, 3+17+1+3+2) =3D=3D 26 */
+	if (primary && entry->quality =3D=3D 0)
+		return sprintf(buff, "HNA %pM, ", entry->dest);
+	else if (compare_orig(entry->src, src))
+		return sprintf(buff, "TQ %pM %d, ", entry->dest,
+			       entry->quality);
+
+	return 0;
+}
+
+int vis_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct vis_info *info;
+	struct vis_packet *packet;
+	struct vis_info_entry *entries;
+	struct net_device *net_dev =3D (struct net_device *)seq->private;
+	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct hashtable_t *hash =3D bat_priv->vis_hash;
+	HLIST_HEAD(vis_if_list);
+	struct if_list_entry *entry;
+	struct hlist_node *pos, *n;
+	int i, j;
+	int vis_server =3D atomic_read(&bat_priv->vis_mode);
+	size_t buff_pos, buf_size;
+	char *buff;
+	int compare;
+
+	if ((!bat_priv->primary_if) ||
+	    (vis_server =3D=3D VIS_TYPE_CLIENT_UPDATE))
+		return 0;
+
+	buf_size =3D 1;
+	/* Estimate length */
+	spin_lock_bh(&bat_priv->vis_hash_lock);
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			info =3D bucket->data;
+			packet =3D (struct vis_packet *)info->skb_packet->data;
+			entries =3D (struct vis_info_entry *)
+				((char *)packet + sizeof(struct vis_packet));
+
+			for (j =3D 0; j < packet->entries; j++) {
+				if (entries[j].quality =3D=3D 0)
+					continue;
+				compare =3D
+				 compare_orig(entries[j].src, packet->vis_orig);
+				vis_data_insert_interface(entries[j].src,
+							  &vis_if_list,
+							  compare);
+			}
+
+			hlist_for_each_entry(entry, pos, &vis_if_list, list) {
+				buf_size +=3D 18 + 26 * packet->entries;
+
+				/* add primary/secondary records */
+				if (compare_orig(entry->addr, packet->vis_orig))
+					buf_size +=3D
+					  vis_data_count_prim_sec(&vis_if_list);
+
+				buf_size +=3D 1;
+			}
+
+			hlist_for_each_entry_safe(entry, pos, n, &vis_if_list,
+						  list) {
+				hlist_del(&entry->list);
+				kfree(entry);
+			}
+		}
+	}
+
+	buff =3D kmalloc(buf_size, GFP_ATOMIC);
+	if (!buff) {
+		spin_unlock_bh(&bat_priv->vis_hash_lock);
+		return -ENOMEM;
+	}
+	buff[0] =3D '\0';
+	buff_pos =3D 0;
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			info =3D bucket->data;
+			packet =3D (struct vis_packet *)info->skb_packet->data;
+			entries =3D (struct vis_info_entry *)
+				((char *)packet + sizeof(struct vis_packet));
+
+			for (j =3D 0; j < packet->entries; j++) {
+				if (entries[j].quality =3D=3D 0)
+					continue;
+				compare =3D
+				 compare_orig(entries[j].src, packet->vis_orig);
+				vis_data_insert_interface(entries[j].src,
+							  &vis_if_list,
+							  compare);
+			}
+
+			hlist_for_each_entry(entry, pos, &vis_if_list, list) {
+				buff_pos +=3D sprintf(buff + buff_pos, "%pM,",
+						entry->addr);
+
+				for (i =3D 0; i < packet->entries; i++)
+					buff_pos +=3D vis_data_read_entry(
+							buff + buff_pos,
+							&entries[i],
+							entry->addr,
+							entry->primary);
+
+				/* add primary/secondary records */
+				if (compare_orig(entry->addr, packet->vis_orig))
+					buff_pos +=3D
+					 vis_data_read_prim_sec(buff + buff_pos,
+								&vis_if_list);
+
+				buff_pos +=3D sprintf(buff + buff_pos, "\n");
+			}
+
+			hlist_for_each_entry_safe(entry, pos, n, &vis_if_list,
+						  list) {
+				hlist_del(&entry->list);
+				kfree(entry);
+			}
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->vis_hash_lock);
+
+	seq_printf(seq, "%s", buff);
+	kfree(buff);
+
+	return 0;
+}
+
+/* add the info packet to the send list, if it was not
+ * already linked in. */
+static void send_list_add(struct bat_priv *bat_priv, struct vis_info *in=
fo)
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
+
+	entry =3D kmalloc(sizeof(struct recvlist_node), GFP_ATOMIC);
+	if (!entry)
+		return;
+
+	memcpy(entry->mac, mac, ETH_ALEN);
+	spin_lock_bh(&bat_priv->vis_list_lock);
+	list_add_tail(&entry->list, recv_list);
+	spin_unlock_bh(&bat_priv->vis_list_lock);
+}
+
+/* returns 1 if this mac is in the recv_list */
+static int recv_list_is_in(struct bat_priv *bat_priv,
+			   struct list_head *recv_list, char *mac)
+{
+	struct recvlist_node *entry;
+
+	spin_lock_bh(&bat_priv->vis_list_lock);
+	list_for_each_entry(entry, recv_list, list) {
+		if (memcmp(entry->mac, mac, ETH_ALEN) =3D=3D 0) {
+			spin_unlock_bh(&bat_priv->vis_list_lock);
+			return 1;
+		}
+	}
+	spin_unlock_bh(&bat_priv->vis_list_lock);
+	return 0;
+}
+
+/* try to add the packet to the vis_hash. return NULL if invalid (e.g. t=
oo old,
+ * broken.. ).	vis hash must be locked outside.  is_new is set when the =
packet
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
+	int hash_added;
+
+	*is_new =3D 0;
+	/* sanity check */
+	if (!bat_priv->vis_hash)
+		return NULL;
+
+	/* see if the packet is already in vis_hash */
+	search_elem.skb_packet =3D dev_alloc_skb(sizeof(struct vis_packet));
+	if (!search_elem.skb_packet)
+		return NULL;
+	search_packet =3D (struct vis_packet *)skb_put(search_elem.skb_packet,
+						     sizeof(struct vis_packet));
+
+	memcpy(search_packet->vis_orig, vis_packet->vis_orig, ETH_ALEN);
+	old_info =3D hash_find(bat_priv->vis_hash, vis_info_cmp, vis_info_choos=
e,
+			     &search_elem);
+	kfree_skb(search_elem.skb_packet);
+
+	if (old_info) {
+		old_packet =3D (struct vis_packet *)old_info->skb_packet->data;
+		if (!seq_after(ntohl(vis_packet->seqno),
+			       ntohl(old_packet->seqno))) {
+			if (old_packet->seqno =3D=3D vis_packet->seqno) {
+				recv_list_add(bat_priv, &old_info->recv_list,
+					      vis_packet->sender_orig);
+				return old_info;
+			} else {
+				/* newer packet is already in hash. */
+				return NULL;
+			}
+		}
+		/* remove old entry */
+		hash_remove(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
+			    old_info);
+		send_list_del(old_info);
+		kref_put(&old_info->refcount, free_info);
+	}
+
+	info =3D kmalloc(sizeof(struct vis_info), GFP_ATOMIC);
+	if (!info)
+		return NULL;
+
+	info->skb_packet =3D dev_alloc_skb(sizeof(struct vis_packet) +
+					 vis_info_len + sizeof(struct ethhdr));
+	if (!info->skb_packet) {
+		kfree(info);
+		return NULL;
+	}
+	skb_reserve(info->skb_packet, sizeof(struct ethhdr));
+	packet =3D (struct vis_packet *)skb_put(info->skb_packet,
+					      sizeof(struct vis_packet) +
+					      vis_info_len);
+
+	kref_init(&info->refcount);
+	INIT_LIST_HEAD(&info->send_list);
+	INIT_LIST_HEAD(&info->recv_list);
+	info->first_seen =3D jiffies;
+	info->bat_priv =3D bat_priv;
+	memcpy(packet, vis_packet, sizeof(struct vis_packet) + vis_info_len);
+
+	/* initialize and add new packet. */
+	*is_new =3D 1;
+
+	/* Make it a broadcast packet, if required */
+	if (make_broadcast)
+		memcpy(packet->target_orig, broadcast_addr, ETH_ALEN);
+
+	/* repair if entries is longer than packet. */
+	if (packet->entries * sizeof(struct vis_info_entry) > vis_info_len)
+		packet->entries =3D vis_info_len / sizeof(struct vis_info_entry);
+
+	recv_list_add(bat_priv, &info->recv_list, packet->sender_orig);
+
+	/* try to add it */
+	hash_added =3D hash_add(bat_priv->vis_hash, vis_info_cmp, vis_info_choo=
se,
+			      info);
+	if (hash_added < 0) {
+		/* did not work (for some reason) */
+		kref_put(&old_info->refcount, free_info);
+		info =3D NULL;
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
+	int vis_server =3D atomic_read(&bat_priv->vis_mode);
+
+	make_broadcast =3D (vis_server =3D=3D VIS_TYPE_SERVER_SYNC);
+
+	spin_lock_bh(&bat_priv->vis_hash_lock);
+	info =3D add_packet(bat_priv, vis_packet, vis_info_len,
+			  &is_new, make_broadcast);
+	if (!info)
+		goto end;
+
+	/* only if we are server ourselves and packet is newer than the one in
+	 * hash.*/
+	if (vis_server =3D=3D VIS_TYPE_SERVER_SYNC && is_new)
+		send_list_add(bat_priv, info);
+end:
+	spin_unlock_bh(&bat_priv->vis_hash_lock);
+}
+
+/* handle an incoming client update packet and schedule forward if neede=
d. */
+void receive_client_update_packet(struct bat_priv *bat_priv,
+				  struct vis_packet *vis_packet,
+				  int vis_info_len)
+{
+	struct vis_info *info;
+	struct vis_packet *packet;
+	int is_new;
+	int vis_server =3D atomic_read(&bat_priv->vis_mode);
+	int are_target =3D 0;
+
+	/* clients shall not broadcast. */
+	if (is_broadcast_ether_addr(vis_packet->target_orig))
+		return;
+
+	/* Are we the target for this VIS packet? */
+	if (vis_server =3D=3D VIS_TYPE_SERVER_SYNC	&&
+	    is_my_mac(vis_packet->target_orig))
+		are_target =3D 1;
+
+	spin_lock_bh(&bat_priv->vis_hash_lock);
+	info =3D add_packet(bat_priv, vis_packet, vis_info_len,
+			  &is_new, are_target);
+
+	if (!info)
+		goto end;
+	/* note that outdated packets will be dropped at this point. */
+
+	packet =3D (struct vis_packet *)info->skb_packet->data;
+
+	/* send only if we're the target server or ... */
+	if (are_target && is_new) {
+		packet->vis_type =3D VIS_TYPE_SERVER_SYNC;	/* upgrade! */
+		send_list_add(bat_priv, info);
+
+		/* ... we're not the recipient (and thus need to forward). */
+	} else if (!is_my_mac(packet->target_orig)) {
+		send_list_add(bat_priv, info);
+	}
+
+end:
+	spin_unlock_bh(&bat_priv->vis_hash_lock);
+}
+
+/* Walk the originators and find the VIS server with the best tq. Set th=
e packet
+ * address to its address and return the best_tq.
+ *
+ * Must be called with the originator hash locked */
+static int find_best_vis_server(struct bat_priv *bat_priv,
+				struct vis_info *info)
+{
+	struct hashtable_t *hash =3D bat_priv->orig_hash;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct orig_node *orig_node;
+	struct vis_packet *packet;
+	int best_tq =3D -1, i;
+
+	packet =3D (struct vis_packet *)info->skb_packet->data;
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			orig_node =3D bucket->data;
+			if ((orig_node) && (orig_node->router) &&
+			(orig_node->flags & VIS_SERVER) &&
+			(orig_node->router->tq_avg > best_tq)) {
+				best_tq =3D orig_node->router->tq_avg;
+				memcpy(packet->target_orig, orig_node->orig,
+				       ETH_ALEN);
+			}
+		}
+	}
+
+	return best_tq;
+}
+
+/* Return true if the vis packet is full. */
+static bool vis_packet_full(struct vis_info *info)
+{
+	struct vis_packet *packet;
+	packet =3D (struct vis_packet *)info->skb_packet->data;
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
+	struct hashtable_t *hash =3D bat_priv->orig_hash;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct orig_node *orig_node;
+	struct neigh_node *neigh_node;
+	struct vis_info *info =3D (struct vis_info *)bat_priv->my_vis_info;
+	struct vis_packet *packet =3D (struct vis_packet *)info->skb_packet->da=
ta;
+	struct vis_info_entry *entry;
+	struct hna_local_entry *hna_local_entry;
+	int best_tq =3D -1, i;
+
+	info->first_seen =3D jiffies;
+	packet->vis_type =3D atomic_read(&bat_priv->vis_mode);
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	memcpy(packet->target_orig, broadcast_addr, ETH_ALEN);
+	packet->ttl =3D TTL;
+	packet->seqno =3D htonl(ntohl(packet->seqno) + 1);
+	packet->entries =3D 0;
+	skb_trim(info->skb_packet, sizeof(struct vis_packet));
+
+	if (packet->vis_type =3D=3D VIS_TYPE_CLIENT_UPDATE) {
+		best_tq =3D find_best_vis_server(bat_priv, info);
+
+		if (best_tq < 0) {
+			spin_unlock_bh(&bat_priv->orig_hash_lock);
+			return -1;
+		}
+	}
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			orig_node =3D bucket->data;
+			neigh_node =3D orig_node->router;
+
+			if (!neigh_node)
+				continue;
+
+			if (!compare_orig(neigh_node->addr, orig_node->orig))
+				continue;
+
+			if (neigh_node->if_incoming->if_status !=3D IF_ACTIVE)
+				continue;
+
+			if (neigh_node->tq_avg < 1)
+				continue;
+
+			/* fill one entry into buffer. */
+			entry =3D (struct vis_info_entry *)
+				      skb_put(info->skb_packet, sizeof(*entry));
+			memcpy(entry->src,
+			       neigh_node->if_incoming->net_dev->dev_addr,
+			       ETH_ALEN);
+			memcpy(entry->dest, orig_node->orig, ETH_ALEN);
+			entry->quality =3D neigh_node->tq_avg;
+			packet->entries++;
+
+			if (vis_packet_full(info)) {
+				spin_unlock_bh(&bat_priv->orig_hash_lock);
+				return 0;
+			}
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	hash =3D bat_priv->hna_local_hash;
+
+	spin_lock_bh(&bat_priv->hna_lhash_lock);
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			hna_local_entry =3D bucket->data;
+			entry =3D (struct vis_info_entry *)
+					skb_put(info->skb_packet,
+						sizeof(*entry));
+			memset(entry->src, 0, ETH_ALEN);
+			memcpy(entry->dest, hna_local_entry->addr, ETH_ALEN);
+			entry->quality =3D 0; /* 0 means HNA */
+			packet->entries++;
+
+			if (vis_packet_full(info)) {
+				spin_unlock_bh(&bat_priv->hna_lhash_lock);
+				return 0;
+			}
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+	return 0;
+}
+
+/* free old vis packets. Must be called with this vis_hash_lock
+ * held */
+static void purge_vis_packets(struct bat_priv *bat_priv)
+{
+	int i;
+	struct hashtable_t *hash =3D bat_priv->vis_hash;
+	struct hlist_node *walk, *safe;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct vis_info *info;
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
+			info =3D bucket->data;
+
+			/* never purge own data. */
+			if (info =3D=3D bat_priv->my_vis_info)
+				continue;
+
+			if (time_after(jiffies,
+				       info->first_seen + VIS_TIMEOUT * HZ)) {
+				hlist_del(walk);
+				kfree(bucket);
+				send_list_del(info);
+				kref_put(&info->refcount, free_info);
+			}
+		}
+	}
+}
+
+static void broadcast_vis_packet(struct bat_priv *bat_priv,
+				 struct vis_info *info)
+{
+	struct hashtable_t *hash =3D bat_priv->orig_hash;
+	struct hlist_node *walk;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	struct orig_node *orig_node;
+	struct vis_packet *packet;
+	struct sk_buff *skb;
+	struct batman_if *batman_if;
+	uint8_t dstaddr[ETH_ALEN];
+	int i;
+
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	packet =3D (struct vis_packet *)info->skb_packet->data;
+
+	/* send to all routers in range. */
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		hlist_for_each_entry(bucket, walk, head, hlist) {
+			orig_node =3D bucket->data;
+
+			/* if it's a vis server and reachable, send it. */
+			if ((!orig_node) || (!orig_node->router))
+				continue;
+			if (!(orig_node->flags & VIS_SERVER))
+				continue;
+			/* don't send it if we already received the packet from
+			* this node. */
+			if (recv_list_is_in(bat_priv, &info->recv_list,
+					    orig_node->orig))
+				continue;
+
+			memcpy(packet->target_orig, orig_node->orig, ETH_ALEN);
+			batman_if =3D orig_node->router->if_incoming;
+			memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+			spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+			skb =3D skb_clone(info->skb_packet, GFP_ATOMIC);
+			if (skb)
+				send_skb_packet(skb, batman_if, dstaddr);
+
+			spin_lock_bh(&bat_priv->orig_hash_lock);
+		}
+
+	}
+
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+}
+
+static void unicast_vis_packet(struct bat_priv *bat_priv,
+			       struct vis_info *info)
+{
+	struct orig_node *orig_node;
+	struct sk_buff *skb;
+	struct vis_packet *packet;
+	struct batman_if *batman_if;
+	uint8_t dstaddr[ETH_ALEN];
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
+	packet =3D (struct vis_packet *)info->skb_packet->data;
+	orig_node =3D ((struct orig_node *)hash_find(bat_priv->orig_hash,
+						   compare_orig, choose_orig,
+						   packet->target_orig));
+
+	if ((!orig_node) || (!orig_node->router))
+		goto out;
+
+	/* don't lock while sending the packets ... we therefore
+	 * copy the required data before sending */
+	batman_if =3D orig_node->router->if_incoming;
+	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+
+	skb =3D skb_clone(info->skb_packet, GFP_ATOMIC);
+	if (skb)
+		send_skb_packet(skb, batman_if, dstaddr);
+
+	return;
+
+out:
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+}
+
+/* only send one vis packet. called from send_vis_packets() */
+static void send_vis_packet(struct bat_priv *bat_priv, struct vis_info *=
info)
+{
+	struct vis_packet *packet;
+
+	packet =3D (struct vis_packet *)info->skb_packet->data;
+	if (packet->ttl < 2) {
+		pr_debug("Error - can't send vis packet: ttl exceeded\n");
+		return;
+	}
+
+	memcpy(packet->sender_orig, bat_priv->primary_if->net_dev->dev_addr,
+	       ETH_ALEN);
+	packet->ttl--;
+
+	if (is_broadcast_ether_addr(packet->target_orig))
+		broadcast_vis_packet(bat_priv, info);
+	else
+		unicast_vis_packet(bat_priv, info);
+	packet->ttl++; /* restore TTL */
+}
+
+/* called from timer; send (and maybe generate) vis packet. */
+static void send_vis_packets(struct work_struct *work)
+{
+	struct delayed_work *delayed_work =3D
+		container_of(work, struct delayed_work, work);
+	struct bat_priv *bat_priv =3D
+		container_of(delayed_work, struct bat_priv, vis_work);
+	struct vis_info *info, *temp;
+
+	spin_lock_bh(&bat_priv->vis_hash_lock);
+	purge_vis_packets(bat_priv);
+
+	if (generate_vis_packet(bat_priv) =3D=3D 0) {
+		/* schedule if generation was successful */
+		send_list_add(bat_priv, bat_priv->my_vis_info);
+	}
+
+	list_for_each_entry_safe(info, temp, &bat_priv->vis_send_list,
+				 send_list) {
+
+		kref_get(&info->refcount);
+		spin_unlock_bh(&bat_priv->vis_hash_lock);
+
+		if (bat_priv->primary_if)
+			send_vis_packet(bat_priv, info);
+
+		spin_lock_bh(&bat_priv->vis_hash_lock);
+		send_list_del(info);
+		kref_put(&info->refcount, free_info);
+	}
+	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	start_vis_timer(bat_priv);
+}
+
+/* init the vis server. this may only be called when if_list is already
+ * initialized (e.g. bat0 is initialized, interfaces have been added) */
+int vis_init(struct bat_priv *bat_priv)
+{
+	struct vis_packet *packet;
+	int hash_added;
+
+	if (bat_priv->vis_hash)
+		return 1;
+
+	spin_lock_bh(&bat_priv->vis_hash_lock);
+
+	bat_priv->vis_hash =3D hash_new(256);
+	if (!bat_priv->vis_hash) {
+		pr_err("Can't initialize vis_hash\n");
+		goto err;
+	}
+
+	bat_priv->my_vis_info =3D kmalloc(MAX_VIS_PACKET_SIZE, GFP_ATOMIC);
+	if (!bat_priv->my_vis_info) {
+		pr_err("Can't initialize vis packet\n");
+		goto err;
+	}
+
+	bat_priv->my_vis_info->skb_packet =3D dev_alloc_skb(
+						sizeof(struct vis_packet) +
+						MAX_VIS_PACKET_SIZE +
+						sizeof(struct ethhdr));
+	if (!bat_priv->my_vis_info->skb_packet)
+		goto free_info;
+
+	skb_reserve(bat_priv->my_vis_info->skb_packet, sizeof(struct ethhdr));
+	packet =3D (struct vis_packet *)skb_put(
+					bat_priv->my_vis_info->skb_packet,
+					sizeof(struct vis_packet));
+
+	/* prefill the vis info */
+	bat_priv->my_vis_info->first_seen =3D jiffies -
+						msecs_to_jiffies(VIS_INTERVAL);
+	INIT_LIST_HEAD(&bat_priv->my_vis_info->recv_list);
+	INIT_LIST_HEAD(&bat_priv->my_vis_info->send_list);
+	kref_init(&bat_priv->my_vis_info->refcount);
+	bat_priv->my_vis_info->bat_priv =3D bat_priv;
+	packet->version =3D COMPAT_VERSION;
+	packet->packet_type =3D BAT_VIS;
+	packet->ttl =3D TTL;
+	packet->seqno =3D 0;
+	packet->entries =3D 0;
+
+	INIT_LIST_HEAD(&bat_priv->vis_send_list);
+
+	hash_added =3D hash_add(bat_priv->vis_hash, vis_info_cmp, vis_info_choo=
se,
+			      bat_priv->my_vis_info);
+	if (hash_added < 0) {
+		pr_err("Can't add own vis packet into hash\n");
+		/* not in hash, need to remove it manually. */
+		kref_put(&bat_priv->my_vis_info->refcount, free_info);
+		goto err;
+	}
+
+	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	start_vis_timer(bat_priv);
+	return 1;
+
+free_info:
+	kfree(bat_priv->my_vis_info);
+	bat_priv->my_vis_info =3D NULL;
+err:
+	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	vis_quit(bat_priv);
+	return 0;
+}
+
+/* Decrease the reference count on a hash item info */
+static void free_info_ref(void *data, void *arg)
+{
+	struct vis_info *info =3D data;
+
+	send_list_del(info);
+	kref_put(&info->refcount, free_info);
+}
+
+/* shutdown vis-server */
+void vis_quit(struct bat_priv *bat_priv)
+{
+	if (!bat_priv->vis_hash)
+		return;
+
+	cancel_delayed_work_sync(&bat_priv->vis_work);
+
+	spin_lock_bh(&bat_priv->vis_hash_lock);
+	/* properly remove, kill timers ... */
+	hash_delete(bat_priv->vis_hash, free_info_ref, NULL);
+	bat_priv->vis_hash =3D NULL;
+	bat_priv->my_vis_info =3D NULL;
+	spin_unlock_bh(&bat_priv->vis_hash_lock);
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
--=20
1.7.2.3
