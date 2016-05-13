From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: [PATCH] arm64: bpf: jit JMP_JSET_{X,K}
Date: Fri, 13 May 2016 09:23:02 -0700
Message-ID: <5a03c0b4-7686-6232-9c64-c6ec0f30edae@linaro.org>
References: <1463121478-18484-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Zi Shen Lim <zlim.lnx@gmail.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35800 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbcEMQXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 12:23:05 -0400
Received: by mail-pf0-f173.google.com with SMTP id 77so43810638pfv.2
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 09:23:04 -0700 (PDT)
In-Reply-To: <1463121478-18484-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/2016 11:37 PM, Zi Shen Lim wrote:
> Original implementation commit e54bcde3d69d ("arm64: eBPF JIT compiler")
> had the relevant code paths, but due to an oversight always fail jiting.
>
> As a result, we had been falling back to BPF interpreter whenever a BPF
> program has JMP_JSET_{X,K} instructions.
>
> With this fix, we confirm that the corresponding tests in lib/test_bpf
> continue to pass, and also jited.
>
> ...
> [    2.784553] test_bpf: #30 JSET jited:1 188 192 197 PASS
> [    2.791373] test_bpf: #31 tcpdump port 22 jited:1 325 677 625 PASS
> [    2.808800] test_bpf: #32 tcpdump complex jited:1 323 731 991 PASS
> ...
> [    3.190759] test_bpf: #237 JMP_JSET_K: if (0x3 & 0x2) return 1 jited:1 110 PASS
> [    3.192524] test_bpf: #238 JMP_JSET_K: if (0x3 & 0xffffffff) return 1 jited:1 98 PASS
> [    3.211014] test_bpf: #249 JMP_JSET_X: if (0x3 & 0x2) return 1 jited:1 120 PASS
> [    3.212973] test_bpf: #250 JMP_JSET_X: if (0x3 & 0xffffffff) return 1 jited:1 89 PASS
> ...
>
> Fixes: e54bcde3d69d ("arm64: eBPF JIT compiler")
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>

Acked-by: Yang Shi <yang.shi@linaro.org>

Thanks,
Yang

> ---
>  arch/arm64/net/bpf_jit_comp.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
> index 031ed08..d0d5190 100644
> --- a/arch/arm64/net/bpf_jit_comp.c
> +++ b/arch/arm64/net/bpf_jit_comp.c
> @@ -478,6 +478,7 @@ emit_cond_jmp:
>  		case BPF_JGE:
>  			jmp_cond = A64_COND_CS;
>  			break;
> +		case BPF_JSET:
>  		case BPF_JNE:
>  			jmp_cond = A64_COND_NE;
>  			break;
>
