From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: add adaptive coalescing
Date: Tue, 06 Oct 2009 22:25:21 -0700 (PDT)
Message-ID: <20091006.222521.167077213.davem@davemloft.net>
References: <20091006.172537.148962576.davem@davemloft.net>
	<4ACBEEB2.7010703@hp.com>
	<4ACC247A.9020504@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, brice@myri.com, netdev@vger.kernel.org,
	gallatin@myri.com
To: Brice.Goglin@ens-lyon.org, bgoglin@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46337
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753332AbZJGFZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 01:25:26 -0400
In-Reply-To: <4ACC247A.9020504@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <bgoglin@free.fr>
Date: Wed, 07 Oct 2009 07:17:46 +0200

> Rick Jones wrote:
>> David Miller wrote:
>>> From: Brice Goglin <brice@myri.com>
>>> Date: Tue, 06 Oct 2009 18:52:43 +0200
>>>
>>>
>>>> This patch adds support for adaptive interrupt coalescing to the
>>>> myri10ge driver. It is based on the host periodically look at
>>>> statistics and update the NIC coalescing accordingly.
>>>>
>>>> The NIC only provides packet throughput and we feel that it is a
>>>> better heuristics than the packet rate heuristics currently used
>>>> in ethtool. Also, assuming that the packet packet rate heuristics
>>>> uses what is actually sent on the wire when using TSO, it would be
>>>> much more expensive to implement correctly, as the driver would
>>>> need to calculate how many packets were sent.
>>>>
>>>> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
>>>> Signed-off-by: Brice Goglin <brice@myri.com>
>>>
>>>
>>> Drivers tried to do this as far back as 6 years ago (tg3) and we don't
>>> recommend doing this with NAPI drivers.
>>
>> Doesn't e1000(e) still try to do adaptive coalescing?
> 
> mlx_en, benet, sfc, ... do as well.

If the patches that added that code slipped by me, my bad.  But
if I had noticed I would have been against them as well.

It really isn't the right thing to do.  By the same arguments
it is even arguable to turn off TCP congestion control completely
on local subnets.

It is absolutely impossible to react to on-the-wire changes in
traffic patterns at the granularity in which we get to execute.
It simply is not possible to do it right.
