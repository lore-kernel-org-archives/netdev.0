From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/2] macvlan: Avoid unnecessary multicast cloning
Date: Mon, 30 May 2016 16:17:52 +0800
Message-ID: <20160530081752.GA4956@gondor.apana.org.au>
References: <20160526234433.GU8402@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57139 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcE3ISR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 04:18:17 -0400
Content-Disposition: inline
In-Reply-To: <20160526234433.GU8402@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2016 at 02:44:33AM +0300, Lennert Buytenhek wrote:
> Commit 412ca1550cbecb2c ("macvlan: Move broadcasts into a work queue")
> moved processing of all macvlan multicasts into a work queue.  This
> causes a noticable performance regression when there is heavy multicast
> traffic on the underlying interface for multicast groups that the
> macvlan subinterfaces are not members of, in which case we end up
> cloning all those packets and then freeing them again from a work queue
> without really doing any useful work with them in between.

OK so your motivation is to get rid of the unnecessary memory
allocation, right?

Here's my totally untested patch, it tries to resolve your problem
by maintaining a filter hash at the macvlan_port level so that we
can quickly determine whether a given packet is needed or not.

It is preceded by a patch that fixes a potential use-after-free
bug that I discovered while looking over this.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
