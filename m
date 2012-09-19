From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Wed, 19 Sep 2012 12:04:36 -0700
Message-ID: <505A1744.50209@intel.com>
References: <1347901493.26523.151.camel@edumazet-glaptop> <20120917.130732.1894375657044880827.davem@davemloft.net> <1348067659.26523.949.camel@edumazet-glaptop> <20120919.135655.381209248813843140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19278 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754335Ab2ISTE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 15:04:29 -0400
In-Reply-To: <20120919.135655.381209248813843140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2012 10:56 AM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 19 Sep 2012 17:14:19 +0200
>
>> I did some tests and got no problem so far, even using splice() [ this
>> one was tricky because it only deals with order-0 pages at this moment ]
>>
>> NIC tested : ixgbe, igb, bnx2x, tg3, mellanox mlx4
>>
>> On loopback, performance of netperf goes from 31900 Mb/s to 38500 Mb/s,
>> thats a 20 % increase.
> That's really a lot more than I expected, nice.

When I get some time I will test this patch on a system with an iommu
enabled.  I suspect it will have a huge performance impact there since
now you would be looking at roughly 1/8th the total number of map/unmap
calls on a system with 4K pages.

Thanks,

Alex
