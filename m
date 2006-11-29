From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [patch sungem] improved locking
Date: Wed, 29 Nov 2006 11:16:38 +0100
Message-ID: <5cac192f0611290216u4f0d7a98w3879aa12ba3b6200@mail.gmail.com>
References: <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
	 <20061128.144911.55733883.davem@davemloft.net>
	 <1164754644.5350.110.camel@localhost.localdomain>
	 <20061128.154350.02290212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:61968 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S966680AbWK2KQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 05:16:40 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1740251uga
        for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 02:16:39 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061128.154350.02290212.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/29/06, David Miller <davem@davemloft.net> wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Wed, 29 Nov 2006 09:57:24 +1100
>
> >
> > > This looks mostly fine.
> > >
> > > I was thinking about the lockless stuff, and I wonder if there
> > > is a clever way you can get it back down to one PIO on the
> > > GREG_STAT register.
> > >
> > > I think you'd need to have the ->poll() clear gp->status, then
> > > do a smp_wb(), right before it re-enables interrupts.
> > >
> > > Then in the interrupt handler, you need to find a way to safely
> > > OR-in any unset bits in gp->status in a race-free manner.
> >
> > Having it atomic might work at a slightly smaller cost than a lock,
> > though atomics don't have strong ordering requirements so you'd still
> > have to be a bit careful.
>
> At least in theory the atomic + any necessary memory barriers
> would be cheaper than the extra PIO read we need otherwise.

Just a remark: the lockless impl doesn't add a PIO read, it adds a PIO
write (to the IACK reg). FYI, I'm currently checking whether I can get
rid of this extra PIO write, based on David's suggestion...


-- 
Eric
