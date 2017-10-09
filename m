From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] net/core: Fix BUG to BUG_ON conditionals.
Date: Mon, 9 Oct 2017 10:15:42 -0700
Message-ID: <20171009171540.lgmk2slq3bdrptxk@ast-mbp.dhcp.thefacebook.com>
References: <20171009153759.km3lqss7hb72wrze@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
        soheil@google.com, pabeni@redhat.com, elena.reshetova@intel.com,
        tom@quantonium.net, Jason@zx2c4.com, fw@strlen.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexander.levin@one.verizon.com
To: Tim Hansen <devtimhansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37179 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754151AbdJIRPp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:15:45 -0400
Content-Disposition: inline
In-Reply-To: <20171009153759.km3lqss7hb72wrze@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 09, 2017 at 11:37:59AM -0400, Tim Hansen wrote:
> Fix BUG() calls to use BUG_ON(conditional) macros.
> 
> This was found using make coccicheck M=net/core on linux next
> tag next-2017092
> 
> Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
> ---
>  net/core/skbuff.c | 15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d98c2e3ce2bf..34ce4c1a0f3c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1350,8 +1350,7 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
>  	/* Set the tail pointer and length */
>  	skb_put(n, skb->len);
>  
> -	if (skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len))
> -		BUG();
> +	BUG_ON(skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len));

I'm concerned with this change.
1. Calling non-trivial bit of code inside the macro is a poor coding style (imo)
2. BUG_ON != BUG. Some archs like mips and ppc have HAVE_ARCH_BUG_ON and implementation
of BUG and BUG_ON look quite different.

I'd prefer to keep the code as-is.
