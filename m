From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] staging: net: core: skbuff.c: Added do-while pair for
 complex macros
Date: Thu, 26 Nov 2015 09:00:23 -0800
Message-ID: <1448557223.18647.4.camel@perches.com>
References: <1448555763-5088-1-git-send-email-jitendra.khasdev@hotwaxsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jitendra Kumar Khasdev <jitendra.khasdev@hotwaxsystems.com>
To: Jitendra Kumar Khasdev <jkhasdev@gmail.com>, davem@davemloft.net,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	linus.luessing@c0d3.bluen, hannes@stressinduktion.org,
	willemb@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448555763-5088-1-git-send-email-jitendra.khasdev@hotwaxsystems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-11-26 at 22:06 +0530, Jitendra Kumar Khasdev wrote:
> This patch is to file skbuff.c that fixes up following error,
> reported by checkpatch.pl tool,

Your subject title is not correct.
This is not a staging patch.

> 1. ERROR: Macros with multiple statements should be enclosed
>    in a do - while loop.

checkpatch is brainless.
Not every message it emits needs fixing.


> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
[]
> @@ -748,11 +748,13 @@ void consume_skb(struct sk_buff *skb)
>  EXPORT_SYMBOL(consume_skb);
>  
>  /* Make sure a field is enclosed inside headers_start/headers_end section */
> -#define CHECK_SKB_FIELD(field) \
> -	BUILD_BUG_ON(offsetof(struct sk_buff, field) <		\
> -		     offsetof(struct sk_buff, headers_start));	\
> -	BUILD_BUG_ON(offsetof(struct sk_buff, field) >		\
> -		     offsetof(struct sk_buff, headers_end));	\
> +#define CHECK_SKB_FIELD(field)						\
> +	do {								\
> +		BUILD_BUG_ON(offsetof(struct sk_buff, field) <		\
> +			offsetof(struct sk_buff, headers_start));	\
> +		BUILD_BUG_ON(offsetof(struct sk_buff, field) >		\
> +			offsetof(struct sk_buff, headers_end));		\
> +	} while (0)							\

Perhaps the last check should add a sizeof(field)

	BUILD_BUG_ON((offsetof(struct sk_buff, field) +
		      FIELD_SIZEOF(struct sk_buff, field)) >
		     offsetof(struct sk_buff, headers_end));
