From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] [PKT_SCHED] CLS_U32: Use ffs() instead of C code on hash mask to get first set bit.
Date: Thu, 8 Nov 2007 12:37:52 +0100
Message-ID: <20071108113752.GA1602@ff.dom.local>
References: <20071107.012220.17723288.davem@davemloft.net> <1194520067-20868-1-git-send-email-radu.rendec@ines.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:46309 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755927AbXKHLeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 06:34:01 -0500
Content-Disposition: inline
In-Reply-To: <1194520067-20868-1-git-send-email-radu.rendec@ines.ro>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 01:07:47PM +0200, Radu Rendec wrote:
> Computing the rank of the first set bit in the hash mask (for using later
> in u32_hash_fold()) was done with plain C code. Using ffs() instead makes
> the code more readable and improves performance (since ffs() is better
> optimized in assembler).
> 
> Using the conditional operator on hash mask before applying ntohl() also
> saves one ntohl() call if mask is 0.
> 
> Signed-off-by: Radu Rendec <radu.rendec@ines.ro>

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

> ---
>  net/sched/cls_u32.c |   12 +-----------
>  1 files changed, 1 insertions(+), 11 deletions(-)
> 
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 5317102..c390082 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -613,17 +613,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
>  	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
>  	n->ht_up = ht;
>  	n->handle = handle;
> -{
> -	u8 i = 0;
> -	u32 mask = ntohl(s->hmask);
> -	if (mask) {
> -		while (!(mask & 1)) {
> -			i++;
> -			mask>>=1;
> -		}
> -	}
> -	n->fshift = i;
> -}
> +	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
>  
>  #ifdef CONFIG_CLS_U32_MARK
>  	if (tb[TCA_U32_MARK-1]) {
> -- 
> 1.5.3.2
> 
