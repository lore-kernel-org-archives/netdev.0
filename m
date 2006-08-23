From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 14:03:03 +0400
Message-ID: <20060823100303.GA1144@2ka.mipt.ru>
References: <b3f268590608221551q5e6a1057hd1474ee8b9811f10@mail.gmail.com> <20060822231129.GA18296@ms2.inr.ac.ru> <b3f268590608221728r6cffd03i2f2dd12421b9f37@mail.gmail.com> <20060822.173200.126578369.davem@davemloft.net> <b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com> <20060823065659.GC24787@2ka.mipt.ru> <20060823000758.5ebed7dd.akpm@osdl.org> <20060823071002.GA16400@2ka.mipt.ru> <p73pser7ozn.fsf@verdi.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Jari Sundell <sundell.software@gmail.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	nmiell@comcast.net, linux-kernel@vger.kernel.org,
	drepper@redhat.com, netdev@vger.kernel.org, zach.brown@oracle.com,
	hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:20413 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S964805AbWHWKFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 06:05:21 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <p73pser7ozn.fsf@verdi.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2006 at 11:58:20AM +0200, Andi Kleen (ak@suse.de) wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> > 
> > Let's then place there a structure with 64bit seconds and nanoseconds,
> > similar to timspec, but without longs there.
> 
> You need 64bit (or at least more than 32bit) for the seconds,
> otherwise you add a y2038 problem which would be sad in new code.
> Remember you might be still alive then ;-)

I hope so :)

> Ok one could argue that on 32bit architectures 2038 is so deeply
> embedded that it doesn't make much difference, but I still
> think it would be better to not readd it to new interfaces there.
> 
> 64bit longs on 32bit is fine, as long as you use aligned_u64,
> never long long or u64 (which has varying alignment between i386 and x86-64)

Btw, aligned_u64 is not exported to userspace.
I commited a change with __u64 nanoseconds without any strucutres.
Do we really need a structure?

> -Andi

-- 
	Evgeniy Polyakov
