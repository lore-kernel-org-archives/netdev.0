From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 1/3] iproute2 and xfrm
Date: Thu, 15 Jul 2004 15:02:14 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715150214.6067a457@localhost>
References: <20040703094632.GA14235@gondor.apana.org.au>
	<20040705160500.208591b5@localhost>
	<20040706140550.2d483dc8@dell_ss3.pdx.osdl.net>
	<20040707130950.0112edf6@localhost>
	<20040707140533.41c66c03@localhost>
	<20040707155602.4698121a@localhost>
	<20040707110315.GA26100@gondor.apana.org.au>
	<20040709125100.3edce4e9@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040709125100.3edce4e9@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This patch is minor fix for iproute2.
It consists of two small ChangeSets.

Regards,


ChangeSet@1.55, 2004-07-12 19:58:53+09:00, nakam@linux-ipv6.org
  fix usage message for ipxfrm.

diff -Nru a/ip/xfrm_policy.c b/ip/xfrm_policy.c
--- a/ip/xfrm_policy.c	2004-07-14 16:35:49 +09:00
+++ b/ip/xfrm_policy.c	2004-07-14 16:35:49 +09:00
@@ -55,7 +55,6 @@
 {
 	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR sel SELECTOR [ index INDEX ] \n");
 	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ LIMIT-LIST ] [ TMPL-LIST ]\n");
-	fprintf(stderr, "        [ sel SELECTOR | index INDEX ] [ TMPL-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ sel SELECTOR | index INDEX ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy { flush | list } [ dir DIR ] [ sel SELECTOR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ action ACTION ] [ priority PRIORITY ]\n");
@@ -75,7 +74,7 @@
 	fprintf(stderr, "LIMIT := [ [time-soft|time-hard|time-use-soft|time-use-hard] SECONDS ] |\n");
 	fprintf(stderr, "         [ [byte-soft|byte-hard] SIZE ] | [ [packet-soft|packet-hard] NUMBER ]\n");
 
-	fprintf(stderr, "TMPL-LIST := [ TMPL-LIST ] | [ tmpl TMPL ] | [ tmpl remain ](change only)\n");
+	fprintf(stderr, "TMPL-LIST := [ TMPL-LIST ] | [ tmpl TMPL ]\n");
 	fprintf(stderr, "TMPL := ID [ mode MODE ] [ reqid REQID ] [ level LEVEL ]\n");
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
 


ChangeSet@1.54, 2004-07-12 19:57:50+09:00, nakam@linux-ipv6.org
  fix command line option to understand "ip x p" and "ip x s".

diff -Nru a/ip/ipxfrm.c b/ip/ipxfrm.c
--- a/ip/ipxfrm.c	2004-07-14 16:35:49 +09:00
+++ b/ip/ipxfrm.c	2004-07-14 16:35:49 +09:00
@@ -793,13 +793,12 @@
 	if (argc < 1)
 		usage();
 
-	if (strcmp(*argv, "state") == 0 ||
-	    strcmp(*argv, "sa") == 0) {
+	if (matches(*argv, "state") == 0 ||
+	    matches(*argv, "sa") == 0) {
 		return do_xfrm_state(argc-1, argv+1);
-	} else if (strcmp(*argv, "policy") == 0 ||
-		   strcmp(*argv, "pol") == 0) {
+	} else if (matches(*argv, "policy") == 0)
 		return do_xfrm_policy(argc-1, argv+1);
-	} else if (strcmp(*argv, "help") == 0) {
+	else if (matches(*argv, "help") == 0) {
 		usage();
 		fprintf(stderr, "xfrm Object \"%s\" is unknown.\n", *argv);
 		exit(-1);



-- 
Masahide NAKAMURA
