From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [patch sungem] improved locking
Date: Fri, 10 Nov 2006 14:28:41 +0100
Message-ID: <5cac192f0611100528r4a53498emc8d866955cc36c8d@mail.gmail.com>
References: <5cac192f0611091333w5740810bhe1966d6391c6d46a@mail.gmail.com>
	 <20061109.150436.94557169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:24400 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1946610AbWKJN2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 08:28:43 -0500
Received: by ug-out-1314.google.com with SMTP id m3so520449ugc
        for <netdev@vger.kernel.org>; Fri, 10 Nov 2006 05:28:41 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061109.150436.94557169.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/10/06, David Miller <davem@davemloft.net> wrote:
>
> Please use GREG_STAT_* instead of magic constants for the
> interrupt mask and ACK register writes.  In fact, there are
> some questionable values you use, in particular this one:
>
> +static inline void gem_ack_int(struct gem *gp)
> +{
> +       writel(0x3f, gp->regs + GREG_IACK);
> +}

This code clears bits 0 through 6, which GREG_IACK is for.

> There is no bit defined in GREG_STAT_* for 0x08, but you
> set it in this magic bitmask.  It is another reason not
> to use magic constants like this :-)

Yes, the bit 4 isn't used, but I assumed clearing it shouldn't be prolem.

Would you prefer that:

#define GREG_STAT_IACK 0x3f

static inline void gem_ack_int(struct gem *gp)
{
       writel(GREG_STAT_IACK, gp->regs + GREG_IACK);
}

or that:

#define GREG_STAT_IACK (GREG_STAT_TXINTME | GREG_STAT_TXALL | \
                                         GREG_STAT_RXDONE | GREG_STAT_RXNOBUF)

to avoid bit 4, and bit 3 (TX_DONE) which is masked.

Personnaly, I like the first way best.

>
> Also, if you need to use an attachment to get the tabbing
> right, that's fine, but please also provide a copy inline
> so that it is easy to quote the patch for review purposes.
> It's a truly a pain in the rear to quote things when you use
> a binary attachment.

I will.

>
> I'd like these very simple and straightforward issues to
> be worked out before I even begin to review the actual
> locking change itself.

Ok.

I'll wait for you regarding gem_ack_int() and send out another patch.

Thanks,


-- 
Eric
