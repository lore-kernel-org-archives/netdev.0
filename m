From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/4] ATM-ZeitNet: Improve a size determination in zatm_open()
Date: Sat, 10 Sep 2016 11:01:25 +0200
Message-ID: <31713ca7-078f-92fe-0595-60c6904004c5@users.sourceforge.net>
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
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <0b5381e1-d725-0706-1cc0-188df6c201f2@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 10 Sep 2016 10:07:38 +0200

Replace the specification of a data structure by a pointer dereference
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/zatm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index d378ff2..218c6af 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1399,7 +1399,7 @@ static int zatm_open(struct atm_vcc *vcc)
 	DPRINTK(DEV_LABEL "(itf %d): open %d.%d\n",vcc->dev->number,vcc->vpi,
 	    vcc->vci);
 	if (!test_bit(ATM_VF_PARTIAL,&vcc->flags)) {
-		zatm_vcc = kmalloc(sizeof(struct zatm_vcc),GFP_KERNEL);
+		zatm_vcc = kmalloc(sizeof(*zatm_vcc), GFP_KERNEL);
 		if (!zatm_vcc) {
 			clear_bit(ATM_VF_ADDR,&vcc->flags);
 			return -ENOMEM;
-- 
2.10.0

