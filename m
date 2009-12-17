From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with	vhost-net
Date: Thu, 17 Dec 2009 17:29:55 +0530
Message-ID: <OF35B7AA9F.54F10167-ON6525768F.0040BB45-6525768F.0040E28C@in.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:35323 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbZLQLsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 06:48:47 -0500
In-Reply-To: <20091217114535.GA30429@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Herbert Xu <herbert@gondor.apana.org.au>
> Sent by: netdev-owner@vger.kernel.org
>
> 12/17/2009 05:15 PM
>
> To
>
> Jarek Poplawski <jarkao2@gmail.com>
>
> cc
>
> Krishna Kumar2/India/IBM@IBMIN, Sridhar Samudrala <sri@us.ibm.com>,
> mst@redhat.com, netdev@vger.kernel.org, Rusty Russell
> <rusty@rustcorp.com.au>, "David S. Miller" <davem@davemloft.net>
>
> Subject
>
> Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
>
> On Thu, Dec 17, 2009 at 11:27:55AM +0000, Jarek Poplawski wrote:
> >
> > So we _should_ get into sch_direct_xmit when the queue was stopped...
> > I guess Herbert might forget the multiqueue change, and Sridhar isn't
> > missing much. ;-)
>
> Hmm, if that's the case then this new multiqueue code is seriously
> broken.  It means that once the queue is stopped, every new tx packet
> will cause an unnecessary dequeue/requeue, up to 1000.

I think it is fine. The first skb after the stop is requeue'd. All
subsequent new skbs get screened out at qdisc_restart() -> dequeue_skb
-> NULL -> no work to do. Hope I didn't miss something now :-)

Thanks,

- KK

