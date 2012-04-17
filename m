From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] net: filter: Just In Time compiler for sparc
Date: Tue, 17 Apr 2012 19:02:22 +0200
Message-ID: <4F8DA21E.9020809@computer.org>
References: <20120416.225823.1395194623649559124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20120416.225823.1395194623649559124.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>
> Signed-off-by: David S. Miller<davem@davemloft.net>
> ---
>
> I think I'll commit this to net-next so it's easier to track
> any BPF changes we make there.

I hate to nitpick; see below.

> +	bl	bpf_slow_path_word_neg
> +	 nop
> +	.globl	bpf_jit_load_word_positive_offset
> +bpf_jit_load_word_positive_offset:
> +	sub	r_HEADLEN, r_OFF, r_TMP
> +	cmp	r_TMP, 3
> +	ble	bpf_slow_path_word
> +	 add	r_SKB_DATA, r_OFF, r_TMP
> +	andcc	r_TMP, 3, %g0
> +	bne	load_word_unaligned
> +	 nop
> +	retl
> +	 ld	[r_SKB_DATA + r_OFF], r_A

There is inconsistent spacing in multiple places; a few examples shown 
above.

KR, Jan
