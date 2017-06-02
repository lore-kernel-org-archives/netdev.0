From: Joe Perches <joe@perches.com>
Subject: [PATCH] net-procfs: Use vsnprintf extension %phN
Date: Fri,  2 Jun 2017 02:40:44 -0700
Message-ID: <41a53a84b6332651a9c562a4f834ba964c1810e9.1496396274.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0165.hostedemail.com ([216.40.44.165]:54245 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750813AbdFBJkr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 05:40:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save a bit of code by using the kernel extension.

$ size net/core/net-procfs.o*
   text	   data	    bss	    dec	    hex	filename
   3701	    120	      0	   3821	    eed	net/core/net-procfs.o.new
   3764	    120	      0	   3884	    f2c	net/core/net-procfs.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/net-procfs.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 14d09345f00d..4847964931df 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -363,15 +363,10 @@ static int dev_mc_seq_show(struct seq_file *seq, void *v)
 
 	netif_addr_lock_bh(dev);
 	netdev_for_each_mc_addr(ha, dev) {
-		int i;
-
-		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
-			   dev->name, ha->refcount, ha->global_use);
-
-		for (i = 0; i < dev->addr_len; i++)
-			seq_printf(seq, "%02x", ha->addr[i]);
-
-		seq_putc(seq, '\n');
+		seq_printf(seq, "%-4d %-15s %-5d %-5d %*phN\n",
+			   dev->ifindex, dev->name,
+			   ha->refcount, ha->global_use,
+			   (int)dev->addr_len, ha->addr);
 	}
 	netif_addr_unlock_bh(dev);
 	return 0;
-- 
2.10.0.rc2.1.g053435c
