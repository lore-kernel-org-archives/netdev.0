From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] net/ip6_tunnel: fix dst leak
Date: Wed, 18 Nov 2015 09:37:52 -0800
Message-ID: <20151118173730.GA22676@kafai-mba.local>
References: <9dd416a82166a27f5cf5eda71a63222a0eb96c04.1447859978.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14734 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755212AbbKRRiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 12:38:01 -0500
Content-Disposition: inline
In-Reply-To: <9dd416a82166a27f5cf5eda71a63222a0eb96c04.1447859978.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015 at 04:40:19PM +0100, Paolo Abeni wrote:
> the commit cdf3464e6c6b ("ipv6: Fix dst_entry refcnt bugs in ip6_tunnel")
> introduced percpu storage for ip6_tunnel dst cache, but while clearing
> such cache it used raw_cpu_ptr to walk the per cpu entries, so cached
> dst on non current cpu are not actually reset.
>
> This patch replaces raw_cpu_ptr with per_cpu_ptr, properly cleaning
> such storage.
Thanks for fixing it.

Acked-by: Martin KaFai Lau <kafai@fb.com>

>
> Fixes: cdf3464e6c6b ("ipv6: Fix dst_entry refcnt bugs in ip6_tunnel")
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv6/ip6_tunnel.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index eabffbb..137fca4 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -177,7 +177,7 @@ void ip6_tnl_dst_reset(struct ip6_tnl *t)
>  	int i;
>
>  	for_each_possible_cpu(i)
> -		ip6_tnl_per_cpu_dst_set(raw_cpu_ptr(t->dst_cache), NULL);
> +		ip6_tnl_per_cpu_dst_set(per_cpu_ptr(t->dst_cache, i), NULL);
>  }
>  EXPORT_SYMBOL_GPL(ip6_tnl_dst_reset);
>
> --
> 1.8.3.1
>
