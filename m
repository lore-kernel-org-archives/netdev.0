From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: Use IS_ERR_OR_NULL instead of IS_ERR and
 NULl check to simplify the codes in ip_vs_genl_dump_dests and
 resolve_normal_ct
Date: Thu, 21 Jul 2016 19:01:00 +0200
Message-ID: <20160721170100.GA11613@salvia>
References: <1469110159-19200-1-git-send-email-fgao@ikuai8.com>
 <20160721164553.GA10667@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35086 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412AbcGURBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2016 13:01:08 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 8C0DC21058A
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 19:01:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7B43DFAB5A
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 19:01:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5BBECFC61B
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 19:01:05 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20160721164553.GA10667@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 06:45:53PM +0200, Pablo Neira Ayuso wrote:
> > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> > index 153e33f..634d592 100644
> > --- a/net/netfilter/nf_conntrack_core.c
> > +++ b/net/netfilter/nf_conntrack_core.c
> > @@ -1108,10 +1108,8 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
> >  	if (!h) {
> >  		h = init_conntrack(net, tmpl, &tuple, l3proto, l4proto,
> >  				   skb, dataoff, hash);
> > -		if (!h)
> > -			return NULL;
> > -		if (IS_ERR(h))
> > -			return (void *)h;
> > +		if (IS_ERR_OR_NULL(h))
> > +			return ERR_CAST(h);
> 
> Interesting.
> 
> I think we can actually simplify this patch, I'm sending a patch for
> this now.

Forget this, I cannot actually achieve the simplification, we need the
ENOMEM to drop packets when we're under stress.
