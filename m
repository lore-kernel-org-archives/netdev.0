From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH v2 net-next 1/2] ptp: Add a command line option in testptp to set a specific PTP time
Date: Wed, 26 Mar 2014 08:16:02 +0100
Message-ID: <4fe325c5-dad2-4619-8e40-a1d22de83315@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Richard Cochran <richardcochran@gmail.com>,
	Manfred Rudigier <manfred.rudigier@omicron.at>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:57013 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751951AbaCZHQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 03:16:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manfred Rudigier <manfred.rudigier@omicron.at>

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---

Changes for v2:
- Added Richard's Acked-by

 Documentation/ptp/testptp.c |   20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index e9eaee6..13bddd5 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -131,7 +131,8 @@ static void usage(char *progname)
 		" -P val     enable or disable (val=1|0) the system clock PPS\n"
 		" -s         set the ptp clock time from the system time\n"
 		" -S         set the system time from the ptp clock time\n"
-		" -t val     shift the ptp clock time by 'val' seconds\n",
+		" -t val     shift the ptp clock time by 'val' seconds\n"
+		" -T val     set the ptp clock time to 'val' seconds\n",
 		progname);
 }
 
@@ -172,6 +173,7 @@ int main(int argc, char *argv[])
 	int perout = -1;
 	int pin_index = -1, pin_func;
 	int pps = -1;
+	int seconds = 0;
 	int settime = 0;
 
 	int64_t t1, t2, tp;
@@ -179,7 +181,7 @@ int main(int argc, char *argv[])
 
 	progname = strrchr(argv[0], '/');
 	progname = progname ? 1+progname : argv[0];
-	while (EOF != (c = getopt(argc, argv, "a:A:cd:e:f:ghi:k:lL:p:P:sSt:v"))) {
+	while (EOF != (c = getopt(argc, argv, "a:A:cd:e:f:ghi:k:lL:p:P:sSt:T:v"))) {
 		switch (c) {
 		case 'a':
 			oneshot = atoi(optarg);
@@ -234,6 +236,10 @@ int main(int argc, char *argv[])
 		case 't':
 			adjtime = atoi(optarg);
 			break;
+		case 'T':
+			settime = 3;
+			seconds = atoi(optarg);
+			break;
 		case 'h':
 			usage(progname);
 			return 0;
@@ -326,6 +332,16 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	if (settime == 3) {
+		ts.tv_sec = seconds;
+		ts.tv_nsec = 0;
+		if (clock_settime(clkid, &ts)) {
+			perror("clock_settime");
+		} else {
+			puts("set time okay");
+		}
+	}
+
 	if (extts) {
 		memset(&extts_request, 0, sizeof(extts_request));
 		extts_request.index = index;
-- 
1.7.9.5
