From: Dave Jones <davej@redhat.com>
Subject: Re: oops in udpv6_sendmsg
Date: Wed, 10 Apr 2013 20:29:24 -0400
Message-ID: <20130411002924.GA29437@redhat.com>
References: <20130329184006.GA23893@redhat.com>
 <1364582958.5113.49.camel@edumazet-glaptop>
 <1364865839.5113.165.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934952Ab3DKA33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Apr 2013 20:29:29 -0400
Content-Disposition: inline
In-Reply-To: <1364865839.5113.165.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 01, 2013 at 06:23:59PM -0700, Eric Dumazet wrote:
 > On Fri, 2013-03-29 at 11:49 -0700, Eric Dumazet wrote:
 > > On Fri, 2013-03-29 at 14:40 -0400, Dave Jones wrote:
 > > > Just hit this on Linus' current tree.
 > > > 
 > > > BUG: unable to handle kernel NULL pointer dereference at 0000000000000031
 > > > IP: [<ffffffff8166ca6b>] udpv6_sendmsg+0x34b/0xa90
 > > > 
 > > > Looks like the last line of an inlined __ip6_dst_store() call. So line 1243 of net/ipv6/udp.c
 > > > 
 > > > 	Dave
 > > 
 > > Yes, I had the same problem on my lab machine yesterday and was working
 > > on it (Using a linux-3.3.8 code base)
 > > 
 > > In my case, the invalid rt6i_node value was 0x66b579de
 > 
 > I am mystified by this problem, I could not reproduce it...

So right now, 3.9-rc6 is in good enough shape that this is the
only outstanding thing that I can pick up with trinity.
It still seems to take a long time to reproduce though
(Just hit it after 15 hours).

I've tried narrowing it down by reproducing with seed values
dumped shortly before the bug, but haven't had any luck,
so it must be reliant upon some earlier state.

I'm going to see if I can get it to happen faster by
restricting which syscalls get called.

Is there anything I can add to the ip6 code to print
out when it occurs that might aid in debugging ?

	Dave
