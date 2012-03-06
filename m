From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/6] netfilter: ctnetlink: use GFP_ATOMIC in all
 allocations
Date: Tue, 6 Mar 2012 15:48:38 +0100
Message-ID: <20120306144838.GA1527@1984>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
 <1331032975-5303-4-git-send-email-pablo@netfilter.org>
 <1331038221.9504.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1331038221.9504.9.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2012 at 04:50:21AM -0800, Eric Dumazet wrote:
> On Tue, 2012-03-06 at 12:22 +0100, pablo@netfilter.org wrote:
> > From: Pablo Neira Ayuso <pablo@netfilter.org>
> > 
> > All ctnetlink operations are invoked inside rcu_read_lock
> > (see net/netfilter/nfnetlink.c).
> > 
> > Allocations have to be atomic, as RCU requires.
> > 
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > ---
> >  net/netfilter/nf_conntrack_netlink.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
> > index 1068769..867843f 100644
> > --- a/net/netfilter/nf_conntrack_netlink.c
> > +++ b/net/netfilter/nf_conntrack_netlink.c
> > @@ -1002,7 +1002,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
> >  	ct = nf_ct_tuplehash_to_ctrack(h);
> >  
> >  	err = -ENOMEM;
> > -	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > +	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> >  	if (skb2 == NULL) {
> >  		nf_ct_put(ct);
> >  		return -ENOMEM;
> > @@ -1865,7 +1865,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
> >  	}
> >  
> >  	err = -ENOMEM;
> > -	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > +	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> >  	if (skb2 == NULL) {
> >  		nf_ct_expect_put(exp);
> >  		goto out;
> 
> This cant be right.
> 
> Really this must be kept as GFP_KERNEL allocations.
> 
> Only if .call_rcu member is used in place of .call rcu_read_lock() is
> held instead of nfnl_lock().

I thought we couldn't sleep while holding rcu_read_lock.

> You should take a look at all GFP_ATOMIC uses in
> net/netfilter/nf_conntrack_netlink.c and check if they can be GFP_KERNEL
> instead.

David, can you take all patches except this one?

I'll have to rebase my tree after this, sorry.
