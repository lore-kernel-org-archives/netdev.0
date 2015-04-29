From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net-next] net: merge redundancy judgement
Date: Wed, 29 Apr 2015 00:28:16 -0400 (EDT)
Message-ID: <20150429.002816.509194069032518571.davem@davemloft.net>
References: <1430278559-5609-1-git-send-email-martinbj2008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: martinbj2008@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430278559-5609-1-git-send-email-martinbj2008@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Zhang <martinbj2008@gmail.com>
Date: Wed, 29 Apr 2015 11:35:59 +0800

> 'if' and 'elseif' do the same operation,
> so merge then into a case.
> 
> Signed-off-by: Martin Zhang <martinbj2008@gmail.com>
> ---
>  net/ipv4/route.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index ad50643..9b5468c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -802,11 +802,8 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
>  	struct dst_entry *ret = dst;
>  
>  	if (rt) {
> -		if (dst->obsolete > 0) {
> -			ip_rt_put(rt);
> -			ret = NULL;
> -		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
> -			   rt->dst.expires) {
> +		if (dst->obsolete > 0 || (rt->rt_flags & RTCF_REDIRECTED)
> +		 || rt->dst.expires) {

Never begin lines with conditional operators.  Rather, end lines with
conditional operators, as it was in the original code.
