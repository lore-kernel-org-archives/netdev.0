From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 4/4] filter: add minimal BPF JIT emitted
 image disassembler
Date: Tue, 19 Mar 2013 08:05:59 -0700
Message-ID: <1363705559.2558.6.camel@edumazet-glaptop>
References: <cover.1363702456.git.dborkman@redhat.com>
	 <18e6abdb8689e02ac099f084d97666c63c22064a.1363702456.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com,
	Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:35912 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757015Ab3CSPGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 11:06:03 -0400
Received: by mail-pb0-f53.google.com with SMTP id un1so504388pbc.12
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 08:06:02 -0700 (PDT)
In-Reply-To: <18e6abdb8689e02ac099f084d97666c63c22064a.1363702456.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 15:34 +0100, Daniel Borkmann wrote:
> This is a minimal stand-alone user space helper, that allows for debugging or
> verification of emitted BPF JIT images. This is in particular useful for
> emitted opcode debugging, since minor bugs in the JIT compiler can be fatal.
> The disassembler is architecture generic and uses libopcodes and libbfd.
> 
> How to get to the disassembly, example:
> 
>   1) `echo 2 > /proc/sys/net/core/bpf_jit_enable`
>   2) Load a BPF filter (e.g. `tcpdump -p -n -s 0 -i eth1 host 192.168.20.0/24`)
>   3) Run e.g. `bpf_jit_disasm -o` to disassemble the most recent JIT code output
> 
> `bpf_jit_disasm -o` will display the related opcodes to a particular instruction
> as well. Example for x86_64:
> 
> $./bpf_jit_disasm
> 94 bytes emitted from JIT compiler (pass:3, flen:9)
> ffffffffa0356000 + <x>:
>    0:	push   %rbp
>    1:	mov    %rsp,%rbp
>    4:	sub    $0x60,%rsp
>    8:	mov    %rbx,-0x8(%rbp)
>    c:	mov    0x68(%rdi),%r9d
>   10:	sub    0x6c(%rdi),%r9d
>   14:	mov    0xe0(%rdi),%r8
>   1b:	mov    $0xc,%esi
>   20:	callq  0xffffffffe0d01b71
>   25:	cmp    $0x86dd,%eax
>   2a:	jne    0x000000000000003d
>   2c:	mov    $0x14,%esi
>   31:	callq  0xffffffffe0d01b8d
>   36:	cmp    $0x6,%eax
> [...]
>   5c:	leaveq
>   5d:	retq
> 
> $ ./bpf_jit_disasm -o
> 94 bytes emitted from JIT compiler (pass:3, flen:9)
> ffffffffa0356000 + <x>:
>    0:	push   %rbp
> 	55
>    1:	mov    %rsp,%rbp
> 	48 89 e5
>    4:	sub    $0x60,%rsp
> 	48 83 ec 60
>    8:	mov    %rbx,-0x8(%rbp)
> 	48 89 5d f8
>    c:	mov    0x68(%rdi),%r9d
> 	44 8b 4f 68
>   10:	sub    0x6c(%rdi),%r9d
> 	44 2b 4f 6c
> [...]
>   5c:	leaveq
> 	c9
>   5d:	retq
> 	c3
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---

Very useful, thanks Daniel !

Acked-by: Eric Dumazet <edumazet@google.com>
