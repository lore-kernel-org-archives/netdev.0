From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH iproute2 3/3] ip-address: fix and extend documentation
Date: Wed, 12 Aug 2015 22:04:08 +0200
Message-ID: <1439409848-26464-3-git-send-email-pavlix@pavlix.net>
References: <1439409848-26464-1-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Vadim Kochan <vadim4j@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Phil Sutter <psutter@redhat.com>,
	=?UTF-8?q?Pavel=20=C5=A0imerda?= <psimerda@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:46382 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034AbbHLUIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2015 16:08:49 -0400
In-Reply-To: <1439409848-26464-1-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

 * Improve manual page synopsis and built-it help
 * Use full subcommand names (e.g. 'address' and 'maddress')
 * Specify when IPv4, IPv6 or both are affected
 * Add lifetimes, home and nodad
 * Remove any remaining excess spaces

Commit 43d29f7 substantially improves generated ip-address.8 instead of
ip-address.8.in and commit e419f2d removes the generated one losing the
improvements entirely. This commit recovers the lost changes, adapts
them to the current manual page and adds more man page and help
improvements.

Original commit by: Kenyon Ralph <kenyon@kenyonralph.com>
---
 ip/ipaddress.c           |  16 +++----
 man/man8/ip-address.8.in | 117 +++++++++++++++++++++++++++++++++++++--=
--------
 2 files changed, 100 insertions(+), 33 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b7b4e3e..177b65a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -71,15 +71,15 @@ static void usage(void)
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
@@ -1126,7 +1126,7 @@ static int ipadd_dump_check_magic(void)
 	__u32 magic =3D 0;
=20
 	if (isatty(STDIN_FILENO)) {
-		fprintf(stderr, "Can't restore addr dump from a terminal\n");
+		fprintf(stderr, "Can't restore address dump from a terminal\n");
 		return -1;
 	}
=20
@@ -1878,6 +1878,6 @@ int do_ipaddr(int argc, char **argv)
 		return ipaddr_restore();
 	if (matches(*argv, "help") =3D=3D 0)
 		usage();
-	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addr help\".\n",=
 *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip address help\".\=
n", *argv);
 	exit(-1);
 }
diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 6e46af8..2ea3e67 100644
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
@@ -52,15 +60,33 @@ ip-address \- protocol address management
 .IR FLAG " :=3D "
 .RB "[ " permanent " | " dynamic " | " secondary " | " primary " | \
 [ - ] " tentative " | [ - ] " deprecated " | [ - ] " dadfailed " | "\
-temporary " ]"
+temporary " ] " CONFFLAG-LIST " ]"
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
@@ -73,7 +99,7 @@ and deletes old ones.
 .SS ip address add - add new protocol address.
=20
 .TP
-.BI dev " NAME"
+.BI dev " IFNAME "
 the name of the device to add the address to.
=20
 .TP
@@ -107,7 +133,7 @@ instead of the broadcast address. In this case, the=
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
@@ -125,7 +151,7 @@ Predefined scope values are:
 - the address is globally valid.
 .sp
 .B site
-- (IPv6 only) the address is site local, i.e. it is
+- (IPv6 only, deprecated) the address is site local, i.e. it is
 valid inside this site.
 .sp
 .B link
@@ -135,6 +161,30 @@ valid inside this site.
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
@@ -145,7 +195,7 @@ If no arguments are given, the first address is del=
eted.
 .SS ip address show - look at protocol addresses
=20
 .TP
-.BI dev " NAME " (default)
+.BI dev " IFNAME " (default)
 name of device.
=20
 .TP
@@ -219,36 +269,53 @@ The difference is that it does not run when no ar=
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
--=20
2.4.1
