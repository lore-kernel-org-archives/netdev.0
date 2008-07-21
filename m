From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Mon, 21 Jul 2008 12:50:51 +0200
Message-ID: <20080721105051.GA5830@elte.hu>
References: <20080717214222.GA29449@elte.hu> <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI> <20080718091146.GQ6875@elte.hu> <20080721094110.GA16029@elte.hu> <84144f020807210252k68d5cf65i8c7ae3c11cecc046@mail.gmail.com> <20080721100627.GA5953@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, cl@linux-foundation.org,
	davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:50648 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757320AbYGUKwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 06:52:15 -0400
Content-Disposition: inline
In-Reply-To: <20080721100627.GA5953@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> Hi.
> 
> On Mon, Jul 21, 2008 at 12:52:45PM +0300, Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> > On Mon, Jul 21, 2008 at 12:41 PM, Ingo Molnar <mingo@elte.hu> wrote:
> > > update about this problem: just triggered another colorful crash, see
> > > below. This was with the 4K object dump patch already, maybe the dump
> > > gives a clue?
> > 
> > ...to point out the obvious:
> > 
> > > =============================================================================
> > > BUG skbuff_head_cache: Poison overwritten
> > > -----------------------------------------------------------------------------
> > >
> > > INFO: 0xf7ccc100-0xf7ccc103. First byte 0x0 instead of 0x6b
> > > INFO: Allocated in __alloc_skb+0x30/0x10e age=1 cpu=1 pid=1
> > > INFO: Freed in __kfree_skb+0x63/0x66 age=1 cpu=0 pid=0
> > > INFO: Slab 0xc1c34ca0 objects=16 used=1 fp=0xf7ccc100 flags=0x400000c3
> > > INFO: Object 0xf7ccc100 @offset=256 fp=0xf7ccc200
> > >
> > > Bytes b4 0xf7ccc0f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> > >  Object 0xf7ccc100:  00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b ....kkkkkkkkkkkk
> > 
> > Use after free where first four bytes are zeroed.
> 
> Not that obvious...
> skb->next is cleared in lots of places, in xmit network helper
> for example, but since rest of the packet was not modified, it
> means given skb was not freed, so it will not help.
> 
> Ingo do you see other similar dumps with last byte modified? That's 
> the one which can help to determine the reason.

the problem is, most of the crashes dont come with any usable dump. This 
is a laptop so netconsole is the only reliable route out - and if 
something in networking crashes chances are that it hoses netconsole 
before it can get anything out.

Another thing is that i'm activating netconsole on this box via a kernel 
boot line and from within a bzImage (to get it activated as early as 
possible) - maybe that's a tad too early for certain initialization 
sequences?

I could try run tests with netconsole deactivated, if you think that's a 
worthwile line of probing this problem. (although that would make me do 
blind tests in essence - having kernel log output is really essential.)

	Ingo
