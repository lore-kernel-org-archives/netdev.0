From: David Miller <davem@davemloft.net>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 01:34:40 -0800 (PST)
Message-ID: <20070221.013440.39157749.davem@davemloft.net>
References: <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com>
	<f2b55d220702201209m6d6a276fj75f3462cdf6daeb@mail.gmail.com>
	<20070221085608.GC1903@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: medwards.linux@gmail.com, dada1@cosmosbay.com, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030196AbXBUJel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 04:34:41 -0500
In-Reply-To: <20070221085608.GC1903@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 21 Feb 2007 11:56:08 +0300

> On Tue, Feb 20, 2007 at 12:09:59PM -0800, Michael K. Edwards (medwards.linux@gmail.com) wrote:
> > On 2/20/07, Michael K. Edwards <medwards.linux@gmail.com> wrote:
> > >Correct.  That's called a "weak hash", and Jenkins is known to be a
> > >thoroughly weak hash.  That's why you never, ever use it without a
> > >salt, and you don't let an attacker inspect the hash output either.
> > 
> > Weak in a cryptographic sense, of course.  Excellent avalanche
> > behavior, though, which is what you care about in a salted hash.
> > http://en.wikipedia.org/wiki/Hash_table
> 
> I repeat again - add your salt into jenkins hash and I will show you
> that it has the same problems.
> So, I'm waiting for your patch for jhash_*_words().

The problem is that whilst XOR, with arbitrary random input
seed, can be forced to use choosen hash chains easily, with
jenkins this is not the case.

The reason is that, due to jenkin's sophisticated mixing, each
random input produces unique "pattern" of hash chains even for
the most carefully crafted inputs.

It is not trivial to target matching hash chains even with known
input seed, and it is impossible with unknown seed such as that
which we use in routing cache.

I do not talk about distribution characteristics here, only about
attackability.
