From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH 1/7] docs: improve manual pages and help
Date: Mon, 13 Apr 2015 15:59:24 +0200
Message-ID: <1428933570-8137-1-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org, psimerda@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:47549 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754131AbbDMOKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 10:10:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

Commit 43d29f7 substantially improves generated ip-address.8 instead of
ip-address.8.in and commit e419f2d removes the generated one losing the
improvements entirely. This commit recovers the lost changes, adapts
them to the current manual page and adds more man page and help
improvements.

Based on previous work by:

 * Kenyon Ralph <kenyon@kenyonralph.com>

ip link:

 * Add VLAN documentation.
 * Fix srcport/dstport in VXLAN documentation.

ip address:

 * Improve manual page synopsis and built-it help.
 * Use full subcommand names (e.g. 'address' and 'maddress').
 * Specify when IPv4, IPv6 or both are affected.
 * Add lifetimes, home and nodad.
 * Reduce left over double spaces.

ip route:

 * Prefer 'show' over 'list' for consistency.

ip rule:

 * Remove false statement about Rule 0.

ip tunnel:

 * Improve manual page synopsis and built-it help.

ifcfg:

 * Add manual page.

bridge fdb:

 * Fix fdb synopsis.

tc qdisc:

 * Add cbq manual page alias.

Changes (ss):

 * Turn Debian specific statement into a general one.
 * Refer to .ps docs instead of .html.

See also:

 * https://bugzilla.redhat.com/show_bug.cgi?id=3D1072441
 * https://bugzilla.redhat.com/show_bug.cgi?id=3D1075692
 * https://bugzilla.redhat.com/show_bug.cgi?id=3D1077191
 * https://bugzilla.redhat.com/show_bug.cgi?id=3D1105438
 * https://bugzilla.redhat.com/show_bug.cgi?id=3D1121261

Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
---
 bridge/fdb.c             |   8 ++--
 doc/ip-cref.tex          |   3 --
 ip/ip.c                  |   4 +-
 ip/ipaddress.c           |  16 +++----
 man/man8/bridge.8        |   6 +--
 man/man8/cbq.8           |   1 +
 man/man8/ifcfg.8         |  57 ++++++++++++++++++++++
 man/man8/ip-address.8.in | 120 ++++++++++++++++++++++++++++++++++++---=
--------
 man/man8/ip-link.8.in    |  25 +++++++++-
 man/man8/ip-route.8.in   |   2 +-
 man/man8/ip-rule.8       |   2 -
 man/man8/ip-tunnel.8     |   6 +--
 man/man8/ip.8            |   6 +--
 man/man8/ss.8            |   4 +-
 14 files changed, 200 insertions(+), 60 deletions(-)
 create mode 100644 man/man8/cbq.8
 create mode 100644 man/man8/ifcfg.8

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 3c33e22..1fec09a 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -31,10 +31,10 @@ static unsigned int filter_index;
=20
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace } A=
DDR dev DEV {self|master} [ temp ]\n"
-		        "              [router] [ dst IPADDR] [ vlan VID ]\n"
-		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
-	fprintf(stderr, "       bridge fdb {show} [ br BRDEV ] [ brport DEV ]=
\n");
+	fprintf(stderr, "Usage: bridge fdb { add | append | del } LLADDR dev =
DEV { local | temp }\n"
+		        "              [ self ] [ embedded ] [ router ] [ dst IPADDR=
 ]\n"
+		        "              [ vni VNI ] [ port PORT ] [ via DEVICE ]\n");
+	fprintf(stderr, "       bridge fdb show [ br BRDEV ] [ brport DEV ]\n=
");
 	exit(-1);
 }
=20
diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index e7a79a5..c938a2f 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -2038,9 +2038,6 @@ table \verb|local| (ID 255).
 The \verb|local| table is a special routing table containing
 high priority control routes for local and broadcast addresses.
=20
-Rule 0 is special. It cannot be deleted or overridden.
-
-
 \item Priority: 32766, Selector: match anything, Action: lookup routin=
g
 table \verb|main| (ID 254).
 The \verb|main| table is the normal routing table containing all non-p=
olicy
diff --git a/ip/ip.c b/ip/ip.c
index da16b15..cba43ca 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -47,8 +47,8 @@ static void usage(void)
 	fprintf(stderr,
 "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "       ip [ -force ] -batch filename\n"
-"where  OBJECT :=3D { link | addr | addrlabel | route | rule | neigh |=
 ntable |\n"
-"                   tunnel | tuntap | maddr | mroute | mrule | monitor=
 | xfrm |\n"
+"where  OBJECT :=3D { link | address | addrlabel | route | rule | neig=
hbor | ntable |\n"
+"                   tunnel | tuntap | maddress | mroute | mrule | moni=
tor | xfrm |\n"
 "                   netns | l2tp | fou | tcp_metrics | token | netconf=
 }\n"
 "       OPTIONS :=3D { -V[ersion] | -s[tatistics] | -d[etails] | -r[es=
olve] |\n"
 "                    -h[uman-readable] | -iec |\n"
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 99a6ab5..dc31515 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -70,15 +70,15 @@ static void usage(void)
 	if (do_link) {
 		iplink_usage();
 	}
-	fprintf(stderr, "Usage: ip addr {add|change|replace} IFADDR dev STRIN=
G [ LIFETIME ]\n");
+	fprintf(stderr, "Usage: ip address {add|change|replace} IFADDR dev IF=
NAME [ LIFETIME ]\n");
 	fprintf(stderr, "                                                    =
  [ CONFFLAG-LIST ]\n");
-	fprintf(stderr, "       ip addr del IFADDR dev STRING [mngtmpaddr]\n"=
);
-	fprintf(stderr, "       ip addr {show|save|flush} [ dev STRING ] [ sc=
ope SCOPE-ID ]\n");
-	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIS=
T ] [ label PATTERN ] [up]\n");
-	fprintf(stderr, "       ip addr {showdump|restore}\n");
+	fprintf(stderr, "       ip address del IFADDR dev IFNAME [mngtmpaddr]=
\n");
+	fprintf(stderr, "       ip address {show|save|flush} [ dev IFNAME ] [=
 scope SCOPE-ID ]\n");
+	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIS=
T ] [ label LABEL ] [up]\n");
+	fprintf(stderr, "       ip address {showdump|restore}\n");
 	fprintf(stderr, "IFADDR :=3D PREFIX | ADDR peer PREFIX\n");
 	fprintf(stderr, "          [ broadcast ADDR ] [ anycast ADDR ]\n");
-	fprintf(stderr, "          [ label STRING ] [ scope SCOPE-ID ]\n");
+	fprintf(stderr, "          [ label IFNAME ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "SCOPE-ID :=3D [ host | link | global | NUMBER ]\n");
 	fprintf(stderr, "FLAG-LIST :=3D [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG  :=3D [ permanent | dynamic | secondary | prima=
ry |\n");
@@ -1059,7 +1059,7 @@ static int ipadd_dump_check_magic(void)
 	__u32 magic =3D 0;
=20
 	if (isatty(STDIN_FILENO)) {
-		fprintf(stderr, "Can't restore addr dump from a terminal\n");
+		fprintf(stderr, "Can't restore address dump from a terminal\n");
 		return -1;
 	}
=20
@@ -1787,6 +1787,6 @@ int do_ipaddr(int argc, char **argv)
 		return ipaddr_restore();
 	if (matches(*argv, "help") =3D=3D 0)
 		usage();
-	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addr help\".\n",=
 *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip address help\".\=
n", *argv);
 	exit(-1);
 }
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 4135d01..fd7e1d8 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -53,8 +53,8 @@ bridge \- show / manipulate bridge addresses and devi=
ces
 .I LLADDR
 .B  dev
 .IR DEV " { "
-.BR local " | " temp " } { "
-.BR self " } { " router " } [ "
+.BR local " | " temp " } [ "
+.BR self " ] [ " router " ] [ "
 .B  dst
 .IR IPADDR " ] [ "
 .B vni
@@ -65,7 +65,7 @@ bridge \- show / manipulate bridge addresses and devi=
ces
 .IR DEVICE " ]"
=20
 .ti -8
-.BR "bridge fdb" " [ " show " ] [ "
+.BR "bridge fdb show" " [ "
 .B  dev
 .IR DEV " ]"
=20
diff --git a/man/man8/cbq.8 b/man/man8/cbq.8
new file mode 100644
index 0000000..78940b6
--- /dev/null
+++ b/man/man8/cbq.8
@@ -0,0 +1 @@
+.so man8/tc-cbq.8
\ No newline at end of file
diff --git a/man/man8/ifcfg.8 b/man/man8/ifcfg.8
new file mode 100644
index 0000000..a6b585e
--- /dev/null
+++ b/man/man8/ifcfg.8
@@ -0,0 +1,57 @@
+.TH IFCFG 8 "September 24 2009" "iproute2" "Linux"
+.SH NAME
+ifcfg \- simplistic script which replaces ifconfig IP managment
+.SH SYNOPSIS
+.ad l
+.in +8
+.ti -8
+.B ifcfg
+.RI "[ " DEVICE " [ " :ALIAS: " ] ] [ " command " ] " ADDRESS " [ " LE=
NGTH " ] [ " PEER " ] "
+.sp
+
+.SH DESCRIPTION
+This manual page documents briefly the
+.B ifcfg
+command.
+.PP
+This is a simplistic script replacing one option of=20
+.B ifconfig
+, namely, IP address management. It not only adds
+addresses, but also carries out Duplicate Address Detection RFC-DHCP,
+sends unsolicited ARP to update the caches of other hosts sharing
+the interface, adds some control routes and restarts Router Discovery
+when it is necessary.
+
+I strongly recommend using it=20
+.RI instead
+of
+.RI ifconfig
+both on hosts and on routers.
+
+.SH IFCONFIG - COMMAND SYNTAX
+
+.SS
+.TP
+.B DEVICE
+- it may have alias, suffix, separated by colon.
+
+.TP
+.B command
+- add, delete or stop.
+
+.TP
+.B address
+- optionally followed by prefix length.
+
+.TP
+.B peer
+- optional peer address for pointpoint interfaces.
+
+.SH EXAMPLE
+.nf ifcfg eth0 193.233.7.90/24
+.fi
+This function determines, whether this is router or host.
+It returns 0, if the host is apparently not router.
+
+.SH SEE ALSO
+.BR ip-cref.dvi
diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 6e46af8..4da3095 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -14,18 +14,26 @@ ip-address \- protocol address management
 .sp
=20
 .ti -8
-.BR "ip address" " { " add " | " del " } "
-.IB IFADDR " dev " STRING
+.BR "ip address" " { " add " | " change " | " replace " } "
+.IB IFADDR " dev " IFNAME
+.RI "[ " LIFETIME " ] [ " CONFFLAG-LIST " ]"
=20
 .ti -8
-.BR "ip address" " { " show " | " flush " } [ " dev
-.IR STRING " ] [ "
+.BR "ip address del"
+.IB IFADDR " dev " IFNAME " [ " mngtmpaddr " ]"
+
+.ti -8
+.BR "ip address" " { " show " | " save " | " flush " } [ " dev
+.IR IFNAME " ] [ "
 .B  scope
 .IR SCOPE-ID " ] [ "
 .B  to
 .IR PREFIX " ] [ " FLAG-LIST " ] [ "
 .B  label
-.IR PATTERN " ]"
+.IR PATTERN " ] [ " up " ]"
+
+.ti -8
+.BR "ip address" " { " showdump " | " restore " }"
=20
 .ti -8
 .IR IFADDR " :=3D " PREFIX " | " ADDR
@@ -36,7 +44,7 @@ ip-address \- protocol address management
 .B  anycast
 .IR ADDR " ] [ "
 .B  label
-.IR STRING " ] [ "
+.IR LABEL " ] [ "
 .B  scope
 .IR SCOPE-ID " ]"
=20
@@ -50,17 +58,34 @@ ip-address \- protocol address management
=20
 .ti -8
 .IR FLAG " :=3D "
-.RB "[ " permanent " | " dynamic " | " secondary " | " primary " | \
-[ - ] " tentative " | [ - ] " deprecated " | [ - ] " dadfailed " | "\
-temporary " ]"
+.RB "[ " permanent " | " dynamic " | " secondary " | " primary " | "\
+tentative " | " deprecated " | " dadfailed " | " temporary " | " CONFF=
LAG-LIST " ]"
+
+.ti -8
+.IR CONFFLAG-LIST " :=3D [ "  CONFFLAG-LIST " ] " CONFFLAG
+
+.ti -8
+.IR CONFFLAG " :=3D "
+.RB "[ " home " | " nodad " ]"
+
+.ti -8
+.IR LIFETIME " :=3D [ "
+.BI valid_lft " LFT"
+.RB "| " preferred_lft
+.IR  LFT " ]"
+
+.ti -8
+.IR LFT " :=3D [ "
+.BR forever " |"
+.IR SECONDS " ]"
=20
 .SH "DESCRIPTION"
 The
 .B address
-is a protocol (IP or IPv6) address attached
-to a network device.  Each device must have at least one address
-to use the corresponding protocol.  It is possible to have several
-different addresses attached to one device.  These addresses are not
+is a protocol (IPv4 or IPv6) address attached
+to a network device. Each device must have at least one address
+to use the corresponding protocol. It is possible to have several
+different addresses attached to one device. These addresses are not
 discriminated, so that the term
 .B alias
 is not quite appropriate for them and we do not use it in this documen=
t.
@@ -73,7 +98,7 @@ and deletes old ones.
 .SS ip address add - add new protocol address.
=20
 .TP
-.BI dev " NAME"
+.BI dev " IFNAME "
 the name of the device to add the address to.
=20
 .TP
@@ -107,7 +132,7 @@ instead of the broadcast address. In this case, the=
 broadcast address
 is derived by setting/resetting the host bits of the interface prefix.
=20
 .TP
-.BI label " NAME"
+.BI label " LABEL"
 Each address may be tagged with a label string.
 In order to preserve compatibility with Linux-2.0 net aliases,
 this string must coincide with the name of the device or must be prefi=
xed
@@ -125,7 +150,7 @@ Predefined scope values are:
 - the address is globally valid.
 .sp
 .B site
-- (IPv6 only) the address is site local, i.e. it is
+- (IPv6 only, deprecated) the address is site local, i.e. it is
 valid inside this site.
 .sp
 .B link
@@ -135,6 +160,30 @@ valid inside this site.
 - the address is valid only inside this host.
 .in -8
=20
+.TP
+.BI valid_lft " LFT"
+the valid lifetime of this address; see section 5.5.4 of
+RFC 4862. When it expires, the address is removed by the kernel.
+Defaults to
+.BR "forever" .
+
+.TP
+.BI preferred_lft " LFT"
+the preferred lifetime of this address; see section 5.5.4
+of RFC 4862. When it expires, the address is no longer used for new
+outgoing connections. Defaults to
+.BR "forever" .
+
+.TP
+.B home
+(IPv6 only) designates this address the "home address" as defined in
+RFC 6275.
+
+.TP
+.B nodad
+(IPv6 only) do not perform Duplicate Address Detection (RFC 4862) when
+adding this address.
+
 .SS ip address delete - delete protocol address
 .B Arguments:
 coincide with the arguments of
@@ -145,7 +194,7 @@ If no arguments are given, the first address is del=
eted.
 .SS ip address show - look at protocol addresses
=20
 .TP
-.BI dev " NAME " (default)
+.BI dev " IFNAME " (default)
 name of device.
=20
 .TP
@@ -219,36 +268,53 @@ The difference is that it does not run when no ar=
guments are given.
=20
 .PP
 .B Warning:
-This command (and other
+This command and other
 .B flush
-commands described below) is pretty dangerous. If you make a mistake,
-it will not forgive it, but will cruelly purge all the addresses.
+commands are unforgiving. They will cruelly purge all the addresses.
=20
 .PP
 With the
 .B -statistics
 option, the command becomes verbose. It prints out the number of delet=
ed
-addresses and the number of rounds made to flush the address list. If
-this option is given twice,
+addresses and the number of rounds made to flush the address list.
+If this option is given twice,
 .B ip address flush
 also dumps all the deleted addresses in the format described in the
 previous subsection.
=20
 .SH "EXAMPLES"
 .PP
+ip address show
+.RS 4
+Shows IPv4 and IPv6 addresses assigned to all network interfaces. The =
'show'
+subcommand can be omitted.
+.RE
+.PP
+ip address show up
+.RS 4
+Same as above except that only addresses assigned to active network in=
terfaces
+are shown.
+.RE
+.PP
 ip address show dev eth0
 .RS 4
-Shows the addresses assigned to network interface eth0
+Shows IPv4 and IPv6 addresses assigned to network interface eth0.
+.RE
+.PP
+ip address add 2001:0db8:85a3::0370:7334/64 dev eth1
+.RS 4
+Adds an IPv6 address to network interface eth1.
 .RE
 .PP
-ip addr add 2001:0db8:85a3::0370:7334/64 dev eth1
+ip address delete 2001:0db8:85a3::0370:7334/64 dev eth1
 .RS 4
-Adds an IPv6 address to network interface eth1
+Delete the IPv6 address added above.
 .RE
 .PP
-ip addr flush dev eth4
+ip address flush dev eth4 scope global
 .RS 4
-Removes all addresses from device eth4
+Removes all global IPv4 and IPv6 addresses from device eth4. Without '=
scope
+global' it would remove all addresses including IPv6 link-local ones.
 .RE
=20
 .SH SEE ALSO
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 5ad372c..8ab50c1 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -255,6 +255,21 @@ specifies the number of receive queues for new dev=
ice.
 specifies the desired index of the new virtual device. The link creati=
on fails, if the index is busy.
=20
 .TP
+VLAN Type Support
+For a link of type
+.I VLAN
+the following additional arguments are supported:
+
+.BI "ip link add " DEVICE
+.BI type " vlan " id " ID
+.BI link " DEVICE
+
+.in +8
+.sp
+.BI  id " VNI "
+- specifies the VLAN Identifer to use. Note that numbers with a leadin=
g " 0 " or " 0x " are interpreted as octal or hexadeimal, respectively.
+
+.TP
 VXLAN Type Support
 For a link of type
 .I VXLAN
@@ -273,7 +288,9 @@ the following additional arguments are supported:
 .R " ] [ "
 .BI tos " TOS "
 .R " ] [ "
-.BI port " MIN MAX "
+.BI dstport " PORT "
+.R " ] [ "
+.BI srcport " MIN MAX "
 .R " ] [ "
 .I "[no]learning "
 .R " ] [ "
@@ -329,7 +346,11 @@ parameter.
 - specifies the TOS value to use in outgoing packets.
=20
 .sp
-.BI port " MIN MAX"
+.BI dstport " PORT"
+- specifies the UDP destination port to communicate to the remote VXLA=
N tunnel endpoint.
+
+.sp
+.BI srcport " MIN MAX"
 - specifies the range of port numbers to use as UDP
 source ports to communicate to the remote VXLAN tunnel endpoint.
=20
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index d53cc76..7e68c52 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -16,7 +16,7 @@ ip-route \- routing table management
=20
 .ti -8
 .BR "ip route" " { "
-.BR list " | " flush " } "
+.BR show " | " flush " } "
 .I  SELECTOR
=20
 .ti -8
diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index dd925be..0c45a6f 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -108,8 +108,6 @@ The
 .B local
 table is a special routing table containing
 high priority control routes for local and broadcast addresses.
-.sp
-Rule 0 is special. It cannot be deleted or overridden.
=20
 .TP
 2.
diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index c97c28c..1cc1105 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -50,7 +50,7 @@ ip-tunnel - tunnel configuration
=20
 .ti -8
 .IR MODE " :=3D "
-.RB " { " ipip " | " gre " | " sit " | " isatap " | " ip6ip6 " | " ipi=
p6 " | " ip6gre " | " any " }"
+.RB " { " ipip " | " gre " | " sit " | " isatap " | " vti " | " ip6ip6=
 " | " ipip6 " | " ip6gre " | " vti6 " | " any " }"
=20
 .ti -8
 .IR ADDR " :=3D { " IP_ADDRESS " |"
@@ -107,10 +107,10 @@ select the tunnel device name.
 set the tunnel mode. Available modes depend on the encapsulating addre=
ss family.
 .br
 Modes for IPv4 encapsulation available:
-.BR ipip ", " sit ", " isatap " and " gre "."
+.BR ipip ", " gre ", " sit ", " isatap " and " vti "."
 .br
 Modes for IPv6 encapsulation available:
-.BR ip6ip6 ", " ipip6 ", " ip6gre ", and " any "."
+.BR ip6ip6 ", " ipip6 ", " ip6gre " and " vti6 "
=20
 .TP
 .BI remote " ADDRESS"
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 4cd71de..24e257b 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -19,8 +19,8 @@ ip \- show / manipulate routing, devices, policy rout=
ing and tunnels
=20
 .ti -8
 .IR OBJECT " :=3D { "
-.BR link " | " addr " | " addrlabel " | " route " | " rule " | " neigh=
 " | "\
- ntable " | " tunnel " | " tuntap " | " maddr " | "  mroute " | " mrul=
e " | "\
+.BR link " | " address " | " addrlabel " | " route " | " rule " | " ne=
igh " | "\
+ ntable " | " tunnel " | " tuntap " | " maddress " | "  mroute " | " m=
rule " | "\
  monitor " | " xfrm " | " netns " | "  l2tp " | "  tcp_metrics " }"
 .sp
=20
@@ -66,7 +66,7 @@ Output more detailed information.
=20
 .TP
 .BR "\-l" , " \-loops " <COUNT>
-Specify maximum number of loops the 'ip addr flush' logic
+Specify maximum number of loops the 'ip address flush' logic
 will attempt before giving up. The default is 10.
 Zero (0) means loop until all addresses are removed.
=20
diff --git a/man/man8/ss.8 b/man/man8/ss.8
index b7fbaef..736d734 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -131,7 +131,7 @@ Read filter information from FILE.
 Each line of FILE is interpreted like single command line option. If F=
ILE is - stdin is used.
 .TP
 .B FILTER :=3D [ state STATE-FILTER ] [ EXPRESSION ]
-Please take a look at the official documentation (Debian package iprou=
te-doc) for details regarding filters.
+Please take a look at the official documentation (package iproute\-doc=
) for details regarding filters.
=20
 .SH STATE-FILTER
=20
@@ -186,7 +186,7 @@ Find all local processes connected to X server.
 List all the tcp sockets in state FIN-WAIT-1 for our apache to network=
 193.233.7/24 and look at their timers.
 .SH SEE ALSO
 .BR ip (8),
-.BR /usr/share/doc/iproute-doc/ss.html " (package iproute=ADdoc)",
+.BR /usr/share/doc/iproute-doc/ss.ps " (package iproute\-doc)",
 .br
 .BR RFC " 793 "
 - https://tools.ietf.org/rfc/rfc793.txt (TCP states)=20
--=20
2.3.5
