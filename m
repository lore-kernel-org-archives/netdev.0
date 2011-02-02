From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 23:03:46 -0800
Message-ID: <1296630226.26937.859.camel@localhost.localdomain>
References: <20110128121616.GA8374@redhat.com>
	 <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
	 <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
	 <1296594585.26937.817.camel@localhost.localdomain>
	 <20110201212411.GD30770@redhat.com>
	 <1296595955.26937.822.camel@localhost.localdomain>
	 <20110201214211.GB31105@redhat.com>
	 <1296597185.26937.829.camel@localhost.localdomain>
	 <20110201215603.GA31348@redhat.com>
	 <1296601197.26937.833.camel@localhost.localdomain>
	 <20110202044002.GB3818@redhat.com>
	 <1296626748.26937.852.camel@localhost.localdomain>
	 <1296627549.26937.856.camel@localhost.localdomain>
	 <OFF5778D3C.84F46700-ON6525782B.00230A94-6525782B.00240890@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:34179 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752660Ab1BBHDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 02:03:51 -0500
In-Reply-To: <OFF5778D3C.84F46700-ON6525782B.00230A94-6525782B.00240890@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-02-02 at 12:04 +0530, Krishna Kumar2 wrote:
> > On Tue, 2011-02-01 at 22:05 -0800, Shirley Ma wrote:
> > >
> > > The way I am changing is only when netif queue has stopped, then
> we
> > > start to count num_free descriptors to send the signal to wake
> netif
> > > queue.
> >
> > I forgot to mention, the code change I am making is in guest kernel,
> in
> > xmit call back only wake up the queue when it's stopped && num_free
> >=
> > 1/2 *vq->num, I add a new API in virtio_ring.
> 
> FYI :)

> I have tried this before. There are a couple of issues:
> 
> 1. the free count will not reduce until you run free_old_xmit_skbs,
>    which will not run anymore since the tx queue is stopped.
> 2. You cannot call free_old_xmit_skbs directly as it races with a
>    queue that was just awakened (current cb was due to the delay
>    in disabling cb's).
> 
> You have to call free_old_xmit_skbs() under netif_queue_stopped()
> check to avoid the race.

Yes, that' what I did, when the netif queue stop, don't enable the
queue, just free_old_xmit_skbs(), if not enough freed, then enabling
callback until half of the ring size are freed, then wake the netif
queue. But somehow I didn't reach the performance compared to drop
packets, need to think about it more. :)

Thanks
Shirley

