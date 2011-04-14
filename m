From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Thu, 14 Apr 2011 17:40:03 +0300
Message-ID: <4DA70743.1050106@redhat.com>
References: <1301783301.2837.77.camel@edumazet-laptop>	 <1301784797.3110.4.camel@localhost> <1301838968.2837.200.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758813Ab1DNOkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 10:40:24 -0400
In-Reply-To: <1301838968.2837.200.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2011 04:56 PM, Eric Dumazet wrote:
> In order to speedup packet filtering, here is an implementation of a JIT
> compiler for x86_64
>

Have you considered putting the compiler in userspace?

You could have a trusted compile server waiting on a pipe and compiling 
programs sent to it by the kernel, sending the results back down.  Use 
the interpreter until the compiler returns; if it doesn't, use the 
interpreter forever.

The upside is that you can use established optimizing compilers like 
LLVM or GCC, which already support more target architectures.  It may 
not matter much for something simple like bpf, but other VMs may be a 
lot more complicated.

-- 
error compiling committee.c: too many arguments to function

