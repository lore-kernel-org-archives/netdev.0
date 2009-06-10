From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 2/4] udp: Handle large UFO packets from
	untrusted sources
Date: Wed, 10 Jun 2009 19:17:57 +1000
Message-ID: <20090610091757.GA19155@gondor.apana.org.au>
References: <1244247391.1526.171.camel@w-sridhar.beaverton.ibm.com> <20090608051608.GA19748@gondor.apana.org.au> <1244480687.18220.36.camel@w-sridhar.beaverton.ibm.com> <20090608233739.GA1021@gondor.apana.org.au> <4A2F49DB.20207@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	rusty@rustcorp.com.au
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50105 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755785AbZFJJSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 05:18:03 -0400
Content-Disposition: inline
In-Reply-To: <4A2F49DB.20207@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2009 at 10:51:23PM -0700, Sridhar Samudrala wrote:
>
> Unfortunately, this doesn't work for UDP without any changes.  
> skb_segment() currently adds transport header to
> each segmented skb. But when we are using IP fragmentation, only the  
> first fragment should include the UDP
> header.
> We either need to fix skb_segment() to handle IP fragmentation or write  
> a new skb_fragment(). I will look into
> this when i get some time.

Couldn't you get around this by setting skb->transport_header to
skb->network_header before getting into skb_segment?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
