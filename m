From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [KJ] [patch] net/tipc: sprintf/strcpy conversion
Date: Fri, 3 Nov 2006 11:50:47 +0100
Message-ID: <20061103105047.GA16343@c3po.0xdef.net>
References: <20061101140624.GA7694@Chamillionaire.breakpoint.cc> <20061103000905.GA4957@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: kernel-janitors@lists.osdl.org,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c3po.0xdef.net ([217.172.181.57]:3847 "EHLO c3po.0xdef.net")
	by vger.kernel.org with ESMTP id S1753208AbWKCKus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 05:50:48 -0500
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20061103000905.GA4957@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Alexey Dobriyan | 2006-11-03 03:09:05 [+0300]:

>On Wed, Nov 01, 2006 at 03:06:24PM +0100, Florian Westphal wrote:
>> convert sprintf(a,b) to strcpy(a,b). Make tipc_bclink_name[] const.
>
>Ahhh, I missed the start of threads.
>
>Patch is useless because it changes one unbounded string function into
>another unbounded string function.

The discussion in this thread is really back-breaking!

1. To make tipc_bclink_name const there is absolutly no objection
2. Replace sprintf with strcpy

  a) First of all: If you _copy_ a string then use also strCPY()
     Thats a question of good style!

  b) If the compiler is smart enough, he realize that you want to copy 
     a string and replace the sprintf call with a
        pushl   %ebx
        call    strcpy
     Surprise - Surprise!

     Assumed you use gcc with -Os or -O2! Don't know how icc handle this 
     case. If you compile without optimization you save at least a
     "repz movsb %ds:(%esi),%es:(%edi)" instruction.

   c) Last but not least I read all the time this patch doesn't introduce
      bounds-checking. This isn't a argument because the author is aware of
      the destination length of the buffer. BTW: grep for (sprintf|strcpy) in
      /usr/src/linux and be surprised how unsecure the kernel is (thats
      ironical).

This patch is 100% OK!

HGN



