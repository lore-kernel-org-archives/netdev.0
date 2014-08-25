From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next 1/2] net: Header length compution function
Date: Mon, 25 Aug 2014 15:21:54 -0700
Message-ID: <53FBB702.8080905@intel.com>
References: <53D90099.6040906@intel.com>	<20140730.183907.1435538533126954589.davem@davemloft.net>	<53DA61FE.40406@intel.com> <20140823.121959.890509134482478336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, amirv@mellanox.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com, idos@mellanox.com,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35951 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755147AbaHYWV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 18:21:56 -0400
In-Reply-To: <20140823.121959.890509134482478336.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2014 12:19 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Thu, 31 Jul 2014 08:34:22 -0700
> 
>> On 07/30/2014 06:39 PM, David Miller wrote:
>>> I don't think my proposed patch is a bad trade off.  Where we have the
>>> __skb_header_pointer() thing that takes preloaded pointers and header
>>> length values.  It adds only one test which frankly should never
>>> trigger and can be moved down into skb_copy_bits() or similar.
>>
>> This works for me.  Once it is in I can see about pushing a patch to add
>> some FCoE support and work on moving over igb and ixgbe.
> 
> You should be able to do this against net-next now, just FYI.
> 

Actually I was just looking at the code.  It looks like commit
19469a873bafd4e65daef3597db2bd724c1b03c9 "flow_dissector: Use IPv6 flow
label in flow_dissector" is likely breaking things in terms of trying to
use this function to get the header length since the code now returns
early if an IPv6 flow label is present.

Thanks,

Alex
