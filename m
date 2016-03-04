From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 01/12] man: Add a man page for the connmark action
Date: Fri,  4 Mar 2016 13:11:36 +0100
Message-ID: <1457093507-25601-2-git-send-email-phil@nwl.cc>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52114 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751513AbcCDMMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 07:12:00 -0500
Received: from mail.nwl.cc (orbyte.nwl.cc [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id 757556AF5C
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:11:58 +0100 (CET)
Received: from xsao (localhost [IPv6:::1])
	by mail.nwl.cc (Postfix) with ESMTP id 5831E6894E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:11:58 +0100 (CET)
In-Reply-To: <1457093507-25601-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-connmark.8 | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)
 create mode 100644 man/man8/tc-connmark.8

diff --git a/man/man8/tc-connmark.8 b/man/man8/tc-connmark.8
new file mode 100644
index 0000000000000..bb4cf7543dfdb
--- /dev/null
+++ b/man/man8/tc-connmark.8
@@ -0,0 +1,55 @@
+.TH "Connmark retriever action in tc" 8 "11 Jan 2016" "iproute2" "Linux"
+
+.SH NAME
+connmark - netfilter connmark retriever action
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " "action connmark " [ " zone"
+.IR u16_zone_index " ] [ " BRANCH " ] ["
+.BI index " u32_index "
+]
+
+.ti -8
+.IR BRANCH " := { " reclassify " | " pipe " | " drop " | " continue " | " ok " }"
+.SH DESCRIPTION
+The connmark action is used to restore the connection's mark value into the
+packet's fwmark.
+.SH OPTIONS
+.TP
+.BI zone " u16_zone_index"
+Specify the conntrack zone when doing conntrack lookups for packets.
+.I u16_zone_index
+is a 16bit unsigned decimal value.
+.TP
+.I BRANCH
+How to continue after executing this action.
+.RS
+.TP
+.B reclassify
+Restarts classification by jumping back to the first filter attached to this
+action's parent.
+.TP
+.B pipe
+Continue with the next action, this is the default.
+.TP
+.B drop
+.TQ
+.B shot
+Packet will be dropped without running further actions.
+.TP
+.B continue
+Continue classification with next filter in line.
+.TP
+.B pass
+Return to calling qdisc for packet processing. This ends the classification
+process.
+.RE
+.TP
+.BI index " u32_index "
+Specify an index for this action in order to being able to identify it in later
+commands.
+.I u32_index
+is a 32bit unsigned decimal value.
+.SH SEE ALSO
+.BR tc (8)
-- 
2.7.2
