From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] Add -target to clang switches while cross compiling.
Date: Thu, 12 Oct 2017 15:23:04 -0700
Message-ID: <20171012222302.3zlndmcm7ixywbs6@ast-mbp>
References: <1507841157-10487-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, yhs@fb.com
To: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507841157-10487-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2017 at 01:45:57PM -0700, Abhijit Ayarekar wrote:
> Latest llvm update excludes assembly instructions.
> As a result __ASM_SYSREGS_H define is not required.
> -target switch includes appropriate target specific files.
> 
> Tested on x86 and arm64 with llvm with git revision
> commit df6ca162269f9d756f8742bf4b658dcf690e3eb5
> Author: Yonghong Song <yhs@fb.com>
> Date:   Thu Sep 28 02:46:11 2017 +0000
> 
>     bpf: add new insns for bswap_to_le and negation
> 
> Signed-off-by: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>
> ---
>  samples/bpf/Makefile | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index ebc2ad6..81f9fcd 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -180,6 +180,7 @@ CLANG ?= clang
>  # Detect that we're cross compiling and use the cross compiler
>  ifdef CROSS_COMPILE
>  HOSTCC = $(CROSS_COMPILE)gcc
> +CLANG_ARCH_ARGS = -target $(ARCH)

this is only need because you're crosscompiling, right?
In native compilation it's unnecessary flag.
Only droping -D__ASM_SYSREG_H is enough, correct?

>  endif
>  
>  # Trick to allow make to be run from this directory
> @@ -229,9 +230,9 @@ $(obj)/tracex5_kern.o: $(obj)/syscall_nrs.h
>  $(obj)/%.o: $(src)/%.c
>  	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) -I$(obj) \
>  		-I$(srctree)/tools/testing/selftests/bpf/ \
> -		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> +		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
>  		-D__TARGET_ARCH_$(ARCH) -Wno-compare-distinct-pointer-types \
>  		-Wno-gnu-variable-sized-type-not-at-end \
>  		-Wno-address-of-packed-member -Wno-tautological-compare \
> -		-Wno-unknown-warning-option \
> +		-Wno-unknown-warning-option $(CLANG_ARCH_ARGS) \
>  		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
> -- 
> 2.7.4
> 
