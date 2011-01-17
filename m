From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Mon, 17 Jan 2011 12:38:42 +0200
Message-ID: <20110117103841.GI23479@redhat.com>
References: <20110106124439.GA17004@verge.net.au>
 <20110114065415.GA30300@redhat.com>
 <20110116223728.GA6279@verge.net.au>
 <201101171026.26213.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>, Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228Ab1AQKjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jan 2011 05:39:15 -0500
Content-Disposition: inline
In-Reply-To: <201101171026.26213.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 17, 2011 at 10:26:25AM +1030, Rusty Russell wrote:
> On Mon, 17 Jan 2011 09:07:30 am Simon Horman wrote:
> 
> [snip]
> 
> I've been away, but what concerns me is that socket buffer limits are
> bypassed in various configurations, due to skb cloning.  We should probably
> drop such limits altogether, or fix them to be consistent.

Further, it looks like when the limits are not bypassed, they
easily result in deadlocks. For example, with
multiple tun devices attached to a single bridge in host,
if a number of these have their queues blocked,
others will reach the socket buffer limit and
traffic on the bridge will get blocked altogether.

It might be better to drop the limits altogether
unless we can fix them. Happily, as the limits are off by
default, doing so does not require kernel changes.

> Simple fix is as someone suggested here, to attach the clone.  That might
> seriously reduce your sk limit, though.  I haven't thought about it hard,
> but might it make sense to move ownership into skb_shared_info; ie. the
> data, rather than the skb head?
> 
> Cheers,
> Rusty.

tracking data ownership might benefit others such as various zero-copy
strategies. It might need to be done per-page, though, not per-skb.

-- 
MST
