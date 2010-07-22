From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: macvtap: Limit packet queue length
Date: Thu, 22 Jul 2010 00:47:32 -0700
Message-ID: <20100722074732.GA24905@sequoia.sous-sol.org>
References: <20100722064157.GA25913@gondor.apana.org.au>
 <20100722074431.GA26744@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Mark Wagner <mwagner@redhat.com>,
	Chris Wright <chrisw@sous-sol.org>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:50443 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758448Ab0GVHr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 03:47:59 -0400
Content-Disposition: inline
In-Reply-To: <20100722074431.GA26744@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Herbert Xu (herbert@gondor.hengli.com.au) wrote:
> On Thu, Jul 22, 2010 at 02:41:57PM +0800, Herbert Xu wrote:
> > Hi:
> > 
> > macvtap: Limit packet queue length
> 
> Chris has informed me that he's already tried a similar patch
> and it only makes the problem worse :)
> 
> The issue is that the macvtap TX queue length defaults to zero.
> 
> So here is an updated patch which addresses this:
> 
> macvtap: Limit packet queue length
> 
> Mark Wagner reported OOM symptoms when sending UDP traffic over
> a macvtap link to a kvm receiver.
> 
> This appears to be caused by the fact that macvtap packet queues
> are unlimited in length.  This means that if the receiver can't
> keep up with the rate of flow, then we will hit OOM. Of course
> it gets worse if the OOM killer then decides to kill the receiver.
> 
> This patch imposes a cap on the packet queue length, in the same
> way as the tuntap driver, using the device TX queue length.
> 
> Please note that macvtap currently has no way of giving congestion
> notification, that means the software device TX queue cannot be
> used and packets will always be dropped once the macvtap driver
> queue fills up.
> 
> This shouldn't be a great problem for the scenario where macvtap
> is used to feed a kvm receiver, as the traffic is most likely
> external in origin so congestion notification can't be applied
> anyway.
> 
> Of course, if anybody decides to complain about guest-to-guest
> UDP packet loss down the track, then we may have to revisit this.
> 
> Incidentally, this patch also fixes a real memory leak when
> macvtap_get_queue fails.
> 
> Chris Wright noticed that for this patch to work, we need a
> non-zero TX queue length.  This patch includes his work to change
> the default macvtap TX queue length to 500.
> 
> Reported-by: Mark Wagner <mwagner@redhat.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Chris Wright <chrisw@sous-sol.org>

Thanks Herbert.
-chris
