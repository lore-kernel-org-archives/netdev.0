From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Fri, 11 Jun 2010 07:56:43 +1000
Message-ID: <20100610215643.GA22048@gondor.apana.org.au>
References: <20100610124047.GA16658@gondor.apana.org.au> <20100610074912.1303e3da@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>, Matt Mackall <mpm@selenic.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:35397 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752302Ab0FJV4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 17:56:53 -0400
Content-Disposition: inline
In-Reply-To: <20100610074912.1303e3da@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 10, 2010 at 07:49:12AM -0700, Stephen Hemminger wrote:
> 
> Thanks for looking at this, and yes the original code does
> look buggy. Not sure if I like the use of in_irq() to handle the netpoll
> packets as special case. Is in_irq() really reliable for this?

Yes because netpoll always calls ndo_start_xmit with IRQs disabled,
while on the normal TX path IRQs must be enabled (as otherwise
enabling BH would warn).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
