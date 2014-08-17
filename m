From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvlan: Allow setting multicast filter on all macvlan
 types
Date: Sun, 17 Aug 2014 12:54:38 +0200
Message-ID: <20140817105438.GE21622@redhat.com>
References: <1408122299-29632-1-git-send-email-vyasevic@redhat.com>
 <53EE59BC.1070605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>, roopa@cumulusnetworks.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26535 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbaHQKyU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Aug 2014 06:54:20 -0400
Content-Disposition: inline
In-Reply-To: <53EE59BC.1070605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2014 at 12:04:28PM -0700, John Fastabend wrote:
> On 08/15/2014 10:04 AM, Vladislav Yasevich wrote:
> > Currently, macvlan code restricts multicast and unicast
> > filter setting only to passthru devices.  As a result,
> > if a guest using macvtap wants to receive multicast
> > traffic, it has to set IFF_ALLMULTI or IFF_PROMISC.
> > 
> > This patch makes it possible to use the fdb interface
> > to add multicast addresses to the filter thus allowing
> > a guest to receive only targeted multicast traffic.
> > 
> > CC: John Fastabend <john.r.fastabend@intel.com>
> > CC: Michael S. Tsirkin <mst@redhat.com>
> > CC: Jason Wang <jasowang@redhat.com>
> > Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> > ---
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Looks good to me. Although I am trying to recall why
> we restrict unicast addresses? It looks like an additional
> check could be made to detect duplicate MAC addresses
> in fdb_add and then we could support this as well. But
> I might be missing why this wasn't supported originally.
> 
> Thanks,
> John

It's not just another macvlan: we need to avoid
conflicts with the underlying device itself.

Although I note that the relevant check when
creating macvlans in macvlan_addr_busy
isn't very robust either: if device address is later
reprogrammed, we can get a conflict.
But it seems better to fix that rather than propagate
the bug in more places.

We would also need to populate the mac hash.

So a bit more code would be needed.

-- 
MST
