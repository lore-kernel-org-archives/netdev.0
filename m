From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net: use-after-free in worker_thread
Date: Mon, 5 Dec 2016 15:21:40 +0800
Message-ID: <20161205072140.GC9496@gondor.apana.org.au>
References: <CAAeHK+x95-n__YSbzebp51ez78yjqjK4CJL=tgOgPuBuGh+q1A@mail.gmail.com>
 <CAAeHK+zDnDugPcdEGBnC6rt5iJMffz+tmmDkF=vv6u0YF=EMwg@mail.gmail.com>
 <CAAeHK+wtAhv2vvLva5a9J52A-bZj1kY8tF8RT7bC=5QVnxOr7A@mail.gmail.com>
 <1480772947.18162.402.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Bob Copeland <me@bobcopeland.com>,
        Tom Herbert <tom@herbertland.com>,
        David Decotigny <decot@googlers.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kostya Serebryany <kcc@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480772947.18162.402.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 03, 2016 at 05:49:07AM -0800, Eric Dumazet wrote:
>
> @@ -600,6 +600,7 @@ static int __netlink_create(struct net *net, struct socket *sock,
>  	}
>  	init_waitqueue_head(&nlk->wait);
>  
> +	sock_set_flag(sk, SOCK_RCU_FREE);
>  	sk->sk_destruct = netlink_sock_destruct;
>  	sk->sk_protocol = protocol;
>  	return 0;

It's not necessarily a big deal but I just wanted to point out
that SOCK_RCU_FREE is not equivalent to the call_rcu thing that
netlink does.  The latter only does the RCU deferral for the socket
release call which is the only place where it's needed while
SOCK_RCU_FREE will force every path to do an RCU deferral.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
