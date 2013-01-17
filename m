From: Dave Jones <davej@redhat.com>
Subject: Re: ip6_dst_lookup_tail oops
Date: Thu, 17 Jan 2013 10:25:04 -0500
Message-ID: <20130117152504.GC32586@redhat.com>
References: <20130116145507.GA12244@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10747 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756918Ab3AQPwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 10:52:23 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0HFqMic027671
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 10:52:23 -0500
Received: from gelk.kernelslacker.org (ovpn-113-149.phx2.redhat.com [10.3.113.149])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r0HFP6DT006846
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 10:25:07 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id r0HFP5m6002409
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 10:25:05 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id r0HFP5SV002368
	for netdev@vger.kernel.org; Thu, 17 Jan 2013 10:25:05 -0500
Content-Disposition: inline
In-Reply-To: <20130116145507.GA12244@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2013 at 09:55:07AM -0500, Dave Jones wrote:

 > BUG: unable to handle kernel NULL pointer dereference at 000000000000017e
 > IP: [<ffffffff81626308>] ip6_dst_lookup_tail+0xe8/0x200
 > RIP: 0010:[<ffffffff81626308>]  [<ffffffff81626308>] ip6_dst_lookup_tail+0xe8/0x200
 > RAX: 0000000000000011 RBX: 0000000000000000 RCX: 0000000000000000
 > ..
 > Call Trace:
 >  [<ffffffff816266cb>] ip6_sk_dst_lookup_flow+0xcb/0x1b0
 >  [<ffffffff8164803e>] udpv6_sendmsg+0x66e/0xb80
 >  [<ffffffff815e6391>] inet_sendmsg+0x111/0x220
 >  [<ffffffff81547220>] sock_sendmsg+0xb0/0xe0
 >  [<ffffffff815486bc>] __sys_sendmsg+0x3ac/0x3c0
 >  [<ffffffff8154afb9>] sys_sendmsg+0x49/0x90
 >  [<ffffffff816a6802>] system_call_fastpath+0x16/0x1b
 > 
 >    0:	f6 80 6d 01 00 00 de 	testb  $0xde,0x16d(%rax)
 >    7:	75 b9                	jne    0xffffffffffffffc2
 >    9:	48 8b 56 18          	mov    0x18(%rsi),%rdx
 >    d:	49 8d 75 24          	lea    0x24(%r13),%rsi
 >   11:	b9                   	.byte 0xb9
 >   12:	01 00                	add    %eax,(%rax)
 > 	...
 > 
 > This looks like the GPF in this function I reported last September.
 > http://www.spinics.net/lists/netdev/msg211894.html
 > 
 > In those reports, I ended up with an rt->n == 0x8000000000000011,
 > but this time, it's just 0x11.

Now I've hit it with rt->n = 2000000000000010. So I'm starting to
think this is getting passed in directly from userspace somehow, as
these values look like the output of my 'set a few random bits' routine
that sometimes gets called for params.

I'm having trouble mapping a corrupt sendmsg parameter to a messed up rt->n though.

Any clues ?

	Dave
