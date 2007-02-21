From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 12:27:17 +0300
Message-ID: <20070221092717.GA15669@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com> <20070221085406.GB1903@2ka.mipt.ru> <200702211015.11975.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34777 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161155AbXBUJ2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 04:28:13 -0500
Content-Disposition: inline
In-Reply-To: <200702211015.11975.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 21, 2007 at 10:15:11AM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Wednesday 21 February 2007 09:54, Evgeniy Polyakov wrote:
> > I shown that numbers 4 times already, do you read mails and links?
> > Did you see an artifact Eric showed with his data?
> >
> 
> I showed all your thinking is wrong.

You mix all the time distribution fairness and complexity of searching
for collisions. Jenkins hash is unfair - having Linux random generator
as attacker's tool we end up in the case, when jenkins hash has some
chains with 5 times longer length.

Short history:
I showed that jenkins is unfair, you confirmed that with your data.
Another question is about complexity of searching for collisions - you
showed that with xor it is quite easy and with jenkins it is complex, 
then I showed that it is not that complex to find collisions in jenkins
too.

> Some guys think MD5 checksum is full of artifacts, since its certainly 
> possible to construct two differents files having the same md5sum.
> Yet, lot of people use md5 checksums. In 10 years, we probably switch to 
> another stronger hash. Its only a question of current state of the art.

It is _NOT_ about having two imputs with the same output.
It is about its distribution.

I say that having random input output will not be fairly distributed -
and it was confirmed by you - having 2^16 random values ended up with
some chains of length 4, while hash table size perfectly allowed them
all to have length 1 as was in case of xor hash.

> Jenkins hash is far better than XOR, at least in the tcp ehash context.

How it can be better than xor when its distribution is unfair?
You get hash chain longer with it compared to xor one - _you_ showed
that data too if you do not believe my data.

> Some hackers already exploited the XOR hash weak, more than two years ago.
> They never succeeded since I changed to Jenkins hash.

It is _different_ problem. It has _absolutely_ nothing in common with
distribution fairness problem found in jenkins hash, do not mix both.

XOR has only one problem - it is quite easy to find a collision, but it
has perfect distribution fairness.

Fix XOR, add random permutation, use sha/md5/whatever which has 
1. fair distribution
2. strong against searching for collisions

Jenkins hash does not have at least first, and as I showed, it is not
that complex to break second (for example case of hash(const, const,
random)).

-- 
	Evgeniy Polyakov
