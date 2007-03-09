From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 0/2] NET: Multiple queue network device support REPOST
Date: Thu, 8 Mar 2007 22:42:19 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329026E981A@orsmsx414.amr.corp.intel.com>
References: <20070308.222154.74746753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22255 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993010AbXCIGm1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 01:42:27 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20070308.222154.74746753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Thursday, March 08, 2007 10:22 PM
> To: Waskiewicz Jr, Peter P
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> Leech, Christopher
> Subject: Re: [PATCH 0/2] NET: Multiple queue network device 
> support REPOST
> 
> 
> You didn't address my correction the other day wherein I 
> clarified for you that my idea was not to store the queue mapping in
> skb->priority but rather to shrink skb->priority to a u16 and
> add a new u16 skb->queue_mapping or whatever field to store 
> the necessary information.
> 
> You're just posting a set of patches using the same approach 
> again plus some bug fixes, so there is essentially nothing 
> new for anyone to review.
> 
> Why ask for feedback if you fail to take any of it into consideration?
> :-/
> 

This was taken into consideration, and I did reply that my concern for
doing that could cause stale data in the skb if the queue mapping
changed.  If a qdisc was implemented that could change the band to queue
mapping without having to reload the qdisc, the result could have skb's
heading for the wrong queues until the old data was drained from the
bands.  An example:

->enqueue() - maps queue, commits to skb, adds to band
netif_stop_queue(dev) - event is triggered that could cause a qdisc to
remap bands to queues, drain hardware queues
netif_wake_queue(dev) - reconfiguration is complete, resume transmission
->dequeue() - grab an skb enqueued prior to reconfiguration, read queue
from skb, hard_start_xmit() to the wrong queue
