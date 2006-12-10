From: Hasso Tepper <hasso@estpak.ee>
Subject: [IPROUTE2 PATCH] Fixes for tc help commands
Date: Sun, 10 Dec 2006 16:33:05 +0200
Message-ID: <200612101633.05306.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_hqBfFAD9Q+pOJWP"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hax.kala.ee ([194.126.124.39]:43733 "HELO hax.kala.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1760803AbWLJOdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Dec 2006 09:33:10 -0500
To: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_hqBfFAD9Q+pOJWP
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

* "tc [class|qdisc|filter] get" doesn't exist, remove it from inline help.

* Add "replace" to "tc [class|filter] get" inline help.

* Fix "tc [class|qdisc|filter] help" output:

  ~$ tc class help
  [snip]
  Command "help" is unknown, try "tc class help".
  ~$



with my best wishes,

-- 
Hasso Tepper
Elion Enterprises Ltd. [AS3249]
Data Communication Network Administrator

--Boundary-00=_hqBfFAD9Q+pOJWP
Content-Type: text/x-diff;
  charset="iso-8859-15";
  name="iproute2-tc-help.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="iproute2-tc-help.patch"

diff --git a/tc/tc_class.c b/tc/tc_class.c
index fb0b6b2..774497a 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -29,7 +29,7 @@ static void usage(void);
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: tc class [ add | del | change | get ] dev STRING\n");
+	fprintf(stderr, "Usage: tc class [ add | del | change | replace | show ] dev STRING\n");
 	fprintf(stderr, "       [ classid CLASSID ] [ root | parent CLASSID ]\n");
 	fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
 	fprintf(stderr, "\n");
@@ -315,8 +315,10 @@ int do_class(int argc, char **argv)
 	if (matches(*argv, "list") == 0 || matches(*argv, "show") == 0
 	    || matches(*argv, "lst") == 0)
 		return tc_class_list(argc-1, argv+1);
-	if (matches(*argv, "help") == 0)
+	if (matches(*argv, "help") == 0) {
 		usage();
+		return 0;
+	}
 	fprintf(stderr, "Command \"%s\" is unknown, try \"tc class help\".\n", *argv);
 	return -1;
 }
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 3e102cd..008f0c1 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -32,7 +32,7 @@ static void usage(void);
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: tc filter [ add | del | change | get ] dev STRING\n");
+	fprintf(stderr, "Usage: tc filter [ add | del | change | replace | show ] dev STRING\n");
 	fprintf(stderr, "       [ pref PRIO ] [ protocol PROTO ]\n");
 	fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
 	fprintf(stderr, "       [ root | classid CLASSID ] [ handle FILTERID ]\n");
@@ -363,8 +363,10 @@ int do_filter(int argc, char **argv)
 	if (matches(*argv, "list") == 0 || matches(*argv, "show") == 0
 	    || matches(*argv, "lst") == 0)
 		return tc_filter_list(argc-1, argv+1);
-	if (matches(*argv, "help") == 0)
+	if (matches(*argv, "help") == 0) {
 		usage();
+		return 0;
+        }
 	fprintf(stderr, "Command \"%s\" is unknown, try \"tc filter help\".\n", *argv);
 	return -1;
 }
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 0b16923..1256f07 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -29,7 +29,7 @@ static int usage(void);
 
 static int usage(void)
 {
-	fprintf(stderr, "Usage: tc qdisc [ add | del | replace | change | get ] dev STRING\n");
+	fprintf(stderr, "Usage: tc qdisc [ add | del | replace | change | show ] dev STRING\n");
 	fprintf(stderr, "       [ handle QHANDLE ] [ root | ingress | parent CLASSID ]\n");
 	fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
 	fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
@@ -316,8 +316,10 @@ int do_qdisc(int argc, char **argv)
 	if (matches(*argv, "list") == 0 || matches(*argv, "show") == 0
 	    || matches(*argv, "lst") == 0)
 		return tc_qdisc_list(argc-1, argv+1);
-	if (matches(*argv, "help") == 0)
+	if (matches(*argv, "help") == 0) {
 		usage();
+		return 0;
+        }
 	fprintf(stderr, "Command \"%s\" is unknown, try \"tc qdisc help\".\n", *argv);
 	return -1;
 }

--Boundary-00=_hqBfFAD9Q+pOJWP--
