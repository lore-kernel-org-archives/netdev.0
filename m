From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] core: fix the use of this_cpu_ptr
Date: Thu, 28 Mar 2013 16:44:37 +0000
Message-ID: <0000013db1e303a2-0a69d056-fb98-4670-94fc-5c9d467fddef-000000@email.amazonses.com>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com> <1364475933.15753.36.camel@edumazet-glaptop> <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com> <1364484976.15753.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: roy.qing.li@gmail.com, Shan Wei <davidshan@tencent.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a10-13.smtp-out.amazonses.com ([54.240.10.13]:53547 "EHLO
	a10-13.smtp-out.amazonses.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756535Ab3C1Qvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 12:51:45 -0400
In-Reply-To: <1364484976.15753.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Mar 2013, Eric Dumazet wrote:

> On Thu, 2013-03-28 at 14:38 +0000, Christoph Lameter wrote:
> > On Thu, 28 Mar 2013, Eric Dumazet wrote:
>
> >
> > > Christoph, could this kind of error be detected by the compiler or
> > > sparse ?
> >
> > The per cpu variables are marked with __percpu. This should be detected by
> > sparse.
>
> make C=2 net/core/flow.o
>
>   CHECK   net/core/flow.c
>
> No warning.

huh?

this_cpu_ptr uses SHIFT_PERCPU_PTR


#ifndef SHIFT_PERCPU_PTR
/* Weird cast keeps both GCC and sparse happy. */
#define SHIFT_PERCPU_PTR(__p, __offset) ({                              \
        __verify_pcpu_ptr((__p));                                       \
        RELOC_HIDE((typeof(*(__p)) __kernel __force *)(__p), (__offset));
\
})
#endif

This would mean that __verify_pcpu_ptr is broken.
