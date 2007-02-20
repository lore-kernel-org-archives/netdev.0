From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 14:41:00 +0300
Message-ID: <20070220114100.GA27069@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <20070220103014.GB7237@2ka.mipt.ru> <200702201210.22907.dada1@cosmosbay.com> <200702201230.19495.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46571 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964827AbXBTLrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 06:47:05 -0500
Content-Disposition: inline
In-Reply-To: <200702201230.19495.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 12:30:18PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Tuesday 20 February 2007 12:10, Eric Dumazet wrote:
>  >
> > > Yep, it happend to be my tests :)
> > > Jenkins hash was slower and had significant artifacts for some usage
> > > cases ended up with extremely long chain length.
> > > One can find more details at
> > > http://tservice.net.ru/~s0mbre/blog/2006/05/14#2006_05_14
> > > http://tservice.net.ru/~s0mbre/blog/2006/06/01#2006_06_01
> >
> > Please explain why you chose    h = jhash_2words(faddr, laddr, ports);
> >         h ^= h >> 16;
> >         h ^= h >> 8;
> >
> > jhash is very good, no need to try to be smarter, shufling some bytes...
> > and adding artifacts.
> 
> I checked with my simulator and got no differences with the extra ops, at 
> least no artifacts. Maybe this is related to the fact my hash size is 2^20 ?
> 
> If we use jenkin hash:
> [0]:617469 0%
> [1]:326671 58.7654%
> [2]:86704 89.9601%
> [3]:15387 98.264%
> [4]:2103 99.7773%
> [5]:216 99.9716%
> [6]:24 99.9975%
> [7]:2 100%
> 
> If we use jenkin hash (+plus Evgeniy Polyakov shifts) :
> [0]:617553 0%
> [1]:326403 58.7172%
> [2]:86902 89.9831%
> [3]:15462 98.3275%
> [4]:2012 99.7753%
> [5]:216 99.9696%
> [6]:27 99.9987%
> [7]:1 100%

Yes, they are the same - but artifacts are artifacts in that regard that
they appear only in special sets, as far as I recall one of the parameters
must be constant (i.e. address or port pair).

-- 
	Evgeniy Polyakov
