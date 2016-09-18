From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net 1/3] net/mlx5: Fix flow counter bulk command out
 mailbox allocation
Date: Sun, 18 Sep 2016 23:24:49 +0300
Message-ID: <CAJ3xEMg8HU9OvPmSziez=dx-y98knpbU1Qs4N1JeJiVNjyL_Sw@mail.gmail.com>
References: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
 <1474212029-1052-2-git-send-email-ogerlitz@mellanox.com> <20160918180223.GM2923@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Leon Romanovsky <leonro@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34867 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756101AbcIRUYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 16:24:50 -0400
Received: by mail-oi0-f66.google.com with SMTP id 2so10769770oif.2
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 13:24:50 -0700 (PDT)
In-Reply-To: <20160918180223.GM2923@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2016 at 9:02 PM, Leon Romanovsky <leon@kernel.org> wrote:
> On Sun, Sep 18, 2016 at 06:20:27PM +0300, Or Gerlitz wrote:
>> From: Roi Dayan <roid@mellanox.com>

>> @@ -425,11 +425,11 @@ struct mlx5_cmd_fc_bulk *
>>  mlx5_cmd_fc_bulk_alloc(struct mlx5_core_dev *dev, u16 id, int num)
>>  {
>>       struct mlx5_cmd_fc_bulk *b;
>> -     int outlen = sizeof(*b) +
>> +     int outlen =
>>               MLX5_ST_SZ_BYTES(query_flow_counter_out) +
>>               MLX5_ST_SZ_BYTES(traffic_counter) * num;
>>
>> -     b = kzalloc(outlen, GFP_KERNEL);
>> +     b = kzalloc(sizeof(*b) + outlen, GFP_KERNEL);
>>       if (!b)
>>               return NULL;

>                   ^^^^^^^^^ very controversial decision.
> The code flow mlx5_fc_stats_query->mlx5_cmd_fc_bulk_alloc->kzalloc
> failure is the same for success scenario too.

Sure, we will look on your comment and if needed come up with a
cleanup patch for net-next (4.9)

> It is not related to the proposed patch.

Correct, the proposed patch fixes a memory corruption that we want to
sort out for net (4.8)

Or.
