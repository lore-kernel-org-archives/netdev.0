From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: RE: [PATCH net-next v3 0/3] enic: Add support for rx_copybreak
Date: Sat, 16 Aug 2014 01:51:32 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1408160047360.5614@ws.cisco>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com> <063D6719AE5E284EB5DD2968C1650D6D17477B95@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: 'Govindarajulu Varadarajan' <_govind@gmx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:54707 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751109AbaHOUWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 16:22:00 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17477B95@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Aug 2014, David Laight wrote:
> Is there any mileage in having a system-wide default for rx_copybreak?
> I'd have thought that the value is really driver independent since it
> (mostly) depends on the comparative cost of dma_map and copy operations.
>

The cost skb_alloc(small_size) and memcpy(small_size) should be completely
independent of driver.

The cost of dma_unmap(mtu) , skb_alloc(mtu) & dma_map(mtu) determines the break
point. This operation should take less time for smaller mtu size,
and more time for larger mtu size. (especially for 9k mtu as we do not have
generic kmem_cache for size above 8192)

mtu of 9k is quite common for enic in data center. So rx_copybreak can go till
254. Most of the drivers use 100 as the copybreak, I guess thats because 1500
mtu is common for those nics and probably 100 is the break point.

Some driver allocates frags of pages, instead of contiguous memory.
I think it's better to leave the default to driver.
