From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 20:56:54 +0800
Message-ID: <20091217125654.GA31560@gondor.apana.org.au>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au> <20091217114937.GA30503@gondor.apana.org.au> <20091217120856.GA30774@gondor.apana.org.au> <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com> <20091217124254.GB8654@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53856 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751973AbZLQM5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 07:57:06 -0500
Content-Disposition: inline
In-Reply-To: <20091217124254.GB8654@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 12:42:54PM +0000, Jarek Poplawski wrote:
> On Thu, Dec 17, 2009 at 05:57:15PM +0530, Krishna Kumar2 wrote:
> > the first resched. I also think the resched in requeue is probably
> > not required, since the device will call netif_tx_wake_queue anyway.

Actually, the requeue is there for the case where we hit lock
contention on the device TX lock so it is needed for that at
least.

However, for the case where the device queue is stopped you're
right we don't need to reschedule.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
