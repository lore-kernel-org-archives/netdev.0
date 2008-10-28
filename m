From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v2)
Date: Tue, 28 Oct 2008 16:16:42 +0000
Message-ID: <20081028161642.GL1034@flint.arm.linux.org.uk>
References: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <20081027143734.GA13565@secretlab.ca> <4906C338.6010300@teltonika.lt> <fa686aa40810280608q1c58e07cq7c5f2cc9feeb8ef6@mail.gmail.com> <20081028151755.GA1034@flint.arm.linux.org.uk> <fa686aa40810280830i1a5a7b84u1dfa8cd97c6b1420@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:57460 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbYJ1QQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 12:16:59 -0400
Content-Disposition: inline
In-Reply-To: <fa686aa40810280830i1a5a7b84u1dfa8cd97c6b1420@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 09:30:10AM -0600, Grant Likely wrote:
> On Tue, Oct 28, 2008 at 9:17 AM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > On Tue, Oct 28, 2008 at 07:08:06AM -0600, Grant Likely wrote:
> >> On Tue, Oct 28, 2008 at 1:46 AM, Paulius Zaleckas
> >> <paulius.zaleckas@teltonika.lt> wrote:
> >> > Grant Likely wrote:
> >> >> The IRQ array is fixed size.  You can add it to the mdio_gpio_info
> >> >> structure and then just set the pointer here so that only one kzalloc
> >> >> is needed.
> >> >
> >> > It can be put in mdio_gpio_info, but please note that mdio_gpio_info is
> >> > allocated with kzalloc() and irq with kmalloc(), because there is no need
> >> > to fill this array with zeros(see below).
> >>
> >> Adding an additional 32 words to be zeroed in the mdio_gpio_info
> >> kzalloc is considerably cheaper than doing an additional kmalloc.
> >> Plus, once the array is zeroed it is then in the cache and so the
> >> filling it with -1 also becomes cheaper.
> >
> > Actually no, it doesn't become cheaper.  You're making the assumption
> > that cache lines are allocated when memory is written to.  This isn't
> > the case with the vast majority of ARM CPUs.
> 
> Okay, I wasn't aware of that on ARM.
> 
> However it is still true that increasing the size of the kzalloc is
> cheaper than doing 2 allocs.

Yes, that 'irq' array might as well be part of the same structure.
