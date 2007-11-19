From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and 2.6.23.8)
Date: Mon, 19 Nov 2007 22:24:24 +0300
Message-ID: <20071119192423.GA26449@2ka.mipt.ru>
References: <47408BBC.6040608@unsolicited.net> <200711182131.38388.ismail@pardus.org.tr> <474093E0.3090007@unsolicited.net> <47409863.8000902@trash.net> <4741DB3A.2030304@unsolicited.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Ismail =?utf8?Q?D=C3=B6nmez?= <ismail@pardus.org.tr>,
	netdev@vger.kernel.org
To: David <david@unsolicited.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44456 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959AbXKST1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 14:27:15 -0500
Content-Disposition: inline
In-Reply-To: <4741DB3A.2030304@unsolicited.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 06:51:38PM +0000, David (david@unsolicited.net) wrote:
> Patrick McHardy wrote:
> >>>>     iptables -t nat -A PREROUTING -j REDIRECT -i eth2 -p udp --dport
> >>>> 5061 --to-ports 5060
> >>>>
> >>>>         
> >>> Also post the kernel panic log.
> >>>       
> >
> > Please try if this patch fixes the problem.
> 
> No luck with the patch I'm afraid, panic log attached (of patched kernel).

Ok, let's try it hard way.
Please check attached patch and tell if it helped (it will produce
some debug though).
What is a load on this machine? Is it simple enough to reproduce?
I will take closer look tomorrow if this will not help.

Thanks.

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 70e7997..7dc3496 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -607,13 +607,13 @@ static void nf_nat_move_storage(struct nf_conn *conntrack, void *old)
 	struct nf_conn_nat *new_nat = nf_ct_ext_find(conntrack, NF_CT_EXT_NAT);
 	struct nf_conn_nat *old_nat = (struct nf_conn_nat *)old;
 	struct nf_conn *ct = old_nat->ct;
-	unsigned int srchash;
+	
+	printk("conntrack: %p, new: %p, old: %p, ct: %p.\n",
+			conntrack, new_nat, old_nat, ct);
 
-	if (!(ct->status & IPS_NAT_DONE_MASK))
+	if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
 		return;
 
-	srchash = hash_by_src(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-
 	write_lock_bh(&nf_nat_lock);
 	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
 	new_nat->ct = ct;

-- 
	Evgeniy Polyakov
