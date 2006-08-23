From: Andi Kleen <ak@suse.de>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: 23 Aug 2006 11:58:20 +0200
Message-ID: <p73pser7ozn.fsf@verdi.suse.de>
References: <b3f268590608221551q5e6a1057hd1474ee8b9811f10@mail.gmail.com>
	<20060822231129.GA18296@ms2.inr.ac.ru>
	<b3f268590608221728r6cffd03i2f2dd12421b9f37@mail.gmail.com>
	<20060822.173200.126578369.davem@davemloft.net>
	<b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com>
	<20060823065659.GC24787@2ka.mipt.ru>
	<20060823000758.5ebed7dd.akpm@osdl.org>
	<20060823071002.GA16400@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jari Sundell <sundell.software@gmail.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	nmiell@comcast.net, linux-kernel@vger.kernel.org,
	drepper@redhat.com, netdev@vger.kernel.org, zach.brown@oracle.com,
	hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:9942 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751502AbWHWJ6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 05:58:31 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060823071002.GA16400@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> 
> Let's then place there a structure with 64bit seconds and nanoseconds,
> similar to timspec, but without longs there.

You need 64bit (or at least more than 32bit) for the seconds,
otherwise you add a y2038 problem which would be sad in new code.
Remember you might be still alive then ;-)

Ok one could argue that on 32bit architectures 2038 is so deeply
embedded that it doesn't make much difference, but I still
think it would be better to not readd it to new interfaces there.

64bit longs on 32bit is fine, as long as you use aligned_u64,
never long long or u64 (which has varying alignment between i386 and x86-64)

-Andi
