From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 net-next] arm: eBPF JIT compiler
Date: Tue, 22 Aug 2017 17:08:23 +0200
Message-ID: <599C48E7.3000409@iogearbox.net>
References: <1503383772-5788-1-git-send-email-illusionist.neo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        keescook@chromium.org
To: Shubham Bansal <illusionist.neo@gmail.com>, linux@armlinux.org.uk,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503383772-5788-1-git-send-email-illusionist.neo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/22/2017 08:36 AM, Shubham Bansal wrote:
[...]
> +
> +static int out_offset = -1; /* initialized on the first pass of build_body() */

Hm, why is this a global var actually? There can be
multiple parallel calls to bpf_int_jit_compile(), we
don't take a global lock on this. Unless I'm missing
something this should really reside in jit_ctx, no?

Given this is on emit_bpf_tail_call(), did you get
tail calls working the way I suggested to test?

> +static int emit_bpf_tail_call(struct jit_ctx *ctx)
>   {
[...]
> +	const int idx0 = ctx->idx;
> +#define cur_offset (ctx->idx - idx0)
> +#define jmp_offset (out_offset - (cur_offset))
[...]
> +
> +	/* out: */
> +	if (out_offset == -1)
> +		out_offset = cur_offset;
> +	if (cur_offset != out_offset) {
> +		pr_err_once("tail_call out_offset = %d, expected %d!\n",
> +			    cur_offset, out_offset);
> +		return -1;
> +	}
> +	return 0;
> +#undef cur_offset
> +#undef jmp_offset
>   }
