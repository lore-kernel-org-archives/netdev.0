From: Phil Sutter <phil@nwl.cc>
Subject: [iproute RFC PATCH 6/9] tc: add a man page for route filter
Date: Fri, 23 Oct 2015 19:47:13 +0200
Message-ID: <1445622436-6386-7-git-send-email-phil@nwl.cc>
References: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:34591 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932297AbbJWRrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 13:47:21 -0400
In-Reply-To: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-route.8 | 74 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 74 insertions(+)
 create mode 100644 man/man8/tc-route.8

diff --git a/man/man8/tc-route.8 b/man/man8/tc-route.8
new file mode 100644
index 0000000..b865cd1
--- /dev/null
+++ b/man/man8/tc-route.8
@@ -0,0 +1,74 @@
+.TH "Route classifier in tc" 8 "21 Oct 2015" "iproute2" "Linux"
+
+.SH NAME
+route \- route traffic control filter
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " " filter " ... " route " [ " from
+.IR REALM " | "
+.B fromif
+.IR TAG " ] [ "
+.B to
+.IR REALM " ] [ "
+.B classid
+.IR CLASSID " ] [ "
+.B action
+.IR ACTION_SPEC " ]"
+.SH DESCRIPTION
+Match packets based on routing table entries. This filter centers around the
+possibility to assign a
+.B realm
+to routing table entries. For any packet to be classified by this filter, a
+routing table lookup is performed and the returned
+.B realm
+is used to decide on whether the packet is a match or not.
+.SH OPTIONS
+.TP
+.BI action " ACTION_SPEC"
+Apply an action from the generic actions framework on matching packets.
+.TP
+.BI classid " CLASSID"
+Push matching packets into the class identified by
+.IR CLASSID .
+.TP
+.BI from " REALM"
+.TQ
+.BI fromif " TAG"
+Perform source route lookups.
+.I TAG
+is the name of an interface which must be present on the system at the time of
+.B tc
+invocation.
+.TP
+.BI to " REALM"
+Match if normal (i.e., destination) routing returns the given
+.IR REALM .
+.SH EXAMPLES
+Consider the subnet 192.168.2.0/24 being attached to eth0:
+
+.RS
+.EX
+ip route add 192.168.2.0/24 dev eth0 realm 2
+.EE
+.RE
+
+The following
+.B route
+filter will then match packets from that subnet:
+
+.RS
+.EX
+tc filter add ... route from 2 classid 1:2
+.EE
+.RE
+
+and pass packets on to class 1:2.
+.SH NOTES
+Due to implementation details,
+.B realm
+values must be in a range from 0 to 255, inclusive. Alternatively, a verbose
+name defined in /etc/iproute2/rt_realms may be given instead.
+.SH SEE ALSO
+.BR tc (8),
+.BR ip-route (8)
-- 
2.1.2
