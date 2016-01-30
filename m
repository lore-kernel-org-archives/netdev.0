From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] netfilter: nf_conntrack: remove the unneed
 check for *bucket
Date: Sat, 30 Jan 2016 22:30:03 +0100
Message-ID: <20160130213003.GA13560@breakpoint.cc>
References: <56ACABBC.9050303@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Weidong Wang <wangweidong1@huawei.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56ACABBC.9050303@huawei.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Weidong Wang <wangweidong1@huawei.com> wrote:
> In the 'for(...) {}', the *bucket alwasy < net->ct.htable_size,
> so remove the check
> @@ -1383,14 +1383,12 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
>  		lockp = &nf_conntrack_locks[*bucket % CONNTRACK_LOCKS];
>  		local_bh_disable();
>  		spin_lock(lockp);
> -		if (*bucket < net->ct.htable_size) {

AFAIU net->ct.htable_size can shrink between for-test and aquiring
the bucket lockp, so this additional if-test is needed.
