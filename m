From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v7 5/5] samples/bpf: example of get selected PMU counter
 value
Date: Tue, 11 Aug 2015 18:59:46 -0700
Message-ID: <55CAA892.80403@plumgrid.com>
References: <1438844556-27064-1-git-send-email-xiakaixu@huawei.com>
 <1438844556-27064-6-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33983 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbbHLB7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 21:59:48 -0400
Received: by iodb91 with SMTP id b91so6367448iod.1
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 18:59:48 -0700 (PDT)
In-Reply-To: <1438844556-27064-6-git-send-email-xiakaixu@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/6/15 12:02 AM, Kaixu Xia wrote:
> This is a simple example and shows how to use the new ability
> to get the selected Hardware PMU counter value.
>
> Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
> ---
>   samples/bpf/Makefile       |  4 +++
>   samples/bpf/bpf_helpers.h  |  2 ++
>   samples/bpf/tracex6_kern.c | 26 ++++++++++++++++++
>   samples/bpf/tracex6_user.c | 68 +++++++++++++++++++++++++++++++++++=
+++++++++++

1.
I see a bunch of warnings building it:
   HOSTCC  samples/bpf/tracex6_user.o
=2E./samples/bpf/tracex6_user.c: In function =91test_bpf_perf_event=92:
=2E./samples/bpf/tracex6_user.c:49:2: warning: passing argument 1 of=20
=91close=92 makes integer from pointer without a cast [enabled by defau=
lt]
In file included from ../samples/bpf/tracex6_user.c:2:0:
/usr/include/unistd.h:354:12: note: expected =91int=92 but argument is =
of=20
type =91int *=92
=2E./samples/bpf/tracex6_user.c:20:16: warning: unused variable =91valu=
e=92=20
[-Wunused-variable]
=2E./samples/bpf/tracex6_user.c:42:8: warning: ignoring return value of=
=20
=91system=92, declared with attribute warn_unused_result [-Wunused-resu=
lt]
=2E./samples/bpf/tracex6_user.c:43:8: warning: ignoring return value of=
=20
=91system=92, declared with attribute warn_unused_result [-Wunused-resu=
lt]
=2E./samples/bpf/tracex6_user.c:44:8: warning: ignoring return value of=
=20
=91system=92, declared with attribute warn_unused_result [-Wunused-resu=
lt]
   HOSTLD  samples/bpf/tracex6
   HOSTCC  samples/bpf/lathist_user.o
   HOSTLD  samples/bpf/lathist
clang  -nostdinc -isystem /usr/lib/gcc/x86_64-linux-gnu/4.7/include=20
-I../arch/x86/include -Iarch/x86/include/generated/uapi=20
-Iarch/x86/include/generated  -I../include -Iinclude=20
-I../arch/x86/include/uapi -Iarch/x86/include/generated/uapi=20
-I../include/uapi -Iinclude/generated/uapi -include=20
=2E./include/linux/kconfig.h  \
		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
		-O2 -emit-llvm -c ../samples/bpf/tracex6_kern.c -o -|=20
=2E./tools/bpf/llvm/bld/Debug+Asserts/bin/llc -march=3Dbpf -filetype=3D=
obj -o=20
samples/bpf/tracex6_kern.o
=2E./samples/bpf/tracex6_kern.c:13:22: warning: declaration of 'struct=20
pt_regs' will not be visible outside of this function [-Wvisibility]
int bpf_prog1(struct pt_regs *ctx)

Please fix.

2.
the example is incomplete.
Please add read_trace_pipe() otherwise it exits without printing
anything useful.

3.
please replace ls and pwd with ls > /dev/null
the spam on the screen is unnecessary.
