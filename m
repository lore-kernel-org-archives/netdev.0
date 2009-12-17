From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 20:08:56 +0800
Message-ID: <20091217120856.GA30774@gondor.apana.org.au>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au> <20091217114937.GA30503@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Sridhar Samudrala <sri@us.ibm.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43418 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764627AbZLQMJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 07:09:06 -0500
Content-Disposition: inline
In-Reply-To: <20091217114937.GA30503@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 07:49:37PM +0800, Herbert Xu wrote:
>
> And indeed, this new requeue behaviour was introduced in 2.6.32.

Actually no, it was merely rearranged.  It would appear that this
behaviour has been around for over a year.

It is even worse than I thought.  Not only would new tx packets
trigger this unnecessary queue run, but once it is triggered, it
would consume 100% CPU as dev_requeue_skb unconditionally reschedules
the queue!

Tell me this is not true please...

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
