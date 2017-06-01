From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH V4] neigh: Really delete an arp/neigh entry on "ip neigh
 delete" or "arp -d"
Date: Thu, 1 Jun 2017 15:45:13 -0400
Message-ID: <20170601194513.GI25693@oracle.com>
References: <1496280282-84895-1-git-send-email-sowmini.varadhan@oracle.com>
 <alpine.LFD.2.20.1706012201100.3101@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25481 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751050AbdFATp0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 15:45:26 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1706012201100.3101@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (06/01/17 22:34), Julian Anastasov wrote:
> > +	np = &nht->hash_buckets[hash_val];
> > +	while ((n = rcu_dereference_protected(*np,
> > +				lockdep_is_held(&tbl->lock))) != NULL) {
> 
> 	checkpatch shows some warnings:
> 
> scripts/checkpatch.pl --strict /tmp/file.patch

Yes, checkpatch complained about 
"CHECK: Alignment should match open parenthesis"
but trying to meet that requirement (without exceeding the 80 char limit)
would need additional variables, and I noticed that there are
other places in the code (e.g., neigh_forced_gc()) where the alignment
prescription is not observed, so I let things follow existing style..

[ In neigh_remove_one()] 
> 	In case there is another patch version,
> the retval can be removed:

Let me see if there are additional review comments, and I can update
with the retval removed. 

Thanks much for the review!

> 	Looks like we can also call neigh_remove_one only when !err.
> But this is some corner case when n->dead is set by GC and entry
> was unlinked, neigh_remove_one simply will not find it in the list,
> so it is not fatal to call neigh_remove_one unconditionally.

> > @@ -1113,13 +1113,17 @@ static int arp_invalidate(struct net_device *dev, __be32 ip)
        :
> 	Here the same race with GC already assigned
> neigh->dead to 1 is possible but it is more tricky to catch
> that exactly neigh_update() has failed. So, may be better to
> call neigh_remove_one like now.
