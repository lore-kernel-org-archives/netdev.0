From: "Eric S. Raymond" <esr@thyrsus.com>
Subject: First set of manpage markup fixes
Date: Fri, 21 Jun 2013 15:57:21 -0400
Message-ID: <20130621195721.GA10029@thyrsus.com>
Reply-To: esr@thyrsus.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:41128
	"EHLO snark.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945935Ab3FUT5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 15:57:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Enclosed patch fixes inappropriate uses of the .SS macro.  Fuller explanation
in the change comment.

There are other problems in these pages that block lifting to
XML-DocBook, most notably in the command synopses.  They will take
some creativity to fix.  I'm working on it
-- 
		<a href="http://www.catb.org/~esr/">Eric S. Raymond</a>

--dDRMvlgZJXvWKvBx
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-Abolish-presentation-level-misuse-of-the-.SS-macro.patch"

>From 75745adba4b45b87577b61a2daa886dd444f44da Mon Sep 17 00:00:00 2001
From: "Eric S. Raymond" <esr@thyrsus.com>
Date: Fri, 21 Jun 2013 15:27:38 -0400
Subject: [PATCH] Abolish presentation-level misuse of the .SS macro.

This change fixes most (but not all) fatal errors in attempts to lift
the iproute2 manual pages to XML-DocBook.  Where .SS is still used it
is a real subsection header, not just a way to outdent and bold text.
Presentation-level instances are turned into .TP calls and tables.
---
 man/man8/ip-maddress.8  | 11 ++++++---
 man/man8/ip-neighbour.8 | 49 +++++++++++++++++++++++-----------------
 man/man8/ip-netns.8     | 35 +++++++++++++++++------------
 man/man8/ip-route.8.in  | 56 +++++++++++++++++++++++++++++++++++-----------
 man/man8/ip-tunnel.8    | 26 ++++++++++++++++------
 man/man8/ip-xfrm.8      | 59 +++++++++++++++++++++----------------------------
 6 files changed, 145 insertions(+), 91 deletions(-)

diff --git a/man/man8/ip-maddress.8 b/man/man8/ip-maddress.8
index e0bad47..288d5cc 100644
--- a/man/man8/ip-maddress.8
+++ b/man/man8/ip-maddress.8
@@ -31,13 +31,17 @@ objects are multicast addresses.
 .BI dev " NAME " (default)
 the device name.
 
-.SS ip maddress add - add a multicast address
-.SS ip maddress delete - delete a multicast address
-these commands attach/detach a static link-layer multicast address
+.TP
+.B ip maddress add - add a multicast address
+.TP
+.B ip maddress delete - delete a multicast address
+.sp
+These commands attach/detach a static link-layer multicast address
 to listen on the interface.
 Note that it is impossible to join protocol multicast groups
 statically.  This command only manages link-layer addresses.
 
+.RS
 .TP
 .BI address " LLADDRESS " (default)
 the link-layer multicast address.
@@ -45,6 +49,7 @@ the link-layer multicast address.
 .TP
 .BI dev " NAME"
 the device to join/leave this multicast address.
+.RE
 
 .SH SEE ALSO
 .br
diff --git a/man/man8/ip-neighbour.8 b/man/man8/ip-neighbour.8
index 5d9768f..67fbec7 100644
--- a/man/man8/ip-neighbour.8
+++ b/man/man8/ip-neighbour.8
@@ -46,10 +46,17 @@ is also known by another name - the ARP table.
 The corresponding commands display neighbour bindings
 and their properties, add new neighbour entries and delete old ones.
 
-.SS ip neighbour add - add a new neighbour entry
-.SS ip neighbour change - change an existing entry
-.SS ip neighbour replace - add a new entry or change an existing one
+.TP
+ip neighbour add
+add a new neighbour entry
+.TP
+ip neighbour change
+change an existing entry
+.TP
+ip neighbour replace
+add a new entry or change an existing one
 
+.PP
 These commands create new neighbour records or update existing ones.
 
 .TP
@@ -74,31 +81,28 @@ the state of the neighbour entry.
 is an abbreviation for 'Neighbour Unreachability Detection'.
 The state can take one of the following values:
 
-.in +8
+.TP
 .B permanent
-- the neighbour entry is valid forever and can be only
+the neighbour entry is valid forever and can be only
 be removed administratively.
-.sp
-
+.TP
 .B noarp
-- the neighbour entry is valid. No attempts to validate
+the neighbour entry is valid. No attempts to validate
 this entry will be made but it can be removed when its lifetime expires.
-.sp
-
+.TP
 .B reachable
-- the neighbour entry is valid until the reachability
+the neighbour entry is valid until the reachability
 timeout expires.
-.sp
-
+.TP
 .B stale
-- the neighbour entry is valid but suspicious.
+the neighbour entry is valid but suspicious.
 This option to
 .B ip neigh
 does not change the neighbour state if it was valid and the address
 is not changed by this command.
-.in -8
-
-.SS ip neighbour delete - delete a neighbour entry
+.RS
+ip neighbour delete - delete a neighbour entry
+.RE
 This command invalidates a neighbour entry.
 
 .PP
@@ -120,9 +124,11 @@ on a
 .B NOARP
 interface or if the address is multicast or broadcast.
 
-.SS ip neighbour show - list neighbour entries
+.RS
+ip neighbour show - list neighbour entries
+.RE
 
-This commands displays neighbour tables.
+This command displays neighbour tables.
 
 .TP
 .BI to " ADDRESS " (default)
@@ -154,7 +160,10 @@ lists all entries except for
 and
 .BR "noarp" .
 
-.SS ip neighbour flush - flush neighbour entries
+.RS
+ip neighbour flush - flush neighbour entries
+.RE
+
 This command flushes neighbour tables, selecting
 entries to flush by some criteria.
 
diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index 87534be..6aa6e93 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -64,35 +64,41 @@ namespace unaware applications, by creating a mount namespace and
 bind mounting all of the per network namespace configure files into
 their traditional location in /etc.
 
-.SS ip netns list - show all of the named network namespaces
-
+.TP
+.B ip netns list - show all of the named network namespaces
+.sp
 This command displays all of the network namespaces in /var/run/netns
 
-.SS ip netns add NAME - create a new named network namespace
-
+.TP
+.B ip netns add NAME - create a new named network namespace
+.sp
 If NAME is available in /var/run/netns/ this command creates a new
 network namespace and assigns NAME.
 
-.SS ip netns delete NAME - delete the name of a network namespace
-
+.TP
+.B ip netns delete NAME - delete the name of a network namespace
+.sp
 If NAME is present in /var/run/netns it is umounted and the mount
 point is removed.  If this is the last user of the network namespace the
 network namespace will be freed, otherwise the network namespace
 persists until it has no more users.  ip netns delete may fail if
 the mount point is in use in another mount namespace.
 
-.SS ip netns identify PID - Report network namespaces names for process
-
+.TP
+.B ip netns identify PID - Report network namespaces names for process
+.sp
 This command walks through /var/run/netns and finds all the network
 namespace names for network namespace of the specified process.
 
-.SS ip netns pids NAME - Report processes in the named network namespace
-
+.TP
+.B ip netns pids NAME - Report processes in the named network namespace
+.sp
 This command walks through proc and finds all of the process who have
 the named network namespace as their primary network namespace.
 
-.SS ip netns exec NAME cmd ... - Run cmd in the named network namespace
-
+.TP
+.B ip netns exec NAME cmd ... - Run cmd in the named network namespace
+.sp
 This command allows applications that are network namespace unaware
 to be run in something other than the default network namespace with
 all of the configuration for the specified network namespace appearing
@@ -100,8 +106,9 @@ in the customary global locations.  A network namespace and bind mounts
 are used to move files from their network namespace specific location
 to their default locations without affecting other processes.
 
-.SS ip netns monitor - Report as network namespace names are added and deleted
-
+.TP
+.B ip netns monitor - Report as network namespace names are added and deleted
+.sp
 This command watches network namespace name addition and deletion events
 and prints a line for each event it sees.
 
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 2c35a97..654816f 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -246,10 +246,16 @@ The multiple routing tables enter the game when
 .I policy routing
 is used.
 
-.SS ip route add - add new route
-.SS ip route change - change route
-.SS ip route replace - change or add new one
-
+.TP
+ip route add
+add new route
+.TP
+ip route change
+change route
+.TP
+ip route replace
+change or add new one
+.RS
 .TP
 .BI to " TYPE PREFIX " (default)
 the destination prefix of the route.  If
@@ -502,9 +508,12 @@ to assign (or not to assign) protocol tags.
 .B onlink
 pretend that the nexthop is directly attached to this link,
 even if it does not match any interface prefix.
+.RE
 
-.SS ip route delete - delete route
-
+.TP
+ip route delete
+delete route
+.RS
 .B ip route del
 has the same arguments as
 .BR "ip route add" ,
@@ -518,8 +527,12 @@ verifies that they coincide with the attributes of the route to delete.
 If no route with the given key and attributes was found,
 .B ip route del
 fails.
+.RE
 
-.SS ip route show - list routes
+.TP
+ip route show
+list routes
+.RS
 the command displays the contents of the routing tables or the route(s)
 selected by some criteria.
 
@@ -628,8 +641,12 @@ by
 .TP
 .BI realms " FROMREALM/TOREALM"
 only list routes with these realms.
+.RE
 
-.SS ip route flush - flush routing tables
+.TP
+ip route flush
+flush routing tables
+.RS
 this command flushes routes selected by some criteria.
 
 .sp
@@ -652,8 +669,12 @@ twice,
 .B ip route flush
 also dumps all the deleted routes in the format described in the
 previous subsection.
+.RE
 
-.SS ip route get - get a single route
+.TP
+ip route get
+get a single route
+.RS
 this command gets a single route to a destination and prints its
 contents exactly as the kernel sees it.
 
@@ -707,21 +728,30 @@ however, no packets are actually sent.  With the
 .B iif
 argument, the kernel pretends that a packet arrived from this interface
 and searches for a path to forward the packet.
+.RE
 
-.SS ip route save - save routing table information to stdout
-this command behaves like
+.TP
+ip route save
+save routing table information to stdout
+.RS
+This command behaves like
 .BR "ip route show"
 except that the output is raw data suitable for passing to
 .BR "ip route restore" .
+.RE
 
-.SS ip route restore - restore routing table information from stdin
-this command expects to read a data stream as returned from
+.TP
+ip route restore
+restore routing table information from stdin
+.RS
+This command expects to read a data stream as returned from
 .BR "ip route save" .
 It will attempt to restore the routing table information exactly as
 it was at the time of the save, so any translation of information
 in the stream (such as device indexes) must be done first.  Any existing
 routes are left unchanged.  Any routes specified in the data stream that
 already exist in the table will be ignored.
+.RE
 
 .SH EXAMPLES
 .PP
diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index cb05a4b..697e80d 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -88,10 +88,16 @@ The encapsulating (or outer) address family is specified by the
 .B -f
 option.  The default is IPv4.
 
-.SS ip tunnel add - add a new tunnel
-.SS ip tunnel change - change an existing tunnel
-.SS ip tunnel delete - destroy a tunnel
-
+.TP
+.B ip tunnel add
+add a new tunnel
+.TP
+.B ip tunnel change
+change an existing tunnel
+.TP
+.B ip tunnel delete
+destroy a tunnel
+.RS
 .TP
 .BI name " NAME " (default)
 select the tunnel device name.
@@ -223,9 +229,12 @@ set a fixed encapsulation limit.  Default is 4.
 .BI flowlabel " FLOWLABEL"
 .RB ( " only IPv6 tunnels " )
 set a fixed flowlabel.
+.RE
 
-.SS ip tunnel prl - potential router list (ISATAP only)
-
+.TP
+.B ip tunnel prl
+potential router list (ISATAP only)
+.RS
 .TP
 .BI dev " NAME"
 mandatory device name.
@@ -238,8 +247,11 @@ mandatory device name.
 .BI prl-delete " ADDR"
 .RB "Add or delete " ADDR
 as a potential router or default router.
+.RE
 
-.SS ip tunnel show - list tunnels
+.TP
+.B ip tunnel show
+list tunnels
 This command has no arguments.
 
 .SH SEE ALSO
diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index 1d33eed..2d31b4d 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -369,23 +369,19 @@ object operating on the Security Association Database, and the
 object operating on the Security Policy Database). It is also used for
 the IP Payload Compression Protocol and features of Mobile IPv6.
 
-.SS ip xfrm state add - add new state into xfrm
-
-.SS ip xfrm state update - update existing state in xfrm
-
-.SS ip xfrm state allocspi - allocate an SPI value
-
-.SS ip xfrm state delete - delete existing state in xfrm
-
-.SS ip xfrm state get - get existing state in xfrm
-
-.SS ip xfrm state deleteall - delete all existing state in xfrm
-
-.SS ip xfrm state list - print out the list of existing state in xfrm
-
-.SS ip xfrm state flush - flush all state in xfrm
-
-.SS ip xfrm state count - count all existing state in xfrm
+.TS
+l l.
+ip xfrm state add	add new state into xfrm
+ip xfrm state update	update existing state in xfrm
+ip xfrm state allocspi	allocate an SPI value
+ip xfrm state delete	delete existing state in xfrm
+ip xfrm state get	get existing state in xfrm
+ip xfrm state deleteall	delete all existing state in xfrm
+ip xfrm state list	print out the list of existing state in xfrm
+ip xfrm state flush	flush all state in xfrm
+ip xfrm state count	count all existing state in xfrm
+ip xfrm monitor 	state monitoring for xfrm objects
+.TE
 
 .TP
 .IR ID
@@ -506,22 +502,18 @@ encapsulates packets with protocol
 .BR espinudp " or " espinudp-nonike ","
 .RI "using source port " SPORT ", destination port "  DPORT
 .RI ", and original address " OADDR "."
-
-.SS ip xfrm policy add - add a new policy
-
-.SS ip xfrm policy update - update an existing policy
-
-.SS ip xfrm policy delete - delete an existing policy
-
-.SS ip xfrm policy get - get an existing policy
-
-.SS ip xfrm policy deleteall - delete all existing xfrm policies
-
-.SS ip xfrm policy list - print out the list of xfrm policies
-
-.SS ip xfrm policy flush - flush policies
-
-.SS ip xfrm policy count - count existing policies
+.sp
+.TS
+l l.
+ip xfrm policy add	add a new policy
+ip xfrm policy update	update an existing policy
+ip xfrm policy delete	delete an existing policy
+ip xfrm policy get	get an existing policy
+ip xfrm policy deleteall	delete all existing xfrm policies
+ip xfrm policy list	print out the list of xfrm policies
+ip xfrm policy flush	flush policies
+ip xfrm policy count	count existing policies
+.TE
 
 .TP
 .IR SELECTOR
@@ -615,7 +607,6 @@ and inbound trigger
 can be
 .BR required " (default) or " use "."
 
-.SS ip xfrm monitor - state monitoring for xfrm objects
 The xfrm objects to monitor can be optionally specified.
 
 .SH AUTHOR
-- 
1.8.0.1.g2b06c9a


--dDRMvlgZJXvWKvBx--
