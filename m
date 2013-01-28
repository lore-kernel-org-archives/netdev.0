From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: loopback: fix a dst refcounting issue
Date: Sun, 27 Jan 2013 19:26:38 -0500 (EST)
Message-ID: <20130127.192638.2227792070943381785.davem@davemloft.net>
References: <1359135881.12374.3249.camel@edumazet-glaptop>
	<20130127.013241.1524448507498580112.davem@davemloft.net>
	<1359307508.5222.2226.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039Ab3A1A0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 19:26:39 -0500
In-Reply-To: <1359307508.5222.2226.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 27 Jan 2013 09:25:08 -0800

> On Sun, 2013-01-27 at 01:32 -0500, David Miller wrote:
> 
>> Applied, I suspect we need to tree wide audit for other instances of
>> this situation.  Probably greps for skb_orphan() would be a good
>> start.
> 
> I highly suspect macvlan needs a skb_dst_drop(), but couldnt trigger
> a case to trigger the fault.

I completely agree, when we hit the ->forward() or ->receive() method
we are leaving the RCU safety zone for the cached dst.

Even if you can't trigger it, this seems clear enough to me that we
should put those skb_dst_drop() calls in, so please formally submit
that patch you posted for Ben as an RFC last week.

Thanks.
