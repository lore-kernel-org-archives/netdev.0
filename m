From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP connection stops after high load.
Date: Sat, 14 Apr 2007 14:21:44 +1000
Message-ID: <E1HcZlg-0006Bi-00@gondolin.me.apana.org.au>
References: <20070413184111.0ab12e32.dada1@cosmosbay.com>
Cc: danielschaffrath@mac.com, greearb@candelatech.com,
	andi@firstfloor.org, netdev@vger.kernel.org, bcrl@kvack.org
To: dada1@cosmosbay.com (Eric Dumazet)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1326 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754172AbXDNEWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 00:22:44 -0400
In-Reply-To: <20070413184111.0ab12e32.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> dev_queue_xmit_nit() is called before attempting to send packet to device.
> 
> If device could not accept the packet (hard_start_xmit() returns an error), packet is requeued and retried later.
> each retry means call ev_queue_xmit_nit() again, so tcpdump/sniffers can 'see' packet transmited several times. 

This should only happen with LLTX drivers.  In fact, LLTX drivers are
really more trouble than they're worth.  They should all be rewritten
to follow the model used in tg3.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
