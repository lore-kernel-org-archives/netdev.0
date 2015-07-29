From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] lwtunnel: Make lwtun_encaps[] static
Date: Wed, 29 Jul 2015 12:35:27 -0700
Message-ID: <55B92AFF.3080101@cumulusnetworks.com>
References: <66e6473d98879c465cf4965d44230374c716ed25.1438155918.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36766 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbbG2Tf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 15:35:29 -0400
Received: by pachj5 with SMTP id hj5so10309882pac.3
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 12:35:29 -0700 (PDT)
In-Reply-To: <66e6473d98879c465cf4965d44230374c716ed25.1438155918.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/29/15, 12:45 AM, Thomas Graf wrote:
> Any external user should use the registration API instead of
> accessing this directly.
>
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

thanks.
> ---
>   include/net/lwtunnel.h | 3 ---
>   net/core/lwtunnel.c    | 2 +-
>   2 files changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
> index b020390..33bd309 100644
> --- a/include/net/lwtunnel.h
> +++ b/include/net/lwtunnel.h
> @@ -31,9 +31,6 @@ struct lwtunnel_encap_ops {
>   	int (*cmp_encap)(struct lwtunnel_state *a, struct lwtunnel_state *b);
>   };
>   
> -extern const struct lwtunnel_encap_ops __rcu *
> -		lwtun_encaps[LWTUNNEL_ENCAP_MAX+1];
> -
>   #ifdef CONFIG_LWTUNNEL
>   static inline struct lwtunnel_state *
>   lwtstate_get(struct lwtunnel_state *lws)
> diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
> index 5f7fae7..c240c89 100644
> --- a/net/core/lwtunnel.c
> +++ b/net/core/lwtunnel.c
> @@ -37,7 +37,7 @@ struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
>   }
>   EXPORT_SYMBOL(lwtunnel_state_alloc);
>   
> -const struct lwtunnel_encap_ops __rcu *
> +static const struct lwtunnel_encap_ops __rcu *
>   		lwtun_encaps[LWTUNNEL_ENCAP_MAX + 1] __read_mostly;
>   
>   int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *ops,
