From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 2/2] tc: man: Add man entry for the matchall classifier.
Date: Mon, 22 Aug 2016 13:56:26 +0200
Message-ID: <1471866986-3156-3-git-send-email-jiri@resnulli.us>
References: <1471866986-3156-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, yotamg@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33561 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752781AbcHVL4c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:56:32 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so13127189wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:56:31 -0700 (PDT)
In-Reply-To: <1471866986-3156-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

In addition to providing infromation about the mathcall filter and its
configurations, the man entry contains examples for creating port
mirorring entries.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 man/man8/Makefile      |  2 +-
 man/man8/tc-matchall.8 | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/tc.8          |  5 ++++
 3 files changed, 82 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/tc-matchall.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 9badbed..9213769 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -14,7 +14,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tipc.8 tipc-bearer.8 tipc-link.8 tipc-media.8 tipc-nametable.8 \
 	tipc-node.8 tipc-socket.8 \
 	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
-	tc-tcindex.8 tc-u32.8 \
+	tc-tcindex.8 tc-u32.8 tc-matchall.8 \
 	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
 	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8 \
 	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8
diff --git a/man/man8/tc-matchall.8 b/man/man8/tc-matchall.8
new file mode 100644
index 0000000..b927784
--- /dev/null
+++ b/man/man8/tc-matchall.8
@@ -0,0 +1,76 @@
+.TH "Match-all classifier in tc" 8 "21 Oct 2015" "iproute2" "Linux"
+
+.SH NAME
+matchall \- traffic control filter that matches every packet
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " " filter " ... " matchall " [ "
+.BR skip_sw " | " skip_hw
+.R " ] [ "
+.B action
+.IR ACTION_SPEC " ] [ "
+.B classid
+.IR CLASSID " ]"
+.SH DESCRIPTION
+The
+.B matchall
+filter allows to classify every packet that flows on the port and run a
+action on it.
+.SH OPTIONS
+.TP
+.BI action " ACTION_SPEC"
+Apply an action from the generic actions framework on matching packets.
+.TP
+.BI classid " CLASSID"
+Push matching packets into the class identified by
+.IR CLASSID .
+.TP
+.BI skip_sw
+Do not process filter by software. If hardware has no offload support for this
+filter, or TC offload is not enabled for the interface, operation will fail.
+.TP
+.BI skip_hw
+Do not process filter by hardware.
+.SH EXAMPLES
+To create ingress mirroring from port eth1 to port eth2:
+.RS
+.EX
+
+tc qdisc  add dev eth1 handle ffff: ingress
+tc filter add dev eth1 parent ffff:           \\
+        matchall skip_sw                      \\
+        action mirred egress mirror           \\
+        dev eth2
+.EE
+.RE
+
+The first command creats an ingress qdisc with handle
+.BR ffff:
+on device
+.BR eth1
+where the second command attaches a matchall filters on it that mirrors the
+pacets to device eth2.
+
+To create engress mirroring from port eth1 to port eth2:
+.EX
+
+tc qdisc add dev eth1 handle 1: root prio
+tc filter add dev eth1 parent 1:               \\
+        matchall skip_sw                       \\
+        action mirred egress mirror            \\
+        dev eth2
+.EE
+.RE
+
+The first command creats an egress qdisc with handle
+.BR 1:
+that replaces the root qdisc on device
+.BR eth1
+where the second command attaches a matchall filters on it that mirrors the
+pacets to device eth2.
+
+
+.EE
+.SH SEE ALSO
+.BR tc (8),
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 4e99dca..7ee1c9c 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -187,6 +187,11 @@ u32
 Generic filtering on arbitrary packet data, assisted by syntax to abstract common operations. See
 .BR tc-u32 (8)
 for details.
+.TP
+matchall
+Traffic control filter that matches every packet. See
+.BR tc-matchall (8)
+for details.
 
 .SH CLASSLESS QDISCS
 The classless qdiscs are:
-- 
2.5.5
