From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man tc: Add description about class name option
Date: Wed,  8 Apr 2015 18:27:43 +0300
Message-ID: <1428506863-8208-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:33394 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbbDHPjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 11:39:52 -0400
Received: by layy10 with SMTP id y10so69039933lay.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 08:39:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/tc.8 | 50 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 49 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index ea4d445..434fe6c 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -62,7 +62,9 @@ DEV
 .ti 8
 .IR OPTIONS " := {"
 \fB[ -force ] -b\fR[\fIatch\fR] \fB[ filename ] \fR|
-\fB[ \fB-n\fR[\fIetns\fR] name \fB] \fR}
+\fB[ \fB-n\fR[\fIetns\fR] name \fB] \fR|
+\fB[ \fB-nm \fR| \fB-nam\fR[\fIes\fR] \fB] \fR|
+\fB[ \fR{ \fB-cf \fR| \fB-c\fR[\fIonf\fR] \fR} \fB[ filename ] \fB] \fR}
 
 .ti 8
 .IR FORMAT " := {"
@@ -463,6 +465,11 @@ to
 .RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
 .BR help " }"
 
+.TP
+.BR "\-cf" , " \-conf " <FILENAME>
+specifies path to the config file. This option is used in conjuction with other options (e.g.
+.BR -nm ")."
+
 .SH FORMAT
 The show command has additional formatting options:
 
@@ -494,6 +501,47 @@ option was specified. Classes can be filtered only by
 .BR "dev"
 option.
 
+.TP
+.BR "\-nm" , " \-name"
+resolve class name from
+.B /etc/iproute2/tc_cls
+file or from file specified by
+.B -cf
+option. This file is just a mapping of
+.B classid
+to class name:
+
+.RS 10
+# Here is comment
+.RE
+.RS 10
+1:40   voip # Here is another comment
+.RE
+.RS 10
+1:50   web
+.RE
+.RS 10
+1:60   ftp
+.RE
+.RS 10
+1:2    home
+.RE
+
+.RS
+.B tc
+will not fail if
+.B -nm
+was specified without
+.B -cf
+option but
+.B /etc/iproute2/tc_cls
+file does not exist, which makes it possible to pass
+.B -nm
+option for creating
+.B tc
+alias.
+.RE
+
 .SH "EXAMPLES"
 .PP
 tc -g class show dev eth0
-- 
2.3.1
