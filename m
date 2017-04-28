From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH v2 binutils] Add BPF support to binutils...
Date: Fri, 28 Apr 2017 13:09:17 -0400
Message-ID: <f7tfugssblu.fsf@redhat.com>
References: <20170427.170934.891283291562287326.davem@davemloft.net>
        <f7td1bwtthr.fsf@redhat.com>
        <20170428.120457.408834081300892396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36397 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424813AbdD1RJV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 13:09:21 -0400
Received: by mail-qk0-f196.google.com with SMTP id y63so9767663qkd.3
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 10:09:21 -0700 (PDT)
In-Reply-To: <20170428.120457.408834081300892396.davem@davemloft.net> (David
        Miller's message of "Fri, 28 Apr 2017 12:04:57 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Aaron Conole <aconole@bytheb.org>
> Date: Fri, 28 Apr 2017 11:57:36 -0400
>
>> I'll get an arm board up and running to do some testing there.  As a
>> teaser:
>
> Great.
>
> I started working on some more relocation stuff, so more of the
> generic gas tests pass.
>
> For example, stuff like this now works properly:
>
> [davem@dhcp-10-15-49-210 build-bpf]$ cat gas/y.s
> 	.data
> 	.globl	foo
> foo:	.xword	bar
> [davem@dhcp-10-15-49-210 build-bpf]$ gas/as-new -o gas/y.o gas/y.s
> [davem@dhcp-10-15-49-210 build-bpf]$ binutils/objdump -r gas/y.o
>
> gas/y.o:     file format elf64-bpfle
>
> RELOCATION RECORDS FOR [.data]:
> OFFSET           TYPE              VALUE 
> 0000000000000000 R_BPF_DATA_64     bar
>
>
> [davem@dhcp-10-15-49-210 build-bpf]$
>
> It turned out that I needed to separate the R_BPF_* relocations into
> data vs. insn ones.
>
> Another idea I am thinking about pursuing is adding BPF simulator
> support under sim/ so that people can use gdb to step through BPF
> programs.
>
> I hope we can make it work in a way that we can even step through
> XDP programs and feed them simple test packets, stuff like that.
>
> Anyways, quick relative live patch against v2 from my tree for the
> reloc stuff:
>
> diff --git a/bfd/elf64-bpf.c b/bfd/elf64-bpf.c
> index 9944bb4..1be285d 100644
> --- a/bfd/elf64-bpf.c
> +++ b/bfd/elf64-bpf.c
> @@ -1,8 +1,89 @@
>  #include "sysdep.h"
>  #include "bfd.h"
> +#include "bfdlink.h"
>  #include "libbfd.h"
> +#include "libiberty.h"
>  #include "elf-bfd.h"
> +#include "elf/bpf.h"
>  #include "opcode/bpf.h"
> +#include "objalloc.h"
> +#include "elf64-bpf.h"

I get a compile error here.  I guess this file wasn't included.
