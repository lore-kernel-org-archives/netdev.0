From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH] net: consolidate lock/unlock into unlock_wait
Date: Sat, 19 Mar 2016 07:24:25 +0000
Message-ID: <20160319072425.GB9761@osadl.at>
References: <1458293525-16842-1-git-send-email-hofrat@osadl.org>
 <20160318.173702.788700055531273267.davem@davemloft.net>
 <1458340518.26915.30.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hofrat@osadl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1458340518.26915.30.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 18, 2016 at 03:35:18PM -0700, Joe Perches wrote:
> On Fri, 2016-03-18 at 17:37 -0400, David Miller wrote:
> > From: Nicholas Mc Guire <hofrat@osadl.org>
> > > The spin_lock()/spin_unlock() is synchronizing on the adapter->work_lock
> > > as the comment also suggests, which is equivalent to spin_unlock_wait()
> > > but the later should be more efficient.
> []
> > There really is no justification for this change.
> > This is an optimization in a slow-path of the driver.
> > The device is a rarely used older piece of hardware.
> 
> It really might be nice to take some of the ancient
> hardware drivers in drivers/net and move them into
> some separate subdirectory like:
> 
> 	drivers/net/ancient
> or
> 	drivers/net/antiques
> or
> 	drivers/net/archaic
> etc...
> 
> so there's some clear designation that these crufty
> old drivers don't need to be touched anymore except
> for maybe when kernel wide changes occur.
>
actually thats just the problem - some of those did not
perform such kernel wide changes lock/unlock -> unlock_wait
being one of them. But having a distinction as proposed to
keep people like me from scanning them, sounds like a good idea.

Will add an "age of code" check before submitting API cleanups.

thx!
hofrat
