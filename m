From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: Network performance with small packets
Date: Wed, 2 Feb 2011 10:09:18 +0530
Message-ID: <OF5CFD7B6A.4CBE4E3B-ON6525782B.0014DC5B-6525782B.001979CB@in.ibm.com>
References: <1296157547.1640.45.camel@localhost.localdomain> <20110127200548.GE5228@redhat.com> <20110127.130240.104065182.davem@davemloft.net> <1296163838.1640.53.camel@localhost.localdomain> <20110201172346.GA24392@redhat.com> <1296590943.26937.797.camel@localhost.localdomain> <20110201201715.GA30050@redhat.com> <1296591908.26937.809.camel@localhost.localdomain> <20110201212110.GC30770@redhat.com> <1296595725.26937.819.camel@localhost.localdomain> <20110201214114.GA31105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	Shirley Ma <mashirle@us.ibm.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, steved@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:33873 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754Ab1BBEiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 23:38:22 -0500
In-Reply-To: <20110201214114.GA31105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> "Michael S. Tsirkin" <mst@redhat.com> 02/02/2011 03:11 AM
>
> On Tue, Feb 01, 2011 at 01:28:45PM -0800, Shirley Ma wrote:
> > On Tue, 2011-02-01 at 23:21 +0200, Michael S. Tsirkin wrote:
> > > Confused. We compare capacity to skb frags, no?
> > > That's sg I think ...
> >
> > Current guest kernel use indirect buffers, num_free returns how many
> > available descriptors not skb frags. So it's wrong here.
> >
> > Shirley
>
> I see. Good point. In other words when we complete the buffer
> it was indirect, but when we add a new one we
> can not allocate indirect so we consume.
> And then we start the queue and add will fail.
> I guess we need some kind of API to figure out
> whether the buf we complete was indirect?
>
> Another failure mode is when skb_xmit_done
> wakes the queue: it might be too early, there
> might not be space for the next packet in the vq yet.

I am not sure if this is the problem - shouldn't you
see these messages:
	if (likely(capacity == -ENOMEM)) {
		dev_warn(&dev->dev,
			"TX queue failure: out of memory\n");
	} else {
		dev->stats.tx_fifo_errors++;
		dev_warn(&dev->dev,
			"Unexpected TX queue failure: %d\n",
			capacity);
	}
in next xmit? I am not getting this in my testing.

> A solution might be to keep some kind of pool
> around for indirect, we wanted to do it for block anyway ...

Your vhost patch should fix this automatically. Right?

Thanks,

- KK

