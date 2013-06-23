From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 01/11] net/mlx4_en: Suppress page allocation
 failure warnings
Date: Sun, 23 Jun 2013 11:46:58 +0300
Message-ID: <51C6B602.20703@mellanox.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>  <1371757222-21412-2-git-send-email-amirv@mellanox.com> <1371763689.3252.419.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:40956 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750914Ab3FWIr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 04:47:26 -0400
In-Reply-To: <1371763689.3252.419.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/06/2013 00:28, Eric Dumazet wrote:
> On Thu, 2013-06-20 at 22:40 +0300, Amir Vadai wrote:
>> From: Yevgeny Petrilin <yevgenyp@mellanox.com>
>>
>> When system is low on resources, those warnings hang the host.
>>
>> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
>> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> index 9c57581..2b564ac 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> @@ -57,8 +57,8 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
>>  	for (i = 0; i < priv->num_frags; i++) {
>>  		frag_info = &priv->frag_info[i];
>>  		if (ring_alloc[i].offset == frag_info->last_offset) {
>> -			page = alloc_pages(GFP_ATOMIC | __GFP_COMP,
>> -					MLX4_EN_ALLOC_ORDER);
>> +			page = alloc_pages(GFP_ATOMIC | __GFP_COMP |
>> +					   __GFP_NOWARN, MLX4_EN_ALLOC_ORDER);
>>  			if (!page)
>>  				goto out;
>>  			dma = dma_map_page(priv->ddev, page, 0,
> 
> 
> Thats IMHO a lazy patch...
> 
> What about mlx4_en_init_allocator() ?
mlx4_en_init_allocator() is called only on driver initialization - I
don't care if it will warn when no memory.
But mlx4_en_alloc_frags() is on the data path, and many warnings there
when the system is already stressed and without memory is bad.
Besides the warnings, this error flow is handled, and
mlx4_en_en_fill_rx_buffers() will handle the ENOMEM.

> 
> I think I did a patch doing fallback to order-1 and order-0 allocations
Current code has, as I said above, a fallback to reduce the rx ring size
when memory is stressed. Do you suggest to use smaller fragments instead
(or in addition)?
Can you send me a link to the patch?


Thanks,
Amir
