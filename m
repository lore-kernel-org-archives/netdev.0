From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: [RESEND PATCH] arm64: bpf: add 'store immediate' instruction
Date: Tue, 01 Dec 2015 14:20:40 -0800
Message-ID: <565E1D38.7020906@linaro.org>
References: <1448922247-5692-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: ast@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448922247-5692-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/2015 2:24 PM, Yang Shi wrote:
> aarch64 doesn't have native store immediate instruction, such operation
> has to be implemented by the below instruction sequence:
>
> Load immediate to register
> Store register
>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>

Had email exchange offline with Zi Shen Lim since he is traveling and 
cannot send text-only mail, quoted below for his reply:

"I've given reviewed-by in response to original posting. Unless 
something has changed, feel free to add it."

Since there is nothing changed, added his reviewed-by.

Reviewed-by: Zi Shen Lim <zlim.lnx@gmail.com>

Thanks,
Yang

> CC: Xi Wang <xi.wang@gmail.com>
> ---
> Thsi patch might be buried by the storm of xadd discussion, however, it is
> absolutely irrelevent to xadd, so resend the patch itself.
>
>   arch/arm64/net/bpf_jit_comp.c | 20 +++++++++++++++++++-
>   1 file changed, 19 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
> index 6809647..49c1f1b 100644
> --- a/arch/arm64/net/bpf_jit_comp.c
> +++ b/arch/arm64/net/bpf_jit_comp.c
> @@ -563,7 +563,25 @@ emit_cond_jmp:
>   	case BPF_ST | BPF_MEM | BPF_H:
>   	case BPF_ST | BPF_MEM | BPF_B:
>   	case BPF_ST | BPF_MEM | BPF_DW:
> -		goto notyet;
> +		/* Load imm to a register then store it */
> +		ctx->tmp_used = 1;
> +		emit_a64_mov_i(1, tmp2, off, ctx);
> +		emit_a64_mov_i(1, tmp, imm, ctx);
> +		switch (BPF_SIZE(code)) {
> +		case BPF_W:
> +			emit(A64_STR32(tmp, dst, tmp2), ctx);
> +			break;
> +		case BPF_H:
> +			emit(A64_STRH(tmp, dst, tmp2), ctx);
> +			break;
> +		case BPF_B:
> +			emit(A64_STRB(tmp, dst, tmp2), ctx);
> +			break;
> +		case BPF_DW:
> +			emit(A64_STR64(tmp, dst, tmp2), ctx);
> +			break;
> +		}
> +		break;
>
>   	/* STX: *(size *)(dst + off) = src */
>   	case BPF_STX | BPF_MEM | BPF_W:
>
