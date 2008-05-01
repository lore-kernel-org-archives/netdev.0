From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Thu, 01 May 2008 19:53:47 +0800
Message-ID: <E1JrXMB-00028Q-00@gondolin.me.apana.org.au>
References: <BAY103-DAV1299426BC4DEDBC952BD39B2D80@phx.gbl>
Cc: netdev@vger.kernel.org
To: pupilla@hotmail.com (Marco Berizzi)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53091 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757250AbYEALxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 07:53:49 -0400
In-Reply-To: <BAY103-DAV1299426BC4DEDBC952BD39B2D80@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi <pupilla@hotmail.com> wrote:

> I have removed these modules from
> the two boxes that are crashing:

OK, I've matched up your xfrm_output.o with the crash and it
would appear that skb->dst is either NULL or crap after the
local_out call in xfrm_output_resume.  We know that it was valid
before the call because skb->dst is used to make that call.

So it would appear that some netfilter rule has freed skb->dst.
Do you have relevant netfilter rules, e.g., NAT entries or any
rules that might reroute the packet?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
