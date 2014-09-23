From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5] netfilter: nft_rbtree: no need for spinlock from
 set destroy path
Date: Tue, 23 Sep 2014 04:54:05 -0700
Message-ID: <1411473245.26859.188.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
	 <1411464288-18069-3-git-send-email-pablo@netfilter.org>
	 <1411465957.26859.179.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140923110159.GA20055@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140923110159.GA20055@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-23 at 13:01 +0200, Pablo Neira Ayuso wrote:

> I'll send a follow up patch for nf-next to use rb_first() in that
> patch. Thanks Eric.

I did a test, and its indeed a bit faster to use rb_first(), by about 5%

Real win is to be able to build a chain using rb_first()/rb_next(),
(leaving the tree as is), then deleting the items in the chain, and
simply reset rb_root.

This only needs to reuse one pointer to store the item->next pointer.

This is then about ~50% faster, because we do not constantly rebalance
tree for every removed item.



