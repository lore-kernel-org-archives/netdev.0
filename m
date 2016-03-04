From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 09/12] man: Add a man page for the vlan action
Date: Fri,  4 Mar 2016 13:11:44 +0100
Message-ID: <1457093507-25601-10-git-send-email-phil@nwl.cc>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40896 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171AbcCDMND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 07:13:03 -0500
Received: from mail.nwl.cc (orbyte.nwl.cc [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id 273506AF5C
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:13:01 +0100 (CET)
Received: from xsao (localhost [IPv6:::1])
	by mail.nwl.cc (Postfix) with ESMTP id 095506894E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:13:01 +0100 (CET)
In-Reply-To: <1457093507-25601-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-vlan.8 | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)
 create mode 100644 man/man8/tc-vlan.8

diff --git a/man/man8/tc-vlan.8 b/man/man8/tc-vlan.8
new file mode 100644
index 0000000000000..e650b72d3b395
--- /dev/null
+++ b/man/man8/tc-vlan.8
@@ -0,0 +1,54 @@
+.TH "VLAN manipulation action in tc" 8 "12 Jan 2015" "iproute2" "Linux"
+
+.SH NAME
+vlan - vlan manipulation module
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " "action vlan" " { " pop " |"
+.IR PUSH " }"
+
+.ti -8
+.IR PUSH " := "
+.BR push " [ " protocol
+.IR VLANPROTO " ]"
+.BI id " VLANID"
+.SH DESCRIPTION
+The
+.B vlan
+action allows to perform 802.1Q en- or decapsulation on a packet, reflected by
+the two operation modes
+.IR POP " and " PUSH .
+The
+.I POP
+mode is simple, as no further information is required to just drop the
+outer-most VLAN encapsulation. The
+.I PUSH
+mode on the other hand requires at least a
+.I VLANID
+and allows to optionally choose the
+.I VLANPROTO
+to use.
+.SH OPTIONS
+.TP
+.B pop
+Decapsulation mode, no further arguments allowed.
+.TP
+.B push
+Encapsulation mode. Requires at least
+.B id
+option.
+.TP
+.BI id " VLANID"
+Specify the VLAN ID to encapsulate into.
+.I VLANID
+is an unsigned 16bit integer, the format is detected automatically (e.g. prefix
+with
+.RB ' 0x '
+for hexadecimal interpretation, etc.).
+.TP
+.BI protocol " VLANPROTO"
+Choose the VLAN protocol to use. At the time of writing, the kernel accepts only
+.BR 802.1Q " or " 802.1ad .
+.SH SEE ALSO
+.BR tc (8)
-- 
2.7.2
