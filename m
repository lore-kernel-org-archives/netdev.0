From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/3] net: dsa: mv88e6xxx: make global2 code optional
Date: Fri, 02 Sep 2016 11:22:27 -0400
Message-ID: <87k2eugwcs.fsf@ketchup.mtl.sfl>
References: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com> <20160902120819.10773-4-vivien.didelot@savoirfairelinux.com> <20160902145511.GH16864@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160902145511.GH16864@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Fri, Sep 02, 2016 at 08:08:19AM -0400, Vivien Didelot wrote:
>> Since not every chip has a Global2 set of registers, make its support
>> optional, in which case the related functions will return -EOPNOTSUPP.
>> 
>> This also allows to reduce the size of the mv88e6xxx driver for devices
>> such as home routers embedding Ethernet chips without Global2 support.
>
> I've no problems with splitting this out.

Yes, I think it is important to split support for independent internal
SMI devices (Globals, PHY, TCAM, ...).

> However, making it optional? I don't think that is a good idea.
>
> 1) If you don't have this, and you should, it looks like the PHYs stop
> working, and since you cannot set the switch MAC address, maybe Pause
> frames are broken.
>
> 2) Distros won't build a kernel per target hardware. They probably
> build a kernel per SoC vendor. That means, they will have this
> optional code built all the time. Very few builds will leave it out.
>
> So the only way i think making this optional, is if it is a kernel
> module, and it gets loaded if needed.

Your points are correct. But unless I'm mistaken, I purposely default
this suppor to 'y'. Distros will compile everything, which is good.

Only people who know their chips and what they are doing will eventually
go there and disable the support for some devices.

I plan to merge mv88e6060.c into the mv88e6xxx driver, these chips don't
have Global2. And we will soon add support for TCAM, which is huge. The
majority of devices supported by mv88e6xxx don't have a TCAM device.

So my point is that I'd like to disable support for unnecessary internal
devices, even if it doesn't make much difference on our huge dev boards,
but it does make a difference for the many embedded devices out there
(think home routers) with some 88E6060, 88E6176 or 88E6185 chips.

What do you think?

Thanks,

        Vivien
