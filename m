From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V2]  vhost: fix check for # of outstanding buffers
Date: Thu, 21 Jul 2011 09:12:01 -0700
Message-ID: <1311264721.3354.7.camel@localhost.localdomain>
References: <1311182592.8573.45.camel@localhost.localdomain>
	 <20110721080617.GA20360@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:57366 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab1GUQMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 12:12:22 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6LG9DFK029115
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 10:09:13 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p6LGCAP6068240
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 10:12:11 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6LAC5qr019729
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 04:12:05 -0600
In-Reply-To: <20110721080617.GA20360@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-21 at 11:06 +0300, Michael S. Tsirkin wrote:
> On Wed, Jul 20, 2011 at 10:23:12AM -0700, Shirley Ma wrote:
> > Fix the check for number of outstanding buffers returns incorrect
> > results due to vq->pend_idx wrap around;
> > 
> > Signed-off-by: Shirley Ma <xma@us.ibm.com>
> 
> OK, the logic's right now, and it's not worse
> than what we had, so I applied this after
> fixing up the comment (it's upend_idx and English
> sentences don't need to end with a semicolumn ;)
> 
> However, I would like to see the effect of the bug
> noted in the log in the future.
> 
> And the reason I mention this here, is that
> I think that the whole VHOST_MAX_PEND thing
> does not work as advertised: this logic only
> triggers when the ring is empty, so we will happily push
> more than VHOST_MAX_PEND packets if the guest manages
> to give them to us.
> 
> I'm not sure why we have the limit, either: the wmem
> limit in the socket still applies and seems more
> effective to prevent denial of service by a malicious guest.

Vhost can push more than VHOST_MAX_PEND if the guest manages to give
more. That's managed by wmem limit.

MAX_PEND is max of outstanding used buffers which lower level device
can't DMAed on time. socket destructor remains unchanged, so it can't
managed by wmem.

Since vhost handle_tx always calls vhost_zerocopy_singal_used() so this
condition is unlikely hit unless the lower device can't DMAed TX
MAX_PEND packets.

Thanks
Shirley

