From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Wed, 09 Apr 2008 17:48:52 +0200
Message-ID: <7ifxtvghaz.fsf@lanthane.pps.jussieu.fr>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
	<873apwrc4t.fsf@basil.nowhere.org> <47FB60EF.1080004@trash.net>
	<7iy77o9wzb.fsf@lanthane.pps.jussieu.fr> <47FB9315.5030109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:50243 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755816AbYDIPtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 11:49:01 -0400
In-Reply-To: <47FB9315.5030109@trash.net> (Patrick McHardy's message of "Tue\, 08 Apr 2008 17\:45\:25 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> I'd suggest to use the flow classifier for this. For simplicity
>>> you could attach a default classifier that uses the same keys as
>>> this one.

>> I'm not sure I know what you're speaking about.  Could you please
>> point me at code somewhere?

> Check out a recent tree (either Linus' current tree or ideally
> the net-2.6.26.git tree from
>
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.26.git
>
> and look at net/sched/cls_flow.c and the recent changes to
> net/sched/sch_sfq.c for external classifiers.

Thanks for the pointer.  Unfortunately, it will need some changes to
work with sfb -- since we do double-buffering, we need some overlap
between the old and new classifiers when we choose to reclassify.  I'm
not quite sure how to do that.

Other than that, it will require some changes to sfb (which currently
assumes we can get an arbitrary amount of hash data for a single
packet, while the classifiers only give 32 bits), but these changes
are a good thing -- 32 bits should be enough.

Would you have an example of how this stuff is configured from
user-space?

> There are also a number of other incompatible changes that your
> patch needs to be adapter to, most importantly the use of the new
> netlink infrastructure.

Done, thanks for the pointer.

                                        Juliusz
