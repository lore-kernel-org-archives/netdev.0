From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 10/11] net: dsa: mv88e6xxx: remove EEE support
Date: Tue, 01 Aug 2017 12:34:18 -0400
Message-ID: <87h8xrfdrp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com> <20170731221719.16695-11-vivien.didelot@savoirfairelinux.com> <20170801142843.GE23157@lunn.ch> <87r2wv2tci.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170801160628.GJ23157@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801160628.GJ23157@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> >> The PHY's EEE settings are already accessed by the DSA layer through the
>> >> Marvell PHY driver and there is nothing to be done for switch's MACs.
>> >
>> > I'm confused, or missing something. Does not patch #1 mean that if the
>> > DSA driver does not have a set_eee function, we always return -ENODEV
>> > in slave.c?
>> 
>> If there is a PHY, phy_init_eee (if eee_enabled is true) and
>> phy_ethtool_set_eee is called. If there is a .set_eee op, it is
>> called. If both are absent, -ENODEV is returned.
>
> O.K, i don't think that is correct. EEE should only be enabled if both
> the MAC and the PHY supports it. We need some way for the MAC to
> indicate it does not support EEE.
>
> If set_eee is optional the meaning of a NULL pointer is that the MAC
> does support EEE. So for mv88e6060, lan9303, microchip and mt7530
> which currently don't support EEE, you need to add a set_eee which
> returns -ENODEV.
>
> Having to implement the op to say you don't implement the feature just
> seems wrong.

Agreed, above I simply described how this patchset currently behaves.

I suggested in the previous mail to define a DSA noop so that the driver
can indicate that its MACs supports EEE, even though there's nothing to
do (and the DSA layer can learn about that):

    static inline int dsa_set_mac_eee_noop(struct dsa_switch *ds,
                                           int port,
                                           struct ethtool_eee *e)
    {
        dev_dbg(ds->dev, "nothing to do for port %d's MAC\n", port);
        return 0;
    }

(and the respective dsa_get_mac_eee_noop() for sure.)

Second option is: we keep it KISS and let the driver define its noop,
but as I explain, it is confusion, especially for the get operation.


Thanks,

        Vivien
