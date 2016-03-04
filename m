From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 03/12] man: Add a man page for the mirred action
Date: Fri,  4 Mar 2016 13:11:38 +0100
Message-ID: <1457093507-25601-4-git-send-email-phil@nwl.cc>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52911 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753441AbcCDMMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 07:12:24 -0500
Received: from mail.nwl.cc (orbyte.nwl.cc [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id 5808E6AF5C
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:17 +0100 (CET)
Received: from xsao (localhost [IPv6:::1])
	by mail.nwl.cc (Postfix) with ESMTP id 3E8C06894E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:17 +0100 (CET)
In-Reply-To: <1457093507-25601-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-mirred.8 | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 89 insertions(+)
 create mode 100644 man/man8/tc-mirred.8

diff --git a/man/man8/tc-mirred.8 b/man/man8/tc-mirred.8
new file mode 100644
index 0000000000000..52d98bc416563
--- /dev/null
+++ b/man/man8/tc-mirred.8
@@ -0,0 +1,89 @@
+.TH "Mirror/redirect action in tc" 8 "11 Jan 2015" "iproute2" "Linux"
+
+.SH NAME
+mirred - mirror/redirect action
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " "action mirred"
+.I DIRECTION ACTION
+.RB "[ " index
+.IR INDEX " ] "
+.BI dev " DEVICENAME"
+
+.ti -8
+.IR DIRECTION " := { "
+.BR ingress " | " egress " }"
+
+.ti -8
+.IR ACTION " := { "
+.BR mirror " | " redirect " }"
+.SH DESCRIPTION
+The
+.B mirred
+action allows to redirect or mirror packets to another network interface on the
+same system. It is typically used in combination with the
+.B ifb
+pseudo device to create a shrared instance where QoS happens, but serves well
+for debugging or monitoring purposes, too.
+.SH OPTIONS
+.TP
+.B ingress
+.TQ
+.B egress
+Specify the direction in which the packet shall appear on the destination
+interface. Currently only
+.B egress
+is implemented.
+.TP
+.B mirror
+.TQ
+.B redirect
+Define whether the packet should be copied
+.RB ( mirror )
+or moved
+.RB ( redirect )
+to the destination interface.
+.TP
+.BI index " INDEX"
+Assign a unique ID to this action instead of letting the kernel choose one
+automatically.
+.I INDEX
+is a 32bit unsigned integer greater than zero.
+.TP
+.BI dev " DEVICENAME"
+Specify the network interface to redirect or mirror to.
+.SH EXAMPLES
+Limit ingress bandwidth on eth0 to 1mbit/s, redirect exceeding traffic to lo for
+debugging purposes:
+
+.RS
+.EX
+# tc qdisc add dev eth0 handle ffff: ingress
+# tc filter add dev eth0 parent ffff: u32 \\
+	match u32 0 0 \\
+	action police rate 1mbit burst 100k conform-exceed pipe \\
+	action mirred egress redirect dev lo
+.EE
+.RE
+
+Use an
+.B ifb
+interface to send ingress traffic on eth0 through an instance of
+.BR sfq :
+
+.RS
+.EX
+# modprobe ifb
+# ip link set ifb0 up
+# tc qdisc add dev ifb0 root sfq
+# tc qdisc add dev eth0 handle ffff: ingress
+# tc filter add dev eth0 parent ffff: u32 \\
+	match u32 0 0 \\
+	action mirred egress redirect dev ifb0
+.EE
+.RE
+
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-u32 (8)
-- 
2.7.2
