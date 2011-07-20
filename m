From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: Remove "monitor" from "ip route help" output
Date: Wed, 20 Jul 2011 17:08:14 +0200
Message-ID: <20110720150814.GA12025@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, martin f krafft <madduck@debian.org>,
	537681@bugs.debian.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b21.telenor.se ([195.54.99.212]:34946 "EHLO
	smtprelay-b21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab1GTPHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:07:45 -0400
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-b21.telenor.se (Postfix) with ESMTP id 78F55EAEF3
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 17:07:43 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

$ ip route help 2>&1 | grep monitor
ip route { add | del | change | append | replace | monitor } ROUTE
$ ip route monitor
Command "monitor" is unknown, try "ip route help".

(I guess what was really intended is "ip monitor route", so just remove
the argument from the help output.)

Originally reported by martin f krafft at http://bugs.debian.org/537681

While at it, also drop all non-existant (route,link,netns) monitor
arguments from the ip(8) man page.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff --git a/ip/iproute.c b/ip/iproute.c
index ca09029..21e1a4b 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -63,7 +63,7 @@ static void usage(void)
 	fprintf(stderr, "       ip route get ADDRESS [ from ADDRESS iif STRING ]\n");
 	fprintf(stderr, "                            [ oif STRING ]  [ tos TOS ]\n");
 	fprintf(stderr, "                            [ mark NUMBER ]\n");
-	fprintf(stderr, "       ip route { add | del | change | append | replace | monitor } ROUTE\n");
+	fprintf(stderr, "       ip route { add | del | change | append | replace } ROUTE\n");
 	fprintf(stderr, "SELECTOR := [ root PREFIX ] [ match PREFIX ] [ exact PREFIX ]\n");
 	fprintf(stderr, "            [ table TABLE_ID ] [ proto RTPROTO ]\n");
 	fprintf(stderr, "            [ type TYPE ] [ scope SCOPE ]\n");
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 8d2ab87..26cb17f 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -14,7 +14,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .ti -8
 .IR OBJECT " := { "
 .BR link " | " addr " | " addrlabel " | " route " | " rule " | " neigh " | "\
- tunnel " | " maddr " | "  mroute " | " monitor " }"
+ tunnel " | " maddr " | "  mroute " }"
 .sp
 
 .ti -8
@@ -165,7 +165,7 @@ tentative " | " deprecated " | " dadfailed " | " temporary " ]"
 .BR "ip addrlabel" " { " list " | " flush " }"
 
 .ti -8
-.BR "ip netns" " { " list " | " monitor " } "
+.BR "ip netns" " { " list " } "
 
 .ti -8
 .BR "ip netns" " { " add " | " delete " } "
@@ -198,7 +198,7 @@ tentative " | " deprecated " | " dadfailed " | " temporary " ]"
 
 .ti -8
 .BR "ip route" " { " add " | " del " | " change " | " append " | "\
-replace " | " monitor " } "
+replace " } "
 .I  ROUTE
 
 .ti -8
@@ -2547,7 +2547,6 @@ bind mounting all of the per network namespace configure files into
 their traditional location in /etc.
 
 .SS ip netns list - show all of the named network namespaces
-.SS ip netns monitor - report when network namespace names are created and destroyed
 .SS ip netns add NAME - create a new named network namespace
 .SS ip netns delete NAME - delete the name of a network namespace
 .SS ip netns exec NAME cmd ... - Run cmd in the named network namespace
