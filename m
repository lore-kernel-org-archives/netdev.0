From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Fri, 10 Nov 2006 12:42:46 -0800 (PST)
Message-ID: <20061110.124246.41636039.davem@davemloft.net>
References: <5cac192f0611091333w5740810bhe1966d6391c6d46a@mail.gmail.com>
	<20061109.150436.94557169.davem@davemloft.net>
	<5cac192f0611100528r4a53498emc8d866955cc36c8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5100
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424413AbWKJUmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 15:42:47 -0500
To: eric.lemoine@gmail.com
In-Reply-To: <5cac192f0611100528r4a53498emc8d866955cc36c8d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric Lemoine" <eric.lemoine@gmail.com>
Date: Fri, 10 Nov 2006 14:28:41 +0100

> On 11/10/06, David Miller <davem@davemloft.net> wrote:
> >
> > Please use GREG_STAT_* instead of magic constants for the
> > interrupt mask and ACK register writes.  In fact, there are
> > some questionable values you use, in particular this one:
> >
> > +static inline void gem_ack_int(struct gem *gp)
> > +{
> > +       writel(0x3f, gp->regs + GREG_IACK);
> > +}
> 
> This code clears bits 0 through 6, which GREG_IACK is for.
> 
> > There is no bit defined in GREG_STAT_* for 0x08, but you
> > set it in this magic bitmask.  It is another reason not
> > to use magic constants like this :-)
> 
> Yes, the bit 4 isn't used, but I assumed clearing it shouldn't be prolem.
> 
> Would you prefer that:
> 
> #define GREG_STAT_IACK 0x3f
> 
> static inline void gem_ack_int(struct gem *gp)
> {
>        writel(GREG_STAT_IACK, gp->regs + GREG_IACK);
> }
> 
> or that:
> 
> #define GREG_STAT_IACK (GREG_STAT_TXINTME | GREG_STAT_TXALL | \
>                                          GREG_STAT_RXDONE | GREG_STAT_RXNOBUF)
> 
> to avoid bit 4, and bit 3 (TX_DONE) which is masked.
> 
> Personnaly, I like the first way best.

I think the second way is better because it clearly states
your intentions.  The GREG_STAT_IACK 0x3f macro is still
"magic" because it doesn't say what the bits actually mean.
