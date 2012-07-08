From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/7] drivers/isdn/mISDN/stack.c: remove invalid reference to list iterator variable
Date: Sun,  8 Jul 2012 13:37:38 +0200
Message-ID: <1341747464-1772-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1341747464-1772-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341747464-1772-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

If list_for_each_entry, etc complete a traversal of the list, the iterator
variable ends up pointing to an address at an offset from the list head,
and not a meaningful structure.  Thus this value should not be used after
the end of the iterator.  The dereferences are just deleted from the
debugging statement.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/isdn/mISDN/stack.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/mISDN/stack.c b/drivers/isdn/mISDN/stack.c
index 1a0ae44..5f21f62 100644
--- a/drivers/isdn/mISDN/stack.c
+++ b/drivers/isdn/mISDN/stack.c
@@ -135,8 +135,8 @@ send_layer2(struct mISDNstack *st, struct sk_buff *skb)
 			skb = NULL;
 		else if (*debug & DEBUG_SEND_ERR)
 			printk(KERN_DEBUG
-			       "%s ch%d mgr prim(%x) addr(%x) err %d\n",
-			       __func__, ch->nr, hh->prim, ch->addr, ret);
+			       "%s mgr prim(%x) err %d\n",
+			       __func__, hh->prim, ret);
 	}
 out:
 	mutex_unlock(&st->lmutex);
