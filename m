From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [patch sungem] improved locking
Date: Tue, 14 Nov 2006 08:28:42 +0100
Message-ID: <5cac192f0611132328i52d6d615g28d8c493dc028621@mail.gmail.com>
References: <5cac192f0611100528r4a53498emc8d866955cc36c8d@mail.gmail.com>
	 <20061110.124246.41636039.davem@davemloft.net>
	 <5cac192f0611121511w6a8fec54pdf6124b5f2f79a08@mail.gmail.com>
	 <20061113.164622.28395064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:28191 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S933244AbWKNH2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 02:28:44 -0500
Received: by nf-out-0910.google.com with SMTP id o25so179467nfa
        for <netdev@vger.kernel.org>; Mon, 13 Nov 2006 23:28:42 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061113.164622.28395064.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/06, David Miller <davem@davemloft.net> wrote:
> From: "Eric Lemoine" <eric.lemoine@gmail.com>
> Date: Mon, 13 Nov 2006 00:11:49 +0100
>
> > +#if GEM_INTERRUPT_LOCKLESS
> > +
> > +/* Bitmask representing the interrupt conditions that we clear using GREG_IACK.
> > + * We clear all the top-level interrupt conditions (bits 0 through 6) that we
> > + * handle.
> > + */
> > +#define GREG_STAT_IACK               (GREG_STAT_NAPI & 0x3f)
> > +#endif
>
> I'm asking for this a second time...  and to be honest I'm a little
> bit ticked off.
>
> Please spell out the explicit bits using the existing defines to
> create this mask.  Do not use this magic 0x3f magic number which
> contains bits which are undefined, so obtain this mask (as I asked the
> first time) like this:
>
>         (GREG_STAT_TXINTME | GREG_STAT_TXALL |
>          GREG_STAT_TXDONE | GREG_STAT_RXDONE |
>          GREG_STAT_RXNOBUF)
>
> I will not go through the effort a third time, instead I will simply
> ignore your patch submissions, it's that simple.  If you ignore me, I
> ignore you.

Dave, please believe me, I'm not ignoring you at all! I'm just trying
to make things better.

I had thought that:

(GREG_STAT_NAPI & 0x3f)

was better than

(GREG_STAT_TXINTME | GREG_STAT_TXALL |
 GREG_STAT_TXDONE | GREG_STAT_RXDONE |
 GREG_STAT_RXNOBUF)

because it makes it explicit that only bits 0 through 6 are taken into
account when writing the IACK register. In addition,  GREG_STAT_IACK
doesn't need to be changed if GREG_STAT_NAPI is changed. That's why I
did it that way. And as opposed to what I did in the previous patch, I
no longer set bits that don't exist with this new macro.

If you don't like it, let's discuss, and I can change my mind. But
again, please, do not think I'm ignoring your comments.

Thanks,

-- 
Eric
