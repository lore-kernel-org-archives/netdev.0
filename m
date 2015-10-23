From: Phil Sutter <phil@nwl.cc>
Subject: [iproute RFC PATCH 5/9] tc: add a man page for fw filter
Date: Fri, 23 Oct 2015 19:47:12 +0200
Message-ID: <1445622436-6386-6-git-send-email-phil@nwl.cc>
References: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:57713 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932298AbbJWRrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 13:47:21 -0400
In-Reply-To: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-fw.8 | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)
 create mode 100644 man/man8/tc-fw.8

diff --git a/man/man8/tc-fw.8 b/man/man8/tc-fw.8
new file mode 100644
index 0000000..d742b47
--- /dev/null
+++ b/man/man8/tc-fw.8
@@ -0,0 +1,66 @@
+.TH "Firewall mark classifier in tc" 8 "21 Oct 2015" "iproute2" "Linux"
+
+.SH NAME
+fw \- fwmark traffic control filter
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " " filter " ... " fw " [ " classid
+.IR CLASSID " ] [ "
+.B action
+.IR ACTION_SPEC " ]"
+.SH DESCRIPTION
+the
+.B fw
+filter allows to classify packets based on a previously set
+.BR fwmark " by " iptables .
+If it is identical to the filter's
+.BR handle ,
+the filter matches.
+.B iptables
+allows to mark single packets with the
+.B MARK
+target, or whole connections using
+.BR CONNMARK .
+The benefit of using this filter instead of doing the
+heavy-lifting with
+.B tc
+itself is that on one hand it might be convenient to keep packet filtering and
+classification in one place, possibly having to match a packet just once, and on
+the other users familiar with
+.BR iptables " but not " tc
+will have a less hard time adding QoS to their setups.
+.SH OPTIONS
+.TP
+.BI classid " CLASSID"
+Push matching packets to the class identified by
+.IR CLASSID .
+.TP
+.BI action " ACTION_SPEC"
+Apply an action from the generic actions framework on matching packets.
+.SH EXAMPLES
+Take e.g. the following tc filter statement:
+
+.RS
+.EX
+tc filter add ... handle 6 fw classid 1:1
+.EE
+.RE
+
+will match if the packet's
+.B fwmark
+value is
+.BR 6 .
+This is a sample
+.B iptables
+statement marking packets coming in on eth0:
+
+.RS
+.EX
+iptables -t mangle -A PREROUTING -i eth0 -j MARK --set-mark 6
+.EE
+.RE
+.SH SEE ALSO
+.BR tc (8),
+.BR iptables (8),
+.BR iptables-extensions (8)
-- 
2.1.2
