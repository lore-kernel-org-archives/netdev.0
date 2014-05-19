From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] isdn: hisax: l3dss1.c:  Fix for possible null pointer dereference
Date: Mon, 19 May 2014 23:24:22 +0200
Message-ID: <1400534662-5729-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is otherwise a risk of a possible null pointer dereference.

Was largely found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/isdn/hisax/l3dss1.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/hisax/l3dss1.c b/drivers/isdn/hisax/l3dss1.c
index cda7006..9ea7377 100644
--- a/drivers/isdn/hisax/l3dss1.c
+++ b/drivers/isdn/hisax/l3dss1.c
@@ -2203,13 +2203,14 @@ static int l3dss1_cmd_global(struct PStack *st, isdn_ctrl *ic)
 			memcpy(p, ic->parm.dss1_io.data, ic->parm.dss1_io.datalen); /* copy data */
 			l = (p - temp) + ic->parm.dss1_io.datalen; /* total length */
 
-			if (ic->parm.dss1_io.timeout > 0)
-				if (!(pc = dss1_new_l3_process(st, -1)))
-				{ free_invoke_id(st, id);
+			if (ic->parm.dss1_io.timeout > 0) {
+				if (!(pc = dss1_new_l3_process(st, -1))) {
+					free_invoke_id(st, id);
 					return (-2);
 				}
-			pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
-			pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
+				pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
+				pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
+			}
 
 			if (!(skb = l3_alloc_skb(l)))
 			{ free_invoke_id(st, id);
-- 
1.7.10.4
