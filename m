From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/5] ISDN-CAPI: Adjust checks for null pointers in four
 functions
Date: Sun, 25 Sep 2016 13:14:07 +0200
Message-ID: <20395fb4-0899-eb2a-c0ce-cca8bf6fd6f0@users.sourceforge.net>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 25 Sep 2016 12:26:38 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script "checkpatch.pl" can point information out like the following.

Comparison to NULL could be written !…

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/capi/capidrv.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index bd614e3..83f756d 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -334,8 +334,7 @@ static capidrv_plci *new_plci(capidrv_contr *card, int chan)
 	capidrv_plci *plcip;
 
 	plcip = kzalloc(sizeof(capidrv_plci), GFP_ATOMIC);
-
-	if (plcip == NULL)
+	if (!plcip)
 		return NULL;
 
 	plcip->state = ST_PLCI_NONE;
@@ -403,8 +402,7 @@ static inline capidrv_ncci *new_ncci(capidrv_contr *card,
 	capidrv_ncci *nccip;
 
 	nccip = kzalloc(sizeof(capidrv_ncci), GFP_ATOMIC);
-
-	if (nccip == NULL)
+	if (!nccip)
 		return NULL;
 
 	nccip->ncci = ncci;
@@ -757,7 +755,7 @@ static inline int new_bchan(capidrv_contr *card)
 {
 	int i;
 	for (i = 0; i < card->nbchan; i++) {
-		if (card->bchans[i].plcip == NULL) {
+		if (!card->bchans[i].plcip) {
 			card->bchans[i].disconnecting = 0;
 			return i;
 		}
@@ -2192,7 +2190,7 @@ static void enable_dchannel_trace(capidrv_contr *card)
 		       card->name, errcode);
 		return;
 	}
-	if (strstr(manufacturer, "AVM") == NULL) {
+	if (!strstr(manufacturer, "AVM")) {
 		printk(KERN_ERR "%s: not from AVM, no d-channel trace possible (%s)\n",
 		       card->name, manufacturer);
 		return;
-- 
2.10.0

