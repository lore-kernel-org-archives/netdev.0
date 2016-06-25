From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Sat, 25 Jun 2016 09:22:51 -0700
Message-ID: <CALx6S377catSZbvovx-Dfern0PGE3TVp+xk5=9mKfReRTJ9GQQ@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
 <20160623.034004.1518087003165708123.davem@davemloft.net> <576B94DA.7070804@nod.at>
 <CALx6S35ii7nF0s9n2ocpvNcjo25uDHd+788X+3oTqc4sd1SjOQ@mail.gmail.com>
 <576DA7C4.7040108@hpe.com> <CALx6S34Vu_xG7jjTSdFXdbkJOfKt=639ji5DX4gOjObi8Nf+7A@mail.gmail.com>
 <576DAEF9.8080501@hpe.com> <CALx6S37e5uQ9RXzVaAmAD=rpeqpwDizRQML9G6XCjCf273Gr1A@mail.gmail.com>
 <576DC9C0.4080102@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Weinberger <richard@nod.at>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:35622 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcFYQWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:22:53 -0400
Received: by mail-it0-f42.google.com with SMTP id g127so36747403ith.0
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2016 09:22:52 -0700 (PDT)
In-Reply-To: <576DC9C0.4080102@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2016 at 5:01 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 06/24/2016 04:43 PM, Tom Herbert wrote:
>>
>> Here's Christoph's slides on TFO in the wild which presents a good
>> summary of the middlebox problem. There is one significant difference
>> in that ECN needs network support whereas TFO didn't. Given that
>> experience, I'm doubtful other new features at L4 could ever be
>> productively use (like EDO or maybe TCP-ENO).
>>
>> https://www.ietf.org/proceedings/94/slides/slides-94-tcpm-13.pdf
>
>
> Perhaps I am being overly optimistic, but my takeaway from those slides is
> Apple were able to come-up with ways to deal with the middleboxes and so
> could indeed productively use TCP FastOpen.
>
They do it by detecting that TFO packets are being dropped and so
fallback to not using TFO. Clients behind such a middlebox can't use
the feature.

> "Overall, very good success-rate"
> though tempered by
> "But... middleboxes were a big issue in some ISPs..."
>
> Though it doesn't get into how big (some connections, many, most, all?) and
> how many ISPs.
>
Note that this not just about TCP. TCP was never ordained to be the
one an only transport protocol on the Internet, in fact the intent of
the Internet architecture and a layered protocol stack was to
encourage innovation in protocol design not to ossify to just one in
perpetuity. SCTP for instance has some very interesting features like
sub streams to avoid HOL block, reliable messages model. But we can't
even consider the possibility of deploying it for our applications,
firewalls and NAT boxes will likely drop; not all major client OSes
(e.g. WIndows) even provide support for it.

ECN, TFO, and SCTP issues are just anecdotes of problems that have the
same root cause: middleboxes are invasive in transport protocols in
non-standard ways so that extending or changing transport protocols
difficult or infeasible to deploy. This is protocol ossification, and
IMO the solution is to eliminate middleboxes have visibility of L4.

Tom
