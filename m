From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Wed, 29 Jul 2009 21:02:22 -0400
Message-ID: <20090730010222.GA4169@localhost.localdomain>
References: <20090729073523.GA4515@gondor.apana.org.au> <1248894478.4545.2822.camel@calx> <20090729194300.GB17410@hmsreliant.think-freely.org> <1248904097.4545.2934.camel@calx> <20090729231517.GA32670@hmsreliant.think-freely.org> <20090729231735.GB14066@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33509 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755575AbZG3BCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 21:02:32 -0400
Content-Disposition: inline
In-Reply-To: <20090729231735.GB14066@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2009 at 07:17:35AM +0800, Herbert Xu wrote:
> On Wed, Jul 29, 2009 at 07:15:17PM -0400, Neil Horman wrote:
> >
> > Not quite.  I agree private locking in a driver is a pain when you consider
> > netpoll clients, its not the tx/tx recursion you need to worry about though, its
> > shared locking between the tx and rx path that you need to be worried about.
> > We should be protected against deadlock on the _xmit_lock from what we discussed
> > above, but if you take a lock in the driver, then call printk, its possible that
> > you'll go down the ->poll routine path in the driver.  If there you try to take
> > the same private lock, the result is then deadlock.
> 
> xmit_lock suffers from exactly the same problem in ->poll.
> 
Under what conditions do you try to take the xmit_lock from within a drivers
->poll routine?  Do you have an example?

Neil


