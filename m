From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: ip6_dst_lookup_tail oops
Date: Fri, 18 Jan 2013 07:48:09 -0500
Message-ID: <20130118124809.GA15977@hmsreliant.think-freely.org>
References: <20130116145507.GA12244@redhat.com>
 <20130117152504.GC32586@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49664 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab3ARMsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 07:48:21 -0500
Content-Disposition: inline
In-Reply-To: <20130117152504.GC32586@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2013 at 10:25:04AM -0500, Dave Jones wrote:
> On Wed, Jan 16, 2013 at 09:55:07AM -0500, Dave Jones wrote:
> 
>  > BUG: unable to handle kernel NULL pointer dereference at 000000000000017e
>  > IP: [<ffffffff81626308>] ip6_dst_lookup_tail+0xe8/0x200
>  > RIP: 0010:[<ffffffff81626308>]  [<ffffffff81626308>] ip6_dst_lookup_tail+0xe8/0x200
>  > RAX: 0000000000000011 RBX: 0000000000000000 RCX: 0000000000000000
>  > ..
>  > Call Trace:
>  >  [<ffffffff816266cb>] ip6_sk_dst_lookup_flow+0xcb/0x1b0
>  >  [<ffffffff8164803e>] udpv6_sendmsg+0x66e/0xb80
>  >  [<ffffffff815e6391>] inet_sendmsg+0x111/0x220
>  >  [<ffffffff81547220>] sock_sendmsg+0xb0/0xe0
>  >  [<ffffffff815486bc>] __sys_sendmsg+0x3ac/0x3c0
>  >  [<ffffffff8154afb9>] sys_sendmsg+0x49/0x90
>  >  [<ffffffff816a6802>] system_call_fastpath+0x16/0x1b
>  > 
>  >    0:	f6 80 6d 01 00 00 de 	testb  $0xde,0x16d(%rax)
>  >    7:	75 b9                	jne    0xffffffffffffffc2
>  >    9:	48 8b 56 18          	mov    0x18(%rsi),%rdx
>  >    d:	49 8d 75 24          	lea    0x24(%r13),%rsi
>  >   11:	b9                   	.byte 0xb9
>  >   12:	01 00                	add    %eax,(%rax)
>  > 	...
>  > 
>  > This looks like the GPF in this function I reported last September.
>  > http://www.spinics.net/lists/netdev/msg211894.html
>  > 
>  > In those reports, I ended up with an rt->n == 0x8000000000000011,
>  > but this time, it's just 0x11.
> 
> Now I've hit it with rt->n = 2000000000000010. So I'm starting to
> think this is getting passed in directly from userspace somehow, as
> these values look like the output of my 'set a few random bits' routine
> that sometimes gets called for params.
> 
> I'm having trouble mapping a corrupt sendmsg parameter to a messed up rt->n though.
> 
> Any clues ?
> 
> 	Dave
> 
Well, neighbor table entries for ipv6 get added over rtnetlink, but it seems you
would have to be able to memory map the socket to get a pointer like that into
place.  Trinity doesn't record the syscalls it makes does it?  That might be
helpful in tracking this down.
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
