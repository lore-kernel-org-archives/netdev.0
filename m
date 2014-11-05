From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 iproute2 5/5] iproute2: Man pages for fou and gue
Date: Wed,  5 Nov 2014 10:06:28 -0800
Message-ID: <1415210788-8058-6-git-send-email-therbert@google.com>
References: <1415210788-8058-1-git-send-email-therbert@google.com>
To: stephen@networkplumber.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:62223 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbaKESHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 13:07:00 -0500
Received: by mail-ig0-f175.google.com with SMTP id h3so9236144igd.8
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 10:07:00 -0800 (PST)
In-Reply-To: <1415210788-8058-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Man pages for Foo-over-UDP and Generic UDP Encapsulation receive
port configuration. gue man page links to fou one.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 man/man8/ip-fou.8 | 76 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-gue.8 |  1 +
 2 files changed, 77 insertions(+)
 create mode 100644 man/man8/ip-fou.8
 create mode 100644 man/man8/ip-gue.8

diff --git a/man/man8/ip-fou.8 b/man/man8/ip-fou.8
new file mode 100644
index 0000000..0fa22ee
--- /dev/null
+++ b/man/man8/ip-fou.8
@@ -0,0 +1,76 @@
+.TH IP\-FOU 8 "2 Nov 2014" "iproute2" "Linux"
+.SH "NAME"
+ip-fou \- Foo-over-UDP receive port configuration
+.P
+ip-gue \- Generic UDP Encapsulation receive port configuration
+.SH "SYNOPSIS"
+.sp
+.ad l
+.in +8
+.ti -8
+.B ip
+.RI "[ " OPTIONS " ]"
+.B fou
+.RI " { " COMMAND " | "
+.BR help " }"
+.sp
+.ti -8
+.BR "ip fou add"
+.B port
+.IR PORT
+.RB "{ "
+.B gue
+.RI "|"
+.B ipproto
+.IR PROTO
+.RB " }"
+.br
+.ti -8
+.BR "ip fou del"
+.B port
+.IR PORT
+.SH DESCRIPTION
+The
+.B ip fou
+commands are used to create and delete receive ports for Foo-over-UDP
+(FOU) as well as Generic UDP Encapsulation (GUE).
+.PP
+Foo-over-UDP allows encapsulating packets of an IP protocol directly
+over UDP. The receiver infers the protocol of a packet received on
+a FOU UDP port to be the protocol configured for the port.
+.PP
+Generic UDP Encapsulation (GUE) encapsulates packets of an IP protocol
+within UDP and an encapsulation header. The encapsulation header contains the
+IP protocol number for the encapsulated packet.
+.PP
+When creating a FOU or GUE receive port, the port number is specified in
+.I PORT
+argument. If FOU is used, the IP protocol number associated with the port is specified in
+.I PROTO
+argument.
+.PP
+A FOU or GUE receive port is deleted by specifying
+.I PORT
+in the delete command.
+.SH EXAMPLES
+.PP
+.SS Configure a FOU receive port for GRE bound to 7777
+.nf
+# ip fou add port 8888 ipproto 47
+.PP
+.SS Configure a FOU receive port for IPIP bound to 8888
+.nf
+# ip fou add port 8888 ipproto 4
+.PP
+.SS Configure a GUE receive port bound to 9999
+.nf
+# ip fou add port 9999 gue
+.PP
+.SS Delete the GUE receive port bound to 9999
+.nf
+# ip fou del port 9999
+.SH SEE ALSO
+.br
+.BR ip (8)
+.SH AUTHOR
+Tom Herbert <therbert@google.com>
diff --git a/man/man8/ip-gue.8 b/man/man8/ip-gue.8
new file mode 100644
index 0000000..4d2914c
--- /dev/null
+++ b/man/man8/ip-gue.8
@@ -0,0 +1 @@
+.so man8/ip-fou.8
-- 
2.1.0.rc2.206.gedb03e5
