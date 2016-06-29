From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Wed, 29 Jun 2016 23:44:06 +0200
Message-ID: <1467236646.6369.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
	 <20160628034150.GA13953@gondor.apana.org.au>
	 <CALCETrXOT-zaV8O1Yu4RGybGvPv5C7gr=7EWjTKvUQUaRxz1aQ@mail.gmail.com>
	 <20160629022337.GB23390@gondor.apana.org.au>
	 <CALCETrW3zzMRazohKfOh7PKb5jegJOmyrC7EiCEF0eQ5SArNyg@mail.gmail.com>
	 <20160629150257.GA29490@gondor.apana.org.au>
	 <CALCETrVKjwKkzR+qwsC=DMvM9tR4beAtvw=LLjzsAyuztV4bWw@mail.gmail.com>
	 <20160629153818.GA29838@gondor.apana.org.au>
	 <CALCETrUR1+au2-11qSAT24832nZcTwjUj8UY09rCMisyHawnaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32806 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbcF2Voe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 17:44:34 -0400
Received: by mail-wm0-f68.google.com with SMTP id r201so17540752wme.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 14:44:09 -0700 (PDT)
In-Reply-To: <CALCETrUR1+au2-11qSAT24832nZcTwjUj8UY09rCMisyHawnaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-29 at 09:41 -0700, Andy Lutomirski wrote:

> Overall, it looks like there's overhead of something like 50ns for
> each ahash invocation vs the shash equivalent.  It's not huge, but
> it's there.  (This is cache-hot.  I bet it's considerably worse if
> cache-cold, because ahash will require a lot more code cache lines as
> well as the extra cache lines involved in the scatterlist and whatever
> arch stuff is needed to map back and forth between virtual and
> physical addresses.

I am kind of mystified seeing someone caring about TCP MD5, other than
just making sure it wont crash the host when it needs to be used ;)

The real useful work would be to use a jump label so that we can avoid
spending cycles for non TCP MD5 sessions, when a host never had to use
any MD5 negotiation.
