From: Anton Blanchard <anton@samba.org>
Subject: 100 network limit
Date: Fri, 29 Aug 2003 04:00:19 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030828180019.GH12541@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

We hit the 100 network naming limit :) Yes the comment is correct, we
need to fix the algorithm. dev_base_lock really starts to show up
(eg in dev_get_by_index), especially when doing IO to raw sockets
(does every packet to a raw socket result in a dev_get_by_index? Couldnt
we embed a pointer to the device in the socket?)

Anyway as a short term fix Jamal suggested making a sysctl for this
maximum. If fixing this all properly is out of the question for 2.6,
would the sysctl approach be satisfactory? The other option is to just
bump the limit and recognise that the user is on his own if performance
sucks.

Anton

diff -ru gr14/net/core/dev.c gr14_work/net/core/dev.c
--- gr14/net/core/dev.c	2003-08-18 13:40:43.000000000 -0500
+++ gr14_work/net/core/dev.c	2003-08-28 12:56:45.000000000 -0500
@@ -630,9 +630,9 @@
 		return -EINVAL;
 
 	/*
-	 * If you need over 100 please also fix the algorithm...
+	 * If you need over 200 please also fix the algorithm...
 	 */
-	for (i = 0; i < 100; i++) {
+	for (i = 0; i < 200; i++) {
 		snprintf(buf, sizeof(buf), name, i);
 		if (!__dev_get_by_name(buf)) {
 			strcpy(dev->name, buf);
