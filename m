From: Andi Kleen <ak@muc.de>
Subject: Re: Locking model for NAPI drivers
Date: Wed, 01 Jun 2005 08:28:04 +0200
Message-ID: <m1fyw2wpzf.fsf@muc.de>
References: <20050531.154847.63995530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050531.154847.63995530.davem@davemloft.net> (David S.
 Miller's message of "Tue, 31 May 2005 15:48:47 -0700 (PDT)")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:

Stupid question, but...

> I was doing some brainstorming to try and fix a nagging problem in
> the tg3 driver which suggested that doing the SMP locking differently
> might be the best and cleanest solution.
>
> The tg3 problem is that it can do an skb_copy() in HW IRQ disabled
> context which is illegal.

That is because of the kmap_atomic it does right? At least in the i386
highmem implementation I don't see any code that would be less safe in
hard interrupt context compared to BHs.  And FRV and mips look like they
allow it too.

> This fixes the skb_copy() we were doing with hw
> IRQs disabled (which is illegal and triggers a
> BUG() with HIGHMEM enabled).  

Which BUG did it trigger?

-Andi
