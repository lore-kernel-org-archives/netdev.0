From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] lib: test_bpf: purge CPP register redefinitions
Date: Sun, 21 Jun 2015 23:05:27 -0700
Message-ID: <20150622060523.GA16156@Alexeis-MacBook-Pro.local>
References: <87twu0df3k.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Richard Weinberger <richard@nod.at>,
	daniel@iogearbox.net
To: Nicolai Stange <nicstange@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38197 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbbFVGFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 02:05:31 -0400
Content-Disposition: inline
In-Reply-To: <87twu0df3k.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 21, 2015 at 09:41:03PM +0200, Nicolai Stange wrote:
> Fix compilation failer with allmodconfig on ARCH=um:
>   lib/test_bpf.c:50:0: warning: "R8" redefined
>    #define R8  BPF_REG_8
>    ^
>   In file included from arch/um/include/asm/ptrace-generic.h:11:0,
>                    from arch/x86/um/asm/ptrace.h:8,
>                    from arch/x86/include/asm/alternative.h:8,
>                    from arch/x86/include/asm/bitops.h:16,
>                    from include/linux/bitops.h:36,
>                    from include/linux/kernel.h:10,
>                    from include/linux/list.h:8,
>                    from include/linux/module.h:9,
>                    from lib/test_bpf.c:19:
>   arch/x86/include/uapi/asm/ptrace-abi.h:42:0:
>     note: this is the location of the previous definition
>      #define R8 72
> 
> Get rid of the
>   #define Rx BPF_REG_x
> defines by substituting the Rx macros with their BPF_REG_x expansion
> in test_bpf.c.
> 
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>
> ---
> Tested:
>   - compilation for ARCH=x86_64 and ARCH=um
>   - 'modprobe test_bpf' on ARCH=x86_64
> 
>  lib/test_bpf.c | 2374 ++++++++++++++++++++++++++++----------------------------
>  1 file changed, 1193 insertions(+), 1181 deletions(-)

to get rid of warning you proposing to do 1k line renames?!
Just add:
+#undef R8
+#undef R9
+#undef R10
 #define R0             BPF_REG_0

Though I think the better fix woud be to clean up:
arch/x86/include/uapi/asm/ptrace-abi.h
What's the point of:
#define R8 72
from 'uapi' point of view?
Look like kernel details that shouldn't be exposed in uapi.
