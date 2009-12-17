From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 12:19:11 +0000
Message-ID: <20091217121911.GA8654@ff.dom.local>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Sridhar Samudrala <sri@us.ibm.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:62244 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934016AbZLQMTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 07:19:16 -0500
Received: by fxm21 with SMTP id 21so1824565fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 04:19:14 -0800 (PST)
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

Hmm, I can even remember who inspired this change ;-) But I'm not sure
this really broken: it seems it's "optimized" for non-stopped case.

Btw, IIRC, Krishna worked on changing this for uniqueues - I wonder if
there could be much difference in testing?

Cheers,
Jarek P.
