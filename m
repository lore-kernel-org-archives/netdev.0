From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 1 May 2008 19:12:47 +0800
Message-ID: <20080501111247.GA7756@gondor.apana.org.au>
References: <20080430214845.GC14219@solarflare.com> <E1JrWFU-0001ue-00@gondolin.me.apana.org.au> <20080501110225.GG14219@solarflare.com> <1209640128.4191.30.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58872 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755902AbYEALMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 07:12:55 -0400
Content-Disposition: inline
In-Reply-To: <1209640128.4191.30.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 12:08:48PM +0100, Kieran Mansley wrote:
>
> Yes, everything works fine in that case.  It's only when LRO packets are
> forwarded to another physical interface that things go wrong.  

Now this is definitely broken because it fiddles with TCP packets
in the middle, but still it should *work* in as much as making the
packet go out.  Well except that you need to fix up the checksum
so that it only contains the pseudo-header on output.  That's
probably what you need to address if we failed in avoiding LRO
on forwarded traffic.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
