From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 2/4] samples/bpf: Use llc in PATH, rather than a hardcoded
 value
Date: Thu, 31 Mar 2016 10:46:37 -0700
Message-ID: <56FD627D.5080405@fb.com>
References: <922f95fb5d16686367a66d2d4bd176149a87e9ad.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <ba23d688b3550c3f22dd0dd6d5cb1233c2f34816.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ba23d688b3550c3f22dd0dd6d5cb1233c2f34816.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/31/16 4:25 AM, Naveen N. Rao wrote:
> While at it, fix some typos in the comment.
>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> ---
>   samples/bpf/Makefile | 11 ++++-------
>   1 file changed, 4 insertions(+), 7 deletions(-)
>
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index 502c9fc..88bc5a0 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -76,16 +76,13 @@ HOSTLOADLIBES_offwaketime += -lelf
>   HOSTLOADLIBES_spintest += -lelf
>   HOSTLOADLIBES_map_perf_test += -lelf -lrt
>
> -# point this to your LLVM backend with bpf support
> -LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
> -
> -# asm/sysreg.h inline assmbly used by it is incompatible with llvm.
> -# But, ehere is not easy way to fix it, so just exclude it since it is
> +# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
> +# But, there is no easy way to fix it, so just exclude it since it is
>   # useless for BPF samples.
>   $(obj)/%.o: $(src)/%.c
>   	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
>   		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> -		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
> +		-O2 -emit-llvm -c $< -o -| llc -march=bpf -filetype=obj -o $@
>   	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
>   		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> -		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=asm -o $@.s
> +		-O2 -emit-llvm -c $< -o -| llc -march=bpf -filetype=asm -o $@.s

that was a workaround when clang/llvm didn't have bpf support.
Now clang 3.7 and 3.8 have bpf built-in, so make sense to remove
manual calls to llc completely.
Just use 'clang -target bpf -O2 -D... -c $< -o $@'
