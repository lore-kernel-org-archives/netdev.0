From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Mon, 7 Dec 2015 16:35:24 +0100
Message-ID: <20151207153524.GA22032@pox.localdomain>
References: <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
 <20151203125117.GB5505@gondor.apana.org.au>
 <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151204143956.GA17471@gondor.apana.org.au>
 <20151204170101.GB29598@orbit.nwl.cc>
 <1449251120.25029.31.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151204181555.GC29598@orbit.nwl.cc>
 <20151205070603.GB23255@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151205070603.GB23255@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/05/15 at 03:06pm, Herbert Xu wrote:
> On Fri, Dec 04, 2015 at 07:15:55PM +0100, Phil Sutter wrote:
> >
> > > Only one should really do this, while others are waiting.
> > 
> > Sure, that was my previous understanding of how this thing works.
> 
> Yes that's clearly how it should be.  Unfortunately while adding
> the locking to do this, I found out that you can't actually call
> __vmalloc with BH disabled so this is a no-go.
> 
> Unless we can make __vmalloc work with BH disabled, I guess we'll
> have to go back to multi-level lookups unless someone has a better
> suggestion.

Thanks for fixing the race.

As for the remaining problem, I think we'll have to find a way to
serve a hard pounding user if we want to convert TCP hashtables
later on.

Did you look into what __vmalloc prevents to work with BH disabled?
