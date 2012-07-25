From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net] net/mlx4_en: Limit the RFS filter IDs to be
 < RPS_NO_FILTER
Date: Wed, 25 Jul 2012 15:23:37 -0700 (PDT)
Message-ID: <20120725.152337.155627167530086828.davem@davemloft.net>
References: <1343226979-32004-1-git-send-email-ogerlitz@mellanox.com>
	<1343228230.2694.12.camel@bwh-desktop.uk.solarflarecom.com>
	<50100B03.2020205@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	oren@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278Ab2GYWXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:23:38 -0400
In-Reply-To: <50100B03.2020205@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 25 Jul 2012 18:04:35 +0300

> On 25/07/2012 17:57, Ben Hutchings wrote:
>>> @@ -77,12 +77,8 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv,
>>> struct mlx4_en_cq *cq,
>>>   	struct mlx4_en_dev *mdev = priv->mdev;
>>>   	int err = 0;
>>>   	char name[25];
>>> -	struct cpu_rmap *rmap =
>>> -#ifdef CONFIG_RFS_ACCEL
>>> -		priv->dev->rx_cpu_rmap;
>>> -#else
>>> -		NULL;
>>> -#endif
>>> +	struct cpu_rmap *rmap = IS_ENABLED(CONFIG_RFS_ACCEL) ?
>>> +		priv->dev->rx_cpu_rmap : NULL;
>>
>> This is a separate change.
> 
> OK, will send two patches

This change breaks the build.

You can't do this check at run-time, because the reason you need to
check CONFIG_RFS_ACCEL is because if that's disabled then the netdev
structure doesn't even have the ->rx_cpu_rmap member.
