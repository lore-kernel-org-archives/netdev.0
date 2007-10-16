From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] [NET_DOC] Document some simple rules for actions
Date: Tue, 16 Oct 2007 20:51:35 +0800
Message-ID: <20071016125134.GA11319@gondor.apana.org.au>
References: <1192538011.4480.84.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1550 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756882AbXJPMwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 08:52:08 -0400
Content-Disposition: inline
In-Reply-To: <1192538011.4480.84.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 16, 2007 at 08:33:31AM -0400, jamal wrote:
>
> +2) If you munge any packet thou shalt call skb_expand in the case
> +someone else is referencing the skb. After that you "own" the skb. 
> +You must also tell us if it is ok to munge the packet (TC_OK2MUNGE), 
> +this way any action downstream can stomp on the packet.

Thanks for the documentation!

But I still think the distinction between skb_clone and
skb_copy_header is wrong.

When you munge a packet, it's still going to go back up
the stack and be processed along the same path.  Therefore
you should be calling pskb_expand_head.

In other words, this does not explain why skb_copy/pskb_copy
and skb_copy_expand should differ from skb_clone.  As far as
I can see all these functions should behave in the same manner
with respect to tc_verd.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
