From: Christoph Lameter <cl@linux.com>
Subject: Re: Poll about irqsafe_cpu_add and others
Date: Thu, 17 Mar 2011 13:42:10 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1103171338350.18529@router.home>
References: <1300371834.6315.93.camel@edumazet-laptop>  <20110317.081420.71114992.davem@davemloft.net>  <alpine.DEB.2.00.1103171016270.12540@router.home>  <1300380801.6315.306.camel@edumazet-laptop>  <alpine.DEB.2.00.1103171245430.16620@router.home>
 <1300386569.6315.404.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300386569.6315.404.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2011, Eric Dumazet wrote:

> By the way, I noticed :
>
> DECLARE_PER_CPU(u64, xt_u64);
> __this_cpu_add(xt_u64, 2) translates to following x86_32 code :
>
> 	mov	$xt_u64,%eax
> 	add	%fs:0x0,%eax
> 	addl	$0x2,(%eax)
> 	adcl	$0x0,0x4(%eax)
>
>
> I wonder why we dont use :
>
> 	addl	$0x2,%fs:xt_u64
> 	addcl	$0x0,%fs:xt_u64+4

The compiler is fed the following

	*__this_cpu_ptr(xt_u64) += 2

__this_cpu_ptr makes it:

	*(xt_u64 + __my_cpu_offset) += 2

So the compiler calculates the address first and then increments it.

The compiler could optimize this I think. Wonder why that does not happen.




