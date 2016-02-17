From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Wed, 17 Feb 2016 14:00:04 +0200
Message-ID: <CALzJLG-nbmz292duYuDrU8WUTNi90KAtC+d04Xes8cW+oXXoJQ@mail.gmail.com>
References: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
	<1455653401-9808-5-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMhxezhiU4XjVZuaDbvZ=0D-HLZYnm8DORLDSg_xquT3Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:35587 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbcBQMAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 07:00:05 -0500
Received: by mail-yw0-f176.google.com with SMTP id g127so10916522ywf.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 04:00:04 -0800 (PST)
In-Reply-To: <CAJ3xEMhxezhiU4XjVZuaDbvZ=0D-HLZYnm8DORLDSg_xquT3Yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>  struct mlx5e_priv {
>>         /* priv data path fields - start */
>> -       int                        default_vlan_prio;
>>         struct mlx5e_sq            **txq_to_sq_map;
>>         int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
>>         /* priv data path fields - end */
>
>
> Didn't see a note on the removal of the default vlan prio in the
> change-log, could you elaborate what was the role of it before the
> patch and why we can just throw it?
>
it did nothing other than holding the number "0" which is always the
default prio for vlans
it was replaced with a the real 0 (the hardcoded "0") in the following lines:
+       int up = (netdev_get_num_tc(dev) && skb_vlan_tag_present(skb)) ?
+                skb->vlan_tci >> VLAN_PRIO_SHIFT : 0;

>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
>> @@ -0,0 +1,184 @@
>> +/*
>> + * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
>
> we're happily in 2016 (please fix here and also in other patches that
> introduce new files)
>

Ok.
