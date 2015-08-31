From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Mon, 31 Aug 2015 13:00:12 +0200
Message-ID: <20150831110012.GO20760@orbit.nwl.cc>
References: <20150829090701.GN20760@orbit.nwl.cc>
 <20150830074717.GA25396@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150830074717.GA25396@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 30, 2015 at 03:47:17PM +0800, Herbert Xu wrote:
> Phil Sutter <phil@nwl.cc> wrote:
> >
> > Should we introduce a new field to struct rhashtable to track the
> > internal state? This might allow to clean up some rather obscure tests,
> > e.g. whether a table resize is in progress or not.
> 
> Why would we want to do that? The deferred expansion is done
> on a best effort basis so its failure has nothing to do with
> the failure of a subsequent insertion.

The variable would be used to track if the worker has failed to allocate
memory in background.

Since the failing insertion will be retried, subsequent inserts are not
necessary unrelated.

> The insertion must have tried its own last-ditch synchronous
> expansion and only fail if that fails.

Who do you mean with "the insertion"? The user or the API?

Cheers, Phil
