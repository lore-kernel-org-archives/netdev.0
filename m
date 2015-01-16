From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/5] s390/net: Delete useless checks before function calls
Date: Fri, 16 Jan 2015 14:05:46 +0100
Message-ID: <1421413549-56937-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1421413549-56937-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Markus Elfring <elfring@users.sourceforge.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:33320 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227AbbAPNGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:06:23 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 16 Jan 2015 13:06:22 -0000
In-Reply-To: <1421413549-56937-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>

The function debug_unregister() tests whether its argument is
NULL and then returns immediately. Thus the test around the call
is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>

---
 drivers/s390/net/claw.c    | 6 ++----
 drivers/s390/net/lcs.c     | 6 ++----
 drivers/s390/net/netiucv.c | 9 +++------
 3 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index 213e54e..d609ca0 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -109,10 +109,8 @@ static debug_info_t *claw_dbf_trace;
 static void
 claw_unregister_debug_facility(void)
 {
-	if (claw_dbf_setup)
-		debug_unregister(claw_dbf_setup);
-	if (claw_dbf_trace)
-		debug_unregister(claw_dbf_trace);
+	debug_unregister(claw_dbf_setup);
+	debug_unregister(claw_dbf_trace);
 }
 
 static int
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 92190aa..00b7d9c 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -88,10 +88,8 @@ static debug_info_t *lcs_dbf_trace;
 static void
 lcs_unregister_debug_facility(void)
 {
-	if (lcs_dbf_setup)
-		debug_unregister(lcs_dbf_setup);
-	if (lcs_dbf_trace)
-		debug_unregister(lcs_dbf_trace);
+	debug_unregister(lcs_dbf_setup);
+	debug_unregister(lcs_dbf_trace);
 }
 
 static int
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 7e91f54..33f7040 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -487,12 +487,9 @@ DEFINE_PER_CPU(char[256], iucv_dbf_txt_buf);
 
 static void iucv_unregister_dbf_views(void)
 {
-	if (iucv_dbf_setup)
-		debug_unregister(iucv_dbf_setup);
-	if (iucv_dbf_data)
-		debug_unregister(iucv_dbf_data);
-	if (iucv_dbf_trace)
-		debug_unregister(iucv_dbf_trace);
+	debug_unregister(iucv_dbf_setup);
+	debug_unregister(iucv_dbf_data);
+	debug_unregister(iucv_dbf_trace);
 }
 static int iucv_register_dbf_views(void)
 {
-- 
2.1.4
