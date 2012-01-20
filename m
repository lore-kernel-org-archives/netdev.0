From: nick black <dankamongmen@gmail.com>
Subject: Re: Bug#656585: iproute: "ip l" fails with RTNETLINK message
Date: Fri, 20 Jan 2012 11:52:19 -0500
Message-ID: <20120120165219.GA21936@qemfd.net>
References: <20120120101233.17696.79723.reportbug@localhost>
 <20120120131047.GA7179@amd64.fatal.se>
 <20120120143922.GA20128@qemfd.net>
 <20120120145054.GA8443@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:57298 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab2ATQwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 11:52:22 -0500
Received: by ghbg18 with SMTP id g18so344730ghb.19
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2012 08:52:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20120120145054.GA8443@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Andreas Henriksson left as an exercise for the reader:
> Hello again!
> 
> On Fri, Jan 20, 2012 at 09:39:22AM -0500, nick black wrote:
> > I can put together a manpage patch if you'd like, but I suspect you'd rather
> > I leave it in your capable hands.
> 
> I'd very much appreciate if you'd create a patch and submit it upstream
> (Stephen Hemminger <shemminger@vyatta.com> and the netdev mailing list)
> There are many other issues with the man pages and help output that
> you are more then willing to help dig into if you have time.
> Please see http://bugs.debian.org/src:iproute for hints on where
> documentation updates are needed.

Alrightie, I did just that.

I'm in no position to write a full ip-l2tp(8) man page. I have, however:

 * synced SYNOPSIS up with current "ip help" entries
 * made SYNOPSIS conform to "ip help"'s ordering
 * synced SYNTAX up with SYNOPSIS, pulling definitions for netns and
    ntable out from beyond the realms of my ass. please verify.
 * alphabetized the SYNTAX entries
 * synced SEE ALSO up with current "dpkg -L iproute | grep 8/ip-"

Attached and inline.

diff -ur /home/dank/iproute-20120105/man/man8/ip.8 /home/dank/src/iproute-20120105/man/man8/ip.8
--- /home/dank/iproute-20120105/man/man8/ip.8	2012-01-05 11:34:31.000000000 -0500
+++ /home/dank/src/iproute-20120105/man/man8/ip.8	2012-01-20 11:47:12.751632078 -0500
@@ -14,7 +14,8 @@
 .ti -8
 .IR OBJECT " := { "
 .BR link " | " addr " | " addrlabel " | " route " | " rule " | " neigh " | "\
- tunnel " | " maddr " | "  mroute " }"
+ ntable " | " tunnel " | " tuntap " | " maddr " | "  mroute " | " mrule " | "\
+ monitor " | " xfrm " | " netns " | "  l2tp " }"
 .sp
 
 .ti -8
@@ -103,10 +104,6 @@
 .I OBJECT
 
 .TP
-.B link
-- network device.
-
-.TP
 .B address
 - protocol (IP or IPv6) address on a device.
 
@@ -115,8 +112,40 @@
 - label configuration for protocol address selection.
 
 .TP
+.B l2tp
+- tunnel PPP over IP (L2TP).
+
+.TP
+.B link
+- network device.
+
+.TP
+.B maddress
+- multicast address.
+
+.TP
+.B monitor
+- watch for netlink messages.
+
+.TP
+.B mroute
+- multicast routing cache entry.
+
+.TP
+.B mrule
+- rule in multicast routing policy database.
+
+.TP
 .B neighbour
-- ARP or NDISC cache entry.
+- manage ARP or NDISC cache entries.
+
+.TP
+.B netns
+- manage network namespaces.
+
+.TP
+.B ntable
+- manage the neighbor cache's operation.
 
 .TP
 .B route
@@ -127,16 +156,16 @@
 - rule in routing policy database.
 
 .TP
-.B maddress
-- multicast address.
+.B tunnel
+- tunnel over IP.
 
 .TP
-.B mroute
-- multicast routing cache entry.
+.B tuntap
+- manage TUN/TAP devices.
 
 .TP
-.B tunnel
-- tunnel over IP.
+.B xfrm
+- manage IPSec policies.
 
 .PP
 The names of all objects may be written in full or
@@ -181,6 +210,7 @@
 .BR ip-monitor (8),
 .BR ip-mroute (8),
 .BR ip-neighbour (8),
+.BR ip-netns (8),
 .BR ip-ntable (8),
 .BR ip-route (8),
 .BR ip-rule (8),

-- 
                                 nick black <nickblack@linux.com>
                   "if you want to make an apple pie from scratch,
                             you need to first invent a universe."

--vtzGhvizbBRQ85DL
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="iproute-20120105.manpage-less-shitty.diff"

diff -ur /home/dank/iproute-20120105/man/man8/ip.8 /home/dank/src/iproute-20120105/man/man8/ip.8
--- /home/dank/iproute-20120105/man/man8/ip.8	2012-01-05 11:34:31.000000000 -0500
+++ /home/dank/src/iproute-20120105/man/man8/ip.8	2012-01-20 11:47:12.751632078 -0500
@@ -14,7 +14,8 @@
 .ti -8
 .IR OBJECT " := { "
 .BR link " | " addr " | " addrlabel " | " route " | " rule " | " neigh " | "\
- tunnel " | " maddr " | "  mroute " }"
+ ntable " | " tunnel " | " tuntap " | " maddr " | "  mroute " | " mrule " | "\
+ monitor " | " xfrm " | " netns " | "  l2tp " }"
 .sp
 
 .ti -8
@@ -103,10 +104,6 @@
 .I OBJECT
 
 .TP
-.B link
-- network device.
-
-.TP
 .B address
 - protocol (IP or IPv6) address on a device.
 
@@ -115,8 +112,40 @@
 - label configuration for protocol address selection.
 
 .TP
+.B l2tp
+- tunnel PPP over IP (L2TP).
+
+.TP
+.B link
+- network device.
+
+.TP
+.B maddress
+- multicast address.
+
+.TP
+.B monitor
+- watch for netlink messages.
+
+.TP
+.B mroute
+- multicast routing cache entry.
+
+.TP
+.B mrule
+- rule in multicast routing policy database.
+
+.TP
 .B neighbour
-- ARP or NDISC cache entry.
+- manage ARP or NDISC cache entries.
+
+.TP
+.B netns
+- manage network namespaces.
+
+.TP
+.B ntable
+- manage the neighbor cache's operation.
 
 .TP
 .B route
@@ -127,16 +156,16 @@
 - rule in routing policy database.
 
 .TP
-.B maddress
-- multicast address.
+.B tunnel
+- tunnel over IP.
 
 .TP
-.B mroute
-- multicast routing cache entry.
+.B tuntap
+- manage TUN/TAP devices.
 
 .TP
-.B tunnel
-- tunnel over IP.
+.B xfrm
+- manage IPSec policies.
 
 .PP
 The names of all objects may be written in full or
@@ -181,6 +210,7 @@
 .BR ip-monitor (8),
 .BR ip-mroute (8),
 .BR ip-neighbour (8),
+.BR ip-netns (8),
 .BR ip-ntable (8),
 .BR ip-route (8),
 .BR ip-rule (8),

--vtzGhvizbBRQ85DL--
