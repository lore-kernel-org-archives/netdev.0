From: "Reeuwijk, C. van" <c.van.reeuwijk@vu.nl>
Subject: [PATCH] iproute: clarification of various man8 pages
Date: Thu, 31 Jan 2013 16:04:00 +0000
Message-ID: <1C7941B6-6341-438C-8959-3799FEAEEF6E@cs.vu.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.vu.nl ([130.37.164.19]:14838 "EHLO mailin.vu.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149Ab3AaQJY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 11:09:24 -0500
Content-Language: en-US
Content-ID: <7EA9F432A16CBA4EA508C46A0AEA9764@ad.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  From: Kees van Reeuwijk <reeuwijk@few.vu.nl>

Rephrasing for clarity.

Note that in ip-rule.8 I rephrased a sentence to "The RPDB is scanned in order of decreasing priority." The original version talked about *in*creasing priority, but from the context that didn't make sense.


Signed-off-by: Kees van Reeuwijk <reeuwijk@few.vu.nl>

---
arpd.8         |   38 +++++++++++++++++++-------------------
 bridge.8       |   10 +++++-----
 ip-addrlabel.8 |   16 ++++++++--------
 ip-maddress.8  |   10 +++++-----
 ip-monitor.8   |   25 ++++++++++++++++---------
 ip-mroute.8    |    4 ++--
 ip-neighbour.8 |    2 +-
 ip-netconf.8   |    6 +++---
 ip-netns.8     |    4 ++--
 ip-rule.8      |    6 +++---
 ip.8           |   20 ++++++++++----------
 tc.8           |    6 +++---
 12 files changed, 77 insertions(+), 70 deletions(-)

diff --git a/arpd.8 b/arpd.8
index a14044b..aa1685a 100644
--- a/arpd.8
+++ b/arpd.8
@@ -4,12 +4,12 @@
 arpd \- userspace arp daemon.
 
 .SH SYNOPSIS
-Usage: arpd [ -lkh? ] [ -a N ] [ -b dbase ] [ -B number ] [ -f file ] [-p interval ] [ -n time ] [ -R rate ] [ interfaces ]
+Usage: arpd [ -lkh? ] [ -a N ] [ -b dbase ] [ -B number ] [ -f file ] [-p interval ] [ -n time ] [ -R rate ] [ <INTERFACES> ]
 
 .SH DESCRIPTION
 The
 .B arpd
-daemon collects gratuitous ARP information, saving it on local disk and feeding it to kernel on demand to avoid redundant broadcasting due to limited size of kernel ARP cache.
+daemon collects gratuitous ARP information, saving it on local disk and feeding it to the kernel on demand to avoid redundant broadcasting due to limited size of the kernel ARP cache.
 
 .SH OPTIONS
 .TP
@@ -17,41 +17,41 @@ daemon collects gratuitous ARP information, saving it on local disk and feeding
 Print help
 .TP
 -l
-Dump arpd database to stdout and exit. Output consists of three columns: interface index, IP address and MAC address. Negative entries for dead hosts are also shown, in this case MAC address is replaced by word FAILED followed by colon and time when the fact that host is dead was proven the last time.
+Dump arpd database to stdout and exit. Output consists of three columns: interface index, IP address and MAC address. Negative entries for dead hosts are also shown, in this case MAC address is replaced by the word FAILED followed by a colon and the time when the fact that host is dead was proven the last time.
 .TP
 -f <FILE>
-Read and load arpd database from FILE in text format similar dumped by option -l. Exit after load, probably listing resulting database, if option -l is also given. If FILE is -, stdin is read to get ARP table.
+Read and load an arpd database from FILE in a text format similar to that dumped by option -l. Exit after load, possibly listing resulting database, if option -l is also given. If FILE is -, stdin is read to get the ARP table.
 .TP
 -b <DATABASE>
-location of database file. Default location is /var/lib/arpd/arpd.db
+the location of the database file. The default location is /var/lib/arpd/arpd.db
 .TP
 -a <NUMBER>
-arpd not only passively listens ARP on wire, but also send brodcast queries itself. NUMBER is number of such queries to make before destination is considered as dead. When arpd is started as kernel helper (i.e. with app_solicit enabled in sysctl or even with option -k) without this option and still did not learn enough information, you can observe 1 second gaps in service. Not fatal, but not good.
+With this option, arpd not only passively listens for ARP packets on the interface, but also sends brodcast queries itself. NUMBER is the number of such queries to make before a destination is considered dead. When arpd is started as kernel helper (i.e. with app_solicit enabled in sysctl or even with option -k) without this option and still did not learn enough information, you can observe 1 second gaps in service. Not fatal, but not good.
 .TP
 -k
-Suppress sending broadcast queries by kernel. It takes sense together with option -a.
+Suppress sending broadcast queries by the kernel. This option only makes sense together with option -a.
 .TP
 -n <TIME>
-Timeout of negative cache. When resolution fails arpd suppresses further attempts to resolve for this period. It makes sense only together with option -k This timeout should not be too much longer than boot time of a typical host not supporting gratuitous ARP. Default value is 60 seconds.
+Specifies the timeout of the negative cache. When resolution fails, arpd suppresses further attempts to resolve for this period. This option only makes sense together with option '-k'. This timeout should not be too much longer than the boot time of a typical host not supporting gratuitous ARP. Default value is 60 seconds.
 .TP
 -p <TIME>
-Time to wait in seconds between polling attempts to the kernel ARP table. TIME may be a floating point number.  The default value is 30.
+The time to wait in seconds between polling attempts to the kernel ARP table. TIME may be a floating point number.  The default value is 30.
 .TP
 -R <RATE>
 Maximal steady rate of broadcasts sent by arpd in packets per second. Default value is 1.
 .TP
 -B <NUMBER>
-Number of broadcasts sent by <tt/arpd/ back to back. Default value is 3. Together with option <tt/-R/ this option allows to police broadcasting not to exceed B+R*T over any interval of time T.
+The number of broadcasts sent by arpd back to back. Default value is 3. Together with the -R option, this option ensures that the number of ARP queries that are broadcast does not exceed B+R*T over any interval of time T.
 .P
-<INTERFACE> is the name of networking interface to watch. If no interfaces given, arpd monitors all the interfaces. In this case arpd does not adjust sysctl parameters, it is supposed user does this himself after arpd is started.
+<INTERFACES> is a list of names of networking interfaces to watch. If no interfaces are given, arpd monitors all the interfaces. In this case arpd does not adjust sysctl parameters, it is assumed that the user does this himself after arpd is started.
 .P
-Signals
-.br
-arpd exits gracefully syncing database and restoring adjusted sysctl parameters, when receives SIGINT or SIGTERM. SIGHUP syncs database to disk. SIGUSR1 sends some statistics to syslog. Effect of another signals is undefined, they may corrupt database and leave sysctl praameters in an unpredictable state.
+.SH SIGNALS
+.TP
+When arpd receives a SIGINT or SIGTERM signal, it exits gracefully, syncing the database and restoring adjusted sysctl parameters. On a SIGHUP it syncs the database to disk. With SIGUSR1 it sends some statistics to syslog. The effect of any other signals is undefined. In particular, they may corrupt the database and leave the sysctl parameters in an unpredictable state.
 .P
-Note
-.br
-In order for arpd to be able to serve as ARP resolver, kernel must be compiled with the option CONFIG_ARPD and, in the case when interface list in not given on command line, variable app_solicit on interfaces of interest should be in /proc/sys/net/ipv4/neigh/*. If this is not made arpd still collects gratuitous ARP information in its database.
+.SH NOTE
+.TP
+In order for arpd to be able to serve as ARP resolver, the kernel must be compiled with the option CONFIG_ARPD and, in the case when interface list in not given on command line, variable app_solicit on interfaces of interest should be in /proc/sys/net/ipv4/neigh/*. If this is not made arpd still collects gratuitous ARP information in its database.
 .SH EXAMPLES
 .TP
 arpd -b /var/tmp/arpd.db
@@ -64,6 +64,6 @@ arpd -b /var/tmp/arpd.db -a 1 eth0 eth1
 Enable kernel helper, leaving leading role to kernel.
 .TP
 arpd -b /var/tmp/arpd.db -a 3 -k eth0 eth1
-Completely replace kernel resolution on interfaces eth0 and eth1. In this case kernel still does unicast probing to validate entries, but all the broadcast activity is suppressed and made under authority of arpd.
+Completely replace kernel resolution on interfaces eth0 and eth1. In this case the kernel still does unicast probing to validate entries, but all the broadcast activity is suppressed and made under authority of arpd.
 .PP
-This is mode which arpd is supposed to work normally. It is not default just to prevent occasional enabling of too aggressive mode occasionally.
+This is the mode in which arpd normally is supposed to work. It is not the default to prevent occasional enabling of too aggressive a mode.
diff --git a/bridge.8 b/bridge.8
index 5ce8219..fd91618 100644
--- a/bridge.8
+++ b/bridge.8
@@ -47,8 +47,8 @@ utility and exit.
 
 .TP
 .BR "\-s" , " \-stats", " \-statistics"
-output more information.  If the option
-appears twice or more, the amount of information increases.
+output more information.  If this option
+is given multiple times, the amount of information increases.
 As a rule, the information is statistics or some time values.
 
 
@@ -135,7 +135,7 @@ The arguments are the same as with
 
 .SS bridge fdb show - list forwarding entries.
 
-This commands displays current forwarding table.
+This command displays the current forwarding table.
 
 .PP
 With the
@@ -154,7 +154,7 @@ Namely, the
 command is the first in the command line and then the object list follows:
 
 .BR "bridge monitor" " [ " all " |"
-.IR LISTofOBJECTS " ]"
+.IR OBJECT-LIST " ]"
 
 .I OBJECT-LIST
 is the list of object types that we want to monitor.
@@ -186,7 +186,7 @@ based on the bridge to which the coresponding ethernet device is attached.
 
 .SH SEE ALSO
 .BR ip (8)
-.br
+.SH BUGS
 .RB "Please direct bugreports and patches to: " <netdev@vger.kernel.org>
 
 .SH AUTHOR
diff --git a/ip-addrlabel.8 b/ip-addrlabel.8
index 3252bd2..fefc3ef 100644
--- a/ip-addrlabel.8
+++ b/ip-addrlabel.8
@@ -34,12 +34,12 @@ ip-addrlabel \- protocol address label management
 .BR "ip addrlabel" " { " list " | " flush " }"
 
 .SH "DESCRIPTION"
-IPv6 address label is used for address selection
-described in RFC 3484.  Precedence is managed by userspace,
-and only label is stored in kernel.
+IPv6 address labels are used for address selection;
+they are described in RFC 3484.  Precedence is managed by userspace,
+and only the label itself is stored in the kernel.
 
 .SS ip addrlabel add - add an address label
-the command adds an address label entry to the kernel.
+add an address label entry to the kernel.
 .TP
 .BI prefix " PREFIX"
 .TP
@@ -50,15 +50,15 @@ the outgoing interface.
 the label for the prefix.
 0xffffffff is reserved.
 .SS ip addrlabel del - delete an address label
-the command deletes an address label entry in the kernel.
+delete an address label entry from the kernel.
 .B Arguments:
 coincide with the arguments of
 .B ip addrlabel add
-but label is not required.
+but the label is not required.
 .SS ip addrlabel list - list address labels
-the command show contents of address labels.
+list the current address label entries in the kernel.
 .SS ip addrlabel flush - flush address labels
-the command flushes the contents of address labels and it does not restore default settings.
+flush all address labels in the kernel. This does not restore any default settings.
 
 .SH SEE ALSO
 .br
diff --git a/ip-maddress.8 b/ip-maddress.8
index afae551..e0bad47 100644
--- a/ip-maddress.8
+++ b/ip-maddress.8
@@ -15,11 +15,11 @@ ip-maddress \- multicast addresses management
 .ti -8
 
 .BR "ip maddress" " [ " add " | " del " ]"
-.IB MULTIADDR " dev " STRING
+.IB MULTIADDR " dev " NAME
 
 .ti -8
 .BR "ip maddress show" " [ " dev
-.IR STRING " ]"
+.IR NAME " ]"
 
 .SH DESCRIPTION
 .B maddress
@@ -33,14 +33,14 @@ the device name.
 
 .SS ip maddress add - add a multicast address
 .SS ip maddress delete - delete a multicast address
-these commands attach/detach a static link layer multicast address
+these commands attach/detach a static link-layer multicast address
 to listen on the interface.
 Note that it is impossible to join protocol multicast groups
-statically.  This command only manages link layer addresses.
+statically.  This command only manages link-layer addresses.
 
 .TP
 .BI address " LLADDRESS " (default)
-the link layer multicast address.
+the link-layer multicast address.
 
 .TP
 .BI dev " NAME"
diff --git a/ip-monitor.8 b/ip-monitor.8
index b07cb0e..b6e8d1d 100644
--- a/ip-monitor.8
+++ b/ip-monitor.8
@@ -6,8 +6,12 @@ ip-monitor, rtmon \- state monitoring
 .ad l
 .in +8
 .ti -8
-.BR "ip " " [ ip-OPTIONS ] " "monitor" " [ " all " |"
-.IR LISTofOBJECTS " ] [ file " FILENAME " ]
+.BR "ip " " [ "
+.IR ip-OPTIONS " ]"
+.BR  "monitor" " [ " all " |"
+.IR OBJECT-LIST " ] ["
+.BI file " FILENAME "
+]
 .sp
 
 .SH DESCRIPTION
@@ -20,7 +24,9 @@ Namely, the
 command is the first in the command line and then the object list follows:
 
 .BR "ip monitor" " [ " all " |"
-.IR LISTofOBJECTS " ] [ file " FILENAME " ]
+.IR OBJECT-LIST " ] ["
+.BI file " FILENAME "
+]
 
 .I OBJECT-LIST
 is the list of object types that we want to monitor.
@@ -35,11 +41,12 @@ opens RTNETLINK, listens on it and dumps state changes in the format
 described in previous sections.
 
 .P
-If a
-.I FILENAME
-is given, it does not listen on RTNETLINK,
-but opens the file containing RTNETLINK messages saved in binary format
-and dumps them.  Such a history file can be generated with the
+If the
+.BI file
+option is given, the program does not listen on RTNETLINK,
+but opens the given file, and dumps its contents. The file
+should contain RTNETLINK messages saved in binary format.
+Such a file can be generated with the
 .B rtmon
 utility.  This utility has a command line syntax similar to
 .BR "ip monitor" .
@@ -56,7 +63,7 @@ in a startup script, you will be able to view the full history
 later.
 
 .P
-Certainly, it is possible to start
+Nevertheless, it is possible to start
 .B rtmon
 at any time.
 It prepends the history with the state snapshot dumped at the moment
diff --git a/ip-mroute.8 b/ip-mroute.8
index 870df5e..3b708cf 100644
--- a/ip-mroute.8
+++ b/ip-mroute.8
@@ -18,7 +18,7 @@ ip-mroute \- multicast routing cache management
 
 .SH DESCRIPTION
 .B mroute
-objects are multicast routing cache entries created by a user level
+objects are multicast routing cache entries created by a user-level
 mrouting daemon (f.e.
 .B pimd
 or
@@ -28,7 +28,7 @@ or
 Due to the limitations of the current interface to the multicast routing
 engine, it is impossible to change
 .B mroute
-objects administratively, so we may only display them.  This limitation
+objects administratively, so we can only display them.  This limitation
 will be removed in the future.
 
 .SS ip mroute show - list mroute cache entries
diff --git a/ip-neighbour.8 b/ip-neighbour.8
index 34980c5..5d9768f 100644
--- a/ip-neighbour.8
+++ b/ip-neighbour.8
@@ -40,7 +40,7 @@ command manipulates
 objects that establish bindings between protocol addresses and
 link layer addresses for hosts sharing the same link.
 Neighbour entries are organized into tables. The IPv4 neighbour table
-is known by another name - the ARP table.
+is also known by another name - the ARP table.
 
 .P
 The corresponding commands display neighbour bindings
diff --git a/ip-netconf.8 b/ip-netconf.8
index 8041ea2..2718258 100644
--- a/ip-netconf.8
+++ b/ip-netconf.8
@@ -8,7 +8,7 @@ ip-netconf \- network configuration monitoring
 .ti -8
 .BR "ip " " [ ip-OPTIONS ] " "netconf show" " [ "
 .B dev
-.IR STRING " ]"
+.IR NAME " ]"
 
 .SH DESCRIPTION
 The
@@ -25,8 +25,8 @@ is displayed.
 .SS ip netconf show - display network parameters
 
 .TP
-.BI dev " STRING"
-the name of the device to display network parameters.
+.BI dev " NAME"
+the name of the device to display network parameters for.
 
 .SH SEE ALSO
 .br
diff --git a/ip-netns.8 b/ip-netns.8
index 349ee7e..11bac18 100644
--- a/ip-netns.8
+++ b/ip-netns.8
@@ -37,8 +37,8 @@ descriptor can be used with the
 .B setns(2)
 system call to change the network namespace associated with a task.
 
-The convention for network namespace aware applications is to look
-for global network configuration files first in
+For applications that are aware of network namespaces, the convention
+is to look for global network configuration files first in
 .BR "/etc/netns/" NAME "/"
 then in
 .BR "/etc/".
diff --git a/ip-rule.8 b/ip-rule.8
index 0f62a53..36f461b 100644
--- a/ip-rule.8
+++ b/ip-rule.8
@@ -75,16 +75,16 @@ Each policy routing rule consists of a
 .B selector
 and an
 .B action predicate.
-The RPDB is scanned in the order of increasing priority. The selector
+The RPDB is scanned in order of decreasing priority. The selector
 of each rule is applied to {source address, destination address, incoming
 interface, tos, fwmark} and, if the selector matches the packet,
 the action is performed.  The action predicate may return with success.
 In this case, it will either give a route or failure indication
 and the RPDB lookup is terminated. Otherwise, the RPDB program
-continues on the next rule.
+continues with the next rule.
 
 .P
-Semantically, natural action is to select the nexthop and the output device.
+Semantically, the natural action is to select the nexthop and the output device.
 
 .P
 At startup time the kernel configures the default RPDB consisting of three
diff --git a/ip.8 b/ip.8
index 9063049..881e1ff 100644
--- a/ip.8
+++ b/ip.8
@@ -36,24 +36,24 @@ print the version of the
 utility and exit.
 
 .TP
-.BR "\-s" , " \-stats", " \-statistics"
+.BR "\-s" , " \-stats" , " \-statistics"
 output more information.  If the option
 appears twice or more, the amount of information increases.
 As a rule, the information is statistics or some time values.
 
 .TP
-.BR "\-l" , " \-loops"
+.BR "\-l" , " \-loops " <COUNT>
 Specify maximum number of loops the 'ip addr flush' logic
 will attempt before giving up.  The default is 10.
 Zero (0) means loop until all addresses are removed.
 
 .TP
-.BR "\-f" , " \-family"
-followed by protocol family identifier:
-.BR "inet" , " inet6" , "bridge" , "ipx" , "dnet"
+.BR "\-f" , " \-family " <FAMILY>
+Specifies the protocol family to use. The protocol family identifier can be one of
+.BR "inet" , " inet6" , " bridge" , " ipx" , " dnet"
 or
-.BR link ,
-enforce the protocol family to use.  If the option is not present,
+.BR link .
+If this option is not present,
 the protocol family is guessed from other arguments.  If the rest
 of the command line does not give enough information to guess the
 family,
@@ -178,9 +178,9 @@ host addresses.
 
 .PP
 The names of all objects may be written in full or
-abbreviated form, f.e.
+abbreviated form, for exampe
 .B address
-is abbreviated as
+can be abbreviated as
 .B addr
 or just
 .B a.
@@ -230,7 +230,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .br
 .RB "IP Command reference " ip-cref.ps
 .SH REPORTING BUGS
-Report bug to the Network Developers mailing list
+Report any bugs to the Network Developers mailing list
 .B <netdev@vger.kernel.org>
 where the development and maintenance is primarily done.
 You do not have to be subscribed to the list to send a message there.
diff --git a/tc.8 b/tc.8
index e9a7229..bbc6790 100644
--- a/tc.8
+++ b/tc.8
@@ -75,7 +75,7 @@ is also called prioritizing, and happens only on egress.
 
 .TP
 POLICING
-Where shaping deals with transmission of traffic, policing pertains to traffic
+Whereas shaping deals with transmission of traffic, policing pertains to traffic
 arriving. Policing thus occurs on ingress.
 
 .TP
@@ -203,7 +203,7 @@ Furthermore, each class contains a
 .B leaf qdisc
 which by default has
 .B pfifo
-behaviour though another qdisc can be attached in place. This qdisc may again
+behaviour, although another qdisc can be attached in place. This qdisc may again
 contain classes, but each class can have only one leaf qdisc.
 
 When a packet enters a classful qdisc it can be
@@ -233,7 +233,7 @@ attached to that class. Check qdisc specific manpages for details, however.
 All qdiscs, classes and filters have IDs, which can either be specified
 or be automatically assigned.
 
-ID's consist of a major number and a minor number, separated by a colon.
+IDs consist of a major number and a minor number, separated by a colon.
 Both major and minor number are limited to 16 bits. There are two special
 values: root is signified by major and minor of all ones, and unspecified
 is all zeros.

-- 
Dr. ir. Kees van Reeuwijk, Vrije Universiteit Amsterdam
