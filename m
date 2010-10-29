From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Fri, 29 Oct 2010 08:43:08 -0700
Message-ID: <1288366988.4110.5.camel@localhost.localdomain>
References: <1288216693.17571.38.camel@localhost.localdomain>
	 <1288240804.14342.1.camel@localhost.localdomain>
	 <20101028052021.GD5599@redhat.com>
	 <1288286062.11251.15.camel@localhost.localdomain>
	 <20101029081027.GB22688@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:56903 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932823Ab0J2PnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 11:43:15 -0400
In-Reply-To: <20101029081027.GB22688@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-29 at 10:10 +0200, Michael S. Tsirkin wrote:
> Hmm. I don't yet understand. We are still doing copies into the per-vq
> buffer, and the data copied is really small.  Is it about cache line
> bounces?  Could you try figuring it out?

per-vq buffer is much less expensive than 3 put_copy() call. I will
collect the profiling data to show that.

> > > 2. How about flushing out queued stuff before we exit
> > >    the handle_tx loop? That would address most of
> > >    the spec issue. 
> > 
> > The performance is almost as same as the previous patch. I will
> resubmit
> > the modified one, adding vhost_add_used_and_signal_n after handle_tx
> > loop for processing pending queue.
> > 
> > This patch was a part of modified macvtap zero copy which I haven't
> > submitted yet. I found this helped vhost TX in general. This pending
> > queue will be used by DMA done later, so I put it in vq instead of a
> > local variable in handle_tx.
> > 
> > Thanks
> > Shirley
> 
> BTW why do we need another array? Isn't heads field exactly what we
> need
> here?

head field is only for up to 32, the more used buffers add and signal
accumulated the better performance is from test results. That's was one
of the reason I didn't use heads. The other reason was I used these
buffer for pending dma done in mavctap zero copy patch. It could be up
to vq->num in worse case.

Thanks
Shirley

