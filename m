From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 11/16] esp: Use a synchronous crypto algorithm on
 offloading.
Date: Thu, 20 Apr 2017 11:17:52 +0200
Message-ID: <20170420091752.GH2649@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
 <1492678515-14347-12-git-send-email-steffen.klassert@secunet.com>
 <20170420090617.GA8325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:52624 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941662AbdDTJVt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 05:21:49 -0400
Content-Disposition: inline
In-Reply-To: <20170420090617.GA8325@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 05:06:17PM +0800, Herbert Xu wrote:
> On Thu, Apr 20, 2017 at 10:55:10AM +0200, Steffen Klassert wrote:
> > We need a fallback algorithm for crypto offloading to a NIC.
> > This is because packets can be rerouted to other NICs that
> > don't support crypto offloading. The fallback is going to be
> > implemented at layer2 where we know the final output device
> > but can't handle asynchronous returns fron the crypto layer.
> 
> Can you explain why we can't handle async algorithms on the fallback
> path?

I tried to use async algorithms but it lead to serveral problems.
The GSO layer can't handle async returns, we'd need callbacks
for all the GSO handlers. Also we need something where we can
requeue packets if the driver is busy etc.

This would require a lot of changes in the generic code,
so I decided to use a synchronous fallback algorithm for
now.
