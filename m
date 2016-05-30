From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 0/2] macvlan: Avoid unnecessary multicast cloning
Date: Mon, 30 May 2016 19:27:59 +0300
Message-ID: <20160530162759.GD8402@wantstofly.org>
References: <20160526234433.GU8402@wantstofly.org>
 <20160530081752.GA4956@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:53482 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161417AbcE3Q2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 12:28:02 -0400
Content-Disposition: inline
In-Reply-To: <20160530081752.GA4956@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 30, 2016 at 04:17:52PM +0800, Herbert Xu wrote:

> > Commit 412ca1550cbecb2c ("macvlan: Move broadcasts into a work queue")
> > moved processing of all macvlan multicasts into a work queue.  This
> > causes a noticable performance regression when there is heavy multicast
> > traffic on the underlying interface for multicast groups that the
> > macvlan subinterfaces are not members of, in which case we end up
> > cloning all those packets and then freeing them again from a work queue
> > without really doing any useful work with them in between.
> 
> OK so your motivation is to get rid of the unnecessary memory
> allocation, right?

That and stack switches to kworker threads and serialisation on
the bc_queue queue lock.
