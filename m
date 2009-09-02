From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crypto oops in async_chainiv_do_postponed
Date: Thu, 3 Sep 2009 07:57:12 +1000
Message-ID: <20090902215712.GA16941@gondor.apana.org.au>
References: <19095.1264.682820.125602@waldo.imnotcreative.homeip.net> <20090829104606.GA13141@gondor.apana.org.au> <19099.63038.425414.514063@waldo.imnotcreative.homeip.net> <20090831220459.GA15713@gondor.apana.org.au> <19101.16628.347039.619378@waldo.imnotcreative.homeip.net> <20090901221721.GA1964@gondor.apana.org.au> <19102.31846.180030.843571@waldo.imnotcreative.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	offbase0@gmail.com
To: Brad Bosch <bradbosch@comcast.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <19102.31846.180030.843571@waldo.imnotcreative.homeip.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 02, 2009 at 09:08:38AM -0500, Brad Bosch wrote:
> 
> Assume the worker thread is executing between the dequeue in
> async_chainiv_do_postponed and the clear_bit call in
> async_chainiv_schedule_work.  Further assume that we are processing

It cannot.  The worker thread can only execute when it owns
the INUSE bit.  In that case do_postponed will never call the
schedule_work function.

Perhaps you were misled by the clear_bit call in schedule_work.
That is only used if we end up not scheduling the work.
 
> Unfortunately, the offset problem is not easily reproduced with our
> application, so testing long enough to be sure the problem is fixed
> (assuming that it was indeed the cause of the oops) may not be
> practical.  All I can say at the moment is that I have not seen the
> crash since I introduced the two patches I sent you.

OK I'll forward this upstream then.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
