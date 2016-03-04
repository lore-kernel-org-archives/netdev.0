From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 10/12] man: Add a man page for the xt action
Date: Fri,  4 Mar 2016 13:11:45 +0100
Message-ID: <1457093507-25601-11-git-send-email-phil@nwl.cc>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36342 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477AbcCDMMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 07:12:06 -0500
Received: from mail.nwl.cc (orbyte.nwl.cc [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id AEF236AF5C
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:04 +0100 (CET)
Received: from xsao (localhost [IPv6:::1])
	by mail.nwl.cc (Postfix) with ESMTP id 92B846894E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:04 +0100 (CET)
In-Reply-To: <1457093507-25601-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-xt.8 | 42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)
 create mode 100644 man/man8/tc-xt.8

diff --git a/man/man8/tc-xt.8 b/man/man8/tc-xt.8
new file mode 100644
index 0000000000000..4fd800cf2b8a7
--- /dev/null
+++ b/man/man8/tc-xt.8
@@ -0,0 +1,42 @@
+.TH "iptables action in tc" 8 "3 Mar 2016" "iproute2" "Linux"
+
+.SH NAME
+xt - tc iptables action
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " "action xt \-j"
+.IR TARGET " [ " TARGET_OPTS " ]"
+.SH DESCRIPTION
+The
+.B xt
+action allows to call arbitrary iptables targets for packets matching the filter
+this action is attached to.
+.SH OPTIONS
+.TP
+.BI -j " TARGET \fR[\fI TARGET_OPTS \fR]"
+Perform a jump to the given iptables target, optionally passing any target
+specific options in
+.IR TARGET_OPTS .
+.SH EXAMPLES
+The following will attach a
+.B u32
+filter to the
+.B ingress
+qdisc matching ICMP replies and using the
+.B xt
+action to make the kernel yell 'PONG' each time:
+
+.RS
+.EX
+tc qdisc add dev eth0 ingress
+tc filter add dev eth0 parent ffff: proto ip u32 \\
+	match ip protocol 1 0xff \\
+	match ip icmp_type 0 0xff \\
+	action xt -j LOG --log-prefix PONG
+.EE
+.RE
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-u32 (8),
+.BR iptables-extensions (8)
-- 
2.7.2
