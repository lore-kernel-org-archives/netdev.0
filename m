From: Joe Perches <joe@perches.com>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 13:50:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1067637004.11564.98.camel@localhost.localdomain>
References: <200310312006.h9VK62Hh005910@hera.kernel.org>
	 <1067635446.11564.92.camel@localhost.localdomain>
	 <20031031132331.35a9aaca.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David S Miller <davem@redhat.com>
In-Reply-To: <20031031132331.35a9aaca.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-10-31 at 13:23, David S. Miller wrote:
> we're as mystified as you are as to why it is that:
> 	if (sum & 0x10000) {
> 		sum++;
> 		sum &= 0xffff;
> 	}
> works while:
> 	sum = ((sym >> 16) + sum) & 0xffff;
> does not.  The theory was that it might be some x86 gcc bug,
> but looking at the assembler diff Arnaldo Carvalho de Melo
> (the appletalk maintainer) showed me between the before and
> after:
>  	xorl	%eax, %eax
> -	decl	%ecx
>  	movb	(%ebx), %al
> -	incl	%ebx
>  	addl	%eax, %edx
>  	addl	%edx, %edx
> -	movl	%edx, %eax
> -	shrl	$16, %eax
> -	addl	%edx, %eax
> -	movzwl	%ax,%edx
> +	testl	$65536, %edx
> +	je	.L982
> +	incl	%edx
> +	andl	$65535, %edx
> +.L982:
> +	decl	%ecx
> +	incl	%ebx
>  	cmpl	$-1, %ecx
> 
> we still can't see what's wrong.
> He did confirm that the change in question makes IPX compute checksums
> correctly.

If so, something major is WRONG.
Code all over the place would need this "fix".

Was an old NG Sniffer being used to verify this?
Sniffer had a long term problem with IPX checksums.

Has the gcc team been contacted?
