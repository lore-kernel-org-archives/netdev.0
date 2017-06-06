From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/5] net: dsa: Stop accessing ds->dst->cpu_dp in drivers
Date: Tue, 06 Jun 2017 14:33:17 -0400
Message-ID: <871sqxc6fm.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170606170202.21491-1-f.fainelli@gmail.com> <20170606170202.21491-6-f.fainelli@gmail.com> <8760g9kmy6.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <99c1a096-2128-f259-0537-0456a117280c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37132 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751239AbdFFSf0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 14:35:26 -0400
In-Reply-To: <99c1a096-2128-f259-0537-0456a117280c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 06/06/2017 11:09 AM, Vivien Didelot wrote:
>> Florian Fainelli <f.fainelli@gmail.com> writes:
>> 
>>> -	phy_mode = of_get_phy_mode(ds->dst->cpu_dp->dn);
>>> +	phy_mode = of_get_phy_mode(ds->ports[QCA8K_CPU_PORT].dn);
>> 
>> Is it necessary to use QCA8K_CPU_PORT?
>> 
>>> +static inline struct dsa_port *dsa_ds_get_cpu_dp(struct dsa_switch *ds)
>>> +{
>>> +	return &ds->ports[fls(ds->cpu_port_mask) - 1];
>>> +}
>> 
>> Wouldn't it be better to return the CPU port for a given port?
>> Something like return ds->ports[port].cpu_dp, so that we ease the
>> introduction of multiple CPU port a bit more?
>
> ds->ports[port].cpu_dp only gets assigned at dsa_slave_create() time,
> which is after ops->setup() has been called, hence this helper function
> in case you need it earlier (e.g: like mv88e6060).

I see no reason why we cannot assign ds->ports[x].cpu_dp before calling
ops->setup().

Even though it can be changed later, the DSA core can assign a dedicated
CPU port to each ports and only after that, call into drivers ops.

To me the DSA topology (dsa_ports, CPU, etc.) should be determined
before calling into the hardware and exposing slave interfaces to the
user. Otherwise it is confusing. Am I wrong?

Thanks,

        Vivien
