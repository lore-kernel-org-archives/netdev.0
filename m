From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] man: ip-neighbour.8: Document all known nud states
Date: Fri,  4 Mar 2016 20:07:20 +0100
Message-ID: <1457118441-15349-2-git-send-email-phil@nwl.cc>
References: <1457118441-15349-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52069 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758710AbcCDTHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 14:07:46 -0500
In-Reply-To: <1457118441-15349-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure how useful they are in practice, but as 'ip neigh' supports
setting them all, they deserve to be described as well.

While at it, also add a missing layer of indentation to the subordinate
nud state list.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-neighbour.8 | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-neighbour.8 b/man/man8/ip-neighbour.8
index 19c6d9d8bf605..b292e18144950 100644
--- a/man/man8/ip-neighbour.8
+++ b/man/man8/ip-neighbour.8
@@ -35,7 +35,8 @@ ip-neighbour \- neighbour/arp tables management.
 
 .ti -8
 .IR STATE " := {"
-.BR permanent " | " noarp " | " stale " | " reachable " }"
+.BR permanent " | " noarp " | " stale " | " reachable " | " none " |"
+.BR incomplete " | " delay " | " probe " | " failed " }"
 
 .SH DESCRIPTION
 The
@@ -86,6 +87,7 @@ the state of the neighbour entry.
 is an abbreviation for 'Neighbour Unreachability Detection'.
 The state can take one of the following values:
 
+.RS
 .TP
 .B permanent
 the neighbour entry is valid forever and can be only
@@ -105,6 +107,24 @@ This option to
 .B ip neigh
 does not change the neighbour state if it was valid and the address
 is not changed by this command.
+.TP
+.B none
+this is a pseudo state used when initially creating a neighbour entry or after
+trying to remove it before it becomes free to do so.
+.TP
+.B incomplete
+the neighbour entry has not (yet) been validated/resolved.
+.TP
+.B delay
+neighbor entry validation is currently delayed.
+.TP
+.B probe
+neighbor is being probed.
+.TP
+.B failed
+max number of probes exceeded without success, neighbor validation has
+ultimately failed.
+.RE
 .RE
 
 .TP
-- 
2.7.2
