From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH RESEND net] net/mlx4_en: Limit the RFS filter IDs to be
 < RPS_NO_FILTER
Date: Wed, 25 Jul 2012 18:04:35 +0300
Message-ID: <50100B03.2020205@mellanox.com>
References: <1343226979-32004-1-git-send-email-ogerlitz@mellanox.com> <1343228230.2694.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<oren@mellanox.com>, "Amir Vadai" <amirv@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:41306 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933160Ab2GYPII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 11:08:08 -0400
In-Reply-To: <1343228230.2694.12.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/07/2012 17:57, Ben Hutchings wrote:
>
> resending as of typo in my signature... sorry
>
> --signoff is so much easier than typing it every time :-)

I know and I do that on the regular basis, today did that differently 
and here's the result...

Or.

>
>
>>   drivers/net/ethernet/mellanox/mlx4/en_cq.c     |    8 ++------
>>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
>>   2 files changed, 3 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
>> index aa9c2f6..866829b 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
>> @@ -77,12 +77,8 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
>>   	struct mlx4_en_dev *mdev = priv->mdev;
>>   	int err = 0;
>>   	char name[25];
>> -	struct cpu_rmap *rmap =
>> -#ifdef CONFIG_RFS_ACCEL
>> -		priv->dev->rx_cpu_rmap;
>> -#else
>> -		NULL;
>> -#endif
>> +	struct cpu_rmap *rmap = IS_ENABLED(CONFIG_RFS_ACCEL) ?
>> +		priv->dev->rx_cpu_rmap : NULL;
>
> This is a separate change.

OK, will send two patches

>
>
>>   	cq->dev = mdev->pndev[priv->port];
>>   	cq->mcq.set_ci_db  = cq->wqres.db.db;
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> index 8864d8b..edd9cb8 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> @@ -201,7 +201,7 @@ mlx4_en_filter_alloc(struct mlx4_en_priv *priv, int rxq_index, __be32 src_ip,
>>
>>   	filter->flow_id = flow_id;
>>
>> -	filter->id = priv->last_filter_id++;
>> +	filter->id = priv->last_filter_id++ % RPS_NO_FILTER;
>
> This should do for now.

thanks

Or.

>
>
> Ideally the filter ID would be based on the index used in hardware.  We
> would need to change the API to allow for devices where this cannot be
> determined synchronously, as in this driver.  (And the filter ID might
> also need to be wider.)
>
> Ben.
>
>>
>>   	list_add_tail(&filter->next,&priv->filters);
>>   	hlist_add_head(&filter->filter_chain,
>
