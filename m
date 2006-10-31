From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [SCTP]: Always linearise packet on input
Date: Tue, 31 Oct 2006 14:01:10 +1100
Message-ID: <20061031030110.GA27427@gondor.apana.org.au>
References: <20061030071128.GA15715@gondor.apana.org.au> <20061029.234619.112618588.davem@davemloft.net> <1162258285.22597.33.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:13329 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1752025AbWJaDBW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 22:01:22 -0500
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <1162258285.22597.33.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sridhar:

On Mon, Oct 30, 2006 at 05:31:24PM -0800, Sridhar Samudrala wrote:
> 
> I think we currently assume atleast the SCTP header and the data
> chunk header to be in the skb head.
> But we do handle skbs with data in the frag_list.
> Not sure about skb's with paged fragments.

You can't assume the chunk header to be in the head.  Think about what
happens when some malicious person sends you a fragmented SCTP packet.

> Does XEN use frag_list or frags array?

Xen creates paged frags in domU=>dom0 or domU=>domU traffic.
Of course frag_list can always occur as a result of IP fragmentation.

> Is there a simple way to simulate incoming packets with transport
> headers and data in skb's frag_list/pages without having to use XEN.

You can use IP fragments to create them.

But the important thing is to work through the code.  Basically wherever
you see things like skb_pull/skb->data without a preceding pskb_may_pull
call, then you have a problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
