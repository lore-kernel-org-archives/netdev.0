From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv2 perf/core 0/7] Libbpf improvements
Date: Tue, 24 Jan 2017 13:12:10 -0300
Message-ID: <20170124161210.GE10340@kernel.org>
References: <20170123011128.26534-1-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170123011128.26534-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Sun, Jan 22, 2017 at 05:11:21PM -0800, Joe Stringer escreveu:
> Patch 1 fixes an issue when using drastically different BPF map definitions
> inside ELFs from a client using libbpf, vs the map definition libbpf uses.
> 
> Patches 2-4 add some simple, useful helper functions for setting prog type
> and retrieving libbpf errors without depending on kernel headers from
> userspace programs.
> 
> Patches 5-7 add a new pinning functionality for maps, programs, and objects.
> Library users may call bpf_map__pin(map, path) or bpf_program__pin(prog, path)
> to pin maps and programs separately, or use bpf_object__pin(obj, path) to
> pin all maps and programs from the BPF object to the path. The map and program
> variations require a full path where it will be pinned in the filesystem,
> and the object variation will create directories "maps/" and "progs/" under
> the specified path, then mount each map and program under those subdirectories.

Merged the ones either acked by Wang or adjusted by you to address
Wang's remarks, the last ones introducing those __pin() methods, please
provide users together with those APIs, preferably entries for 'perf
test',

- Arnaldo
 
> ---
> v1: Initial post.
> v2: Wang Nan provided improvements to patch 1.
>     Dropped patch 2 from v1.
>     Added acks for acked patches.
>     Split the bpf_obj__pin() to also provide map / program pinning APIs.
>     Allow users to provide full filesystem path (don't autodetect/mount BPFFS).
> 
> Joe Stringer (7):
>   tools lib bpf: Fix map offsets in relocation
>   tools lib bpf: Define prog_type fns with macro
>   tools lib bpf: Add set/is helpers for all prog types
>   tools lib bpf: Add libbpf_get_error()
>   tools lib bpf: Add bpf_program__pin()
>   tools lib bpf: Add bpf_map__pin()
>   tools lib bpf: Add bpf_object__pin()
> 
>  tools/lib/bpf/libbpf.c  | 240 ++++++++++++++++++++++++++++++++++++++++++------
>  tools/lib/bpf/libbpf.h  |  17 +++-
>  tools/perf/tests/llvm.c |   2 +-
>  3 files changed, 229 insertions(+), 30 deletions(-)
> 
> -- 
> 2.11.0
