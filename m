From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] [TC U32] Fix input parsing to support more than 9 flow id's
	correctly
Date: Tue, 12 Feb 2008 11:37:25 -0800
Message-ID: <20080212193725.4137.62287.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42045 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752745AbYBMCcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 21:32:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Using strtoul with a base of 16 converts flowid 10 into 0x10, which makes
it flowid 16.  This is interpreted by the kernel incorrectly, and causes
traffic flows above 9 to be classified into band 0 on multiband qdiscs.
This changes the base to 10, which will correctly parse input into the
proper hexidecimal value.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 tc/tc_util.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index cdbae42..a277eac 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -65,7 +65,7 @@ int get_tc_classid(__u32 *h, const char *str)
 	maj = TC_H_UNSPEC;
 	if (strcmp(str, "none") == 0)
 		goto ok;
-	maj = strtoul(str, &p, 16);
+	maj = strtoul(str, &p, 10);
 	if (p == str) {
 		maj = 0;
 		if (*p != ':')
@@ -76,7 +76,7 @@ int get_tc_classid(__u32 *h, const char *str)
 			return -1;
 		maj <<= 16;
 		str = p+1;
-		min = strtoul(str, &p, 16);
+		min = strtoul(str, &p, 10);
 		if (*p != 0)
 			return -1;
 		if (min >= (1<<16))

