From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/31: netfilter update
Date: Fri, 12 Jun 2009 03:35:09 +0200
Message-ID: <4A31B0CD.40300@trash.net>
References: <20090611.161910.109357779.davem@davemloft.net>	<20090611.164047.74924409.davem@davemloft.net>	<4A31978A.3040300@trash.net> <20090611.165041.201036582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020807030704080406090104"
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32769 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbZFLBfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 21:35:09 -0400
In-Reply-To: <20090611.165041.201036582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020807030704080406090104
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 12 Jun 2009 01:47:22 +0200
>
>   
>> Appologies again, I didn't test CONFIG_NETFILTER_DEBUG=y.
>> I'll fix it up and do a few more compile tests myself.
>>     
>
> Thank you.
>   

I've added this patch and built all combinations I could come up with,
I think it should finally be fine.

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


--------------020807030704080406090104
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 24992eacd8a9f4af286bdaaab627b6802ceb8bce
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 01:53:09 2009 +0200

    netfilter: ip_tables: fix build error
    
    Fix build error introduced by commit bb70dfa5 (netfilter: xtables:
    consolidate comefrom debug cast access):
    
    net/ipv4/netfilter/ip_tables.c: In function 'ipt_do_table':
    net/ipv4/netfilter/ip_tables.c:421: error: 'comefrom' undeclared (first use in this function)
    net/ipv4/netfilter/ip_tables.c:421: error: (Each undeclared identifier is reported only once
    net/ipv4/netfilter/ip_tables.c:421: error: for each function it appears in.)
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 5bf7c3f..fdefae6 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -418,7 +418,7 @@ ipt_do_table(struct sk_buff *skb,
 #endif
 		verdict = t->u.kernel.target->target(skb, &tgpar);
 #ifdef CONFIG_NETFILTER_DEBUG
-		if (comefrom != 0xeeeeeeec && verdict == IPT_CONTINUE) {
+		if (tb_comefrom != 0xeeeeeeec && verdict == IPT_CONTINUE) {
 			printk("Target %s reentered!\n",
 			       t->u.kernel.target->name);
 			verdict = NF_DROP;

--------------020807030704080406090104--
