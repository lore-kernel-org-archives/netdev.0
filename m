From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Tue, 1 Sep 2015 15:56:18 +0200
Message-ID: <20150901135618.GD27550@orbit.nwl.cc>
References: <20150829090701.GN20760@orbit.nwl.cc>
 <20150830074717.GA25396@gondor.apana.org.au>
 <20150831110012.GO20760@orbit.nwl.cc>
 <20150901114300.GB12691@gondor.apana.org.au>
 <20150901124648.GA27550@orbit.nwl.cc>
 <20150901130057.GA13230@gondor.apana.org.au>
 <20150901134310.GB27550@orbit.nwl.cc>
 <20150901135019.GA13629@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150901135019.GA13629@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 01, 2015 at 09:50:19PM +0800, Herbert Xu wrote:
> On Tue, Sep 01, 2015 at 03:43:11PM +0200, Phil Sutter wrote:
> >
> > Hmm. Since memory allocation is first tried with GFP_ATOMIC set and upon
> > failure retried in background, this seems like a situation which might
> > happen during normal use. If that already indicates a severe problem,
> > why retry in background at all?
> 
> It should be tried in the background first at 70% and only when
> that fails would we hit the 100% case and then we will try it
> with GFP_ATOMIC.  If that fails then the insertion will fail.

Ah, good to know. Thanks for clarifying this!

Looking at rhashtable_test.c, I see the initial table size is 8 entries.
70% of that is 5.6 entries, so background expansion is started after the
6th entry has been added, right? Given there are 10 threads running
which try to insert 50k entries at the same time, I don't think it's
unlikely that three more entries are inserted before the background
expansion completes.

Cheers, Phil
