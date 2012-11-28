From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Wed, 28 Nov 2012 11:04:12 +0100
Message-ID: <20121128100412.GA6269@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2012 at 09:21:37AM -0000, David Laight wrote:
> > On Tue, 27 Nov 2012 18:02:29 +0000
> > David Woodhouse <dwmw2@infradead.org> wrote:
> > 
> > > In solos-pci at least, the ops->close() function doesn't flush all
> > > pending skbs for this vcc before returning. So can be a tasklet
> > > somewhere which has loaded the address of the vcc->pop function from one
> > > of them, and is going to call it in some unspecified amount of time.
> > >
> > > Should we make the device's ->close function wait for all TX and RX skbs
> > > for this vcc to complete?
> > 
> > the driver's close routine should wait for any of the pending tx and rx
> > to complete.  take a look at the he.c in driver/atm
> 
> I'm not sure that sleeping for long periods in close() is always a
> good idea. If the process is event driven it will be unable to
> handle events on other fd until the close completes.
> This may be known not to be true in this case, but is more generally
> a problem.
> In this case the close should probably (IMHO at least) only sleep
> while pending tx and rx are aborted/discarded.
> 
> Even when it might make sense to sleep in close until tx drains
> there needs to be a finite timeout before it become abortive.
> 

The ->close() routine can just abort any pending rx/tx and just wait
for completion of currently running rx/tx code. That shouldn't take
long.

Krzysiek
