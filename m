From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 11/16] esp: Use a synchronous crypto algorithm on
 offloading.
Date: Thu, 20 Apr 2017 17:52:35 +0800
Message-ID: <20170420095235.GA8580@gondor.apana.org.au>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
 <1492678515-14347-12-git-send-email-steffen.klassert@secunet.com>
 <20170420090617.GA8325@gondor.apana.org.au>
 <20170420091752.GH2649@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:36798 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S944179AbdDTJzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 05:55:16 -0400
Content-Disposition: inline
In-Reply-To: <20170420091752.GH2649@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 11:17:52AM +0200, Steffen Klassert wrote:
>
> I tried to use async algorithms but it lead to serveral problems.
> The GSO layer can't handle async returns, we'd need callbacks
> for all the GSO handlers. Also we need something where we can
> requeue packets if the driver is busy etc.

Why would we need to requeue? As it is if you get an EBUSY on
an IPsec packet it's simply dropped.

The main AES implementation on x86 is now async so I think it's
pretty important that we support it out-of-the-box.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
