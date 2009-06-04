From: David Miller <davem@davemloft.net>
Subject: Re: gso: Stop fraglists from escaping
Date: Wed, 03 Jun 2009 21:21:05 -0700 (PDT)
Message-ID: <20090603.212105.160757852.davem@davemloft.net>
References: <20090604010121.GA22871@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750724AbZFDEVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 00:21:04 -0400
In-Reply-To: <20090604010121.GA22871@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 4 Jun 2009 11:01:21 +1000

> gso: Stop fraglists from escaping
> 
> As it stands skb fraglists can get past the check in dev_queue_xmit
> if the skb is marked as GSO.  In particular, if the packet doesn't
> have the proper checksums for GSO, but can otherwise be handled by
> the underlying device, we will not perform the fraglist check on it
> at all.
> 
> If the underlying device cannot handle fraglists, then this will
> break.
> 
> The fix is as simple as moving the fraglist check from the device
> check into skb_gso_ok.
> 
> This has caused crashes with Xen when used together with GRO which
> can generate GSO packets with fraglists.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6, thanks Herbert.
