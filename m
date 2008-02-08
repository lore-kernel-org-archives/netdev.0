From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/2][SCTP]: Use snmp_fold_field instead of a homebrew analogue.
Date: Fri, 08 Feb 2008 14:04:55 +0300
Message-ID: <47AC3757.6020405@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	lksctp-developers@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40775 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827AbYBHLFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 06:05:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCPT already depends in INET, so this doesn't create additional
dependencies.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/sctp/proc.c |   23 ++---------------------
 1 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 2499732..974350b 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -38,6 +38,7 @@
 #include <linux/seq_file.h>
 #include <linux/init.h>
 #include <net/sctp/sctp.h>
+#include <net/ip.h> /* for snmp_fold_field */
 
 static struct snmp_mib sctp_snmp_list[] = {
 	SNMP_MIB_ITEM("SctpCurrEstab", SCTP_MIB_CURRESTAB),
@@ -75,26 +76,6 @@ static struct snmp_mib sctp_snmp_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
-/* Return the current value of a particular entry in the mib by adding its
- * per cpu counters.
- */
-static unsigned long
-fold_field(void *mib[], int nr)
-{
-	unsigned long res = 0;
-	int i;
-
-	for_each_possible_cpu(i) {
-		res +=
-		    *((unsigned long *) (((void *) per_cpu_ptr(mib[0], i)) +
-					 sizeof (unsigned long) * nr));
-		res +=
-		    *((unsigned long *) (((void *) per_cpu_ptr(mib[1], i)) +
-					 sizeof (unsigned long) * nr));
-	}
-	return res;
-}
-
 /* Display sctp snmp mib statistics(/proc/net/sctp/snmp). */
 static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 {
@@ -102,7 +83,7 @@ static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 
 	for (i = 0; sctp_snmp_list[i].name != NULL; i++)
 		seq_printf(seq, "%-32s\t%ld\n", sctp_snmp_list[i].name,
-			   fold_field((void **)sctp_statistics,
+			   snmp_fold_field((void **)sctp_statistics,
 				      sctp_snmp_list[i].entry));
 
 	return 0;
-- 
1.5.3.4

