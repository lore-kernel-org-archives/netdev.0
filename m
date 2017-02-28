From: Colin King <colin.king@canonical.com>
Subject: [PATCH] netfilter: remove redundant check on ret being non-zero
Date: Tue, 28 Feb 2017 11:31:15 +0000
Message-ID: <20170228113115.19888-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

ret is initialized to zero and if it is set to non-zero in the
xt_entry_foreach loop then we exit via the out_free label. Hence
the check for ret being non-zero is redundant and can be removed.

Detected by CoverityScan, CID#1357132 ("Logically Dead Code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv4/netfilter/arp_tables.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 6241a81..f17dab1 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -562,8 +562,6 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		    XT_ERROR_TARGET) == 0)
 			++newinfo->stacksize;
 	}
-	if (ret != 0)
-		goto out_free;
 
 	ret = -EINVAL;
 	if (i != repl->num_entries)
-- 
2.10.2
