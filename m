From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Sat, 18 Sep 2004 10:24:04 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918.102404.30656051.yoshfuji@linux-ipv6.org>
References: <20040918.085003.77842779.yoshfuji@linux-ipv6.org>
	<20040917170607.2e96b58a.davem@davemloft.net>
	<20040918001216.GB24235@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20040918001216.GB24235@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040918001216.GB24235@gondor.apana.org.au> (at Sat, 18 Sep 2004 10:12:16 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Fri, Sep 17, 2004 at 05:06:07PM -0700, David S. Miller wrote:
> > 
> > Compiler is smarter than you think :-)
> 
> Sparc bigots :)
> 
> Unfortunately it can't do that on architectures where the arguments
> are pushed onto the stack in reverse order, i.e., i386.

I've tested on i386.

.globl ip_route_output_key
	.type	 ip_route_output_key,@function
ip_route_output_key:
	movl 4(%esp),%edx
	movl 8(%esp),%eax
	pushl $0
	pushl $0
	pushl %eax
	pushl %edx
	call ip_route_output_flow
	addl $16,%esp
	ret

This is not good.

We, however, now have (up to 3) register parameters on i386 (CONFIG_REGPARM), 
and assembly code is:

.globl ip_route_output_key
	.type	ip_route_output_key,@function
ip_route_output_key:
	pushl	$0
	xorl	%ecx, %ecx
	call	ip_route_output_flow
	popl	%ecx
	ret

This is (not good as sparc, but) not bad
(well, much better than before at least).

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
