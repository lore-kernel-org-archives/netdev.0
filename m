From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH] fix IP_ECN_set_ce
Date: Wed, 19 Dec 2012 10:58:53 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1212191051590.1906@ja.ssi.bg>
References: <1355898095-7444-1-git-send-email-roy.qing.li@gmail.com> <alpine.LFD.2.00.1212191001530.1620@ja.ssi.bg> <CAJFZqHyhMS22pKuW50D0uZLA5-WDUYBEZurPGCW6gSyRY-6JHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41247 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018Ab2LSI5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 03:57:42 -0500
In-Reply-To: <CAJFZqHyhMS22pKuW50D0uZLA5-WDUYBEZurPGCW6gSyRY-6JHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 19 Dec 2012, RongQing Li wrote:

> >>  static inline int IP_ECN_set_ce(struct iphdr *iph)
> >>  {
> >> -     u32 check = (__force u32)iph->check;
> >> -     u32 ecn = (iph->tos + 1) & INET_ECN_MASK;
> >> -
> >> -     /*
> >> -      * After the last operation we have (in binary):
> >> -      * INET_ECN_NOT_ECT => 01
> >> -      * INET_ECN_ECT_1   => 10
> >> -      * INET_ECN_ECT_0   => 11
> >> -      * INET_ECN_CE      => 00
> >> -      */
> >
> >         I think, the above comment explains how an
> > increment (iph->tos + 1) serves the purpose to check
> > for ECT_1 and ECT_0, there is no such thing as
> > addressing the next byte from header. It is just an
> > optimized logic that avoids complex INET_ECN_is_XXX
> > checks.
> Thanks for your reply.
> Do you mean this comment are valuable?

	It looks better to me with the comment and the
original checks. But I can't comment the correctness of
the other changes in your patch.

> >> -     if (!(ecn & 2))
> >> +     u32 ecn = iph->tos & INET_ECN_MASK;
> >> +
> >> +     if (INET_ECN_is_ce(ecn) || INET_ECN_is_not_ect(ecn))
> >>               return !ecn;
> >
> >         May be return INET_ECN_is_ce(ecn) ?
> >
> 
> I like to set the return value to void, since noone cares about the
> return value.

	It is used by INET_ECN_set_ce and its users in
net/sched/

> -Roy

Regards

--
Julian Anastasov <ja@ssi.bg>
