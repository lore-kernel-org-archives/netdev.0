From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute: make ss --help output to stdout
Date: Mon, 7 Dec 2009 13:12:36 +0100
Message-ID: <20091207121236.GA15104@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, 545008@bugs.debian.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:60289 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755336AbZLGML2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 07:11:28 -0500
Received: from ipb1.telenor.se (195.54.127.164) by proxy3.bredband.net (7.3.140.3)
        id 4AD3E1BA01760F41 for netdev@vger.kernel.org; Mon, 7 Dec 2009 13:11:31 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Palfrader said in http://bugs.debian.org/545008 that
"--help output, if explicitly requested, should go to stdout, not stderr."
which this patch fixes.

Additionally, the exit code was adjusted to success if help was
explicitly requested.

(Syntax error still outputs to stderr and has the same exit code.)

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff --git a/misc/ss.c b/misc/ss.c
index ac7f411..8a9663c 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2331,12 +2331,9 @@ int print_summary(void)
 	return 0;
 }
 
-
-static void usage(void) __attribute__((noreturn));
-
-static void usage(void)
+static void _usage(FILE *dest)
 {
-	fprintf(stderr,
+	fprintf(dest,
 "Usage: ss [ OPTIONS ]\n"
 "       ss [ OPTIONS ] [ FILTER ]\n"
 "   -h, --help		this message\n"
@@ -2368,6 +2365,19 @@ static void usage(void)
 "   -F, --filter=FILE   read filter information from FILE\n"
 "       FILTER := [ state TCP-STATE ] [ EXPRESSION ]\n"
 		);
+}
+
+static void help(void) __attribute__((noreturn));
+static void help(void)
+{
+	_usage(stdout);
+	exit(0);
+}
+
+static void usage(void) __attribute__((noreturn));
+static void usage(void)
+{
+	_usage(stderr);
 	exit(-1);
 }
 
@@ -2514,7 +2524,7 @@ int main(int argc, char *argv[])
 			else if (strcmp(optarg, "netlink") == 0)
 				preferred_family = AF_NETLINK;
 			else if (strcmp(optarg, "help") == 0)
-				usage();
+				help();
 			else {
 				fprintf(stderr, "ss: \"%s\" is invalid family\n", optarg);
 				usage();
@@ -2596,6 +2606,7 @@ int main(int argc, char *argv[])
 			exit(0);
 		case 'h':
 		case '?':
+			help();
 		default:
 			usage();
 		}
