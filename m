From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Add tx queue maxrate support
Date: Thu, 12 Mar 2015 10:25:32 +0200
Message-ID: <CAJ3xEMhF0uMWYZ89xc3FP7C9jE1KTm3ng7sbeUr2SadZ6D_AiQ@mail.gmail.com>
References: <1426079690-28271-1-git-send-email-ogerlitz@mellanox.com>
	<1426079690-28271-4-git-send-email-ogerlitz@mellanox.com>
	<550062D5.8030407@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34663 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbbCLIZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 04:25:32 -0400
Received: by obcwp18 with SMTP id wp18so13662351obc.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 01:25:32 -0700 (PDT)
In-Reply-To: <550062D5.8030407@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 5:44 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 3/11/2015 4:14 PM, Or Gerlitz wrote:
>
>> Add ndo_set_tx_maxrate support.
>
>
>> To support per tx queue maxrate limit, we use the update-qp firmware
>> command to do run-time rate setting for the qp that serves this tx ring.
>>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> Signed-off-by: Ido Shamay <idos@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   33
>> ++++++++++++++++++++++++
>>   1 files changed, 33 insertions(+), 0 deletions(-)
>
>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> index c59ed92..2a58d2a 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> @@ -2379,6 +2379,37 @@ static netdev_features_t
>> mlx4_en_features_check(struct sk_buff *skb,
>>   }
>>   #endif
>>
>> +int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32
>> maxrate)
>> +{
>> +       struct mlx4_en_priv *priv = netdev_priv(dev);
>> +       struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[queue_index];
>> +       struct mlx4_update_qp_params params;
>> +       int err;
>> +
>> +       if (!(priv->mdev->dev->caps.flags2 &
>> MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT)) {
>> +               err = -EOPNOTSUPP;
>> +               goto out;
>
>
>    I would have just used *return*...
>
>> +       }
>> +
>> +       /* rate provided to us in Mbs, check if it fits into 12 bits, if
>> not use Gbs */
>> +       if ((maxrate >> 12)) {
>
>
>    Double parens make not sense.
>
> [...]
>>
>> +       err = mlx4_update_qp(priv->mdev->dev, tx_ring->qpn,
>> MLX4_UPDATE_QP_RATE_LIMIT,
>> +                            &params);
>> +
>> +out:
>> +       return err;
>> +}
>> +
>>   static const struct net_device_ops mlx4_netdev_ops = {
>>         .ndo_open               = mlx4_en_open,
>>         .ndo_stop               = mlx4_en_close,
>
> [...]

Sure, will fix your two comments from this reply and also the one
related to Mbps in your other post

Or.
