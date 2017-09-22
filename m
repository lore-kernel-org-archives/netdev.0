From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/4] net: dsa: remove phy arg from port enable/disable
Date: Fri, 22 Sep 2017 14:12:14 -0400
Message-ID: <87377eob5t.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com> <20170922161753.19563-3-vivien.didelot@savoirfairelinux.com> <f8d74c3c-bd7f-8a84-2d57-c37250ff25f8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f8d74c3c-bd7f-8a84-2d57-c37250ff25f8@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 09/22/2017 09:17 AM, Vivien Didelot wrote:
>> The .port_enable and .port_disable functions are meant to deal with the
>> switch ports only, and no driver is using the phy argument anyway.
>> Remove it.
>
> I don't think this makes sense, there are perfectly legit reasons why a
> switch driver may have something to do with the PHY device attached to
> its per-port network interface, we should definitively keep that around,
> unless you think we should be accessing the PHY within the switch
> drivers by doing:
>
> struct phy_device *phydev = ds->ports[port].netdev->phydev?

bcm_sf2 is the only user for this phy argument right now. The reason I'm
doing this is because I prefer to discourage switch drivers to dig into
the phy device themselves while as you said there must be a cleaner
solution. This must be handled somehow elsewhere in the stack.

In the meantime, moving the PHY device up to the dsa_port structure is a
good solution, in order not to expose it in switch ops, but still make
it available to more complex drivers.

Do you know if netdev->phydev is usable? Why do DSA has its own copy in
dsa_slave_priv then?


I'll respin, thanks.

    Vivien
