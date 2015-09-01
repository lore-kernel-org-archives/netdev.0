From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Tue, 1 Sep 2015 16:13:05 +0200
Message-ID: <20150901141305.GA11564@pox.localdomain>
References: <20150829090701.GN20760@orbit.nwl.cc>
 <20150830074717.GA25396@gondor.apana.org.au>
 <20150831110012.GO20760@orbit.nwl.cc>
 <20150901114300.GB12691@gondor.apana.org.au>
 <20150901124648.GA27550@orbit.nwl.cc>
 <20150901130057.GA13230@gondor.apana.org.au>
 <20150901134310.GB27550@orbit.nwl.cc>
 <20150901135019.GA13629@gondor.apana.org.au>
 <20150901135618.GD27550@orbit.nwl.cc>
 <20150901140341.GA13757@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150901140341.GA13757@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/01/15 at 10:03pm, Herbert Xu wrote:
> On Tue, Sep 01, 2015 at 03:56:18PM +0200, Phil Sutter wrote:
> > 
> > Looking at rhashtable_test.c, I see the initial table size is 8 entries.
> > 70% of that is 5.6 entries, so background expansion is started after the
> > 6th entry has been added, right? Given there are 10 threads running
> > which try to insert 50k entries at the same time, I don't think it's
> > unlikely that three more entries are inserted before the background
> > expansion completes.
> 
> Yes but in that case the GFP_ATOMIC allocation should work because
> the table is so small anyway.

You can easily trigger this outside of the testsuite as well. Open
10K Netlink sockets in a loop and the creation of the sockets will
fail way before memory pressure kicks in.

I agree with you that the user should never retry on memory failure.
That's why I suggested to differentiate between a "permanent" failure
(memory pressure) and non-permanent failure (temporary overload on
background expansion). Hence the proposed difference of return codes
ENOMEM and EBUSY to report this back to the API user.
