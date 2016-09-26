From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/5] ISDN-Gigaset: Use kmalloc_array() in two functions
Date: Mon, 26 Sep 2016 17:38:49 +0200
Message-ID: <4fb300f1-ff02-7983-464f-fcbca5919dac@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 25 Sep 2016 22:22:04 +0200

* Multiplications for the size determination of memory allocations
  indicated that array data structures should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of a data structure by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/gigaset/common.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 7c78144..cecbb6a 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -709,8 +709,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 
 	cs->mode = M_UNKNOWN;
 	cs->mstate = MS_UNINITIALIZED;
-
-	cs->bcs = kmalloc(channels * sizeof(struct bc_state), GFP_KERNEL);
+	cs->bcs = kmalloc_array(channels, sizeof(*cs->bcs), GFP_KERNEL);
 	cs->inbuf = kmalloc(sizeof(struct inbuf_t), GFP_KERNEL);
 	if (!cs->bcs || !cs->inbuf) {
 		pr_err("out of memory\n");
@@ -1089,8 +1088,7 @@ struct gigaset_driver *gigaset_initdriver(unsigned minor, unsigned minors,
 	drv->ops = ops;
 	drv->owner = owner;
 	INIT_LIST_HEAD(&drv->list);
-
-	drv->cs = kmalloc(minors * sizeof *drv->cs, GFP_KERNEL);
+	drv->cs = kmalloc_array(minors, sizeof(*drv->cs), GFP_KERNEL);
 	if (!drv->cs)
 		goto error;
 
-- 
2.10.0
