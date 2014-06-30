From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 2/2] openvswitch: Enable tunnel GSO for OVS bridge.
Date: Tue, 1 Jul 2014 00:53:25 +0300
Message-ID: <CAJZOPZLDhqkosAVty2TpOx5JrkTwVdn2JhMNY8Jti2pu6jU9xQ@mail.gmail.com>
References: <1401017985-1574-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:33096 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbaF3Vx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 17:53:26 -0400
Received: by mail-qa0-f52.google.com with SMTP id w8so6829853qac.25
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 14:53:25 -0700 (PDT)
In-Reply-To: <1401017985-1574-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 25, 2014 at 2:39 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>



Hi Pravin, ping... this addresses a real life use case where offloads
didn't come into play, right? can you respin the patch with non-empty
change-log so people can review/ack it? --> and we'll have upstream
support for that case.

Or.



>
> ---
>  include/linux/netdev_features.h      | 4 ++++
>  net/openvswitch/vport-internal_dev.c | 3 ++-
>  2 files changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> index e5a5894..12118a5 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -152,6 +152,10 @@ enum {
>  #define NETIF_F_ALL_FCOE       (NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
>                                  NETIF_F_FSO)
>
> +#define NETIF_F_ALL_ENCAP_GSO   (NETIF_F_GSO_GRE | NETIF_F_GSO_GRE_CSUM | \
> +                                NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |     \
> +                                NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_MPLS)
> +
>  /*
>   * If one device supports one of these features, then enable them
>   * for all in netdev_increment_features.
> diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
> index 789af92..b971610 100644
> --- a/net/openvswitch/vport-internal_dev.c
> +++ b/net/openvswitch/vport-internal_dev.c
> @@ -134,7 +134,8 @@ static void do_setup(struct net_device *netdev)
>         netdev->tx_queue_len = 0;
>
>         netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
> -                          NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE;
> +                          NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE |
> +                          NETIF_F_ALL_ENCAP_GSO;
>
>         netdev->vlan_features = netdev->features;
>         netdev->features |= NETIF_F_HW_VLAN_CTAG_TX;
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
