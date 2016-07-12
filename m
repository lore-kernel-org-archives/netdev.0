From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2] ip-address.8: Document autojoin flag
Date: Tue, 12 Jul 2016 09:56:16 +0200
Message-ID: <1468310176-27306-1-git-send-email-phil@nwl.cc>
References: <1468059262-14591-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50001 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbcGLH4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 03:56:30 -0400
In-Reply-To: <1468059262-14591-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Description copied from related kernel support commit message with a
little tailoring to fit.

While at it, fix font of non-terminal CONFFLAG-LIST in synopsis.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Set commands/flags in bold font instead of quotes.
- Make capitalization consistent for 'Ethernet' and 'IGMP'.
- Set 'VXLAN' and 'Openvswitch' in upper case.
- Fix typo: then -> them.
- Misc grammar and language fixup.
---
 man/man8/ip-address.8.in | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 7cb9271731339..7d6eb9b2b1915 100644
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
@@ -249,6 +250,26 @@ address, and don't search for one to delete when removing the address. Changing
 an address to add this flag will remove the automatically added prefix route,
 changing it to remove this flag will create the prefix route automatically.
 
+.TP
+.B autojoin
+Joining multicast groups on Ethernet level via
+.B "ip maddr"
+command does not work if connected to an Ethernet switch that does IGMP
+snooping since the switch would not replicate multicast packets on ports that
+did not have IGMP reports for the multicast addresses.
+
+Linux VXLAN interfaces created via
+.B "ip link add vxlan"
+have the
+.B group
+option that enables them to do the required join.
+
+Using the
+.B autojoin
+flag when adding a multicast address enables similar functionality for
+Openvswitch VXLAN interfaces as well as other tunneling mechanisms that need to
+receive multicast traffic.
+
 .SS ip address delete - delete protocol address
 .B Arguments:
 coincide with the arguments of
-- 
2.8.2
