From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH net v2 1/1] driver: ipvlan: Unlink the upper dev when
 ipvlan_link_new failed
Date: Thu, 8 Dec 2016 10:29:02 -0800
Message-ID: <CAF2d9jh_3fGaZWDKm-ZanGZeU0MW6=Sq37ZtSjG0=92538cF3g@mail.gmail.com>
References: <1481167018-559-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:36551 "EHLO
        mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752419AbcLHS3X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:29:23 -0500
Received: by mail-yw0-f181.google.com with SMTP id a10so328084204ywa.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 10:29:23 -0800 (PST)
In-Reply-To: <1481167018-559-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2016 at 7:16 PM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> When netdev_upper_dev_unlink failed in ipvlan_link_new, need to
> unlink the ipvlan dev with upper dev.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
Acked-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  v2: Rename the label to unlink_netdev, per Mahesh Bandewar
>  v1: Initial patch
>
>  drivers/net/ipvlan/ipvlan_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 0fef178..dfbc4ef 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -546,13 +546,15 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
>         }
>         err = ipvlan_set_port_mode(port, mode);
>         if (err) {
> -               goto unregister_netdev;
> +               goto unlink_netdev;
>         }
>
>         list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
>         netif_stacked_transfer_operstate(phy_dev, dev);
>         return 0;
>
> +unlink_netdev:
> +       netdev_upper_dev_unlink(phy_dev, dev);
>  unregister_netdev:
>         unregister_netdevice(dev);
>  destroy_ipvlan_port:
> --
> 1.9.1
>
>
