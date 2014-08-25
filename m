From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Header length compution function
Date: Mon, 25 Aug 2014 15:32:32 -0700 (PDT)
Message-ID: <20140825.153232.123310243841432720.davem@davemloft.net>
References: <53DA61FE.40406@intel.com>
	<20140823.121959.890509134482478336.davem@davemloft.net>
	<53FBB702.8080905@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, amirv@mellanox.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com, idos@mellanox.com,
	therbert@google.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38602 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148AbaHYWcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:32:33 -0400
In-Reply-To: <53FBB702.8080905@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 25 Aug 2014 15:21:54 -0700

> On 08/23/2014 12:19 PM, David Miller wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>> Date: Thu, 31 Jul 2014 08:34:22 -0700
>> 
>>> On 07/30/2014 06:39 PM, David Miller wrote:
>>>> I don't think my proposed patch is a bad trade off.  Where we have the
>>>> __skb_header_pointer() thing that takes preloaded pointers and header
>>>> length values.  It adds only one test which frankly should never
>>>> trigger and can be moved down into skb_copy_bits() or similar.
>>>
>>> This works for me.  Once it is in I can see about pushing a patch to add
>>> some FCoE support and work on moving over igb and ixgbe.
>> 
>> You should be able to do this against net-next now, just FYI.
>> 
> 
> Actually I was just looking at the code.  It looks like commit
> 19469a873bafd4e65daef3597db2bd724c1b03c9 "flow_dissector: Use IPv6 flow
> label in flow_dissector" is likely breaking things in terms of trying to
> use this function to get the header length since the code now returns
> early if an IPv6 flow label is present.

Feel free to insert a facility to disable that logic.
