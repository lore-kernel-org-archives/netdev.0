From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Thu, 22 Dec 2011 13:20:24 -0500 (EST)
Message-ID: <20111222.132024.2100751924070475608.davem@davemloft.net>
References: <1324476138.2728.65.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111221.142841.2253787084484360430.davem@davemloft.net>
	<1324550017.7877.77.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab1LVSUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 13:20:32 -0500
In-Reply-To: <1324550017.7877.77.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 22 Dec 2011 10:33:36 +0000

> On Wed, 2011-12-21 at 19:28 +0000, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 21 Dec 2011 15:02:18 +0100
>> 
>> > No idea on this +2 point.
>> 
>> I think I know, and I believe I instructed Alexey Kuznetsov to do
>> this.
>> 
>> When sendfile() is performed, we might start the SKB with the last few
>> bytes of one page, and end the SKB with the first few bytes of another
>> page.
>> 
>> In order to fit a full 64K frame into an SKB in this situation we have
>> to accomodate this case.
> 
> Thanks David, that makes sense.
> 
> However I think you only actually need 1 extra page for that. If the
> data in frag[0] starts at $offset then frag[16] will need to have
> $offset bytes in it. e.g.
> 	4096-$offset + 4096*15 + $offset = 65536
> which == 17 pages rather than 18.
> 
> The following documents the status quo but I could update to switch to +
> 1 instead if there are no flaws in the above logic...

Indeed, you're right.  Please change this to 1 and document it, and we
can put that change into net-next, thanks a lot!
