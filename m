From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Thu, 14 Apr 2011 18:41:47 +0300
Message-ID: <4DA715BB.6050307@redhat.com>
References: <1301783301.2837.77.camel@edumazet-laptop> <1301784797.3110.4.camel@localhost> <1301838968.2837.200.camel@edumazet-laptop> <4DA70743.1050106@redhat.com> <0a7fdea6b816da546ea71f752d36b5c2@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757353Ab1DNPmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 11:42:02 -0400
In-Reply-To: <0a7fdea6b816da546ea71f752d36b5c2@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2011 05:55 PM, Hagen Paul Pfeifer wrote:
> On Thu, 14 Apr 2011 17:40:03 +0300, Avi Kivity<avi@redhat.com>  wrote:
>
> >  Have you considered putting the compiler in userspace?
>
> Kernelspace (modules, threads, etc) can register BPF filters too. It is
> possible that there is no userspace involved at all.

A userspace jit would still work just fine, no?  I don't want the user 
who supplied the program to also supply the jit; rather, when the kernel 
installs the bpf program, it also asks an independent userspace compiler 
to translate it.

> >  The upside is that you can use established optimizing compilers like
> >  LLVM or GCC, which already support more target architectures.  It may
> >  not matter much for something simple like bpf, but other VMs may be a
> >  lot more complicated.
>
> BPF is another domain. Standard compiler optimization are not comparable
> to BPF optimizations so there is no gain there. Maybe writing a gcc front
> _and_ back-end may gain some valuable advantages.

I'm talking about optimizing the generated code.  For example, bpf has 
just two registers so a complex program generates a lot of loads and 
stores.  An optimizing compiler can use extra target registers to avoid 
those spills, and doesn't need to keep A and X in fixed registers.

If you translate the bpf program to C and optimize that with gcc you'll 
probably get much better machine code that the jit in the patch.

-- 
error compiling committee.c: too many arguments to function

