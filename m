From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Tue, 01 Sep 2015 06:40:48 -0700
Message-ID: <1441114848.8932.172.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150829090701.GN20760@orbit.nwl.cc>
	 <20150830074717.GA25396@gondor.apana.org.au>
	 <20150831110012.GO20760@orbit.nwl.cc>
	 <20150901114300.GB12691@gondor.apana.org.au>
	 <20150901124648.GA27550@orbit.nwl.cc>
	 <20150901130057.GA13230@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150901130057.GA13230@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-01 at 21:00 +0800, Herbert Xu wrote:
> On Tue, Sep 01, 2015 at 02:46:48PM +0200, Phil Sutter wrote:
> >
> > This is not an inherent behaviour of the implementation but general
> > agreement. The insertion may fail non-permanently (returning -EBUSY),
> > users are expected to handle this by retrying the operation.
> 
> Absolutely not.  The only reason for an insertion to fail is if we
> can't allocate enough memory.  Unless the user is also looping its
> kmalloc calls it definitely shouldn't be retrying the insert.
> 
> If an expansion fails it means either that the system is suffering
> a catastrophic memory shortage, or the user of rhashtable is doing
> something wrong.


-EBUSY does not sound as a memory allocation error.
