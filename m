From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH v5 05/13] net: ethernet: aquantia: Support for
 NIC-specific code
Date: Sun, 15 Jan 2017 00:55:02 +0200
Message-ID: <CAKoUArkh3gyVSrX1GWRQsrFFBg8B59LjtXK=yG6JWMHan7fW7A@mail.gmail.com>
References: <cover.1484283610.git.vomlehn@texas.net> <5e87af3b0effb96698d0c085366b1ba9320a6305.1484283610.git.vomlehn@texas.net>
 <3dfe11ac-4215-21d0-2242-7a4ad6157e56@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Netdev <netdev@vger.kernel.org>,
        David VomLehn <vomlehn@texas.net>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36789 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750721AbdANWzE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 17:55:04 -0500
Received: by mail-it0-f67.google.com with SMTP id o138so8756202ito.3
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 14:55:04 -0800 (PST)
In-Reply-To: <3dfe11ac-4215-21d0-2242-7a4ad6157e56@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Florian,

> +}
> +
> +static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
> +{
> +     struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +     int err = 0;
> +
> +     if (new_mtu == ndev->mtu) {
> +             err = 0;
> +             goto err_exit;
> +     }
> +     if (new_mtu < 68) {
> +             err = -EINVAL;
> +             goto err_exit;
> +     }

> What's so special about 68 here?

I think that the check that the passed MTU is at least 68 bytes is
justified and correct.
This convention is followed by a large number of Ethernet drivers; for example,
http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/i40e/i40e_main.c#L2246
http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c#L6049

The size of 68 bytes is originated from RFC 791:
https://tools.ietf.org/html/rfc791
...
Every internet module must be able to forward a datagram of 68 octets
without further fragmentation.
This is because an internet header may be up to 60 octets, and the
minimum fragment is 8 octets.
...

Regards,
Rami Rosen
