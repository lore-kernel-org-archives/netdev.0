From: Phil Sutter <phil@nwl.cc>
Subject: [iproute RFC PATCH 7/9] tc: add a man page for tcindex filter
Date: Fri, 23 Oct 2015 19:47:14 +0200
Message-ID: <1445622436-6386-8-git-send-email-phil@nwl.cc>
References: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Werner Almesberger <werner@almesberger.net>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:54567 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932299AbbJWRrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 13:47:21 -0400
In-Reply-To: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Werner Almesberger <werner@almesberger.net>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-tcindex.8 | 58 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)
 create mode 100644 man/man8/tc-tcindex.8

diff --git a/man/man8/tc-tcindex.8 b/man/man8/tc-tcindex.8
new file mode 100644
index 0000000..7fcf825
--- /dev/null
+++ b/man/man8/tc-tcindex.8
@@ -0,0 +1,58 @@
+.TH "Traffic control index filter" 8 "21 Oct 2015" "iproute2" "Linux"
+
+.SH NAME
+tcindex \- traffic control index filter
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " " filter " ... " tcindex " [ " hash
+.IR SIZE " ] [ "
+.B mask
+.IR MASK " ] [ "
+.B shift
+.IR SHIFT " ] [ "
+.BR pas_on " | " fall_through " ] [ " classid
+.IR CLASSID " ] [ "
+.B action
+.BR ACTION_SPEC " ]"
+.SH DESCRIPTION
+This filter allows to match packets based on their
+.B tcindex
+field value, i.e. the combination of the DSCP and ECN fields as present in IPv4
+and IPv6 headers.
+.SH OPTIONS
+.TP
+.BI action " ACTION_SPEC"
+Apply an action from the generic actions framework on matching packets.
+.TP
+.BI classid " CLASSID"
+Push matching packets into the class identified by
+.IR CLASSID .
+.TP
+.BI hash " SIZE"
+Hash table size in entries to use. Defaults to 64.
+.TP
+.BI mask " MASK"
+An optional bitmask to binary
+.BR AND " to the packet's " tcindex
+field before use.
+.TP
+.BI shift " SHIFT"
+The number of bits to right-shift a packet's
+.B tcindex
+value before use. If a
+.B mask
+has been set, masking is done before shifting.
+.TP
+.B pass_on
+If this flag is set, failure to find a class for the resulting ID will make the
+filter fail and lead to the next filter being consulted.
+.TP
+.B fall_through
+This is the opposite of
+.B pass_on
+and the default. The filter will classify the packet even if there is no class
+present for the resulting class ID.
+
+.SH SEE ALSO
+.BR tc (8)
-- 
2.1.2
