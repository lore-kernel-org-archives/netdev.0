From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 00/18] netfilter updates for net-next
Date: Mon, 29 Apr 2013 19:50:35 +0200
Message-ID: <20130429175034.GA9307@localhost>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
 <20130429.113720.1954422885523724201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
Content-Transfer-Encoding: 8bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35900 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758377Ab3D2Rul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 13:50:41 -0400
Content-Disposition: inline
In-Reply-To: <20130429.113720.1954422885523724201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Mon, Apr 29, 2013 at 11:37:20AM -0400, David Miller wrote:
> 
> This doesn't compile:
> 
> net/sched/em_ipset.c:86:5: error: ‘struct ip_set_adt_opt’ has no member named ‘timeout’

Sorry, I overlooked em_ipset, it was not appropriately adapted after
the new ipset extension infrastructure was added.

The attached patch fixes the problem. Should I send a new pull
request?

--BXVAT5kNtrzKuDFl
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-sched-em_ipset-fix-compilation-after-new-ipset-exten.patch"

>From 8a61fa178549c91822ac4c148053d6b6a519a6d5 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 29 Apr 2013 19:44:00 +0200
Subject: [PATCH] sched: em_ipset: fix compilation after new ipset extension
 infrastructure

This fixes compilation for the ipset packet classifier which was not
appropriately adapted when the new ipset extension infrastructure was
added in (80eddba netfilter: ipset: Introduce extensions to elements
in the core).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/sched/em_ipset.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index 3130320..938b7cb 100644
--- a/net/sched/em_ipset.c
+++ b/net/sched/em_ipset.c
@@ -83,7 +83,7 @@ static int em_ipset_match(struct sk_buff *skb, struct tcf_ematch *em,
 	opt.dim = set->dim;
 	opt.flags = set->flags;
 	opt.cmdflags = 0;
-	opt.timeout = ~0u;
+	opt.ext.timeout = ~0u;
 
 	network_offset = skb_network_offset(skb);
 	skb_pull(skb, network_offset);
-- 
1.7.10.4


--BXVAT5kNtrzKuDFl--
