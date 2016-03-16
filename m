From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 5/8] man: tc-police.8: Emphasize on the two rate control mechanisms
Date: Wed, 16 Mar 2016 22:56:21 +0100
Message-ID: <1458165384-900-6-git-send-email-phil@nwl.cc>
References: <1458165384-900-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41072 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755656AbcCPV4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 17:56:37 -0400
In-Reply-To: <1458165384-900-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Jamal pointed out, there are two different approaches to bandwidth
measurement. Try to make this clear by separating them in synopsis and
also documenting the way to fine-tune avrate.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-police.8 | 29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/man/man8/tc-police.8 b/man/man8/tc-police.8
index 2b1537ec52875..5c5a632335dc9 100644
--- a/man/man8/tc-police.8
+++ b/man/man8/tc-police.8
@@ -12,13 +12,21 @@ police - policing action
 .IR BYTES [\fB/ BYTES "] ] ["
 .BI peakrate " RATE"
 ] [
-.BI avrate " RATE"
-] [
 .BI overhead " BYTES"
 ] [
 .BI linklayer " TYPE"
 ] [
-.BI conform-exceed " EXCEEDACT\fR[\fB/\fIEXCEEDACT\fR]"
+.IR CONTROL " ]"
+
+.ti -8
+.BR tc " ... " filter " ... [ " estimator
+.IR "SAMPLE AVERAGE " ]
+.BR "action police avrate"
+.IR RATE " [ " CONTROL " ]"
+
+.ti -8
+.IR CONTROL " :="
+.BI conform-exceed " EXCEEDACT\fR[\fB/\fIEXCEEDACT"
 
 .ti -8
 .IR EXCEEDACT " := { "
@@ -27,7 +35,14 @@ police - policing action
 The
 .B police
 action allows to limit bandwidth of traffic matched by the filter it is
-attached to.
+attached to. Basically there are two different algorithms available to measure
+the packet rate: The first one uses an internal dual token bucket and is
+configured using the
+.BR rate ", " burst ", " mtu ", " peakrate ", " overhead " and " linklayer
+parameters. The second one uses an in-kernel sampling mechanism. It can be
+fine-tuned using the
+.B estimator
+filter parameter.
 .SH OPTIONS
 .TP
 .BI rate " RATE"
@@ -73,6 +88,12 @@ cell sizes, for
 .B ethernet
 no action is taken.
 .TP
+.BI estimator " SAMPLE AVERAGE"
+Fine-tune the in-kernel packet rate estimator.
+.IR SAMPLE " and " AVERAGE
+are time values and control the frequency in which samples are taken and over
+what timespan an average is built.
+.TP
 .BI conform-exceed " EXCEEDACT\fR[\fB/\fIEXCEEDACT\fR]"
 Define how to handle packets which exceed (and, if the second
 .I EXCEEDACT
-- 
2.7.2
