From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/4] ATM-ZeitNet: Replace one kzalloc() call by kcalloc()
Date: Sat, 10 Sep 2016 11:02:44 +0200
Message-ID: <c4ad47eb-ca16-a862-ee0b-fdc555fed0f2@users.sourceforge.net>
References: <0b5381e1-d725-0706-1cc0-188df6c201f2@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Paolo Bonzini <pbonzini@redhat.com>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0b5381e1-d725-0706-1cc0-188df6c201f2@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 10 Sep 2016 10:21:15 +0200

* The script "checkpatch.pl" can point information out like the following.

  WARNING: Prefer kcalloc over kzalloc with multiply

  Thus fix the affected source code place.

* Replace the specification of a data type by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

* Delete the local variable "size" which became unnecessary with
  this refactoring.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/zatm.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 218c6af..2cc9e2a 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -598,12 +598,13 @@ static void close_rx(struct atm_vcc *vcc)
 static int start_rx(struct atm_dev *dev)
 {
 	struct zatm_dev *zatm_dev;
-	int size,i;
+	int i;
 
 DPRINTK("start_rx\n");
 	zatm_dev = ZATM_DEV(dev);
-	size = sizeof(struct atm_vcc *)*zatm_dev->chans;
-	zatm_dev->rx_map =  kzalloc(size,GFP_KERNEL);
+	zatm_dev->rx_map = kcalloc(zatm_dev->chans,
+				   sizeof(*zatm_dev->rx_map),
+				   GFP_KERNEL);
 	if (!zatm_dev->rx_map) return -ENOMEM;
 	/* set VPI/VCI split (use all VCIs and give what's left to VPIs) */
 	zpokel(zatm_dev,(1 << dev->ci_range.vci_bits)-1,uPD98401_VRR);
-- 
2.10.0
