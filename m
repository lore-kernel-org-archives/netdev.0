From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: x_tables: xt_init() should run
 earlier
Date: Wed, 5 Sep 2012 18:53:21 +0200
Message-ID: <20120905165321.GA22243@1984>
References: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
 <1346860506.13121.148.camel@edumazet-glaptop>
 <1346861569.13121.149.camel@edumazet-glaptop>
 <1346863073.13121.155.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1346863073.13121.155.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Wed, Sep 05, 2012 at 06:37:53PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Cong Wang reported a NULL dereference in xt_register_target()
> 
> It turns out xt_nat_init() was called before xt_init(), so xt array
> was not yet setup.
> 
> xt_init() should be marked core_initcall() to solve this problem.
> 
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/netfilter/x_tables.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index 8d987c3..afcea11 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1390,6 +1390,6 @@ static void __exit xt_fini(void)
>  	kfree(xt);
>  }
>  
> -module_init(xt_init);
> +core_initcall(xt_init);
>  module_exit(xt_fini);

It seems we've clashed fixing this, sorry. Can you still see any
problem with my patch?

Thanks for looking into this.
