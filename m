From: Joe Perches <joe@perches.com>
Subject: [PATCH 46/49] net/netfilter: Use vzalloc
Date: Thu,  4 Nov 2010 20:08:10 -0700
Message-ID: <7d6da34b7e84955795717b0241000a0701cd5b34.1288925425.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/x_tables.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8046350..89e8895 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -753,12 +753,11 @@ static int xt_jumpstack_alloc(struct xt_table_info *i)
 
 	size = sizeof(void **) * nr_cpu_ids;
 	if (size > PAGE_SIZE)
-		i->jumpstack = vmalloc(size);
+		i->jumpstack = vzalloc(size);
 	else
-		i->jumpstack = kmalloc(size, GFP_KERNEL);
+		i->jumpstack = kzalloc(size, GFP_KERNEL);
 	if (i->jumpstack == NULL)
 		return -ENOMEM;
-	memset(i->jumpstack, 0, size);
 
 	i->stacksize *= xt_jumpstack_multiplier;
 	size = sizeof(void *) * i->stacksize;
-- 
1.7.3.1.g432b3.dirty
