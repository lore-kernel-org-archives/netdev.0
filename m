From: Paul Marks <pmarks@google.com>
Subject: Re: [PATCH] ipv6: Fix preferred_lft not updating in some cases
Date: Fri, 27 Sep 2013 13:28:06 -0700
Message-ID: <CAHaKRvJDZJjuv4sALmQAotk5EUMfYPiLN=8_noWCRQYOW+bxSA@mail.gmail.com>
References: <1380147175-14874-1-git-send-email-pmarks@google.com> <20130927081604.GB28287@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Paul Marks <pmarks@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org,
	Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f49.google.com ([209.85.128.49]:47517 "EHLO
	mail-qe0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3I0U21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 16:28:27 -0400
Received: by mail-qe0-f49.google.com with SMTP id s14so2178605qeb.8
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 13:28:26 -0700 (PDT)
In-Reply-To: <20130927081604.GB28287@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 1:16 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Sep 25, 2013 at 03:12:55PM -0700, Paul Marks wrote:
>> -                                     if (prefered_lft != ifp->prefered_lft) {
>
> Wouldn't the easiest solution be to just drop this if and execute the two
> lines below unconditionally?

Yes, that's also correct.  But is it not better to have simpler code
than shorter diffs?  Should we transliterate English to C, or think
about what the algorithm is actually doing?  The fact that this bug
has gone unnoticed provides some evidence that the code may have been
too complicated.

>> +                             const u32 minimum_lft = min(
>> +                                     stored_lft, (u32)MIN_VALID_LIFETIME);
>> +                             valid_lft = max(valid_lft, minimum_lft);
>
> Quick question: Don't we need a prefered_lft = min(preferred_lft, valid_lft)
> here?

The invariant is (preferred_lft <= valid_lft), and valid_lft can only
get bigger, so I don't think there's a problem.
