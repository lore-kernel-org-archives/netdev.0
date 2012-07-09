From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] netfilter: ipset: timeout fixing bug broke SET
 target special timeout value
Date: Mon, 9 Jul 2012 10:58:27 +0200
Message-ID: <20120709085827.GA10776@1984>
References: <1341574779-3373-1-git-send-email-pablo@netfilter.org>
 <1341574779-3373-2-git-send-email-pablo@netfilter.org>
 <20120709.002903.592402805831614695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120709.002903.592402805831614695.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 09, 2012 at 12:29:03AM -0700, David Miller wrote:
> From: pablo@netfilter.org
> Date: Fri,  6 Jul 2012 13:39:38 +0200
> 
> > +	if (add_opt.timeout != IPSET_NO_TIMEOUT
> > +	    && add_opt.timeout > UINT_MAX/MSEC_PER_SEC)
> 
> We do not write conditionals like this, with operators beginning
> a continued line.  Instead, write this as:
> 
> 	if (a &&
> 	    b)

Oops, indeed, sorry. New patch attached.

I've also rebased my tree to include this change. Should I send a new
pull request?

Let me know what you prefer.

--r5Pyd7+fXNt84Ff3
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-ipset-timeout-fixing-bug-broke-SET-target-.patch"

>From a73f89a61f92b364f0b4a3be412b5b70553afc23 Mon Sep 17 00:00:00 2001
From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date: Fri, 29 Jun 2012 09:42:28 +0000
Subject: [PATCH] netfilter: ipset: timeout fixing bug broke SET target
 special timeout value

The patch "127f559 netfilter: ipset: fix timeout value overflow bug"
broke the SET target when no timeout was specified.

Reported-by: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_set.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 035960e..c6f7db7 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -16,6 +16,7 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_set.h>
+#include <linux/netfilter/ipset/ip_set_timeout.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -310,7 +311,8 @@ set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 		info->del_set.flags, 0, UINT_MAX);
 
 	/* Normalize to fit into jiffies */
-	if (add_opt.timeout > UINT_MAX/MSEC_PER_SEC)
+	if (add_opt.timeout != IPSET_NO_TIMEOUT &&
+	    add_opt.timeout > UINT_MAX/MSEC_PER_SEC)
 		add_opt.timeout = UINT_MAX/MSEC_PER_SEC;
 	if (info->add_set.index != IPSET_INVALID_ID)
 		ip_set_add(info->add_set.index, skb, par, &add_opt);
-- 
1.7.10


--r5Pyd7+fXNt84Ff3--
