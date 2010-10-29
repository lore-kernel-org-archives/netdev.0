From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Fri, 29 Oct 2010 10:10:27 +0200
Message-ID: <20101029081027.GB22688@redhat.com>
References: <1288216693.17571.38.camel@localhost.localdomain>
 <1288240804.14342.1.camel@localhost.localdomain>
 <20101028052021.GD5599@redhat.com>
 <1288286062.11251.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47158 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628Ab0J2IKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 04:10:32 -0400
Content-Disposition: inline
In-Reply-To: <1288286062.11251.15.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 10:14:22AM -0700, Shirley Ma wrote:
> 
> > Two ideas:
> > 1. How about writing out used, just delaying the signal?
> >    This way we don't have to queue separately.
> 
> This improves some performance, but not as good as delaying
> both used and signal. Since delaying used buffers combining
> multiple small copies to a large copy, which saves more CPU
> utilization and increased some BW.

Hmm. I don't yet understand. We are still doing copies into the per-vq
buffer, and the data copied is really small.  Is it about cache line
bounces?  Could you try figuring it out?

> > 2. How about flushing out queued stuff before we exit
> >    the handle_tx loop? That would address most of
> >    the spec issue. 
> 
> The performance is almost as same as the previous patch. I will resubmit
> the modified one, adding vhost_add_used_and_signal_n after handle_tx
> loop for processing pending queue.
> 
> This patch was a part of modified macvtap zero copy which I haven't
> submitted yet. I found this helped vhost TX in general. This pending
> queue will be used by DMA done later, so I put it in vq instead of a
> local variable in handle_tx.
> 
> Thanks
> Shirley

BTW why do we need another array? Isn't heads field exactly what we need
here?

