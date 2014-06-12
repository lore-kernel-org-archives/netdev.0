From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 2/2] openvswitch: Enable tunnel GSO for OVS bridge.
Date: Thu, 12 Jun 2014 12:27:26 +0300
Message-ID: <CAJZOPZKhxTWP_vGYKADBc6-B4HSj-QJygdATGkd6cHqHO+PHoQ@mail.gmail.com>
References: <1401017985-1574-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:46427 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932553AbaFLJ11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 05:27:27 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so1512675qcy.29
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 02:27:26 -0700 (PDT)
In-Reply-To: <1401017985-1574-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 25, 2014 at 2:39 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
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

OK, I guess this commit is similar in spirit to 82d8189 "veth: extend
features to support tunneling"

So in that respect, don't you need to set also dev->hw_enc_features
for the NETIF_F_GSO_YYY to come into play?
