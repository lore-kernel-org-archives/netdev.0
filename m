From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 2/2] openvswitch: Enable tunnel GSO for OVS bridge.
Date: Wed, 11 Jun 2014 12:26:18 +0300
Message-ID: <CAJZOPZJ0c21oxPs=B3rb+v5M+rE37+C1T-78fR73V-fUcOpJ6Q@mail.gmail.com>
References: <1401017985-1574-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alon Harel <alonha@mellanox.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:60458 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbaFKJ0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 05:26:19 -0400
Received: by mail-qa0-f44.google.com with SMTP id j7so10805445qaq.31
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 02:26:19 -0700 (PDT)
In-Reply-To: <1401017985-1574-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 25, 2014 at 2:39 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Hi Pravin,

Can you please provide a non-empty change log for this patch... I
understand the patch
addresses some openvswitch use case where offloads are currently
non-coming into play and
you want to support that, right?


> +++ b/include/linux/netdev_features.h
> @@ -152,6 +152,10 @@ enum {
>  #define NETIF_F_ALL_FCOE       (NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
>                                  NETIF_F_FSO)
>
> +#define NETIF_F_ALL_ENCAP_GSO   (NETIF_F_GSO_GRE | NETIF_F_GSO_GRE_CSUM | \
> +                                NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |     \
> +                                NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_MPLS)

AFAIK OVS supports only VXLAN and GRE tunneling -- wouldn't it be
enough to add here only
NETIF_F_GSO_GRE and NETIF_F_GSO_UDP_TUNNEL?

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
