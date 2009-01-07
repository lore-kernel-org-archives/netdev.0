From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 22:50:32 +1100
Message-ID: <20090107115032.GA25198@gondor.apana.org.au>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk> <20090107044232.GA22218@gondor.apana.org.au> <20090107112906.GA28161@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45248 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751073AbZAGLur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 06:50:47 -0500
Content-Disposition: inline
In-Reply-To: <20090107112906.GA28161@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 02:29:06PM +0300, Evgeniy Polyakov wrote:
>
> That would not happen without scatter-gather support on the interface,
> date would be plain copied, and after Jarek's requst Willy confirmed
> that corruption happens with all acceleration being turned off.

It will happen without scatter-gather support.  The problem
is with skb->head, which is always there.  In any case, SG can't
make any difference because the skb is an inbound one and most
drivers only produce linear packets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
