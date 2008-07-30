From: Alan Cox <alan@letsannoyjonsmirl.ukuu.org.uk>
Subject: [PATCH] skfp: Fix warning spew on 64bit
Date: Wed, 30 Jul 2008 16:28:27 +0100
Message-ID: <20080730162827.25007152@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:35267 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750962AbYG3Pph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 11:45:37 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by lxorguk.ukuu.org.uk (8.14.2/8.14.2) with ESMTP id m6UFSROX021827
	for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 16:28:28 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skfp spews warnings in 64bit mode. The actual problem is using int for pointer
differences. True the offsets are int sized but the compiler doesn't know that

Signed-off-by: Alan Cox <alan@letsannoyjonsmirl.ukuu.org.uk>

---
  "Standards committees don't like hashing.  It looks complicated and
        insufficiently deterministic on an overhead projector."
						- Vern Schryver


 drivers/net/skfp/ess.c |    6 +++---
 drivers/net/skfp/pmf.c |   16 ++++++++--------
 2 files changed, 11 insertions(+), 11 deletions(-)


diff --git a/drivers/net/skfp/ess.c b/drivers/net/skfp/ess.c
index 889f987..e7eba07 100644
--- a/drivers/net/skfp/ess.c
+++ b/drivers/net/skfp/ess.c
@@ -510,7 +510,7 @@ static void ess_send_response(struct s_smc *smc, struct smt_header *sm,
 	chg->path.para.p_type = SMT_P320B ;
 	chg->path.para.p_len = sizeof(struct smt_p_320b) - PARA_LEN ;
 	chg->path.mib_index = SBAPATHINDEX ;
-	chg->path.path_pad = (u_short)NULL ;
+	chg->path.path_pad = (u_short)0 ;
 	chg->path.path_index = PRIMARY_RING ;
 
 	/* set P320F */
@@ -606,7 +606,7 @@ static void ess_send_alc_req(struct s_smc *smc)
 	req->path.para.p_type = SMT_P320B ;
 	req->path.para.p_len = sizeof(struct smt_p_320b) - PARA_LEN ;
 	req->path.mib_index = SBAPATHINDEX ;
-	req->path.path_pad = (u_short)NULL ;
+	req->path.path_pad = (u_short)0 ;
 	req->path.path_index = PRIMARY_RING ;
 
 	/* set P0017 */
@@ -636,7 +636,7 @@ static void ess_send_alc_req(struct s_smc *smc)
 	/* set P19 */
 	req->a_addr.para.p_type = SMT_P0019 ;
 	req->a_addr.para.p_len = sizeof(struct smt_p_0019) - PARA_LEN ;
-	req->a_addr.sba_pad = (u_short)NULL ;
+	req->a_addr.sba_pad = (u_short)0;
 	req->a_addr.alloc_addr = null_addr ;
 
 	/* set P1A */
diff --git a/drivers/net/skfp/pmf.c b/drivers/net/skfp/pmf.c
index ea85de9..a3e6916 100644
--- a/drivers/net/skfp/pmf.c
+++ b/drivers/net/skfp/pmf.c
@@ -44,17 +44,17 @@ static SMbuf *smt_build_pmf_response(struct s_smc *smc, struct smt_header *req,
 				     int set, int local);
 static int port_to_mib(struct s_smc *smc, int p);
 
-#define MOFFSS(e)	((int)&(((struct fddi_mib *)0)->e))
-#define MOFFSA(e)	((int) (((struct fddi_mib *)0)->e))
+#define MOFFSS(e)	((unsigned long)&(((struct fddi_mib *)0)->e))
+#define MOFFSA(e)	((unsigned long) (((struct fddi_mib *)0)->e))
 
-#define MOFFMS(e)	((int)&(((struct fddi_mib_m *)0)->e))
-#define MOFFMA(e)	((int) (((struct fddi_mib_m *)0)->e))
+#define MOFFMS(e)	((unsigned long)&(((struct fddi_mib_m *)0)->e))
+#define MOFFMA(e)	((unsigned long) (((struct fddi_mib_m *)0)->e))
 
-#define MOFFAS(e)	((int)&(((struct fddi_mib_a *)0)->e))
-#define MOFFAA(e)	((int) (((struct fddi_mib_a *)0)->e))
+#define MOFFAS(e)	((unsigned long)&(((struct fddi_mib_a *)0)->e))
+#define MOFFAA(e)	((unsigned long) (((struct fddi_mib_a *)0)->e))
 
-#define MOFFPS(e)	((int)&(((struct fddi_mib_p *)0)->e))
-#define MOFFPA(e)	((int) (((struct fddi_mib_p *)0)->e))
+#define MOFFPS(e)	((unsigned long)&(((struct fddi_mib_p *)0)->e))
+#define MOFFPA(e)	((unsigned long) (((struct fddi_mib_p *)0)->e))
 
 
 #define AC_G	0x01		/* Get */
