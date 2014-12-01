From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: [PATCH] mips: bpf: Fix broken BPF_MOD
Date: Mon, 1 Dec 2014 10:13:03 +0000
Message-ID: <547C3F2F.3070708@imgtec.com>
References: <1417427822-12729-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Denis Kirjanov <kda@linux-powerpc.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:55432 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbaLAKNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 05:13:06 -0500
In-Reply-To: <1417427822-12729-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2014 09:57 AM, Denis Kirjanov wrote:
> Remove optimize_div() from BPF_MOD | BPF_K case
> since we don't know the dividend and fix the
> emit_mod() by reading the mod operation result from HI register
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
>  arch/mips/net/bpf_jit.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
> index 9b55143..9fd6834 100644
> --- a/arch/mips/net/bpf_jit.c
> +++ b/arch/mips/net/bpf_jit.c
> @@ -426,7 +426,7 @@ static inline void emit_mod(unsigned int dst, unsigned int src,
>  		u32 *p = &ctx->target[ctx->idx];
>  		uasm_i_divu(&p, dst, src);
>  		p = &ctx->target[ctx->idx + 1];
> -		uasm_i_mflo(&p, dst);
> +		uasm_i_mfhi(&p, dst);

That looks correct.

>  	}
>  	ctx->idx += 2; /* 2 insts */
>  }
> @@ -971,7 +971,7 @@ load_ind:
>  			break;
>  		case BPF_ALU | BPF_MOD | BPF_K:
>  			/* A %= k */
> -			if (k == 1 || optimize_div(&k)) {
> +			if (k == 1) {
>  				ctx->flags |= SEEN_A;
>  				emit_jit_reg_move(r_A, r_zero, ctx);
>  			} else {
> 

That looks correct too. Thanks for fixing these.

Can you also CC stable for inclusion in >=3.16?

Reviewed-by: Markos Chandras <markos.chandras@imgtec.com>

-- 
markos
