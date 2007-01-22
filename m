From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 22 Jan 2007 07:52:14 +0100
Message-ID: <20070122065214.GA1634@ff.dom.local>
References: <45AE2EDF.4060709@tls.msk.ru> <20070119110641.GA3135@ff.dom.local> <20070119211027.GA16626@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tokarev <mjt@tls.msk.ru>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	"David S\. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:56575 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751453AbXAVGty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 01:49:54 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20070119211027.GA16626@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 20, 2007 at 08:10:27AM +1100, Herbert Xu wrote:
> On Fri, Jan 19, 2007 at 12:06:41PM +0100, Jarek Poplawski wrote:
> > 
> > [PATCH][NET] tcp_output: rare bad TCP checksum with 2.6.19
> > 
> > The patch "Replace CHECKSUM_HW by CHECKSUM_PARTIAL/CHECKSUM_COMPLETE"
> > changed to unconditional copying of ip_summed field from collapsed
> > skb. This patch reverts this change.   
> > 
> > All substantial work including heavy testing and diagnosing by:
> > Michael Tokarev <mjt@tls.msk.ru>
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Thanks for catching this! I'll take the credit for adding this bug :)
> 
> Dave, we'll need this fix for 2.6.20 as well as 2.6.19.
 
I was so impressed by the amount of work done by Michael
that I magnified his merit and forgot to mention the role
of Patrick and Herbert, particularly here:

> Since you're certain that this is being seen on the wire, one
> possibility is that we've got a bug somewhere that's zeroing
> skb->ip_summed on a packet with a partial checksum.

which exactly pointed the reason.

So, I apologize to them and, if there is such possibility,
I would like to ask David Miller to change the description
like that: 
---
[PATCH][NET] tcp_output: rare bad TCP checksum with 2.6.19

The patch "Replace CHECKSUM_HW by CHECKSUM_PARTIAL/CHECKSUM_COMPLETE"
changed to unconditional copying of ip_summed field from collapsed
skb. This patch reverts this change.

The majority of substantial work including heavy testing
and diagnosing by: Michael Tokarev <mjt@tls.msk.ru>
Possible reasons pointed by: Herbert Xu and Patrick McHardy.

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
---

Regards,
Jarek P.
