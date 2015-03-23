From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [v2 PATCH 4/10] netlink: Use default rhashtable hashfn
Date: Mon, 23 Mar 2015 10:18:21 +0900
Message-ID: <20150323011817.GC20755@vergenet.net>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZara-0000vP-C0@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33883 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbbCWBSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 21:18:32 -0400
Received: by pdbni2 with SMTP id ni2so170758530pdb.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 18:18:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E1YZara-0000vP-C0@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

On Sun, Mar 22, 2015 at 07:04:02PM +1100, Herbert Xu wrote:
> This patch removes the explicit jhash value for the hashfn parameter
> of rhashtable.  The default is now jhash so removing the setting
> makes no difference apart from making one less copy of jhash in
> the kernel.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  net/netlink/af_netlink.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 6517921..e2f7f28 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -3133,13 +3133,12 @@ static inline u32 netlink_hash(const void *data, u32 seed)
>  	struct netlink_compare_arg arg;
>  
>  	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->portid);
> -	return jhash(&arg, netlink_compare_arg_len, seed);
> +	return jhash2((u32 *)&arg, netlink_compare_arg_len / sizeof(u32), seed);

I understand the above change in the context of the rest of the series,
however, it does not seem to match up with the changelog for this patch.

>  }
>  
>  static const struct rhashtable_params netlink_rhashtable_params = {
>  	.head_offset = offsetof(struct netlink_sock, node),
>  	.key_len = netlink_compare_arg_len,
> -	.hashfn = jhash,
>  	.obj_hashfn = netlink_hash,
>  	.obj_cmpfn = netlink_compare,
>  	.max_size = 65536,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
