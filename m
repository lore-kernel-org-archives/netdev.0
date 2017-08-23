From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] ss: fix help/man TCP-STATE description for listening
Date: Wed, 23 Aug 2017 14:47:51 +0200
Message-ID: <1503492471-18403-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-83-233-174-181.cust.bredband2.com ([83.233.174.181]:46194
        "EHLO pi.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753921AbdHWMxl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 08:53:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's some misleading information in --help and ss(8) manpage about
TCP-STATE named 'listen'.
ss doesn't know such a state, but it knows 'listening' state.

$ ss -tua state listen
ss: wrong state name: listen

$ ss -tua state listening
[...]

Addresses: https://bugs.debian.org/872990
Reported-by: Pavel Lyulchenko <p.lyulchenko@gmail.com>
Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 man/man8/ss.8 | 4 ++--
 misc/ss.c     | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 81de69de..3bec97f0 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -153,14 +153,14 @@ Available identifiers are:
 
 All standard TCP states:
 .BR established ", " syn-sent ", " syn-recv ", " fin-wait-1 ", " fin-wait-2 ", " time-wait ", " closed ", " close-wait ", " last-ack ", "
-.BR  listen " and " closing.
+.BR  listening " and " closing.
 
 .B all
 - for all the states
 
 .B connected
 - all the states except for
-.BR listen " and " closed
+.BR listening " and " closed
 
 .B synchronized
 - all the
diff --git a/misc/ss.c b/misc/ss.c
index 34c6da54..c197e075 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3922,11 +3922,11 @@ static void _usage(FILE *dest)
 "   -F, --filter=FILE   read filter information from FILE\n"
 "       FILTER := [ state STATE-FILTER ] [ EXPRESSION ]\n"
 "       STATE-FILTER := {all|connected|synchronized|bucket|big|TCP-STATES}\n"
-"         TCP-STATES := {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|closed|close-wait|last-ack|listen|closing}\n"
+"         TCP-STATES := {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|closed|close-wait|last-ack|listening|closing}\n"
 "          connected := {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}\n"
 "       synchronized := {established|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}\n"
 "             bucket := {syn-recv|time-wait}\n"
-"                big := {established|syn-sent|fin-wait-{1,2}|closed|close-wait|last-ack|listen|closing}\n"
+"                big := {established|syn-sent|fin-wait-{1,2}|closed|close-wait|last-ack|listening|closing}\n"
 		);
 }
 
-- 
2.11.0
