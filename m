From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 2/2] actions: update the man page to describe the "since" time filter
Date: Wed,  2 Aug 2017 07:46:27 -0400
Message-ID: <1501674387-15001-2-git-send-email-jhs@emojatatu.com>
References: <1501674387-15001-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, dsahern@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:38082 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753078AbdHBLqp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 07:46:45 -0400
Received: by mail-io0-f196.google.com with SMTP id o9so3525588iod.5
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 04:46:44 -0700 (PDT)
In-Reply-To: <1501674387-15001-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 man/man8/tc-actions.8 | 31 +++++++++++++++++++++++++++----
 1 file changed, 27 insertions(+), 4 deletions(-)

diff --git a/man/man8/tc-actions.8 b/man/man8/tc-actions.8
index 51f43af..f46166e 100644
--- a/man/man8/tc-actions.8
+++ b/man/man8/tc-actions.8
@@ -1,4 +1,4 @@
-.TH "actions in tc" 8 "4 Jul 2017" "iproute2" "Linux"
+.TH "actions in tc" 8 "1 Aug 2017" "iproute2" "Linux"
 
 .SH NAME
 actions \- independently defined actions in tc
@@ -33,6 +33,9 @@ actions \- independently defined actions in tc
 .B actions
 .BR ls " | " list
 .I ACTNAMESPEC
+[
+.I ACTFILTER
+]
 
 .in +8
 .I ACTSPEC
@@ -60,6 +63,10 @@ ACTNAME
 :=
 .BI index " INDEX"
 
+.I ACTFILTER
+:=
+.BI since " MSTIME"
+
 .I COOKIESPEC
 :=
 .BI cookie " COOKIE"
@@ -71,9 +78,8 @@ ACTNAME
 .I ACTNAME
 may be any valid action type: gact, mirred, bpf, connmark, csum, police, etc.
 
-.I ACTPARAMS
-are the action-specific parameters; see the man page for the specific action
-type to be used for details.
+.I MSTIME
+Time since last update.
 
 .I CONTROL
 := {
@@ -132,6 +138,10 @@ List all the actions in the specified table. When combined with the
 option for
 .BR tc ","
 display the statistics for all actions in the specified table.
+When combined with the option
+.B since
+allows doing a millisecond time-filter since the last time an
+action was used in the datapath.
 .TP
 .B flush
 Delete all actions stored in the specified table.
@@ -177,6 +187,19 @@ The value to be stored is completely arbitrary and does not require a specific
 format. It is stored inside the action structure itself.
 
 .TP
+.BI since " MSTIME"
+When dumping large number of actions, a millisecond time-filter can be
+specified
+.IR MSTIME "."
+The
+.I MSTIME
+is a millisecond count since last time a packet hit the action.
+As an example specifying "since 20000" implies to dump all actions
+that have seen packets in the last 20 seconds. This option is useful
+when the kernel has a large number of actions and you are only interested
+in recently used actions.
+
+.TP
 .I CONTROL
 The
 .I CONTROL
-- 
1.9.1
