From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/9] net: dsa: mv88e6xxx: allocate the number of ports
Date: Thu, 30 Mar 2017 10:06:29 -0400
Message-ID: <87tw6aq2oq.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com> <20170329203020.27042-5-vivien.didelot@savoirfairelinux.com> <20170330135050.GD17879@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330135050.GD17879@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Wed, Mar 29, 2017 at 04:30:15PM -0400, Vivien Didelot wrote:
>> The current code allocates DSA_MAX_PORTS ports for a Marvell dsa_switch
>> structure. Provide the exact number of ports so the corresponding
>> ds->num_ports is accurate.
>
> Is net/dsa/dsa.c: dsa_switch_setup() still used?  If it is, won't that
> invalidate your assumption about ds->num_ports.

I think dsa_switch_setup is part of the legacy code and is likely to be
removed soon.

But this is not an issue per-se. What happens if the switch is allocated
with DSA_MAX_PORTS ports instead of the correct number, is that the PVT
will be programmed to allow the non-existent port IDs to egress frames
on the CPU port and DSA links only.

Thanks,

        Vivien
