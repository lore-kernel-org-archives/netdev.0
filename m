From: Tom Gundersen <teg@jklm.no>
Subject: Re: [patch net-next] bonding: allow to add vlans on top of empty bond
Date: Fri, 27 Jun 2014 17:27:53 +0200
Message-ID: <CAG-2HqUKGoG5ZX26aYwv3quUU5RPtn5J1g6i4YzkXUc10u4c0w@mail.gmail.com>
References: <1403878392-10004-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, j.vosburgh@gmail.com,
	vfalico@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f45.google.com ([209.85.213.45]:49269 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbaF0P2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:28:14 -0400
Received: by mail-yh0-f45.google.com with SMTP id t59so3134864yho.32
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 08:28:13 -0700 (PDT)
In-Reply-To: <1403878392-10004-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Fri, Jun 27, 2014 at 4:13 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> This limitation maybe had some reason in the past, but now there is not
> one -> removing this.

If this restriction is really no longer needed, it would be very
helpful if we could drop it. See for instnace
<https://bugs.freedesktop.org/show_bug.cgi?id=76077#c5>.

Cheers,

Tom

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/bonding/bond_main.c | 13 -------------
>  1 file changed, 13 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 3a451b6..ffefb70 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1001,12 +1001,6 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
>         netdev_features_t mask;
>         struct slave *slave;
>
> -       if (!bond_has_slaves(bond)) {
> -               /* Disable adding VLANs to empty bond. But why? --mq */
> -               features |= NETIF_F_VLAN_CHALLENGED;
> -               return features;
> -       }
> -
>         mask = features;
>         features &= ~NETIF_F_ONE_FOR_ALL;
>         features |= NETIF_F_ALL_FOR_ALL;
> @@ -3956,13 +3950,6 @@ void bond_setup(struct net_device *bond_dev)
>         bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT;
>         bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
>
> -       /* At first, we block adding VLANs. That's the only way to
> -        * prevent problems that occur when adding VLANs over an
> -        * empty bond. The block will be removed once non-challenged
> -        * slaves are enslaved.
> -        */
> -       bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
> -
>         /* don't acquire bond device's netif_tx_lock when
>          * transmitting */
>         bond_dev->features |= NETIF_F_LLTX;
> --
> 1.9.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
