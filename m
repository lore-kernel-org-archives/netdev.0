From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH iproute2 2/2] xfrm: revise man page and document ip xfrm policy set
Date: Thu,  9 Apr 2015 17:39:33 +0200
Message-ID: <1428593973-12780-3-git-send-email-christophe.gouault@6wind.com>
References: <1428593973-12780-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:32903 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755589AbbDIPjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 11:39:47 -0400
Received: by wiax7 with SMTP id x7so58135484wia.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 08:39:46 -0700 (PDT)
In-Reply-To: <1428593973-12780-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- document ip xfrm policy set
- update ip xfrm monitor documentation
- in DESCRIPTION section, reorganize grouping of commands

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
---
 man/man8/ip-xfrm.8 |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 59 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index c9d2a2e17c35..29b397f35959 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -257,6 +257,13 @@ ip-xfrm \- transform configuration
 .B "ip xfrm policy count"
 
 .ti -8
+.B "ip xfrm policy set"
+.RB "[ " hthresh4
+.IR LBITS " " RBITS " ]"
+.RB "[ " hthresh6
+.IR LBITS " " RBITS " ]"
+
+.ti -8
 .IR SELECTOR " :="
 .RB "[ " src
 .IR ADDR "[/" PLEN "] ]"
@@ -360,6 +367,13 @@ ip-xfrm \- transform configuration
 .BR "ip xfrm monitor" " [ " all " |"
 .IR LISTofXFRM-OBJECTS " ]"
 
+.ti -8
+.IR LISTofXFRM-OBJECTS " := [ " LISTofXFRM-OBJECTS " ] " XFRM-OBJECT
+
+.ti -8
+.IR XFRM-OBJECT " := "
+.BR acquire " | " expire " | " SA " | " policy " | " aevent " | " report
+
 .in -8
 .ad b
 
@@ -385,7 +399,6 @@ ip xfrm state deleteall	delete all existing state in xfrm
 ip xfrm state list	print out the list of existing state in xfrm
 ip xfrm state flush	flush all state in xfrm
 ip xfrm state count	count all existing state in xfrm
-ip xfrm monitor 	state monitoring for xfrm objects
 .TE
 
 .TP
@@ -507,7 +520,9 @@ encapsulates packets with protocol
 .BR espinudp " or " espinudp-nonike ","
 .RI "using source port " SPORT ", destination port "  DPORT
 .RI ", and original address " OADDR "."
+
 .sp
+.PP
 .TS
 l l.
 ip xfrm policy add	add a new policy
@@ -517,7 +532,6 @@ ip xfrm policy get	get an existing policy
 ip xfrm policy deleteall	delete all existing xfrm policies
 ip xfrm policy list	print out the list of xfrm policies
 ip xfrm policy flush	flush policies
-ip xfrm policy count	count existing policies
 .TE
 
 .TP
@@ -612,7 +626,50 @@ and inbound trigger
 can be
 .BR required " (default) or " use "."
 
+.sp
+.PP
+.TS
+l l.
+ip xfrm policy count	count existing policies
+.TE
+
+.PP
+Use one or more -s options to display more details, including policy hash table
+information.
+
+.sp
+.PP
+.TS
+l l.
+ip xfrm policy set	configure the policy hash table
+.TE
+
+.PP
+Security policies whose address prefix lengths are greater than or equal
+policy hash table thresholds are hashed. Others are stored in the
+policy_inexact chained list.
+
+.TP
+.I LBITS
+specifies the minimum local address prefix length of policies that are
+stored in the Security Policy Database hash table.
+
+.TP
+.I RBITS
+specifies the minimum remote address prefix length of policies that are
+stored in the Security Policy Database hash table.
+
+.sp
+.PP
+.TS
+l l.
+ip xfrm monitor 	state monitoring for xfrm objects
+.TE
+
+.PP
 The xfrm objects to monitor can be optionally specified.
 
 .SH AUTHOR
 Manpage revised by David Ward <david.ward@ll.mit.edu>
+.br
+Manpage revised by Christophe Gouault <christophe.gouault@6wind.com>
-- 
1.7.10.4
