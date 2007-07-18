From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Wed, 18 Jul 2007 02:18:14 -0700 (PDT)
Message-ID: <20070718.021814.99458359.davem@davemloft.net>
References: <200707161506.47915.joakim.koskela@hiit.fi>
	<39e6f6c70707160556m37137161odec6d01cc200524c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joakim.koskela@hiit.fi, netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50843
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756119AbXGRJSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:18:16 -0400
In-Reply-To: <39e6f6c70707160556m37137161odec6d01cc200524c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 16 Jul 2007 09:56:59 -0300

> Sorry for not commented that the code you were using (and David said
> it was invalid) is in fact valid:
> 
>             skb->transport_header = skb->network_header;
> 
> This works for both offsets and pointers, i.e. both transport_header
> and network_header are in the same "address space".
> 
> 
>              skb_set_transport_header(skb, skb_network_offset(skb));
> 
> Also works, but its too convoluted IMHO, for pointers it would reduce to:
> 
>               skb->transport_header = skb->data + skb->network_header
> - skb->data;
> 
> for offsets:
> 
>               skb->transport_header = skb->data - skb->head;
>               skb->transport_header += skb->head + skb->network_header
> - skb->data;
> 
> I.e. both reduce to:
> 
>                skb->transport_header = skb->network_header;
> 
> Some more comments below, but I think this time, sans the above
> possible cleanup, your patch is OK wrt offsets/pointers.

Thanks for the correction, indeed you are correct :)
