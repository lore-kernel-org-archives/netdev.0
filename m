From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCHv3 perf/core 5/7] samples/bpf: Switch over to libbpf
Date: Fri, 9 Dec 2016 13:04:49 +0800
Message-ID: <c256e266-14c0-d546-cf61-264035ed6282@huawei.com>
References: <20161209024620.31660-1-joe@ovn.org>
 <20161209024620.31660-6-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <daniel@iogearbox.net>, <acme@kernel.org>,
        <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209024620.31660-6-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/12/9 10:46, Joe Stringer wrote:
> Now that libbpf under tools/lib/bpf/* is synced with the version from
> samples/bpf, we can get rid most of the libbpf library here.
>
> Signed-off-by: Joe Stringer <joe@ovn.org>
> ---
> v3: First post.
> ---
>   samples/bpf/Makefile   |  60 +++++++++++++-------------
>   samples/bpf/README.rst |   4 +-
>   samples/bpf/libbpf.c   | 111 -------------------------------------------------
>   samples/bpf/libbpf.h   |  19 +--------
>   tools/lib/bpf/Makefile |   2 +
>   5 files changed, 38 insertions(+), 158 deletions(-)
>
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index 72c58675973e..c8f7ed37b2de 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -29,35 +29,38 @@ hostprogs-y += trace_event
>   hostprogs-y += sampleip
>   hostprogs-y += tc_l2_redirect
>   
> -test_verifier-objs := test_verifier.o libbpf.o
> -test_maps-objs := test_maps.o libbpf.o
> -sock_example-objs := sock_example.o libbpf.o
> -fds_example-objs := bpf_load.o libbpf.o fds_example.o
> -sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
> -sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
> -sockex3-objs := bpf_load.o libbpf.o sockex3_user.o
> -tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
> -tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
> -tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
> -tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
> -tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
> -tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
> -test_probe_write_user-objs := bpf_load.o libbpf.o test_probe_write_user_user.o
> -trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
> -lathist-objs := bpf_load.o libbpf.o lathist_user.o
> -offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
> -spintest-objs := bpf_load.o libbpf.o spintest_user.o
> -map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
> -test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
> -test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
> -xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
> +# Libbpf dependencies
> +LIBBPF := libbpf.o ../../tools/lib/bpf/bpf.o
> +
> +test_verifier-objs := test_verifier.o $(LIBBPF)
> +test_maps-objs := test_maps.o $(LIBBPF)
> +sock_example-objs := sock_example.o $(LIBBPF)
> +fds_example-objs := bpf_load.o $(LIBBPF) fds_example.o
> +sockex1-objs := bpf_load.o $(LIBBPF) sockex1_user.o
> +sockex2-objs := bpf_load.o $(LIBBPF) sockex2_user.o
> +sockex3-objs := bpf_load.o $(LIBBPF) sockex3_user.o
> +tracex1-objs := bpf_load.o $(LIBBPF) tracex1_user.o
> +tracex2-objs := bpf_load.o $(LIBBPF) tracex2_user.o
> +tracex3-objs := bpf_load.o $(LIBBPF) tracex3_user.o
> +tracex4-objs := bpf_load.o $(LIBBPF) tracex4_user.o
> +tracex5-objs := bpf_load.o $(LIBBPF) tracex5_user.o
> +tracex6-objs := bpf_load.o $(LIBBPF) tracex6_user.o
> +test_probe_write_user-objs := bpf_load.o $(LIBBPF) test_probe_write_user_user.o
> +trace_output-objs := bpf_load.o $(LIBBPF) trace_output_user.o
> +lathist-objs := bpf_load.o $(LIBBPF) lathist_user.o
> +offwaketime-objs := bpf_load.o $(LIBBPF) offwaketime_user.o
> +spintest-objs := bpf_load.o $(LIBBPF) spintest_user.o
> +map_perf_test-objs := bpf_load.o $(LIBBPF) map_perf_test_user.o
> +test_overhead-objs := bpf_load.o $(LIBBPF) test_overhead_user.o
> +test_cgrp2_array_pin-objs := $(LIBBPF) test_cgrp2_array_pin.o
> +xdp1-objs := bpf_load.o $(LIBBPF) xdp1_user.o
>   # reuse xdp1 source intentionally
> -xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
> -test_current_task_under_cgroup-objs := bpf_load.o libbpf.o \
> +xdp2-objs := bpf_load.o $(LIBBPF) xdp1_user.o
> +test_current_task_under_cgroup-objs := bpf_load.o $(LIBBPF) \
>   				       test_current_task_under_cgroup_user.o
> -trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
> -sampleip-objs := bpf_load.o libbpf.o sampleip_user.o
> -tc_l2_redirect-objs := bpf_load.o libbpf.o tc_l2_redirect_user.o
> +trace_event-objs := bpf_load.o $(LIBBPF) trace_event_user.o
> +sampleip-objs := bpf_load.o $(LIBBPF) sampleip_user.o
> +tc_l2_redirect-objs := bpf_load.o $(LIBBPF) tc_l2_redirect_user.o
>   
>   # Tell kbuild to always build the programs
>   always := $(hostprogs-y)
> @@ -89,7 +92,7 @@ always += test_current_task_under_cgroup_kern.o
>   always += trace_event_kern.o
>   always += sampleip_kern.o
>   
> -HOSTCFLAGS += -I$(objtree)/usr/include
> +HOSTCFLAGS += -I$(objtree)/usr/include -I$(objtree)/tools/lib/
>   

Should use srctree like this:

+HOSTCFLAGS += -I$(objtree)/usr/include -I$(srctree)/tools/lib/

Or you will see following failure when doing off-tree build:

  $ mkdir buildkernel
  $ cd buildkernel
  $ make -C ../ O=`pwd` menuconfig
  $ make -j64
  $ make samples/bpf/
   CHK     include/config/kernel.release
   Using .. as source for kernel
   GEN     ./Makefile
   CHK     include/generated/uapi/linux/version.h
   CHK     include/generated/utsrelease.h
   CHK     include/generated/bounds.h
   CHK     include/generated/timeconst.h
   CHK     include/generated/asm-offsets.h
   CALL    ../scripts/checksyscalls.sh
   HOSTCC  samples/bpf/test_verifier.o
  In file included from ../samples/bpf/test_verifier.c:20:0:
  ../samples/bpf/libbpf.h:5:21: fatal error: bpf/bpf.h: No such file or 
directory
   #include <bpf/bpf.h>
                       ^
  compilation terminated.
  make[3]: *** [samples/bpf/test_verifier.o] Error 1
  make[2]: *** [samples/bpf/] Error 2
  make[1]: *** [sub-make] Error 2
  make: *** [__sub-make] Error 2

>   HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
>   HOSTLOADLIBES_fds_example += -lelf
> @@ -123,6 +126,7 @@ CLANG ?= clang
>   
>   # Trick to allow make to be run from this directory
>   all:
> +	$(MAKE) -C ../../ tools/lib/bpf/
>   	$(MAKE) -C ../../ $$PWD/
>   
>   clean:

[SNIP]

>   
> diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
> index 62d89d50fcbd..616bd55f3be8 100644
> --- a/tools/lib/bpf/Makefile
> +++ b/tools/lib/bpf/Makefile
> @@ -149,6 +149,8 @@ CMD_TARGETS = $(LIB_FILE)
>   
>   TARGETS = $(CMD_TARGETS)
>   
> +libbpf: all
> +

Why we need this? I tested this patch without it and it seems to work, and
this line causes an extra error:
  $ pwd
  /home/wn/kernel/tools/lib/bpf
  $ make libbpf
  ...
  gcc -g -Wall -DHAVE_LIBELF_MMAP_SUPPORT -DHAVE_ELF_GETPHDRNUM_SUPPORT 
-Wbad-function-cast -Wdeclaration-after-statement -Wformat-security 
-Wformat-y2k -Winit-self -Wmissing-declarations -Wmissing-prototypes 
-Wnested-externs -Wno-system-headers -Wold-style-definition -Wpacked 
-Wredundant-decls -Wshadow -Wstrict-aliasing=3 -Wstrict-prototypes 
-Wswitch-default -Wswitch-enum -Wundef -Wwrite-strings -Wformat -Werror 
-Wall -fPIC -I. -I/home/wn/kernel-hydrogen/tools/include 
-I/home/wn/kernel-hydrogen/tools/arch/x86/include/uapi 
-I/home/wn/kernel-hydrogen/tools/include/uapi    libbpf.c all   -o libbpf
  gcc: error: all: No such file or directory
  make: *** [libbpf] Error 1

Thank you.
