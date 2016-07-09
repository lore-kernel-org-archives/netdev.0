From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip-address.8: Document autojoin flag
Date: Sat,  9 Jul 2016 12:14:22 +0200
Message-ID: <1468059262-14591-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43214 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224AbcGIKOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 06:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Description copied from related kernel support commit message with a
little tailoring to fit.

While at it, fix font of non-terminal CONFFLAG-LIST in synopsis.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-address.8.in | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 7cb9271731339..ab59d270321d9 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -77,14 +77,15 @@ ip-address \- protocol address management
 .IR FLAG " := "
 .RB "[ " permanent " | " dynamic " | " secondary " | " primary " |"
 .RB [ - ] tentative " | [" - ] deprecated " | [" - ] dadfailed " |"
-.BR temporary " | " CONFFLAG-LIST " ]"
+.BR temporary " |"
+.IR CONFFLAG-LIST " ]"
 
 .ti -8
 .IR CONFFLAG-LIST " := [ "  CONFFLAG-LIST " ] " CONFFLAG
 
 .ti -8
 .IR CONFFLAG " := "
-.RB "[ " home " | " mngtmpaddr " | " nodad " | " noprefixroute " ]"
+.RB "[ " home " | " mngtmpaddr " | " nodad " | " noprefixroute " | " autojoin " ]"
 
 .ti -8
 .IR LIFETIME " := [ "
@@ -249,6 +250,22 @@ address, and don't search for one to delete when removing the address. Changing
 an address to add this flag will remove the automatically added prefix route,
 changing it to remove this flag will create the prefix route automatically.
 
+.TP
+.B autojoin
+Joining multicast group on ethernet level via "ip maddr" command would not work
+if we have an Ethernet switch that does igmp snooping since the switch would
+not replicate multicast packets on ports that did not have IGMP reports for the
+multicast addresses.
+
+Linux vxlan interfaces created via "ip link add vxlan" have the group option
+that enables then to do the required join.
+
+Using the
+.B autojoin
+flag when adding a multicast address enables similar functionality for
+openvswitch vxlan interfaces as well as other tunneling mechanisms that need to
+receive multicast traffic.
+
 .SS ip address delete - delete protocol address
 .B Arguments:
 coincide with the arguments of
-- 
2.8.2
