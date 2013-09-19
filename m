From: =?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
Subject: [PATCH] iproute2: bridge: document mdb
Date: Thu, 19 Sep 2013 10:41:26 +0200
Message-ID: <1379580086-31784-2-git-send-email-ppisar@redhat.com>
References: <1379578543-31358-1-git-send-email-ppisar@redhat.com>
 <1379580086-31784-1-git-send-email-ppisar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <shemminger@vyatta.com>,
	=?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752352Ab3ISIli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 04:41:38 -0400
In-Reply-To: <1379580086-31784-1-git-send-email-ppisar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This augments bridge(8) manual page with `bridge mdb' and `bridge
monitor mdb' commands which have been added recently.

Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
---
 man/man8/bridge.8 | 88 +++++++++++++++++++++++++++++++++++++++++++++++=
++++++--
 1 file changed, 85 insertions(+), 3 deletions(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 66678b5..9a34804 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -13,7 +13,7 @@ bridge \- show / manipulate bridge addresses and devi=
ces
=20
 .ti -8
 .IR OBJECT " :=3D { "
-.BR link " | " fdb " | " vlan " | " monitor " }"
+.BR link " | " fdb " | " mdb " | " vlan " | " monitor " }"
 .sp
=20
 .ti -8
@@ -65,6 +65,21 @@ bridge \- show / manipulate bridge addresses and dev=
ices
 .IR DEV " ]"
=20
 .ti -8
+.BR "bridge mdb" " { " add " | " del " } "
+.B  dev
+.IR DEV
+.B port
+.IR PORT
+.B grp
+.IR GROUP " [ "
+.BR permanent " | " temp " ]"
+
+.ti -8
+.BR "bridge mdb show " [ "
+.B  dev
+.IR DEV " ]"
+
+.ti -8
 .BR "bridge vlan" " { " add " | " del " } "
 .B  dev
 .IR DEV
@@ -79,7 +94,7 @@ bridge \- show / manipulate bridge addresses and devi=
ces
 .IR DEV " ]"
=20
 .ti -8
-.BR "bridge monitor" " [ " all " | " neigh " | " link " ]"
+.BR "bridge monitor" " [ " all " | " neigh " | " link " | " mdb " ]"
=20
 .SH OPTIONS
=20
@@ -110,6 +125,10 @@ As a rule, the information is statistics or some t=
ime values.
 - Forwarding Database entry.
=20
 .TP
+.B mdb
+- Multicast group database entry.
+
+.TP
 .B vlan
 - VLAN filter list.
=20
@@ -326,6 +345,69 @@ With the
 option, the command becomes verbose.  It prints out the last updated
 and last used time for each entry.
=20
+.SH bridge mdb - multicast group database management
+
+.B mdb
+objects contain known IP multicast group addresses on a link.
+
+.P
+The corresponding commands display mdb entries, add new entries,
+and delete old ones.
+
+.SS bridge mdb add - add a new multicast group database entry
+
+This command creates a new mdb entry.
+
+.TP
+.BI dev " DEV"
+the interface where this group address is associated.
+
+.TP
+.BI port " PORT"
+the port whose link is known to have members of this multicast group.
+
+.TP
+.BI grp " GROUP"
+the IP multicast group address whose members reside on the link connec=
ted to
+the port.
+
+.B permanent
+- the mdb entry is permanent
+.sp
+
+.B temp
+- the mdb entry is temporary (default)
+.sp
+
+.in -8
+.SS bridge mdb delete - delete a multicast group database entry
+This command removes an existing mdb entry.
+
+.PP
+The arguments are the same as with
+.BR "bridge mdb add" .
+
+.SS bridge mdb show - list multicast group database entries
+
+This command displays the current multicast group membership table. Th=
e table
+is populated by IGMP and MLD snooping in the bridge driver automatical=
ly. It
+can be altered by
+.B bridge mdb add
+and
+.B bridge mdb del
+commands manually too.
+
+.TP
+.BI dev " DEV"
+the interface only whose entries should be listed. Default is to list =
all
+bridge interfaces.
+
+.PP
+With the
+.B -details
+option, the command becomes verbose.  It prints out the ports known to=
 have
+a connected router.
+
 .SH bridge vlan - VLAN filter list
=20
 .B vlan
@@ -395,7 +477,7 @@ command is the first in the command line and then t=
he object list follows:
 .I OBJECT-LIST
 is the list of object types that we want to monitor.
 It may contain
-.BR link ",  and " fdb "."
+.BR link ",  " fdb ", and " mdb "."
 If no
 .B file
 argument is given,
--=20
1.8.3.1
