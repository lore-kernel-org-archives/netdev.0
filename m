From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 19:49:37 +0800
Message-ID: <20091217114937.GA30503@gondor.apana.org.au>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Sridhar Samudrala <sri@us.ibm.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35905 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751786AbZLQLtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 06:49:45 -0500
Content-Disposition: inline
In-Reply-To: <20091217114535.GA30429@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 07:45:35PM +0800, Herbert Xu wrote:
> On Thu, Dec 17, 2009 at 11:27:55AM +0000, Jarek Poplawski wrote:
> >
> > So we _should_ get into sch_direct_xmit when the queue was stopped...
> > I guess Herbert might forget the multiqueue change, and Sridhar isn't
> > missing much. ;-)
> 
> Hmm, if that's the case then this new multiqueue code is seriously
> broken.  It means that once the queue is stopped, every new tx packet
> will cause an unnecessary dequeue/requeue, up to 1000.

And indeed, this new requeue behaviour was introduced in 2.6.32.

Sridhar, please build the 2.6.32 virtio-net driver under a 2.6.31
kernel and see if the regression persists.  Alternatively, build
the virtio-net driver under 2.6.32 and see whether it still performs
as well.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
