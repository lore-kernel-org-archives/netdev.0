From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 4/4] filter: add minimal BPF JIT emitted
 image disassembler
Date: Tue, 19 Mar 2013 09:43:10 -0700
Message-ID: <1363711390.2558.20.camel@edumazet-glaptop>
References: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
	 <1363711172-9728-5-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:55991 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932839Ab3CSQnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 12:43:12 -0400
Received: by mail-da0-f46.google.com with SMTP id y19so415383dan.33
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 09:43:12 -0700 (PDT)
In-Reply-To: <1363711172-9728-5-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 17:39 +0100, Daniel Borkmann wrote:
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
>  scripts/bpf_jit_disasm.c | 216 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 216 insertions(+)
>  create mode 100644 scripts/bpf_jit_disasm.c

Acked-by: Eric Dumazet <edumazet@google.com>
