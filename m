From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 14/16] drivers/ssb/main.c: use WARN
Date: Sat,  3 Nov 2012 11:58:35 +0100
Message-ID: <1351940317-14812-15-git-send-email-Julia.Lawall@lip6.fr>
References: <1351940317-14812-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Buesch <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351940317-14812-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Use WARN rather than printk followed by WARN_ON(1), for conciseness.

A simplified version of the semantic patch that makes this transformation
is as follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression list es;
@@

-printk(
+WARN(1,
  es);
-WARN_ON(1);
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/ssb/main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index df0f145..519688d 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -1118,8 +1118,7 @@ static u32 ssb_tmslow_reject_bitmask(struct ssb_device *dev)
 	case SSB_IDLOW_SSBREV_27:     /* same here */
 		return SSB_TMSLOW_REJECT;	/* this is a guess */
 	default:
-		printk(KERN_INFO "ssb: Backplane Revision 0x%.8X\n", rev);
-		WARN_ON(1);
+		WARN(1, KERN_INFO "ssb: Backplane Revision 0x%.8X\n", rev);
 	}
 	return (SSB_TMSLOW_REJECT | SSB_TMSLOW_REJECT_23);
 }
