From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 5/5] net: dsa: Stop accessing ds->dst->cpu_dp in
 drivers
Date: Tue, 6 Jun 2017 11:12:59 -0700
Message-ID: <99c1a096-2128-f259-0537-0456a117280c@gmail.com>
References: <20170606170202.21491-1-f.fainelli@gmail.com>
 <20170606170202.21491-6-f.fainelli@gmail.com>
 <8760g9kmy6.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34195 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751239AbdFFSNC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 14:13:02 -0400
Received: by mail-qt0-f195.google.com with SMTP id o21so21355357qtb.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 11:13:02 -0700 (PDT)
In-Reply-To: <8760g9kmy6.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2017 11:09 AM, Vivien Didelot wrote:
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> -	phy_mode = of_get_phy_mode(ds->dst->cpu_dp->dn);
>> +	phy_mode = of_get_phy_mode(ds->ports[QCA8K_CPU_PORT].dn);
> 
> Is it necessary to use QCA8K_CPU_PORT?
> 
>> +static inline struct dsa_port *dsa_ds_get_cpu_dp(struct dsa_switch *ds)
>> +{
>> +	return &ds->ports[fls(ds->cpu_port_mask) - 1];
>> +}
> 
> Wouldn't it be better to return the CPU port for a given port?
> Something like return ds->ports[port].cpu_dp, so that we ease the
> introduction of multiple CPU port a bit more?

ds->ports[port].cpu_dp only gets assigned at dsa_slave_create() time,
which is after ops->setup() has been called, hence this helper function
in case you need it earlier (e.g: like mv88e6060).
-- 
Florian
