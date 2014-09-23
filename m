From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/5] netfilter: nft_rbtree: no need for spinlock from set
 destroy path
Date: Tue, 23 Sep 2014 18:10:40 +0200
Message-ID: <20140923161040.GA3609@salvia>
References: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
 <1411464288-18069-3-git-send-email-pablo@netfilter.org>
 <1411465957.26859.179.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140923110159.GA20055@salvia>
 <1411473245.26859.188.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1411473245.26859.188.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 23, 2014 at 04:54:05AM -0700, Eric Dumazet wrote:
> On Tue, 2014-09-23 at 13:01 +0200, Pablo Neira Ayuso wrote:
> 
> > I'll send a follow up patch for nf-next to use rb_first() in that
> > patch. Thanks Eric.
> 
> I did a test, and its indeed a bit faster to use rb_first(), by about 5%
> 
> Real win is to be able to build a chain using rb_first()/rb_next(),
> (leaving the tree as is), then deleting the items in the chain, and
> simply reset rb_root.
> 
> This only needs to reuse one pointer to store the item->next pointer.
> 
> This is then about ~50% faster, because we do not constantly rebalance
> tree for every removed item.

Indeed.

struct nft_rbtree_elem {
        struct rb_node          node;
        u16                     flags;
        struct nft_data         key;
        struct nft_data         data[];
};

Actually, I could add to nft_data a pointer in the union area, but I'm
not very confortable with adding it for this specific case. At this
moment we're releasing this from rcu_callback which is "hiding" the
deletion time from the netlink interface.

But I'll keep this back in my head if we later on have some pointer
candidate to be reused in a nice way.

I'll send a patch to make the rb_first()/rb_next() conversion though.

Thanks for your comments!
