From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 21:00:30 +0300
Message-ID: <20070220180027.GC26961@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <20070220165907.GB24930@2ka.mipt.ru> <20070220170525.GC24930@2ka.mipt.ru> <200702201854.00092.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37636 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030330AbXBTSGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 13:06:43 -0500
Content-Disposition: inline
In-Reply-To: <200702201854.00092.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 06:53:59PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > > I've attached source code and running script.
> > > $ ./run.sh
> >
> > Yep, of course.
> 
> Your test program is just bogus. artefacts come from your 'random' generator.
> 
> You just increment a counter, assuming the key you search is not in the table 
> yet.

No, that part is commented, but it does not matter.

> But obviously with only a variation of sport (16 bits), you have a maximum of 
> 65536 values. No need to feed 100*2^20 values are most of them are dups.
> 
> Now if you change your program to do a real lookups with the 2^16 possible 
> values of sport you'll see :

No need to change something - I showed that in some cases jenkins ends
up with a huge problem. If test will be changed, or solar will be turned
off, things will behave good, but as is they behave very bad.

> jhash function :
> 1 61578
> 2 1916
> 3 42
> 
> that is : 61578 chains of length 1
> 1916 chains of length 2
> 42 chains of length 3
> 
> (for reference, with HASH_FOLD, about same results :
> 1 61692
> 2 1856
> 3 44
> 
> Pretty good results... for the gain jhash gives us.
> 
> Of course, XOR hash gives a 'perfect' 65536 chains of length 1.

As you can see, jhash has problems in a really trivial case of 2^16,
which in local lan is a disaster. The only reason jenkins hash is good
for hashing purposes is that is it more complex than xor one, and thus
it is harder to find a collision law. That's all.
And it is two times slower.

-- 
	Evgeniy Polyakov
