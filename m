From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH RFC 2/3] samples/bpf: Add define __EMITTING_BPF__ when
 building BPF
Date: Fri, 16 Jun 2017 12:24:06 +0200
Message-ID: <5943B1C6.7040809@iogearbox.net>
References: <20170615223543.22867-1-david.daney@cavium.com> <20170615223543.22867-3-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org, Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615223543.22867-3-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/16/2017 12:35 AM, David Daney wrote:
> ... this allows gating of inline assembly code that causes llvm to
> fail when emitting BPF.
>
> Signed-off-by: David Daney <david.daney@cavium.com>

I don't have a better idea at the moment, perhaps there could be
a clang rewrite plugin that would ignore all inline assembly code
since this is never used from BPF progs. Hmm. Really ugly that
we have to add this __EMITTING_BPF__ into arch asm files, but I
don't have a better idea for an immediate workaround right now ...
I would really prefer if we could avoid just for the sake of the
kernel samples going down the road of adding a !defined(__EMITTING_BPF__)
into a uapi asm header for mips, though. Is this coming from
networking sample code or rather tracing?

> ---
>   samples/bpf/Makefile | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index a0561dc762fe..4979e6b56662 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -193,12 +193,12 @@ $(src)/*.c: verify_target_bpf
>
>   $(obj)/tracex5_kern.o: $(obj)/syscall_nrs.h
>
> -# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
> -# But, there is no easy way to fix it, so just exclude it since it is
> -# useless for BPF samples.
> +# __EMITTING_BPF__ used to exclude inline assembly, which cannot be
> +# emitted in BPF code.
>   $(obj)/%.o: $(src)/%.c
>   	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
> -		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> +		-D__KERNEL__ -D__EMITTING_BPF__ \
> +		-Wno-unused-value -Wno-pointer-sign \
>   		-Wno-compare-distinct-pointer-types \
>   		-Wno-gnu-variable-sized-type-not-at-end \
>   		-Wno-address-of-packed-member -Wno-tautological-compare \
>
