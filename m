From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 1/4] samples/bpf: add back functionality to redefine
 LLC command
Date: Tue, 26 Apr 2016 13:36:59 +0200
Message-ID: <571F52DB.7050904@iogearbox.net>
References: <20160426110828.20716.13392.stgit@firesoul> <20160426110917.20716.43051.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com, linux-kbuild@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20160426110917.20716.43051.stgit@firesoul>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/26/2016 01:09 PM, Jesper Dangaard Brouer wrote:
> It is practical to be-able-to redefine the location of the LLVM
> command 'llc', because not all distros have a LLVM version with bpf
> target support.  Thus, it is sometimes required to compile LLVM from
> source, and sometimes it is not desired to overwrite the distros
> default LLVM version.
>
> This feature was removed with 128d1514be35 ("samples/bpf: Use llc in
> PATH, rather than a hardcoded value").
>
> Add this features back. Note that it is possible to redefine the LLC
> on the make command like:
>
>   make samples/bpf/ LLC=~/git/llvm/build/bin/llc
>
> Fixes: 128d1514be35 ("samples/bpf: Use llc in PATH, rather than a hardcoded value")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>   samples/bpf/Makefile |    6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index 744dd7a16144..5bae9536f100 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -81,10 +81,14 @@ HOSTLOADLIBES_spintest += -lelf
>   HOSTLOADLIBES_map_perf_test += -lelf -lrt
>   HOSTLOADLIBES_test_overhead += -lelf -lrt
>
> +# Allows pointing LLC to a LLVM backend with bpf support, redefine on cmdline:
> +#  make samples/bpf/ LLC=~/git/llvm/build/bin/llc
> +LLC ?= llc
> +
>   # asm/sysreg.h - inline assembly used by it is incompatible with llvm.
>   # But, there is no easy way to fix it, so just exclude it since it is
>   # useless for BPF samples.
>   $(obj)/%.o: $(src)/%.c
>   	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
>   		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> -		-O2 -emit-llvm -c $< -o -| llc -march=bpf -filetype=obj -o $@
> +		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@

Why not doing the same for clang? True that we're not using 'clang -target bpf'
here, but when someone builds llvm from git, it's very likely that clang is cloned
and built along with it.
