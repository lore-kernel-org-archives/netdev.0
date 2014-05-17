From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] isdn: hisax: l3ni1.c:  Fix for possible null pointer dereference
Date: Sat, 17 May 2014 19:19:40 +0200
Message-ID: <1400347180-25553-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
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
 drivers/isdn/hisax/l3ni1.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/l3ni1.c b/drivers/isdn/hisax/l3ni1.c
index 0df6691..367b9d6 100644
--- a/drivers/isdn/hisax/l3ni1.c
+++ b/drivers/isdn/hisax/l3ni1.c
@@ -2064,8 +2064,12 @@ static int l3ni1_cmd_global(struct PStack *st, isdn_ctrl *ic)
 				{ free_invoke_id(st, id);
 					return (-2);
 				}
-			pc->prot.ni1.ll_id = ic->parm.ni1_io.ll_id; /* remember id */
-			pc->prot.ni1.proc = ic->parm.ni1_io.proc; /* and procedure */
+
+			if (pc)
+			{
+				pc->prot.ni1.ll_id = ic->parm.ni1_io.ll_id; /* remember id */
+				pc->prot.ni1.proc = ic->parm.ni1_io.proc; /* and procedure */
+			}
 
 			if (!(skb = l3_alloc_skb(l)))
 			{ free_invoke_id(st, id);
-- 
1.7.10.4
