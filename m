From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Wed, 17 Feb 2016 14:07:27 +0200
Message-ID: <CALzJLG_7bkC1nZix_SHD_OmumAm8vC-Bhjj6dD95QzNamLsstA@mail.gmail.com>
References: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
	<1455653401-9808-5-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMjbOAyzu_6B23HPJshY+p9Dm23P6Sr2SxA=caHz6iuk6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:35017 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256AbcBQMH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 07:07:28 -0500
Received: by mail-yw0-f182.google.com with SMTP id g127so11056948ywf.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 04:07:27 -0800 (PST)
In-Reply-To: <CAJ3xEMjbOAyzu_6B23HPJshY+p9Dm23P6Sr2SxA=caHz6iuk6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2016 at 11:38 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Feb 16, 2016 at 10:09 PM, Saeed Mahameed <saeedm@mellanox.com>
>> @@ -1602,7 +1622,7 @@ static int mlx5e_create_tis(struct mlx5e_priv
> *priv, int tc)
>>
>>         memset(in, 0, sizeof(in));
>>
>> -       MLX5_SET(tisc, tisc, prio,  tc);
>> +       MLX5_SET(tisc, tisc, prio, tc << 1);
>
> point bug fix? or we could never hit that prior to the patch as ## TCs
> was always 0?

tc was always 0 before this patch.

>
>>         MLX5_SET(tisc, tisc, transport_domain, priv->tdn);
>>
>>         return mlx5_core_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
>> @@ -1618,7 +1638,7 @@ static int mlx5e_create_tises(struct mlx5e_priv *priv)
>>         int err;
>>         int tc;
>>
>> -       for (tc = 0; tc < priv->params.num_tc; tc++) {
>> +       for (tc = 0; tc < MLX5E_MAX_NUM_TC; tc++) {
>>                 err = mlx5e_create_tis(priv, tc);
>
> various places in the patch use priv->params.num_tc, wasn't sure if
> it's correct to hard code things here, and if it does, why not hard
> code everywhere
TISs and TIRs unlike SQs and RQs are created once on driver load, so
we create the MAX supported TISs (TIS per prio)  and when you create
the rings/channels (SQs) we create them according to the dynamic
"priv->params.num_tc" and then we assign the pre allocated TIS to the
SQ according to SQ TC/Prio configuration.
