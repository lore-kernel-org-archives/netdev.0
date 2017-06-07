From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: Stop accessing ds->dst->cpu_dp in drivers
Date: Wed, 07 Jun 2017 13:15:38 -0400
Message-ID: <87ink7oh1h.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170607000317.14729-1-f.fainelli@gmail.com> <20170607000317.14729-6-f.fainelli@gmail.com> <87ink8tum2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <CAGVrzcb_ve=gOAnAo73-TqzZgWN6F3gr7Tu0BtWS8UBYQ2MciQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        John Crispin <john@phrozen.org>,
        David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53114 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdFGRRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 13:17:48 -0400
In-Reply-To: <CAGVrzcb_ve=gOAnAo73-TqzZgWN6F3gr7Tu0BtWS8UBYQ2MciQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

>> So as I said in v2, now that a driver is guaranteed that dp->cpu_dp is
>> correctly assigned at setup time, isn't better (especially for future
>> multi-CPU support) to provide an helper which returns the CPU port for a
>> given port? i.e. dsa_get_cpu_port(struct dsa_switch *ds, int port).
>>
>> Or is there something blocking? I might be wrong.
>
> mt7530.c needs access to the CPU port at ops->setup() time which is
> why this is still here.

Yes, mt7530 is the only one doing this and has an hardcoded CPU port. So
what I meant was, shouldn't we have this instead:

    struct dsa_port *dsa_get_cpu_port(struct dsa_switch *ds, int port)
    {
        return ds->ports[port].cpu_dp;
    }

And:

-       dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
+       cpu_dp = dsa_get_cpu_port(ds, MT7530_CPU_PORT);
+       dn = cpu_dp->netdev->dev.of_node->parent;


Thanks,

        Vivien
