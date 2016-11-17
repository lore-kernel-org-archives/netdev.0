From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v2] net: dummy: Introduce dummy virtual functions
Date: Fri, 18 Nov 2016 00:04:14 +0200
Message-ID: <CAJ3xEMhG4Eeh6pwY2Uq_KxmuHJb9-xYYkr4Ps_kQWwEXeB9Sbg@mail.gmail.com>
References: <20161114130205.18333-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35089 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbcKQWER (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 17:04:17 -0500
Received: by mail-oi0-f66.google.com with SMTP id v84so7739273oie.2
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 14:04:17 -0800 (PST)
In-Reply-To: <20161114130205.18333-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 3:02 PM, Phil Sutter <phil@nwl.cc> wrote:

> Due to the assumption that all PFs are PCI devices, this implementation
> is not completely straightforward: In order to allow for
> rtnl_fill_ifinfo() to see the dummy VFs, a fake PCI parent device is
> attached to the dummy netdev. This has to happen at the right spot so
> register_netdevice() does not get confused. This patch abuses
> ndo_fix_features callback for that. In ndo_uninit callback, the fake
> parent is removed again for the same purpose.

So you did some mimic-ing of PCI interface, how do you let the user to
config the number of VFs? though a module param? why? if the module
param only serves to say how many VF the device supports, maybe
support the maximum possible by PCI spec and skip the module param?


> +module_param(num_vfs, int, 0);
> +MODULE_PARM_DESC(num_vfs, "Number of dummy VFs per dummy device");
> +

> @@ -190,6 +382,7 @@ static int __init dummy_init_one(void)
>         err = register_netdevice(dev_dummy);
>         if (err < 0)
>                 goto err;
> +
>         return 0;

nit, remove this added blank line..
