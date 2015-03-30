From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 1/2] ipvlan: don't loose broadcast MAC when setting MAC filters
Date: Mon, 30 Mar 2015 13:28:46 -0700
Message-ID: <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
References: <1427409698.18540.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>, jbenc@redhat.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:32835 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbbC3U3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 16:29:07 -0400
Received: by obvd1 with SMTP id d1so73545926obv.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 13:29:07 -0700 (PDT)
In-Reply-To: <1427409698.18540.11.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 3:41 PM, Dan Williams <dcbw@redhat.com> wrote:
> The broadcast MAC is supposed to be allowed whenever the device
> has an IPv4 address, otherwise ARP requests get dropped on the
> floor.  If ndo_set_rx_mode (and thus
> ipvlan_set_multicast_mac_filter()) gets called after the address
> was added, it blows away the broadcast MAC address in
> mac_filters that was added at IPv4 address addition.  Fix that.
>
> Signed-off-by: Dan Williams <dcbw@redhat.com>
Acked-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/ipvlan/ipvlan_main.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 4f4099d..d34f580 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -241,6 +241,9 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
>
>                 bitmap_copy(ipvlan->mac_filters, mc_filters,
>                             IPVLAN_MAC_FILTER_SIZE);
> +
> +               if (ipvlan->ipv4cnt)
> +                       ipvlan_set_broadcast_mac_filter(ipvlan, true);
>         }
>         dev_uc_sync(ipvlan->phy_dev, dev);
>         dev_mc_sync(ipvlan->phy_dev, dev);
> --
> 2.1.0
>
>
