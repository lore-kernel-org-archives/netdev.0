From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/3] man: ip-link: document MACVLAN/MACVTAP interface types
Date: Fri, 25 Sep 2015 14:09:51 +0200
Message-ID: <1443182991-4628-4-git-send-email-phil@nwl.cc>
References: <1443182991-4628-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:58187 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755833AbbIYMJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 08:09:53 -0400
In-Reply-To: <1443182991-4628-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 4928249..ac6f481 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -768,6 +768,56 @@ the following additional arguments are supported:
 
 .in -8
 
+.TP
+MACVLAN and MACVTAP Type Support
+For a link of type
+.I MACVLAN
+or
+.I MACVTAP
+the following additional arguments are supported:
+
+.BI "ip link add link " DEVICE " name " NAME
+.BR type " { " macvlan " | " macvtap " } "
+.BR mode " { " private " | " vepa " | " bridge " | " passthru
+.BR " [ " nopromisc " ] } "
+
+.in +8
+.sp
+.BR type " { " macvlan " | " macvtap " } "
+- specifies the link type to use.
+.BR macvlan " creates just a virtual interface, while "
+.BR macvtap " in addition creates a character device "
+.BR /dev/tapX " to be used just like a " tuntap " device."
+
+.B mode private
+- Do not allow communication between
+.B macvlan
+instances on the same physical interface, even if the external switch supports
+hairpin mode.
+
+.B mode vepa
+- Virtual Ethernet Port Aggregator mode. Data from one
+.B macvlan
+instance to the other on the same physical interface is transmitted over the
+physical interface. Either the attached switch needs to support hairpin mode,
+or there must be a TCP/IP router forwarding the packets in order to allow
+communication. This is the default mode.
+
+.B mode bridge
+- In bridge mode, all endpoints are directly connected to each other,
+communication is not redirected through the physical interface's peer.
+
+.BR mode " " passthru " [ " nopromisc " ] "
+- This mode gives more power to a single endpoint, usually in
+.BR macvtap " mode. It is not allowed for more than one endpoint on the same "
+physical interface. All traffic will be forwarded to this endpoint, allowing
+virtio guests to change MAC address or set promiscuous mode in order to bridge
+the interface or create vlan interfaces on top of it. By default, this mode
+forces the underlying interface into promiscuous mode. Passing the
+.BR nopromisc " flag prevents this, so the promisc flag may be controlled "
+using standard tools.
+.in -8
+
 .SS ip link delete - delete virtual link
 
 .TP
-- 
2.1.2
