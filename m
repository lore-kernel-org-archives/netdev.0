From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/5] net: dsa: Stop accessing ds->dst->cpu_dp in drivers
Date: Tue, 06 Jun 2017 14:09:21 -0400
Message-ID: <8760g9kmy6.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170606170202.21491-1-f.fainelli@gmail.com> <20170606170202.21491-6-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35504 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751444AbdFFSLa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 14:11:30 -0400
In-Reply-To: <20170606170202.21491-6-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> -	phy_mode = of_get_phy_mode(ds->dst->cpu_dp->dn);
> +	phy_mode = of_get_phy_mode(ds->ports[QCA8K_CPU_PORT].dn);

Is it necessary to use QCA8K_CPU_PORT?

> +static inline struct dsa_port *dsa_ds_get_cpu_dp(struct dsa_switch *ds)
> +{
> +	return &ds->ports[fls(ds->cpu_port_mask) - 1];
> +}

Wouldn't it be better to return the CPU port for a given port?
Something like return ds->ports[port].cpu_dp, so that we ease the
introduction of multiple CPU port a bit more?

Thanks,

        Vivien
