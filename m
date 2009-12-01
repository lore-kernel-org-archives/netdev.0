From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Tue, 1 Dec 2009 08:01:51 +0000
Message-ID: <20091201080151.GA6408@ff.dom.local>
References: <4B0F8A5D.1040806@gmail.com> <20091128000401.GA3713@ami.dom.local> <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com> <20091130111020.GA7114@ff.dom.local> <412e6f7f0911301832o53e479f0x42345065b0b1616f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <martin.devera@cdi.cz>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:40647 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbZLAIBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 03:01:53 -0500
Received: by fxm5 with SMTP id 5so4591940fxm.28
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 00:01:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911301832o53e479f0x42345065b0b1616f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2009 at 10:32:26AM +0800, Changli Gao wrote:
> On Mon, Nov 30, 2009 at 7:10 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > On Mon, Nov 30, 2009 at 12:26:33PM +0800, Changli Gao wrote:
> >
> > Users can control this with "r2q" and "quantum", and there is a hint
> > on quantum size in the user's guide.
> 
> Yes. But I think most of users will ignore it like me.

In most cases this shouldn't matter. Default r2q/quantum should be
OK for higher rates, and lower ones (< 10pps) are probably controlled
mainly by their state, so even an overflowed deficit doesn't have to
matter (unless your tests show something else ;-).

In other cases those users should see some problems or quantum
warnings, and that's when they should stop ignoring the docs.

> 
> >
> >> And
> >> if we use IMQ to shape traffic, the skb will be defragmented by
> >> conntrack, and its size will be larger than MTU.
> >
> > IMQ is a very nice thing, but it's considered broken as well, so it
> > can't be the reason for changing HTB.
> 
> I find IMQ is used by many network equipments Linux based. Why not fix
> and integrate it into official Linux?

Even I ;-) don't know exact reasons, but I believe some people here
know better.

> 
> > And this patch is very similar, except ->peek()/dequeue(). Additional
> > lookups are done instead of dequeuing the first found class, which
> > might be quite long in some cases.
> 
> If the quantum is set correctly, there isn't difference except of a
> comparison. In the other case, I think some additional CPU cycles are
> better than overflow.

No, my main point is there _is_ a difference when the quantum is set
correctly. Just these additional lookups.

> 
> >
> > It's not acceptable to me mainly because the real change done by this
> > patch is different than you describe: preventing an overflow might be
> > simple. You change the way DRR is implemented here, and even if it's
> > right, it should be written explicitly and proved with tests results.
> >
> 
> This way is used by CBQ.

HTB is different by design:
http://luxik.cdi.cz/~devik/qos/htb/manual/theory.htm

Regards,
Jarek P.
