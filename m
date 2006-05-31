From: David Miller <davem@davemloft.net>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 00:08:18 -0700 (PDT)
Message-ID: <20060531.000818.78646242.davem@davemloft.net>
References: <20060531051451.GA7110@gondor.apana.org.au>
	<20060530.232626.00456312.davem@davemloft.net>
	<20060531063152.GA8032@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14479
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S964849AbWEaHHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 03:07:51 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060531063152.GA8032@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 31 May 2006 16:31:52 +1000

> On Tue, May 30, 2006 at 11:26:26PM -0700, David Miller wrote:
> > 
> > I don't think it will be worthwhile to keep NAPI around just for
> > TX completion.  Sure the dev_kfree_skb() will schedule software
> > interrupt work to do the actual free, but the TX ring walking
> > and dev_kfree_skb() calls will be in hard IRQ context.
> 
> Sure we won't need all of NAPI.  But would it be that bad to schedule
> a tasklet to do the TX completion?

It seems just an extra level of indirection. :)

> Oh, I'm not proposing that we disable IRQs on xmit_lock at all.
 ...

I understand what you're saying.  What I'm talking about is that in
net channel drivers we might go back to IRQ disabling locks again.
