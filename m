From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net-procfs: Adjust buffer output in dev_mc_seq_show()
Date: Wed, 10 May 2017 21:30:29 +0200
Message-ID: <f4834759-37aa-14d7-e000-6526a3a4071f@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 10 May 2017 21:17:43 +0200

* Use a special format string specification for the desired output of the
  array "addr" into a sequence.

  This issue was detected by using the Coccinelle software.

* Delete the local variable "i" and a call of the function "seq_putc"
  which became unnecessary with this refactoring.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/core/net-procfs.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 14d09345f00d..6aa427a2fb98 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -363,15 +363,9 @@ static int dev_mc_seq_show(struct seq_file *seq, void *v)
 
 	netif_addr_lock_bh(dev);
 	netdev_for_each_mc_addr(ha, dev) {
-		int i;
-
 		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
 			   dev->name, ha->refcount, ha->global_use);
-
-		for (i = 0; i < dev->addr_len; i++)
-			seq_printf(seq, "%02x", ha->addr[i]);
-
-		seq_putc(seq, '\n');
+		seq_printf(seq, "%*phN\n", dev->addr_len, ha->addr);
 	}
 	netif_addr_unlock_bh(dev);
 	return 0;
-- 
2.12.3
