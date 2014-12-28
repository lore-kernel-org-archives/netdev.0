From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ss: Add state filter description
Date: Sun, 28 Dec 2014 13:39:08 +0200
Message-ID: <1419766748-4468-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=y
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:45971 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaL1LtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 06:49:20 -0500
Received: by mail-wg0-f48.google.com with SMTP id y19so17024632wgg.21
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 03:49:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Vadim Kochan <vadim4j@gmail.com>

Stolen from generated doc/ss.html
Also added reference to RFC 739 for TCP states.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ss.8 | 41 +++++++++++++++++++++++++++++++++++++++--
 1 file changed, 39 insertions(+), 2 deletions(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 2a4bbc5..f4b709b 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -127,8 +127,41 @@ Do not display anything, just dump raw information=
 about TCP sockets to FILE aft
 Read filter information from FILE.
 Each line of FILE is interpreted like single command line option. If F=
ILE is - stdin is used.
 .TP
-.B FILTER :=3D [ state TCP-STATE ] [ EXPRESSION ]
+.B FILTER :=3D [ state STATE-FILTER ] [ EXPRESSION ]
 Please take a look at the official documentation (Debian package iprou=
te-doc) for details regarding filters.
+
+.SH STATE-FILTER
+
+.B STATE-FILTER
+allows to construct arbitrary set of states to match. Its syntax is se=
quence of keywords state and exclude followed by identifier of state.
+.TP
+Available identifiers are:
+
+All standard TCP states:
+.BR established ", " syn-sent ", " syn-recv ", " fin-wait-1 ", " fin-w=
ait-2 ", " time-wait ", " closed ", " close-wait ", " last-ack ", "
+.BR  listen " and " closing.
+
+.B all
+- for all the states
+
+.B connected
+- all the states except for
+.BR listen " and " closed
+
+.B synchronized
+- all the
+.B connected
+states except for
+.B syn-sent
+
+.B bucket
+- states, which are maintained as minisockets, i.e.
+.BR time-wait " and " syn-recv
+
+.B big
+- opposite to
+.B bucket
+
 .SH USAGE EXAMPLES
 .TP
 .B ss -t -a
@@ -150,7 +183,11 @@ Find all local processes connected to X server.
 List all the tcp sockets in state FIN-WAIT-1 for our apache to network=
 193.233.7/24 and look at their timers.
 .SH SEE ALSO
 .BR ip (8),
-.BR /usr/share/doc/iproute-doc/ss.html " (package iproute=ADdoc)"
+.BR /usr/share/doc/iproute-doc/ss.html " (package iproute=ADdoc)",
+.br
+.BR RFC " 793 "
+- https://tools.ietf.org/rfc/rfc793.txt (TCP states)=20
+
 .SH AUTHOR
 .I ss=20
 was written by Alexey Kuznetosv, <kuznet@ms2.inr.ac.ru>.
--=20
2.1.3
