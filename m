From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 5/6] ip-link.8: Add slave type option descriptions
Date: Sat,  9 Jul 2016 11:22:49 +0200
Message-ID: <1468056170-6056-6-git-send-email-phil@nwl.cc>
References: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37981 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933107AbcGIJXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 05:23:16 -0400
In-Reply-To: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 129 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 129 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 2678d37df7478..ada20fe210793 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1247,6 +1247,135 @@ set the IPv6 address generation mode
 .BR "link-netnsid "
 set peer netnsid for a cross-netns interface
 
+.TP
+.BI type " ETYPE TYPE_ARGS"
+Change type-specific settings. For a list of supported types and arguments refer
+to the description of
+.B "ip link add"
+above. In addition to that, it is possible to manipulate settings to slave
+devices:
+
+.TP
+Bridge Slave Support
+For a link with master
+.B bridge
+the following additional arguments are supported:
+
+.B "ip link set type bridge_slave"
+[
+.BI state " STATE"
+] [
+.BI priority " PRIO"
+] [
+.BI cost " COST"
+] [
+.BR guard " { " on " | " off " }"
+] [
+.BR hairpin " { " on " | " off " }"
+] [
+.BR fastleave " { " on " | " off " }"
+] [
+.BR root_block " { " on " | " off " }"
+] [
+.BR learning " { " on " | " off " }"
+] [
+.BR flood " { " on " | " off " }"
+] [
+.BR proxy_arp " { " on " | " off " }"
+] [
+.BR proxy_arp_wifi " { " on " | " off " }"
+] [
+.BI mcast_router " MULTICAST_ROUTER"
+] [
+.BR mcast_fast_leave " { " on " | " off "} ]"
+
+.in +8
+.sp
+.BI state " STATE"
+- Set port state.
+.I STATE
+is a number representing the following states:
+.BR 0 " (disabled),"
+.BR 1 " (listening),"
+.BR 2 " (learning),"
+.BR 3 " (forwarding),"
+.BR 4 " (blocking)."
+
+.BI priority " PRIO"
+- set port priority (a 16bit unsigned value).
+
+.BI cost " COST"
+- set port cost (a 32bit unsigned value).
+
+.BR guard " { " on " | " off " }"
+- block incoming BPDU packets on this port.
+
+.BR hairpin " { " on " | " off " }"
+- enable hairpin mode on this port. This will allow incoming packets on this
+port to be reflected back.
+
+.BR fastleave " { " on " | " off " }"
+- enable multicast fast leave on this port.
+
+.BR root_block " { " on " | " off " }"
+- block this port from becoming the bridge's root port.
+
+.BR learning " { " on " | " off " }"
+- allow MAC address learning on this port.
+
+.BR flood " { " on " | " off " }"
+- open the flood gates on this port, i.e. forward all unicast frames to this
+port also. Requires
+.BR proxy_arp " and " proxy_arp_wifi
+to be turned off.
+
+.BR proxy_arp " { " on " | " off " }"
+- enable proxy ARP on this port.
+
+.BR proxy_arp_wifi " { " on " | " off " }"
+- enable proxy ARP on this port which meets extended requirements by IEEE
+802.11 and Hotspot 2.0 specifications.
+
+.BI mcast_router " MULTICAST_ROUTER"
+- configure this port for having multicast routers attached. A port with a
+multicast router will receive all multicast traffic.
+.I MULTICAST_ROUTER
+may be either
+.B 0
+to disable multicast routers on this port,
+.B 1
+to let the system detect the presence of of routers (this is the default),
+.B 2
+to permanently enable multicast traffic forwarding on this port or
+.B 3
+to enable multicast routers temporarily on this port, not depending on incoming
+queries.
+
+.BR mcast_fast_leave " { " on " | " off " }"
+- this is a synonym to the
+.B fastleave
+option above.
+
+.in -8
+
+.TP
+Bonding Slave Support
+For a link with master
+.B bond
+the following additional arguments are supported:
+
+.B "ip link set type bond_slave"
+[
+.BI queue_id " ID"
+]
+
+.in +8
+.sp
+.BI queue_id " ID"
+- set the slave's queue ID (a 16bit unsigned value).
+
+.in -8
+
 .SS  ip link show - display device attributes
 
 .TP
-- 
2.8.2
