From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for dsa2
Date: Sun, 08 Jan 2017 21:56:19 -0500
Message-ID: <87y3ylx7os.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com> <20170108233019.GA25588@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Uwe =?utf-8?Q?Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170108233019.GA25588@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> Until the printing of netdev_phys_item_id structures is fixed in
>> net/core/net-sysfs.c, an external helper can be used like this:
>
> As Florian pointed out, this cannot be changed. It is now part of the
> ABI. We have to live with it printing little endian numbers as big
> endian.

I totally understand the fact that ABI must not be changed. However we
should be aware that the current phys_switch_id of DSA is broken.

In addition to the minor issue of being hardly useable, it does not meet
the requirement described in the switchdev documentation of being unique
on a system. A switch ID in DSA is currently unique only to a DSA tree.
A system with two disjoint switch trees will have two switches with a
phys_switch_id of "00000000".

> Rather than recommending something, it might be better to point to the
> Free Desktop "Predictable Network Interface Names" which is what most
> people will end up with, if they rename:
>
> https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
>
> It would also be good to test on a recent systemd system and see what
> happens. What names does it pick?

Note that the udev rules I gave in this commit message were only there
as examples of renaming DSA slave interfaces from userspace. This is
orthogonal with the purpose of this patch.

Thanks,

        Vivien
