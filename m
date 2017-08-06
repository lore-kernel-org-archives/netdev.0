From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [patch net-next 06/15] mlx5e: push cls_flower and mqprio setup_tc
 processing into separate functions
Date: Sun, 6 Aug 2017 23:08:27 +0300
Message-ID: <CALzJLG9qHprSzRd2g=2WyBDEmm1bM_6TjVds_Fg+nyaU+M5qhA@mail.gmail.com>
References: <20170805145337.17728-1-jiri@resnulli.us> <20170805145337.17728-7-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        xiyou.wangcong@gmail.com, Daniel Borkmann <daniel@iogearbox.net>,
        mlxsw@mellanox.com, Andrew Lunn <andrew@lunn.ch>,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:36307 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdHFUIs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 16:08:48 -0400
Received: by mail-ua0-f193.google.com with SMTP id w45so3324289uac.3
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 13:08:47 -0700 (PDT)
In-Reply-To: <20170805145337.17728-7-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 5, 2017 at 5:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Let mlx5e_setup_tc (former mlx5e_ndo_setup_tc) be a splitter for specific
> setup_tc types and push out cls_flower and mqprio specific codes into
> separate functions. Also change the return values so they are the same
> as in the rest of the drivers.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 56 +++++++++++++----------
>  1 file changed, 31 insertions(+), 25 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index 4052e225f..adf35da 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -2998,12 +2998,16 @@ static int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
>         return 0;
>  }
>
> -static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
> +static int mlx5e_setup_tc_mqprio(struct net_device *netdev,
> +                                struct tc_mqprio_qopt *mqprio)
>  {
>         struct mlx5e_priv *priv = netdev_priv(netdev);
>         struct mlx5e_channels new_channels = {};
> +       u8 tc = mqprio->num_tc;
>         int err = 0;
>
> +       mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
> +
>         if (tc && tc != MLX5E_MAX_NUM_TC)
>                 return -EINVAL;
>
> @@ -3027,39 +3031,41 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
>         return err;
>  }
>
Hi Jiri,

Great change, looks very good.

I am going to post a pull request tomorrow based on 4.13-rc4
"for-next" to both net-next and rdma,
it [1] will most certainly conflict with your change, so to avoid
inconvenience, can we hold this change a bit and rebase it on top of
my pull request ?

[1] https://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git/diff/drivers/net/ethernet/mellanox/mlx5/core/en_main.c?h=mlx5-shared-4.13&id=b90d9bba17e2c9bee5b2e3f7bd46b77bd6f43c91

Thanks,
Saeed.
[...]
