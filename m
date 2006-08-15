From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: skb_shared_info()
Date: Tue, 15 Aug 2006 15:30:46 +0400
Message-ID: <20060815113046.GA1848@ms2.inr.ac.ru>
References: <20060808.163915.03600382.davem@davemloft.net> <20060811140019.GA8611@ms2.inr.ac.ru> <20060811.172730.34542868.davem@davemloft.net> <20060813130431.GA14138@ms2.inr.ac.ru> <20060814080120.GA20053@2ka.mipt.ru> <20060814131919.GA13064@ms2.inr.ac.ru> <20060814133843.GA30374@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:51426 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S965368AbWHOLbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 07:31:05 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060814133843.GA30374@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> I still like existing way - it is much simpler (I hope :) to convince
> e1000 developers to fix driver's memory usage

e1000 is not a problem at all. It just has to use pages.
If it is going to use high order allocations, it will suck,
be it order 3 or 2.


> area (does MAX_TCP_HEADER enough for all, what about ipv6 options?)...

This does not matter. All the cases with pathologically extended
headers go slow path with non-trivial pskb_pull(). This is what all
those options are invented for.


> 								 unix 
> socket use that.

Totally does not worth it, unless it is a part of something bigger.


> global changes like you suggested, we can break things more
> fundamentally :)

_You_ have to. :-) Sender zerocopy stalled only because of this. 

Alexey
