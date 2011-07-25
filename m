From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] skbuff: clear tx zero-copy flag
Date: Mon, 25 Jul 2011 11:07:43 +0300
Message-ID: <20110725080743.GC7840@redhat.com>
References: <1310195566.25391.6.camel@localhost.localdomain>
 <20110725004200.GA25794@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830Ab1GYIHV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jul 2011 04:07:21 -0400
Content-Disposition: inline
In-Reply-To: <20110725004200.GA25794@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25, 2011 at 08:42:00AM +0800, Herbert Xu wrote:
> Shirley Ma <mashirle@us.ibm.com> wrote:
> > 
> > This patch clears tx zero-copy flag as needed.
> > 
> > Sign-off-by: Shirley Ma <xma@us.ibm.com>
> 
> I think we also need to copy and clear this flag on the splice
> read path as that takes a direct page reference.
> 
> I hope there isn't any other path that does this.
> 
> Cheers,

When there's a way for an skb to get into the
host networking stack, (e.g. when tap gains zero copy
support) we'll need to handle that.

However macvtap passes an skb directly to the
lower device, so as long as macvtap is the only user
of that interface, we are fine I think - there's
no way for an skb to get from macvtap to splice
read path I think.

Right?

> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
