From: jamal <hadi@cyberus.ca>
Subject: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Thu, 17 Apr 2008 16:35:39 -0400
Message-ID: <1208464539.15888.22.camel@localhost>
References: <20080417103858.0075236b@extreme>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ZkFvm5F/89inNSZmZqH2"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.245]:65250 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398AbYDQUfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 16:35:43 -0400
Received: by hs-out-0708.google.com with SMTP id 4so178813hsl.5
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 13:35:42 -0700 (PDT)
In-Reply-To: <20080417103858.0075236b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZkFvm5F/89inNSZmZqH2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Quick test:
My u32 scripts broke. It seems that i need to pass -raw to get same
output as before; i am sure this will break anyone else depending on old
output.
I have introduced a "cooked" mode instead to output new format.

cheers,
jamal


--=-ZkFvm5F/89inNSZmZqH2
Content-Disposition: attachment; filename=u32_p
Content-Type: text/plain; name=u32_p; charset=us-ascii
Content-Transfer-Encoding: 7bit

[TC] Restore old output of u32 on output

My scripts broke because of the new change that beautifies output.
Restore old output as default and have user enter -cooked if they
want beautified output...

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit d37302089fbc4c4b5374372e587331ab431b6ae3
tree 05403c85aa727ae9ae939ce8978c4b43b0c478b6
parent 727d468e54bd903b91536e28435a43f73b023222
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 17 Apr 2008 16:32:46 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 17 Apr 2008 16:32:46 -0400

 include/utils.h |    1 +
 tc/f_u32.c      |    2 +-
 tc/tc.c         |    3 +++
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 5daed6b..3a7312c 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -13,6 +13,7 @@ extern int preferred_family;
 extern int show_stats;
 extern int show_details;
 extern int show_raw;
+extern int show_cooked;
 extern int resolve_hosts;
 extern int oneline;
 extern int timestamp;
diff --git a/tc/f_u32.c b/tc/f_u32.c
index 7e4d56c..db492fe 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -793,7 +793,7 @@ static void show_key(FILE *f, const struct tc_u32_key *key)
 {
 	char abuf[256];
 
-	if (show_raw)
+	if (!show_cooked)
 		goto raw;
 
 	switch (key->off) {
diff --git a/tc/tc.c b/tc/tc.c
index 6126c71..06058fb 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -33,6 +33,7 @@
 int show_stats = 0;
 int show_details = 0;
 int show_raw = 0;
+int show_cooked = 0;
 int resolve_hosts = 0;
 int use_iec = 0;
 int force = 0;
@@ -273,6 +274,8 @@ int main(int argc, char **argv)
 			++show_details;
 		} else if (matches(argv[1], "-raw") == 0) {
 			++show_raw;
+		} else if (matches(argv[1], "-cooked") == 0) {
+			++show_cooked;
 		} else if (matches(argv[1], "-Version") == 0) {
 			printf("tc utility, iproute2-ss%s\n", SNAPSHOT);
 			return 0;

--=-ZkFvm5F/89inNSZmZqH2--

