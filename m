From: jamal <hadi@cyberus.ca>
Subject: [PATCH 1/3] [TC/U32] Restore old output of u32
Date: Sun, 20 Apr 2008 10:45:44 -0400
Message-ID: <1208702744.12249.51.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Iro1/DzynwtPyEyN4D9J"
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.251]:22659 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbYDTOpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 10:45:47 -0400
Received: by hs-out-0708.google.com with SMTP id 4so604455hsl.5
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 07:45:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Iro1/DzynwtPyEyN4D9J
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


This is a repeat of the first one i sent already..

cheers,
jamal

--=-Iro1/DzynwtPyEyN4D9J
Content-Disposition: attachment; filename=0001-TC-U32-Restore-old-output-of-u32.txt
Content-Type: text/plain; name=0001-TC-U32-Restore-old-output-of-u32.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit

[PATCH 1/3] [TC/U32] Restore old output of u32
My scripts broke because of the new change that beautifies output.
Restore old output as default and have user enter -cooked if they
want beautified output...

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
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
-- 
1.4.4.1.gaed4


--=-Iro1/DzynwtPyEyN4D9J--

