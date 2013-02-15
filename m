From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH iproute 3/3] bridge: Update bridge man pages to include vlan command
Date: Fri, 15 Feb 2013 15:21:52 -0500
Message-ID: <1360959712-7977-4-git-send-email-vyasevic@redhat.com>
References: <1360959712-7977-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968Ab3BOUV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 15:21:57 -0500
In-Reply-To: <1360959712-7977-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the vlan command documentation to bridge man page.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 man/man8/bridge.8 |   73 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 72 insertions(+), 1 deletions(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index fd91618..d34e3cf 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -13,7 +13,7 @@ bridge \- show / manipulate bridge addresses and devices
 
 .ti -8
 .IR OBJECT " := { "
-.BR fdb " | " monitor " }"
+.BR fdb " | " vlan " | " monitor " }"
 .sp
 
 .ti -8
@@ -35,6 +35,20 @@ bridge \- show / manipulate bridge addresses and devices
 .IR DEV " ]"
 
 .ti -8
+.BR "bridge vlan" " { " add " | " del " } "
+.B  dev
+.IR DEV
+.B  vid 
+.IR VID " [ "
+.BR  pvid " ] [ " untagged " ]  [ "
+.BR  self " ]  [ " master " ] "
+
+.ti -8
+.BR "bridge vlan" " [ " show " ] [ "
+.B  dev
+.IR DEV " ]"
+
+.ti -8
 .BR "bridge monitor" " [ " all " | " neigh " | " link " ]"
 
 .SH OPTIONS
@@ -61,6 +75,10 @@ As a rule, the information is statistics or some time values.
 .B fdb 
 - Forwarding Database entry.
 
+.TP
+.B vlan
+- VLAN filter list.
+
 .SS
 .I COMMAND
 
@@ -143,6 +161,59 @@ With the
 option, the command becomes verbose.  It prints out the last updated
 and last used time for each entry.
 
+.SH bridge vlan - VLAN filter list
+
+.B vlan
+objects contain known VLAN IDs for a link.
+
+.P
+The corresponding commands display vlan filter entries, add new entries,
+and delete old ones.
+
+.SS bridge vlan add - add a new vlan filter entry
+
+This command creates a new vlan filter entry.
+
+.TP
+.BI dev " NAME"
+the interface with which this vlan is associated.
+
+.TP
+.BI vid " VID"
+the VLAN ID that identifies the vlan.
+
+.TP
+.BI pvid
+the vlan specified is to be considered a PVID at ingress.
+Any untagged frames will be assigned to this VLAN.
+
+.TP
+.BI untagged
+the vlan specified is to be treated as untagged on egress.
+
+.TP
+.BI self
+the vlan is configured on the specified physical device.  Required if the
+device is the bridge device.
+
+.TP
+.BI master
+the vlan is configured on the sofware bridge (default).
+
+.SS bridge vlan delete - delete a forwarding database entry
+This command removes an existing fdb entry.
+
+.PP
+The arguments are the same as with
+.BR "bridge vlan add".
+The
+.BR "pvid " and " untagged"
+flags are ignored.
+
+.SS bridge vlan show - list vlan configuration.
+
+This command displays the current VLAN filter table.
+
 .SH bridge monitor - state monitoring
 
 The
-- 
1.7.7.6
