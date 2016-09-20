From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: handle multiple ports in ATU
Date: Mon, 19 Sep 2016 21:07:16 -0400
Message-ID: <87wpi7idkr.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20160919235611.31975-1-vivien.didelot@savoirfairelinux.com> <20160920004129.GA8026@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160920004129.GA8026@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Mon, Sep 19, 2016 at 07:56:11PM -0400, Vivien Didelot wrote:
>> An address can be loaded in the ATU with multiple ports, for instance
>> when adding multiple ports to a Multicast group with "bridge mdb".
>>
>> The current code doesn't allow that. Add an helper to get a single entry
>> from the ATU, then set or clear the requested port, before loading the
>> entry back in the ATU.
>>
>> Note that the required _mv88e6xxx_atu_getnext function is defined below
>> mv88e6xxx_port_db_load_purge, so forward-declare it for the moment. The
>> ATU code will be isolated in future patches.
>>
>> Fixes: 83dabd1fa84c ("net: dsa: mv88e6xxx: make switchdev DB ops generic")
>
> Is this a real fixes? You don't make it clear what goes wrong. I
> assume adding the same MAC address for a second time but for a
> different port removes the first entry for the old port?

Yes, this is what happens, sorry for the bad message. Below is an
example with the relevant hardware bits.

Here's the current behavior, without this patch:

    # bridge mdb add dev br0 port lan0 grp 238.39.20.86

    FID  MAC Addr                  State         Trunk?  DPV/Trunk ID
    0    01:00:5e:27:14:56         MC_STATIC       n     0 - - - - - -

    # bridge mdb add dev br0 port lan2 grp 238.39.20.86

    FID  MAC Addr                  State         Trunk?  DPV/Trunk ID
    0    01:00:5e:27:14:56         MC_STATIC       n     - - 2 - - - - 

Here's the new behavior, with this patch:

    # bridge mdb add dev br0 port lan0 grp 238.39.20.86

    FID  MAC Addr                  State         Trunk?  DPV/Trunk ID
    0    01:00:5e:27:14:56         MC_STATIC       n     0 - - - - - -

    # bridge mdb add dev br0 port lan2 grp 238.39.20.86

    FID  MAC Addr                  State         Trunk?  DPV/Trunk ID
    0    01:00:5e:27:14:56         MC_STATIC       n     0 - 2 - - - -

Thanks!

        Vivien
