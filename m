From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPSEC]: Remove nhoff from xfrm_input
Date: Tue, 13 Nov 2007 22:32:58 -0800 (PST)
Message-ID: <20071113.223258.148621375.davem@davemloft.net>
References: <E1IplaD-0001J4-00@gondolin.me.apana.org.au>
	<20071113.214609.04000914.davem@davemloft.net>
	<20071114062758.GA11173@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759620AbXKNGc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:32:59 -0500
In-Reply-To: <20071114062758.GA11173@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Nov 2007 14:27:58 +0800

> [IPSEC]: Remove nhoff from xfrm_input
> 
> The nhoff field isn't actually necessary in xfrm_input.  For tunnel mode
> transforms we now throw away the output IP header so it makes no sense to
> fill in the nexthdr field.  For transport mode we can now let the function
> transport_finish do the setting and it knows where the nexthdr field is.
> 
> The only other thing that needs the nexthdr field to be set is the header
> extraction code.  However, we can simply move the protocol extraction out
> of the generic header extraction.
> 
> We want to minimise the amount of info we have to carry around between
> transforms as this simplifies the resumption process for async crypto.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
