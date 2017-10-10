From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH][net-next] ipv6: fix dereference of rt6_ex before null
 check error
Date: Tue, 10 Oct 2017 10:40:58 -0700
Message-ID: <20171010174058.vcqm5yg5wiv7gyxb@kafai-mbp.dhcp.thefacebook.com>
References: <20171010170116.21124-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171010170116.21124-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2017 at 05:01:16PM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Currently rt6_ex is being dereferenced before it is null checked
> hence there is a possible null dereference bug. Fix this by only
> dereferencing rt6_ex after it has been null checked.
> 
> Detected by CoverityScan, CID#1457749 ("Dereference before null check")
> 
> Fixes: 81eb8447daae ("ipv6: take care of rt6_stats")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>

> ---
>  net/ipv6/route.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 606e80325b21..6db1541eaa7b 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1152,10 +1152,12 @@ static DEFINE_SPINLOCK(rt6_exception_lock);
>  static void rt6_remove_exception(struct rt6_exception_bucket *bucket,
>  				 struct rt6_exception *rt6_ex)
>  {
> -	struct net *net = dev_net(rt6_ex->rt6i->dst.dev);
> +	struct net *net;
>  
>  	if (!bucket || !rt6_ex)
>  		return;
> +
> +	net = dev_net(rt6_ex->rt6i->dst.dev);
>  	rt6_ex->rt6i->rt6i_node = NULL;
>  	hlist_del_rcu(&rt6_ex->hlist);
>  	rt6_release(rt6_ex->rt6i);
> -- 
> 2.14.1
> 
