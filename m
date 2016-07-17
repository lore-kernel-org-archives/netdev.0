From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] drivers: atm: nicstar: Use the correct function to free some resources
Date: Sun, 17 Jul 2016 09:03:24 +0200
Message-ID: <1468739004-3471-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: 3chas3@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In 'get_scq', 'dma_alloc_coherent' has been used to allocate some
resources, so we need to free them using 'dma_free_coherent' instead
of 'kfree'.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/atm/nicstar.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index ddc4ceb..700ed15 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -874,7 +874,8 @@ static scq_info *get_scq(ns_dev *card, int size, u3=
2 scd)
 	scq->skb =3D kmalloc(sizeof(struct sk_buff *) *
 			   (size / NS_SCQE_SIZE), GFP_KERNEL);
 	if (!scq->skb) {
-		kfree(scq->org);
+		dma_free_coherent(&card->pcidev->dev,
+				  2 * size, scq->org, scq->dma);
 		kfree(scq);
 		return NULL;
 	}
--=20
2.7.4


---
L'absence de virus dans ce courrier =C3=A9lectronique a =C3=A9t=C3=A9 v=
=C3=A9rifi=C3=A9e par le logiciel antivirus Avast.
https://www.avast.com/antivirus
