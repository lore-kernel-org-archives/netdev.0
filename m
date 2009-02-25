From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 3/5] drivers/isdn/hisax: fix sparse warning: Should it be
	static?
Date: Thu, 26 Feb 2009 00:11:03 +0100
Message-ID: <20090225231001.5377.60524.stgit@localhost.localdomain>
References: <20090225230737.5377.31370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:42928 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758479AbZBYXLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 18:11:10 -0500
In-Reply-To: <20090225230737.5377.31370.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Move declarations to a header file.

Fix this sparse warning:
  drivers/isdn/hisax/callc.c:24:12: warning: symbol 'lli_revision' was not declared. Should it be static?
  drivers/isdn/hisax/config.c:84:12: warning: symbol 'CardType' was not declared. Should it be static?
  drivers/isdn/hisax/config.c:362:5: warning: symbol 'nrcards' was not declared. Should it be static?
  drivers/isdn/hisax/isdnl1.c:21:12: warning: symbol 'l1_revision' was not declared. Should it be static?
  drivers/isdn/hisax/isdnl2.c:22:12: warning: symbol 'l2_revision' was not declared. Should it be static?
  drivers/isdn/hisax/isdnl3.c:22:12: warning: symbol 'l3_revision' was not declared. Should it be static?
  drivers/isdn/hisax/tei.c:23:12: warning: symbol 'tei_revision' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---

How to deal with this checkpatch.pl warning?
> WARNING: CVS style keyword markers, these will _not_ be updated
> #104: FILE: drivers/isdn/hisax/isdnl1.c:25:
> +const char *l1_revision = "$Revision: 2.46.2.5 $";

 drivers/isdn/hisax/callc.c     |    1 -
 drivers/isdn/hisax/config.c    |    6 ------
 drivers/isdn/hisax/hfcscard.c  |    2 --
 drivers/isdn/hisax/hisax.h     |    9 +++++++++
 drivers/isdn/hisax/isdnl1.c    |    4 ++--
 drivers/isdn/hisax/sedlbauer.c |    2 --
 drivers/isdn/hisax/teles0.c    |    2 --
 drivers/isdn/hisax/teles3.c    |    1 -
 8 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/drivers/isdn/hisax/callc.c b/drivers/isdn/hisax/callc.c
index 7c56c44..025a20d 100644
--- a/drivers/isdn/hisax/callc.c
+++ b/drivers/isdn/hisax/callc.c
@@ -24,7 +24,6 @@
 const char *lli_revision = "$Revision: 2.59.2.4 $";
 
 extern struct IsdnCard cards[];
-extern int nrcards;
 
 static int init_b_st(struct Channel *chanp, int incoming);
 static void release_b_st(struct Channel *chanp);
diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index ded9d0b..4fab18d 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -361,12 +361,6 @@ module_param_array(io1, int, NULL, 0);
 
 int nrcards;
 
-extern const char *l1_revision;
-extern const char *l2_revision;
-extern const char *l3_revision;
-extern const char *lli_revision;
-extern const char *tei_revision;
-
 char *HiSax_getrev(const char *revision)
 {
 	char *rev;
diff --git a/drivers/isdn/hisax/hfcscard.c b/drivers/isdn/hisax/hfcscard.c
index cf08266..20d7688 100644
--- a/drivers/isdn/hisax/hfcscard.c
+++ b/drivers/isdn/hisax/hfcscard.c
@@ -16,8 +16,6 @@
 #include "hfc_2bds0.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
-
 static const char *hfcs_revision = "$Revision: 1.10.2.4 $";
 
 static irqreturn_t
diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index e8d429f..f852704 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -121,6 +121,15 @@
 
 #ifdef __KERNEL__
 
+extern const char *CardType[];
+extern int nrcards;
+
+extern const char *l1_revision;
+extern const char *l2_revision;
+extern const char *l3_revision;
+extern const char *lli_revision;
+extern const char *tei_revision;
+
 /* include l3dss1 & ni1 specific process structures, but no other defines */
 #ifdef CONFIG_HISAX_EURO
   #define l3dss1_process
diff --git a/drivers/isdn/hisax/isdnl1.c b/drivers/isdn/hisax/isdnl1.c
index a14204e..317f16f 100644
--- a/drivers/isdn/hisax/isdnl1.c
+++ b/drivers/isdn/hisax/isdnl1.c
@@ -18,12 +18,12 @@
  *
  */
 
-const char *l1_revision = "$Revision: 2.46.2.5 $";
-
 #include <linux/init.h>
 #include "hisax.h"
 #include "isdnl1.h"
 
+const char *l1_revision = "$Revision: 2.46.2.5 $";
+
 #define TIMER3_VALUE 7000
 
 static struct Fsm l1fsm_b;
diff --git a/drivers/isdn/hisax/sedlbauer.c b/drivers/isdn/hisax/sedlbauer.c
index a10dfa8..5569a52 100644
--- a/drivers/isdn/hisax/sedlbauer.c
+++ b/drivers/isdn/hisax/sedlbauer.c
@@ -48,8 +48,6 @@
 #include <linux/pci.h>
 #include <linux/isapnp.h>
 
-extern const char *CardType[];
-
 static const char *Sedlbauer_revision = "$Revision: 1.34.2.6 $";
 
 static const char *Sedlbauer_Types[] =
diff --git a/drivers/isdn/hisax/teles0.c b/drivers/isdn/hisax/teles0.c
index 4858133..3ca0bed 100644
--- a/drivers/isdn/hisax/teles0.c
+++ b/drivers/isdn/hisax/teles0.c
@@ -21,8 +21,6 @@
 #include "isac.h"
 #include "hscx.h"
 
-extern const char *CardType[];
-
 static const char *teles0_revision = "$Revision: 2.15.2.4 $";
 
 #define TELES_IOMEM_SIZE	0x400
diff --git a/drivers/isdn/hisax/teles3.c b/drivers/isdn/hisax/teles3.c
index 5dc9f1a..e9f5bb4 100644
--- a/drivers/isdn/hisax/teles3.c
+++ b/drivers/isdn/hisax/teles3.c
@@ -20,7 +20,6 @@
 #include "hscx.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
 static const char *teles3_revision = "$Revision: 2.19.2.4 $";
 
 #define byteout(addr,val) outb(val,addr)

