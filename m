From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Fix preferred_lft not updating in some cases
Date: Sat, 28 Sep 2013 22:28:28 +0200
Message-ID: <20130928202828.GB23654@order.stressinduktion.org>
References: <1380147175-14874-1-git-send-email-pmarks@google.com> <20130927081604.GB28287@order.stressinduktion.org> <CAHaKRvJDZJjuv4sALmQAotk5EUMfYPiLN=8_noWCRQYOW+bxSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, Lorenzo Colitti <lorenzo@google.com>
To: Paul Marks <pmarks@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57488 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733Ab3I1U23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 16:28:29 -0400
Content-Disposition: inline
In-Reply-To: <CAHaKRvJDZJjuv4sALmQAotk5EUMfYPiLN=8_noWCRQYOW+bxSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 01:28:06PM -0700, Paul Marks wrote:
> On Fri, Sep 27, 2013 at 1:16 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Wed, Sep 25, 2013 at 03:12:55PM -0700, Paul Marks wrote:
> >> -                                     if (prefered_lft != ifp->prefered_lft) {
> >
> > Wouldn't the easiest solution be to just drop this if and execute the two
> > lines below unconditionally?
> 
> Yes, that's also correct.  But is it not better to have simpler code
> than shorter diffs?  Should we transliterate English to C, or think
> about what the algorithm is actually doing?  The fact that this bug
> has gone unnoticed provides some evidence that the code may have been
> too complicated.

I don't care about the length of diffs or shorter code. I would favour
a transliteration here because it makes verification easier (at least
for me). The algorithm is not that complex and I guess the bug has been
unnoticed because nobody ran into problems and cared til now.

So, why not get rid of update_lft then?

> >> +                             const u32 minimum_lft = min(
> >> +                                     stored_lft, (u32)MIN_VALID_LIFETIME);
> >> +                             valid_lft = max(valid_lft, minimum_lft);
> >
> > Quick question: Don't we need a prefered_lft = min(preferred_lft, valid_lft)
> > here?
> 
> The invariant is (preferred_lft <= valid_lft), and valid_lft can only
> get bigger, so I don't think there's a problem.

Ah, I got confused. Missed in the last case that it got tested earlier in the
function. Your code looks correct regarding every rule.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
