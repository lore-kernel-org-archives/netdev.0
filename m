From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] macvlan: broadcast addr should be part of mc_filter
Date: Thu, 7 Feb 2013 18:05:17 -0800
Message-ID: <CANP3RGeJFMZY_5cmFPg+ZWcNWoH_y0Je0tzaGsomt+xoCP+mWw@mail.gmail.com>
References: <1360288977.28557.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:61993 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757378Ab3BHCFS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 21:05:18 -0500
Received: by mail-ob0-f176.google.com with SMTP id v19so3418505obq.21
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 18:05:18 -0800 (PST)
In-Reply-To: <1360288977.28557.77.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIgned-off-by: Maciej =C5=BBenczykowski <maze@google.com>

On Thu, Feb 7, 2013 at 6:02 PM, Eric Dumazet <erdnetdev@gmail.com> wrot=
e:
> From: Eric Dumazet <edumazet@google.com>
>
> commit cd431e738509e (macvlan: add multicast filter) forgot
> the broadcast case.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  drivers/net/macvlan.c |    3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index f494da8..ce7c926 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -426,6 +426,9 @@ static void macvlan_set_mac_lists(struct net_devi=
ce *dev)
>                 netdev_for_each_mc_addr(ha, dev) {
>                         __set_bit(mc_hash(ha->addr), filter);
>                 }
> +
> +               __set_bit(mc_hash(dev->broadcast), filter);
> +
>                 bitmap_copy(vlan->mc_filter, filter, MACVLAN_MC_FILTE=
R_SZ);
>         }
>         dev_uc_sync(vlan->lowerdev, dev);
>
>
