From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: more accurate network taps in transmit
 path
Date: Wed, 19 Sep 2012 14:16:37 -0400 (EDT)
Message-ID: <20120919.141637.531173978256020103.davem@davemloft.net>
References: <20120918211423.GA19115@darkstar>
	<1348034050.26523.325.camel@edumazet-glaptop>
	<1348037089.26523.397.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamie.gloudon@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932907Ab2ISSQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 14:16:40 -0400
In-Reply-To: <1348037089.26523.397.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Sep 2012 08:44:49 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> dev_queue_xmit_nit() should be called right before ndo_start_xmit()
> calls or we might give wrong packet contents to taps users :
> 
> Packet checksum can be changed, or packet can be linearized or
> segmented, and segments partially sent for the later case.
> 
> Also a memory allocation can fail and packet never really hit the
> driver entry point.
> 
> Reported-by: Jamie Gloudon <jamie.gloudon@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Are you really sure that all the network tap implementations can
handle software GSO segmented skbs using skb->next linkage?

Because that is what they can potentially see after this change.
