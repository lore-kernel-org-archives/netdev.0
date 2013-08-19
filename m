From: Martin Schwenke <martin@meltin.net>
Subject: [PATCH] ip: Add label option to ip monitor
Date: Mon, 19 Aug 2013 15:43:30 +1000
Message-ID: <20130819154330.77c29d55@martins.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44370 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750714Ab3HSFnf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 01:43:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefix labelling is currently only activated when monitoring "all"
objects.  However, the output can still be confusing when monitoring
more than 1 object, so add an option to always print prefix labels.

Signed-off-by: Martin Schwenke <martin@meltin.net>
---
Really a reply to http://www.spinics.net/lists/netdev/msg246739.html


 doc/ip-cref.tex |   16 +++++++++-------
 ip/ipmonitor.c  |    4 +++-
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index d8fed66..f062b3a 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -2542,13 +2542,15 @@ Namely,
 the \verb|monitor| command is the first in the command line and then
 the object list follows:
 \begin{verbatim}
-  ip monitor [ file FILE ] [ all | OBJECT-LIST ]
-\end{verbatim}
-\verb|OBJECT-LIST| is the list of object types that we want to monitor.
-It may contain \verb|link|, \verb|address| and \verb|route|.
-If no \verb|file| argument is given, \verb|ip| opens RTNETLINK,
-listens on it and dumps state changes in the format described
-in previous sections.
+  ip monitor [ file FILE ] [ all | OBJECT-LIST ] [ label ]
+\end{verbatim}
+\verb|OBJECT-LIST| is the list of object types that we want to
+monitor.  It may contain \verb|link|, \verb|address| and \verb|route|.
+Specifying \verb|label| indicates that output lines should be labelled
+with the type of object being printed --- this happens by default if
+\verb|all| is specified.  If no \verb|file| argument is given,
+\verb|ip| opens RTNETLINK, listens on it and dumps state changes in
+the format described in previous sections.
 
 If a file name is given, it does not listen on RTNETLINK,
 but opens the file containing RTNETLINK messages saved in binary format
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 86c473e..4895390 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -29,7 +29,7 @@ int prefix_banner;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ] [ FILE ]\n");
+	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ] [ FILE ] [ label ]\n");
 	fprintf(stderr, "LISTofOBJECTS := link | address | route | mroute | prefix |\n");
 	fprintf(stderr, "                 neigh | netconf\n");
 	fprintf(stderr, "FILE := file FILENAME\n");
@@ -157,6 +157,8 @@ int do_ipmonitor(int argc, char **argv)
 		if (matches(*argv, "file") == 0) {
 			NEXT_ARG();
 			file = *argv;
+		} else if (matches(*argv, "label") == 0) {
+			prefix_banner = 1;
 		} else if (matches(*argv, "link") == 0) {
 			llink=1;
 			groups = 0;
-- 
1.7.10.4
