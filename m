From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [GIT] Networking
Date: Mon, 09 Nov 2015 13:09:22 +0100
Message-ID: <1447070962.399769.433652241.038FDB6A@webmail.messagingengine.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
 <CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
 <1446030209.105419.422375497.14563933@webmail.messagingengine.com>
 <87pozzvzj6.fsf@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:46828 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbbKIMJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 07:09:23 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 5F5692040A
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 07:09:23 -0500 (EST)
In-Reply-To: <87pozzvzj6.fsf@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Oct 28, 2015, at 15:27, Rasmus Villemoes wrote:
> On Wed, Oct 28 2015, Hannes Frederic Sowa <hannes@stressinduktion.org>
> wrote:
> 
> > Hi Linus,
> >
> > On Wed, Oct 28, 2015, at 10:39, Linus Torvalds wrote:
> >> Get rid of it. And I don't *ever* want to see that shit again.
> >
> > I don't want to give up on that this easily:
> >
> > In future I would like to see an interface like this. It is often hard
> > to do correct overflow/wrap-around tests and it would be great if there
> > are helper functions which could easily and without a lot of thinking be
> > used by people to remove those problems from the kernel.
> 
> I agree - proper overflow checking can be really hard. Quick, assuming a
> and b have the same unsigned integer type, is 'a+b<a' sufficient to
> check overflow? Of course not (hint: promotion rules). And as you say,
> it gets even more complicated for signed types.
> 
> A few months ago I tried posting a complete set of fallbacks for older
> compilers (https://lkml.org/lkml/2015/7/19/358), but nothing really
> happened. Now I know where Linus stands, so I guess I can just delete
> that branch.

I actually like your approach of being type agnostic a bit more (in
comparison to static inline functions), mostly because of one specific
reason:

The type agnostic __builtin_*_overflow function even do the correct
things if you deal with types smaller than int. Imagine e.g. you want to
add to unsigned chars a and b,

unsigned char a, b;
if (a + b < a)
  goto overflow;
else
  a += b;

The overflow condition will never trigger, as the comparisons will
always be done in the integer domain and a + b < a is never true. I
actually think that this is easy to overlook and the functions should
handle that. The macro version does this quite nicely.

Bye,
Hannes
