From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Wed, 19 Sep 2007 16:51:50 +0800
Message-ID: <20070919085150.GB18492@gondor.apana.org.au>
References: <20070918120438.GA9121@gondor.apana.org.au> <E1IXbqs-0002Od-00@gondolin.me.apana.org.au> <46F032D5.7020806@katalix.com> <20070919012529.GA15046@gondor.apana.org.au> <46F0E145.4020501@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1796 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753618AbXISIwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 04:52:08 -0400
Content-Disposition: inline
In-Reply-To: <46F0E145.4020501@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 09:43:49AM +0100, James Chapman wrote:
>
> >-discard:
> >-	/* Free the new skb. Caller will free original skb. */
> >-	if (skb2 != skb)
> >-		kfree_skb(skb2);
> > abort:
> >-	return 0;
> >+	/* Free the original skb */
> >+	kfree_skb(skb);
> >+	return 1;
> > }
> 
> Shouldn't this return 0 in the error case and without the kfree_skb()? 
> This lets ppp requeue the skb.

No.  As I described in the changelog, the return value of 0
is only meaningful for ppp_async and ppp_sync.  Returning 0
means that you're congested, not that there has been a
temporary error and the packet should be retried.

Retransmission should be left to the higher protocols.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
