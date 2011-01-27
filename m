From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Thu, 27 Jan 2011 22:05:48 +0200
Message-ID: <20110127200548.GE5228@redhat.com>
References: <OFD293DCD2.7F0260F0-ON86257823.0061DC39-86257823.00743BB3@us.ibm.com>
 <20110126151700.GA14113@redhat.com>
 <1296153874.1640.27.camel@localhost.localdomain>
 <20110127190031.GC5228@redhat.com>
 <1296155340.1640.34.camel@localhost.localdomain>
 <20110127193131.GD5228@redhat.com>
 <1296157547.1640.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dobbelstein <steved@us.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614Ab1A0UGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 15:06:06 -0500
Content-Disposition: inline
In-Reply-To: <1296157547.1640.45.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 27, 2011 at 11:45:47AM -0800, Shirley Ma wrote:
> On Thu, 2011-01-27 at 21:31 +0200, Michael S. Tsirkin wrote:
> > Well slowing down the guest does not sound hard - for example we can
> > request guest notifications, or send extra interrupts :)
> > A slightly more sophisticated thing to try is to
> > poll the vq a bit more aggressively.
> > For example if we handled some requests and now tx vq is empty,
> > reschedule and yeild. Worth a try?
> 
> I used dropping packets in high level to slow down TX.
> I am still
> thinking what's the right the approach here. 

Interesting. Could this is be a variant of the now famuous bufferbloat then?

I guess we could drop some packets if we see we are not keeping up. For
example if we see that the ring is > X% full, we could quickly complete
Y% without transmitting packets on. Or maybe we should drop some bytes
not packets.

> 
> Requesting guest notification and extra interrupts is what we want to
> avoid to reduce VM exits for saving CPUs. I don't think it's good.

Yes but how do you explain regression?
One simple theory is that guest net stack became faster
and so the host can't keep up.


> 
> By polling the vq a bit more aggressively, you meant vhost, right?
> 
> Shirley

Yes.
