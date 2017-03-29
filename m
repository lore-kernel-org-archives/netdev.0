From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH v2] net: veth: use new api ethtool_{get|set}_link_ksettings
Date: Wed, 29 Mar 2017 19:06:19 +0800
Message-ID: <CADvbK_f7FkjCz4A_ZRwsED4A=imOkwioNACi2__8kVD2TMudOA@mail.gmail.com>
References: <1490768661-12467-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem <davem@davemloft.net>, jarod@redhat.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        dsa@cumulusnetworks.com, aduyck@mirantis.com,
        network dev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35098 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932132AbdC2LG0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 07:06:26 -0400
In-Reply-To: <1490768661-12467-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 29, 2017 at 2:24 PM, Philippe Reynes <tremyfr@gmail.com> wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> Changelog:
> v2:
> - avoid useless initiazation to zero (thanks Xin Long)
>
Reviewed-by: Xin Long <lucien.xin@gmail.com>

>  drivers/net/veth.c |   19 +++++++------------
>  1 files changed, 7 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 8c39d6d..3171036 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -45,18 +45,13 @@ struct veth_priv {
>         { "peer_ifindex" },
>  };
>
> -static int veth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> +static int veth_get_link_ksettings(struct net_device *dev,
> +                                  struct ethtool_link_ksettings *cmd)
>  {
> -       cmd->supported          = 0;
> -       cmd->advertising        = 0;
> -       ethtool_cmd_speed_set(cmd, SPEED_10000);
> -       cmd->duplex             = DUPLEX_FULL;
> -       cmd->port               = PORT_TP;
> -       cmd->phy_address        = 0;
> -       cmd->transceiver        = XCVR_INTERNAL;
> -       cmd->autoneg            = AUTONEG_DISABLE;
> -       cmd->maxtxpkt           = 0;
> -       cmd->maxrxpkt           = 0;
> +       cmd->base.speed         = SPEED_10000;
> +       cmd->base.duplex        = DUPLEX_FULL;
> +       cmd->base.port          = PORT_TP;
> +       cmd->base.autoneg       = AUTONEG_DISABLE;
>         return 0;
>  }
>
> @@ -95,12 +90,12 @@ static void veth_get_ethtool_stats(struct net_device *dev,
>  }
>
>  static const struct ethtool_ops veth_ethtool_ops = {
> -       .get_settings           = veth_get_settings,
>         .get_drvinfo            = veth_get_drvinfo,
>         .get_link               = ethtool_op_get_link,
>         .get_strings            = veth_get_strings,
>         .get_sset_count         = veth_get_sset_count,
>         .get_ethtool_stats      = veth_get_ethtool_stats,
> +       .get_link_ksettings     = veth_get_link_ksettings,
>  };
>
>  static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
> --
> 1.7.4.4
>
