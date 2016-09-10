From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 5/5] ATM-nicstar: Refactor a dev_alloc_skb() call in
 dequeue_rx()
Date: Sat, 10 Sep 2016 09:21:29 +0200
Message-ID: <b6465bc0-f0ff-b3b6-8872-79b84f7300f8@users.sourceforge.net>
References: <fe480e1f-285a-bb98-3550-b4fa354f8174@users.sourceforge.net>
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
In-Reply-To: <fe480e1f-285a-bb98-3550-b4fa354f8174@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 10 Sep 2016 08:56:03 +0200

The script "checkpatch.pl" can point out that assignments should usually
not be performed within condition checks.
Thus move an assignment for a local variable to a separate statement
in this function.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/nicstar.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 04f5781..c7296b5 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -2023,7 +2023,8 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 
 		cell = skb->data;
 		for (i = ns_rsqe_cellcount(rsqe); i; i--) {
-			if ((sb = dev_alloc_skb(NS_SMSKBSIZE)) == NULL) {
+			sb = dev_alloc_skb(NS_SMSKBSIZE);
+			if (!sb) {
 				printk
 				    ("nicstar%d: Can't allocate buffers for aal0.\n",
 				     card->index);
-- 
2.10.0
