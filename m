From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Tue, 1 Sep 2015 15:43:11 +0200
Message-ID: <20150901134310.GB27550@orbit.nwl.cc>
References: <20150829090701.GN20760@orbit.nwl.cc>
 <20150830074717.GA25396@gondor.apana.org.au>
 <20150831110012.GO20760@orbit.nwl.cc>
 <20150901114300.GB12691@gondor.apana.org.au>
 <20150901124648.GA27550@orbit.nwl.cc>
 <20150901130057.GA13230@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39178 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752094AbbIANnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 09:43:12 -0400
Content-Disposition: inline
In-Reply-To: <20150901130057.GA13230@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2015 at 09:00:57PM +0800, Herbert Xu wrote:
> On Tue, Sep 01, 2015 at 02:46:48PM +0200, Phil Sutter wrote:
> >
> > This is not an inherent behaviour of the implementation but general
> > agreement. The insertion may fail non-permanently (returning -EBUSY),
> > users are expected to handle this by retrying the operation.
> 
> Absolutely not.  The only reason for an insertion to fail is if we
> can't allocate enough memory.  Unless the user is also looping its
> kmalloc calls it definitely shouldn't be retrying the insert.

rhashtable_insert_fast() returns -EBUSY if the table is full
(rht_grow_above_100() returns true) and an asynchronous rehash operation
is active. AFAICT, this is not necessarily caused by memory pressure.

> If an expansion fails it means either that the system is suffering
> a catastrophic memory shortage, or the user of rhashtable is doing
> something wrong.

Hmm. Since memory allocation is first tried with GFP_ATOMIC set and upon
failure retried in background, this seems like a situation which might
happen during normal use. If that already indicates a severe problem,
why retry in background at all?

Cheers, Phil
