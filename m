From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: Stop accessing ds->dst->cpu_dp in drivers
Date: Tue, 06 Jun 2017 22:11:17 -0400
Message-ID: <87ink8tum2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170607000317.14729-1-f.fainelli@gmail.com> <20170607000317.14729-6-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36868 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdFGCN1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 22:13:27 -0400
In-Reply-To: <20170607000317.14729-6-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> +static inline struct dsa_port *dsa_ds_get_cpu_dp(struct dsa_switch *ds)
> +{
> +	return &ds->ports[fls(ds->cpu_port_mask) - 1];
> +}

So as I said in v2, now that a driver is guaranteed that dp->cpu_dp is
correctly assigned at setup time, isn't better (especially for future
multi-CPU support) to provide an helper which returns the CPU port for a
given port? i.e. dsa_get_cpu_port(struct dsa_switch *ds, int port).

Or is there something blocking? I might be wrong.

Note that I'm suggesting s/dsa_ds_get_cpu_dp/dsa_get_cpu_port/ since
public DSA API does not need to use variable shortcuts such as ds or dp,
but that's a minor suggestion?

Thanks,

        Vivien
