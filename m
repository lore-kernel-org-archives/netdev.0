From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] virtio_net: fix patch: virtio_net: limit xmit polling
Date: Sun, 22 May 2011 20:32:35 +0300
Message-ID: <20110522173235.GB12155@redhat.com>
References: <20110518220125.GA26835@redhat.com>
 <8739kb5era.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: habanero@linux.vnet.ibm.com, Shirley Ma <mashirle@us.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, kvm@vger.kernel.org,
	steved@us.ibm.com, Tom Lendacky <tahm@linux.vnet.ibm.com>,
	borntraeger@de.ibm.com, avi@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926Ab1EVRcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 13:32:55 -0400
Content-Disposition: inline
In-Reply-To: <8739kb5era.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 05:00:17PM +0930, Rusty Russell wrote:
> On Thu, 19 May 2011 01:01:25 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > The patch  virtio_net: limit xmit polling
> > got the logic reversed: it polled while we had
> > capacity not while ring was empty.
> > 
> > Fix it up and clean up a bit by using a for loop.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> > 
> > OK, turns out that patch was borken. Here's
> > a fix that survived stress test on my box.
> > Pushed on my branch, I'll send a rebased series
> > with Rusty's comments addressed ASAP.
> 
> Normally you would have missed the merge window by now, but I'd really
> like this stuff in, so I'm holding it open for this.  I want these patches
> in linux-next for at least a few days before I push them.
> 
> If you think we're not close enough, please tell me and I'll push
> the rest of the virtio patches to Linus now.  
> 
> Thanks,
> Rusty.

I think it makes sense to push just the patches you have
applied by now (event index + delayed callback) - the
rest are close but they are guest only patches so very easy to
experiment with out of tree. OTOH if event index misses the
window it makes testing painful as we have to keep patching
both host and guest.

-- 
MST
