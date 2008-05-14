From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Wed, 14 May 2008 18:17:41 +0200
Message-ID: <m3hcd0kggq.fsf@maximus.localdomain>
References: <20080424.065555.30390704.davem@davemloft.net>
	<m3ve27nfpx.fsf@maximus.localdomain>
	<20080424214457.1d5a1655@the-village.bc.nu>
	<20080512.033244.153113922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, jeff@garzik.org, paulkf@microgate.com,
	jchapman@katalix.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:52324 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbYENQRp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 12:17:45 -0400
In-Reply-To: <20080512.033244.153113922.davem@davemloft.net> (David Miller's message of "Mon\, 12 May 2008 03\:32\:44 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BTW: The dev->ml_priv addition is obviously a good step but I guess
you don't need the dev->priv hackery duplicated with dev->ml_priv.

Can't test it at the moment but I'd leave dev->priv alone and only get
rid of the syncppp_ptr here. Then I'd simply use dev->ml_priv as
syncppp_ptr and dev->priv would be a private driver pointer, as
usual. Generic HDLC uses dev->priv for itself but the relevant hw
drivers use hdlc->priv instead so it's not a problem.

When syncppp.c is removed we can use dev->ml_priv for HDLC layer,
dev->priv for hw driver, and hdlc->priv would be no longer needed.

I mean the following:

David Miller <davem@davemloft.net> writes:

> --- a/include/net/syncppp.h
> +++ b/include/net/syncppp.h
> @@ -59,7 +59,7 @@ struct ppp_device
>  
>  static inline struct sppp *sppp_of(struct net_device *dev) 
>  {
> -	struct ppp_device **ppp = dev->priv;
> +	struct ppp_device **ppp = dev->ml_priv;
>  	BUG_ON((*ppp)->dev != dev);
>  	return &(*ppp)->sppp;
>  }

would become:

static inline struct sppp *sppp_of(struct net_device *dev) 
{
	return dev->ml_priv;
}

The changes are not automatic, I'll look at it when able.
-- 
Krzysztof Halasa
