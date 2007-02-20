From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 18:53:59 +0100
Message-ID: <200702201854.00092.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <20070220165907.GB24930@2ka.mipt.ru> <20070220170525.GC24930@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:45103 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932969AbXBTRyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 12:54:09 -0500
In-Reply-To: <20070220170525.GC24930@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 18:05, Evgeniy Polyakov wrote:
> On Tue, Feb 20, 2007 at 07:59:07PM +0300, Evgeniy Polyakov 
(johnpol@2ka.mipt.ru) wrote:
> > I've attached source code and running script.
> > $ ./run.sh
>
> Yep, of course.

Your test program is just bogus. artefacts come from your 'random' generator.

You just increment a counter, assuming the key you search is not in the table 
yet.

But obviously with only a variation of sport (16 bits), you have a maximum of 
65536 values. No need to feed 100*2^20 values are most of them are dups.

Now if you change your program to do a real lookups with the 2^16 possible 
values of sport you'll see :

jhash function :
1 61578
2 1916
3 42

that is : 61578 chains of length 1
1916 chains of length 2
42 chains of length 3

(for reference, with HASH_FOLD, about same results :
1 61692
2 1856
3 44

Pretty good results... for the gain jhash gives us.

Of course, XOR hash gives a 'perfect' 65536 chains of length 1.
