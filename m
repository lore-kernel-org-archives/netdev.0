From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/2] publish last used index (was Re: TX from KVM guest
 virtio_net to vhost issues)
Date: Mon, 14 Mar 2011 22:29:58 +0200
Message-ID: <cover.1300134326.git.mst@redhat.com>
References: <87d3ly2n81.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com, jasowang@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756334Ab1CNUaT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 16:30:19 -0400
Content-Disposition: inline
In-Reply-To: <87d3ly2n81.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, Mar 11, 2011 at 04:49:26PM +1030, Rusty Russell wrote:
> But if one side outruns the other, it does a lot of unnecessary work
> notifying/interrupting it over and over again before the host/guest gets
> a chance to shut notifications/interrupts off.  Hence the last_used
> publishing patch (Xen does this right, I screwed it up).
> 
> Long weekend here, and I'm otherwise committed.  But if noone has
> cleaned up that patch by early next week, I'll try to do so and see if
> we can make a real difference.
> 
> Cheers,
> Rusty.

I actually had the last_used publishing patch working.  Here it is
again: it's the part that publishes the used index from guest and the
part that uses it in host to avoid spurious interrupts
(this is Tom's case, not Shirley's case)
updated to the latest bits, and clarified the code a bit more.

Note: there's some tricky logic in the vhost part, I think I got it right
but please review.

Warning: compiled only, completely untested, I intend to add the bits
that use the last available index in guest to reduce exits, test it all
together.

Would appreciate review and/or testing.

Michael S. Tsirkin (2):
  virtio: put last seen used index into ring itself
  vhost-net: utilize PUBLISH_USED_IDX feature

 drivers/vhost/vhost.c        |   58 +++++++++++++++++++++++++++++++++++++----
 drivers/vhost/vhost.h        |    9 ++++++
 drivers/virtio/virtio_ring.c |   25 +++++++++++------
 include/linux/virtio_ring.h  |   11 ++++++++
 4 files changed, 88 insertions(+), 15 deletions(-)

-- 
1.7.3.2.91.g446ac
