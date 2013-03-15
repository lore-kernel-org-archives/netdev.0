From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv3 iproute2 3/3] man: Add documentation for the bridge link operation.
Date: Fri, 15 Mar 2013 13:04:50 -0400
Message-ID: <1363367090-27850-1-git-send-email-vyasevic@redhat.com>
References: <1363366869-27778-4-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754042Ab3COREy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 13:04:54 -0400
In-Reply-To: <1363366869-27778-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Darn, forgot to update the patch.  this one is actually updated.  Appologies.
]

Bridge tool now supports setting and retrieving bridge port specific
link attributes.  Document what attributes are supported and what
they mean.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 man/man8/bridge.8 |  135 +++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 122 insertions(+), 13 deletions(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index d34e3cf..8513a5a 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -13,13 +13,35 @@ bridge \- show / manipulate bridge addresses and devices
 
 .ti -8
 .IR OBJECT " := { "
-.BR fdb " | " vlan " | " monitor " }"
+.BR link " | " fdb " | " vlan " | " monitor " }"
 .sp
 
 .ti -8
 .IR OPTIONS " := { "
 \fB\-V\fR[\fIersion\fR] |
-\fB\-s\fR[\fItatistics\fR]
+\fB\-s\fR[\fItatistics\fR] }
+
+.ti -8
+.BR "bridge link set"
+.B  dev
+.IR DEV
+.IR " [ "
+.B  cost
+.IR COST " ] [ "
+.B  priority
+.IR PRIO " ]  [ "
+.B  state
+.IR STATE "] ["
+.BR guard " { " on " | " off " } ] [ "
+.BR hairpin " { " on " | " off " } ] [ "
+.BR fastleave " { " on " | " off " } ] [ "
+.BR root_block " { " on " | " off " } ] [ "
+.BR hwmode " { " vepa " | " veb " } ] "
+
+.ti -8
+.BR "bridge link" " [ " show " ] [ "
+.B  dev
+.IR DEV " ]"
 
 .ti -8
 .BR "bridge fdb" " { " add " | " del " } "
@@ -72,6 +94,10 @@ As a rule, the information is statistics or some time values.
 .I OBJECT
 
 .TP
+.B link
+- Bridge port.
+
+.TP
 .B fdb 
 - Forwarding Database entry.
 
@@ -102,6 +128,100 @@ Usually it is
 or, if the objects of this class cannot be listed,
 .BR "help" .
 
+.SH bridge link - bridge port
+
+.B link
+objects correspond to the port devices of the bridge.
+
+.P
+The corresponding commands set and display port status and bridge specific
+attributes.
+
+.SS bridge link set - set bridge specific attributes on a port
+
+.TP
+.BI dev " NAME "
+interface name of the bridge port
+
+.TP
+.BI cost " COST "
+the STP path cost of the specified port.
+
+.TP
+.BI priority " PRIO "
+the STP port priority.  The priority value is an unsigned 8-bit quantity
+(number between 0 and 255).  This metric is used in the designated port an
+droot port selectio algorithms.
+
+.TP
+.BI state " STATE "
+the operation state of the port.  This is primarily used by user space STP/RSTP
+implementation.  The following is a list of valid values:
+
+.B 0
+- port is DISABLED.  Make this port completely inactive.
+.sp
+
+.B 1
+- STP LISTENING state.  Only valid if STP is enabled on the brige.  In this
+state the port for list for STP BPDUs and drop all other traffic.
+.sp
+
+.B 2
+- STP LEARNING state.  Only valid if STP is enabled on the bridge.  In this
+state the port will accept traffic only for the purpose of updating MAC
+adress tables.
+.sp
+
+.B 3
+- STP FORWARDING state.  Port is fully active.
+.sp
+
+.B 4
+- STP BLOCKING state.  Only valid if STP is eanbled on the bridge.  This state
+is used during the STP election process.  In this state, port will only process
+STP BPDUs.
+.sp
+
+.TP
+.BR "guard on " or " guard off "
+Controls whether STP BPUDs will be processed by the bridge port.  By default,
+the flag is turned off allowed BPDU processing.  Turning this flag on will
+cause the port to stop processing STP BPDUs.
+
+.TP
+.BR "hairpin on " or " hairpin off "
+Controls whether traffic may be send back out of the port on which it was
+received.  By default, this flag is turned off and the bridge will not forward
+traffic back out of the receiving port.
+
+.TP
+.BR "fastleave on " or " fastleave off "
+This flag allows the bridge to immediately stop multicast traffic on a port
+that recieves IGMP Leave message.  It is only used with IGMP snooping is
+enabled on the bridge.  By default the flag is off.
+
+.TP
+.BR "root_block on " or " root_block off "
+Controls whether a given port is allowed to become root port or not.  Only used
+when STP is enabled on the bridge.  By default the flag is off.
+
+.TP
+.BI hwmode
+Some network interface cards support HW bridge functionality and they may be
+configured in different modes.  Currently support modes are:
+
+.B vepa
+- Data sent between HW ports is sent on the wire to the external
+switch.
+
+.B veb
+- bridging happens in hardware.
+
+.SS bridge link show - list bridge port configuration.
+
+This command displays the current bridge port configuration and flags.
+
 .SH bridge fdb - forwarding database management
 
 .B fdb
@@ -123,17 +243,6 @@ the Ethernet MAC address.
 .BI dev " NAME"
 the interface to which this address is associated.
 
-.TP
-.in +8
-.B local
-- the address is associated with a local interface on the system
-and is never forwarded.
-.sp
-
-.B temp
-- the address is a dynamic entry, and will be removed if not used.
-.sp
-
 .B self
 - the address is associated with a software fdb (default)
 .sp
-- 
1.7.7.6
