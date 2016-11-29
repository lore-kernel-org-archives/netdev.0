From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Tue, 29 Nov 2016 12:54:24 -0500
Message-ID: <87oa0yb29b.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480280279-9552-1-git-send-email-afaerber@suse.de> <1480280279-9552-2-git-send-email-afaerber@suse.de> <20161127212709.GD13318@lunn.ch> <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de> <20161127220846.GH13318@lunn.ch> <e5d45b55-a4c1-3b5e-0bdc-a5e340b072d0@suse.de> <20161127231009.GA17704@lunn.ch> <20161128080939.ippqlytvojitefkp@perseus.defre.kleine-koenig.org> <20161128131735.GA4379@lunn.ch> <2c59cc79-b6dc-9920-1725-a7785ff3b6bf@kleine-koenig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Andreas =?utf-8?Q?F=C3=A4rber?= <afaerber@suse.de>,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        "Bed\?\?icha Ko\?\?atu" <bedrich.kosata@nic.cz>,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: Uwe =?utf-8?Q?Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2c59cc79-b6dc-9920-1725-a7785ff3b6bf@kleine-koenig.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Uwe Kleine-König <uwe@kleine-koenig.org> writes:

> Also it seems wrong to write "marvell,mv88e6085" (only) if I know the
> hardware is really a "marvell,mv88e6176".

I agree. It might be complex for a user to dig into the driver in order
to figure out how the switch ID is read and which compatible to choose.

I've sent a patch to change this https://lkml.org/lkml/2016/6/8/1198 but
Andrew had a stronger opinion on compatible strings, which makes sense.

>> Linus has said he does not like ARM devices because of all the busses
>> which are not enumerable. Here we have a device which with a little
>> bit of help we can enumerate. So we should. 
>
> If you write
>
> 	compatible = "marvell,mv88e6176", "marvell,mv88e6085";
>
> you can still enumerate in the same way as before.

So we don't break the existing DTS files, I like this.

The driver already prints info about the detected switch. Instead of
failing at probe, which seems against the notion of compatible and
breaks the existing behavior, it could report the eventual mismatch?

We have examples for both usage, still I don't know what the best
practices are. My _preference_ would go with enumerating them all.

Thanks,

        Vivien
