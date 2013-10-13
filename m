From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fib_trie: remove duplicated rcu lock
Date: Sat, 12 Oct 2013 20:58:57 -0700
Message-ID: <1381636737.3392.29.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381623217-5883-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: baker.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381623217-5883-1-git-send-email-baker.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-10-13 at 08:13 +0800, baker.kernel@gmail.com wrote:
> From: "baker.zhang" <baker.kernel@gmail.com>
> 
> fib_table_lookup has included the rcu lock protection.
> 
> Signed-off-by: baker.zhang <baker.kernel@gmail.com>
> ---
>  net/ipv4/fib_frontend.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index b3f627a..0e9127d 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -170,12 +170,10 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
>  	local_table = fib_get_table(net, RT_TABLE_LOCAL);
>  	if (local_table) {
>  		ret = RTN_UNICAST;
> -		rcu_read_lock();
>  		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
>  			if (!dev || dev == res.fi->fib_dev)
>  				ret = res.type;
>  		}
> -		rcu_read_unlock();
>  	}

This looks very wrong.

res.fi could disappear, and we crash.
