From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: allow order-0 memory allocations in RX
 path
Date: Tue, 25 Jun 2013 16:19:10 -0700 (PDT)
Message-ID: <20130625.161910.683324374150724465.davem@davemloft.net>
References: <51C6B602.20703@mellanox.com>
	<1372000676.3301.27.camel@edumazet-glaptop>
	<CAJZOPZLHueS5X=PN-RP3bwGv1x8C2TUrSwevGHcy=hXjBqji-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, amirv@mellanox.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698Ab3FYXTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:19:11 -0400
In-Reply-To: <CAJZOPZLHueS5X=PN-RP3bwGv1x8C2TUrSwevGHcy=hXjBqji-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Tue, 25 Jun 2013 11:53:50 +0300

> On Sun, Jun 23, 2013 at 6:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>>
>> mlx4 exclusively uses order-2 allocations in RX path, which are
>> likely to fail under memory pressure.
>>
>> We therefore drop frames more than needed.
>>
>> This patch tries order-3, order-2, order-1 and finally order-0
>> allocations to keep good performance, yet allow allocations if/when
>> memory gets fragmented.
>>
>> By using larger pages, and avoiding unnecessary get_page()/put_page()
>> on compound pages, this patch improves performance as well, lowering
>> false sharing on struct page.
>>
>> Also use GFP_KERNEL allocations in initialization path, as allocating 12
>> MB (390 order-3 pages) can easily fail with GFP_ATOMIC.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> Amir is OOO and I am covering for him, so:
> 
> Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
> 

Applied.
