From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in
	2.6.24-rc6,	comparing with 2.6.22
Date: Wed, 16 Jan 2008 15:15:42 +0800
Message-ID: <1200467742.3151.90.camel@ymzhang>
References: <1199871330.3298.132.camel@ymzhang>
	 <1200043854.3265.24.camel@ymzhang>
	 <Pine.LNX.4.64.0801141036400.31652@kivilampi-30.cs.helsinki.fi>
	 <20080114105307.GA22866@gondor.apana.org.au>
	 <1200443644.3151.33.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ingo Molnar <mingo@elte.hu>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:8011 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752429AbYAPHRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 02:17:06 -0500
In-Reply-To: <1200443644.3151.33.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-01-16 at 08:34 +0800, Zhang, Yanmin wrote:
> On Mon, 2008-01-14 at 21:53 +1100, Herbert Xu wrote:
> > On Mon, Jan 14, 2008 at 08:44:40AM +0000, Ilpo Jrvinen wrote:
> > >
> > > > > I tried to use bisect to locate the bad patch between 2.6.22 and 2.6.23-rc1,
> > > > > but the bisected kernel wasn't stable and went crazy.
> > > 
> > > TCP work between that is very much non-existing.
> > 
> > Make sure you haven't switched between SLAB/SLUB while testing this.
> I can make sure. In addition, I tried both SLAB and SLUB and make sure the 
> regression is still there if CONFIG_SLAB=y.
I retried bisect between 2.6.22 and 2.6.23-rc1. This time, I enabled CONFIG_SLAB=y,
and deleted the warmup procedure in the testing scripts. In addition, bind the 2
processes on the same logical processor. The regression is about 20% which is larger
than the one when binding 2 processes to different core.

The new bisect reported cfs core patch causes it. The results of every step look
stable.

dd41f596cda0d7d6e4a8b139ffdfabcefdd46528 is first bad commit
commit dd41f596cda0d7d6e4a8b139ffdfabcefdd46528
Author: Ingo Molnar <mingo@elte.hu>
Date:   Mon Jul 9 18:51:59 2007 +0200

    sched: cfs core code
    
    apply the CFS core code.
    
    this change switches over the scheduler core to CFS's modular
    design and makes use of kernel/sched_fair/rt/idletask.c to implement
    Linux's scheduling policies.
    
    thanks to Andrew Morton and Thomas Gleixner for lots of detailed review
    feedback and for fixlets.
    
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Mike Galbraith <efault@gmx.de>
    Signed-off-by: Dmitry Adamushko <dmitry.adamushko@gmail.com>
    Signed-off-by: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>


-yanmin


