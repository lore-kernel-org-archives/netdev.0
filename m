From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 4/5] random32: add prandom_init_once helper for
 own rngs
Date: Wed, 7 Oct 2015 09:32:24 -0700
Message-ID: <56154918.5070802@plumgrid.com>
References: <cover.1444224502.git.daniel@iogearbox.net>
 <b96539c3efda908e3a347ff15de5eaf894548a5c.1444224502.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32877 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651AbbJGQcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 12:32:23 -0400
Received: by pacex6 with SMTP id ex6so25987507pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 09:32:23 -0700 (PDT)
In-Reply-To: <b96539c3efda908e3a347ff15de5eaf894548a5c.1444224502.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 6:43 AM, Daniel Borkmann wrote:
> +void prandom_init_state_once(void *pcpu_state);
> +
> +#define prandom_init_once(pcpu_state)				\
> +	({ do_once(prandom_init_state_once, (pcpu_state)); })
>
>   /**
>    * prandom_u32_max - returns a pseudo-random number in interval [0, ep_ro)
> diff --git a/lib/random32.c b/lib/random32.c
> index 36c09fb..b166237 100644
> --- a/lib/random32.c
> +++ b/lib/random32.c
> @@ -256,6 +256,11 @@ static void prandom_seed_full_state(struct rnd_state __percpu *pcpu_state)
>   	}
>   }
>
> +void prandom_init_state_once(void *pcpu_state)
> +{
> +	prandom_seed_full_state((struct rnd_state __percpu *)pcpu_state);
> +}
> +

prandom_seed_full_state() is likely not inlined in the above.
Why introduce this helper instead of making prandom_seed_full_state() 
global? with my other suggestion the void cast will be avoided as well
and compiler will do type checking.
