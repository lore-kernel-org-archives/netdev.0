From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next 1/2] net: Header length compution function
Date: Thu, 31 Jul 2014 08:34:22 -0700
Message-ID: <53DA61FE.40406@intel.com>
References: <20140729.215853.2058634690190963314.davem@davemloft.net>	<1406703644.3178.30.camel@edumazet-glaptop2.roam.corp.google.com>	<53D90099.6040906@intel.com> <20140730.183907.1435538533126954589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, amirv@mellanox.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com, idos@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59582 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752976AbaGaPex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 11:34:53 -0400
In-Reply-To: <20140730.183907.1435538533126954589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2014 06:39 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Wed, 30 Jul 2014 07:26:33 -0700
> 
>> It wasn't that I don't trust the core function.  We already had some of
>> our own code floating around for the out-of-tree LRO and so I simply
>> made use of that as it allowed for code reuse in our driver.
> 
> It would be nice if this code were converted to use the generic
> infrastructure, at some point at least.

I agree.  That is one of the reasons why I supported an earlier approach
that had made a function that was shared between the drivers.  My only
real concern was the on-stack skb approach.

The only other change I see that I might need to address would be to add
FCoE support to the function and then I can probably switch over ixgbe
to use it.

> 
> I don't think my proposed patch is a bad trade off.  Where we have the
> __skb_header_pointer() thing that takes preloaded pointers and header
> length values.  It adds only one test which frankly should never
> trigger and can be moved down into skb_copy_bits() or similar.
> 

This works for me.  Once it is in I can see about pushing a patch to add
some FCoE support and work on moving over igb and ixgbe.

Thanks,

Alex
