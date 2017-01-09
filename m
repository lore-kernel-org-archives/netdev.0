From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: Ensure validity of dst->ds[0]
Date: Mon, 09 Jan 2017 15:50:53 -0500
Message-ID: <8737gsc5zm.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170109195834.11697-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41812 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753779AbdAIUvO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:51:14 -0500
In-Reply-To: <20170109195834.11697-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> It is perfectly possible to have non zero indexed switches being present
> in a DSA switch tree, in such a case, we will be deferencing a NULL
> pointer while dsa_cpu_port_ethtool_{setup,restore}. Be more defensive
> and ensure that dst->ds[0] is valid before doing anything with it.
>
> Fixes: 0c73c523cf73 ("net: dsa: Initialize CPU port ethtool ops per tree")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

The patch is correct since we are already using dst->ds[0] here.

But we should stop using that and use dst->cpu_switch instead, because
the switch with ID 0 won't necessary be the CPU switch. Now that the
Ethernet switch chips are true Linux devices, they are registered in
order depending on their bus/address. So in a setup like this:

       ,--MDIO--@4--------@2--
      |         |         |
    [CPU] <-> [swA] <-> [swB]

swB will have index 0 and swA will have index 1. Please correct me if
I'm wrong.

Thanks,

        Vivien
