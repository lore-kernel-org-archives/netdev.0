From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get
Date: Thu, 9 Jan 2014 21:56:22 +0100
Message-ID: <20140109205622.GA29458@breakpoint.cc>
References: <1389090711-15843-1-git-send-email-avagin@openvz.org>
 <1389107305.26646.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140107152520.GF9894@breakpoint.cc>
 <20140109203206.GA26348@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrey Vagin <avagin@openvz.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140109203206.GA26348@paralelels.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Vagin <avagin@parallels.com> wrote:
> Can we allocate conntrack with zero ct_general.use and increment it at
> the first time before inserting the conntrack into the hash table?
> When conntrack is allocated it is attached exclusively to one skb.
> It must be destroyed with skb, if it has not been confirmed, so we
> don't need refcnt on this stage.
> 
> I found only one place, where a reference counter of unconfirmed
> conntract can incremented. It's ctnetlink_dump_table().

What about skb_clone, etc?  They will also increment the refcnt
if a conntrack entry is attached to the skb.
