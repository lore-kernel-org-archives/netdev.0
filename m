From: Mircea Gherzan <mgherzan@gmail.com>
Subject: Re: [PATCH net-next 1/2] ARM: net: bpf_jit_32: add XOR instruction
 for BPF JIT
Date: Wed, 14 Nov 2012 00:00:04 +0100
Message-ID: <50A2D0F4.3090202@gmail.com>
References: <20121108012828.GA23143@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Daniel Borkmann <dxchgb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:34769 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab2KMXAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 18:00:08 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so131707eaa.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 15:00:07 -0800 (PST)
In-Reply-To: <20121108012828.GA23143@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 08.11.2012 02:28, schrieb Daniel Borkmann:
> This patch is a follow-up for patch "filter: add XOR instruction for use
> with X/K" that implements BPF ARM JIT parts for the BPF XOR operation.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
> Cc: Mircea Gherzan <mgherzan@gmail.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>  arch/arm/net/bpf_jit_32.c |   15 ++++++++++-----
>  arch/arm/net/bpf_jit_32.h |    2 ++
>  2 files changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
> index c641fb6..8be702d 100644
> --- a/arch/arm/net/bpf_jit_32.c
> +++ b/arch/arm/net/bpf_jit_32.c
> @@ -646,6 +646,16 @@ load_ind:
>  			update_on_xread(ctx);
>  			emit(ARM_ORR_R(r_A, r_A, r_X), ctx);
>  			break;
> +		case BPF_S_ALU_XOR_K:
> +			/* A ^= K; */
> +			OP_IMM3(ARM_EOR, r_A, r_A, k, ctx);
> +			break;
> +		case BPF_S_ANC_ALU_XOR_X:
> +		case BPF_S_ALU_XOR_X:
> +			/* A ^= X */
> +			update_on_xread(ctx);
> +			emit(ARM_EOR_R(r_A, r_A, r_X), ctx);
> +			break;
>  		case BPF_S_ALU_AND_K:
>  			/* A &= K */
>  			OP_IMM3(ARM_AND, r_A, r_A, k, ctx);
> @@ -762,11 +772,6 @@ b_epilogue:
>  			update_on_xread(ctx);
>  			emit(ARM_MOV_R(r_A, r_X), ctx);
>  			break;
> -		case BPF_S_ANC_ALU_XOR_X:
> -			/* A ^= X */
> -			update_on_xread(ctx);
> -			emit(ARM_EOR_R(r_A, r_A, r_X), ctx);
> -			break;
>  		case BPF_S_ANC_PROTOCOL:
>  			/* A = ntohs(skb->protocol) */
>  			ctx->seen |= SEEN_SKB;
> diff --git a/arch/arm/net/bpf_jit_32.h b/arch/arm/net/bpf_jit_32.h
> index 7fa2f7d..afb8462 100644
> --- a/arch/arm/net/bpf_jit_32.h
> +++ b/arch/arm/net/bpf_jit_32.h
> @@ -69,6 +69,7 @@
>  #define ARM_INST_CMP_I		0x03500000
>  
>  #define ARM_INST_EOR_R		0x00200000
> +#define ARM_INST_EOR_I		0x02200000
>  
>  #define ARM_INST_LDRB_I		0x05d00000
>  #define ARM_INST_LDRB_R		0x07d00000
> @@ -135,6 +136,7 @@
>  #define ARM_CMP_I(rn, imm)	_AL3_I(ARM_INST_CMP, 0, rn, imm)
>  
>  #define ARM_EOR_R(rd, rn, rm)	_AL3_R(ARM_INST_EOR, rd, rn, rm)
> +#define ARM_EOR_I(rd, rn, imm)	_AL3_I(ARM_INST_EOR, rd, rn, imm)
>  
>  #define ARM_LDR_I(rt, rn, off)	(ARM_INST_LDR_I | (rt) << 12 | (rn) << 16 \
>  				 | (off))

Acked-by: Mircea Gherzan <mgherzan@gmail.com>
