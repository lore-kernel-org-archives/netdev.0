From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/3 v2][NET] gen_estimator: faster gen_kill_estimator
Date: Tue, 22 Jan 2008 20:22:14 +0100
Message-ID: <20080122192214.GA2629@ami.dom.local>
References: <20080122072152.GA977@ff.dom.local> <1201002127.4443.32.camel@localhost> <20080122122927.GE2079@ff.dom.local> <1201010068.4443.66.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	slavon@bigtelecom.ru, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:31706 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbYAVTTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 14:19:12 -0500
Received: by nf-out-0910.google.com with SMTP id g13so482912nfb.21
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2008 11:19:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1201010068.4443.66.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2008 at 08:54:28AM -0500, jamal wrote:
> On Tue, 2008-22-01 at 13:29 +0100, Jarek Poplawski wrote:
> > On Tue, Jan 22, 2008 at 06:42:07AM -0500, jamal wrote:
> > ...
> > > Jarek,
> > > 
> > > That looks different from the suggestion from Dave.
> > 
> > Hmm..., I'm not sure you mean my or your suggestion here, but you
> > are right anyway...
> 
> Your idea to grab a pointer to the estimator so you can quickly find it
> upon destruction is a good one.

Let's say it's quite common in the kernel type of idea...

> The challenge was not to break the ABI to user space.
> Dave suggested to use a different struct for the kernel side and
> maintain the user one as is[1]. Your patch didnt do this, hence my
> statement;->

Sure! David's idea is very good, but before reading his message I
decided to try something 'safer'. I simply don't know these structures
like you or David, and after these mistakes at the beginning, I tried
to avoid the next. But now I see it shouldn't be so hard, and I'll do
this David's way, I hope!

> > Maybe I miss something, but there still could be a lot of this walking
> 
> Indeed, that is possible in the case of many estimators configured with
> the same interval - because they will all fall in the same table bucket
> and the idx is not that useful to begin with.
> 
> I was wrong given the nature of interval - the majority of the users
> will have an estimator interval of say 1 sec which will put everything
> in one bucket still. 
> We could introduce a proper index that will allow proper distribution
> and have that stored by the class. I am not sure i made sense.
> But you are coding - and your idea sounds better.

As a matter of fact, I've considered yesterday some additional hash
table too, but wasn't sure it's worth of the savings. It seems there
should be considered optimization of these estimator structures yet.

But since there are now a few similar reports about misterious
problems during deletion of large qdisc, it would be nice to remove
main suspects around this at any price...

Many thanks for your concern with this! (And, if miss something again,
don't be afraid to make it straight & clear; I really prefer to know
the truth about my mistakes, than polite silence.)

Regards,
Jarek P.

> [1] This is _not uncommon_ (note the usage of double negation here for
> emphasis;->) technique actually; ones that go further for example can be
> found all over the net/sched code (struct tcf_police vs tc_police) etc.

I think David's points were very clear and of course right!; it seems now
that only my 'usual' way of friendly joking about this could be more
challenge than any double-negation and turns friendly fire insted...
