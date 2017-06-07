From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: Stop accessing ds->dst->cpu_dp
 in drivers
Date: Tue, 6 Jun 2017 19:38:45 -0700
Message-ID: <CAGVrzcb_ve=gOAnAo73-TqzZgWN6F3gr7Tu0BtWS8UBYQ2MciQ@mail.gmail.com>
References: <20170607000317.14729-1-f.fainelli@gmail.com> <20170607000317.14729-6-f.fainelli@gmail.com>
 <87ink8tum2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        John Crispin <john@phrozen.org>,
        David Miller <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35128 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751474AbdFGCj0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 22:39:26 -0400
Received: by mail-oi0-f46.google.com with SMTP id p7so224695oif.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 19:39:26 -0700 (PDT)
In-Reply-To: <87ink8tum2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-06-06 19:11 GMT-07:00 Vivien Didelot <vivien.didelot@savoirfairelinux.com>:
> Hi Florian,
>
> Florian Fainelli <f.fainelli@gmail.com> writes:
>
>> +static inline struct dsa_port *dsa_ds_get_cpu_dp(struct dsa_switch *ds)
>> +{
>> +     return &ds->ports[fls(ds->cpu_port_mask) - 1];
>> +}
>
> So as I said in v2, now that a driver is guaranteed that dp->cpu_dp is
> correctly assigned at setup time, isn't better (especially for future
> multi-CPU support) to provide an helper which returns the CPU port for a
> given port? i.e. dsa_get_cpu_port(struct dsa_switch *ds, int port).
>
> Or is there something blocking? I might be wrong.

mt7530.c needs access to the CPU port at ops->setup() time which is
why this is still here.

>
> Note that I'm suggesting s/dsa_ds_get_cpu_dp/dsa_get_cpu_port/ since
> public DSA API does not need to use variable shortcuts such as ds or dp,
> but that's a minor suggestion?

We also have a dsa_dst_get_cpu_dp() but sure dsa_get_cpu_port() works for me.
-- 
Florian
