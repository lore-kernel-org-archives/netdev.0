From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Sun, 5 Oct 2008 14:56:48 +0800
Message-ID: <20081005065648.GA13113@gondor.apana.org.au>
References: <E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au> <20081005065509.GA2538@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>, davem@davemloft.net,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57499 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752334AbYJEG47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 02:56:59 -0400
Content-Disposition: inline
In-Reply-To: <20081005065509.GA2538@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2008 at 08:55:10AM +0200, Jarek Poplawski wrote:
>
> > -	/* Not safe to do outside the semaphore.  We must not return
> > -	 * until all unregister events invoked by the local processor
> > -	 * have been completed (either by this todo run, or one on
> > -	 * another cpu).
> > -	 */
> 
> I think, it's about not to let others run this for devices unregistered
> within later rtnl_locks before completing previous tasks. So, it would
> be nice to have some comment why it's not necessary anymore.

Where did you get that idea?

This was there because people did (and still do) stuff like:

unregister_netdev(dev);
free_netdev(dev);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
