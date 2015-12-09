From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Wed, 9 Dec 2015 10:38:44 +0800
Message-ID: <20151209023844.GA24736@gondor.apana.org.au>
References: <20151207.142953.387889541116696974.davem@davemloft.net>
 <20151205070603.GB23255@gondor.apana.org.au>
 <20151209021826.GC19097@pox.localdomain>
 <20151209022454.GA24515@gondor.apana.org.au>
 <20151209023632.GD19097@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Phil Sutter <phil@nwl.cc>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151209023632.GD19097@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 09, 2015 at 03:36:32AM +0100, Thomas Graf wrote:
> 
> Without knowing your exact implementation plans: introducing an
> additional reference indirection for every lookup will have a
> huge performance penalty as well.
> 
> Is your plan to only introduce the master table after an
> allocation has failed?

Right, obviously the extra indirections would only come into play
after a failed allocation.  As soon as we can run the worker thread
it'll try to remove the extra indirections by doing vmalloc.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
