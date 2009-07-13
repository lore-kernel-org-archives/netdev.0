From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/4] drivers/net/wireless: adjust NULL test
Date: Mon, 13 Jul 2009 22:44:08 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907132243420.12374@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757186AbZGMUoN@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Clearly bss cannot be NULL at the point of the test.  The just allocated
bss->bss is more appropriate to test at this point.

A simplified version of the semantic match that finds this problem is as
follows: (http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@r@
expression x,E,E1;
identifier f,l;
position p1,p2;
@@

*x@p1->f = E1;
... when != x = E
    when != goto l;
(
*x@p2 == NULL
|
*x@p2 != NULL
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/iwmc3200wifi/rx.c         |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwmc3200wifi/rx.c b/drivers/net/wireless/iwmc3200wifi/rx.c
index 3909477..453fcb2 100644
--- a/drivers/net/wireless/iwmc3200wifi/rx.c
+++ b/drivers/net/wireless/iwmc3200wifi/rx.c
@@ -698,7 +698,7 @@ static int iwm_mlme_update_bss_table(struct iwm_priv *iwm, u8 *buf,
 	}
 
 	bss->bss = kzalloc(bss_len, GFP_KERNEL);
-	if (!bss) {
+	if (!bss->bss) {
 		kfree(bss);
 		IWM_ERR(iwm, "Couldn't allocate bss\n");
 		return -ENOMEM;
