From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Wed, 23 Nov 2016 10:59:13 -0500
Message-ID: <87shqi89wu.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161122103944.31381-1-stefan.eichenberger@netmodule.com> <20161122150330.GE2691@lunn.ch> <20161122183732.GD13973@gruene.netmodule.intranet> <20161122190206.GE14947@lunn.ch> <20161123120047.GC12698@gruene.netmodule.intranet>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stefan Eichenberger <eichest@gmail.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Stefan Eichenberger <stefan.eichenberger@netmodule.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55874 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750857AbcKWQHb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 11:07:31 -0500
In-Reply-To: <20161123120047.GC12698@gruene.netmodule.intranet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefan,

Stefan Eichenberger <stefan.eichenberger@netmodule.com> writes:

>> Now, the different families are not 100% compatible with each
>> other. We never had access to a 6097, so it has not been tested
>> recently, and we have probably broken it... My guess would be,
>> anywhere mv88e6xxx_6095_family(chip) is used, there also needs to be
>> an mv88e6xxx_6097_family(chip). But i could be wrong.
>
> I think I probably found the problem. For EDSA type switches the bit
> PORT_CONTROL_FORWARD_UNKNOWN_MC is set on the cpu port but not for DSA 
> type switches. Broadcast addresses are threaded as multicast addresses, 
> so unknown frames will never leave the switch.

The Port Control Register (0x04) is one of these registers which changes
almost completely among chip models.

Are you able to give us the layout of the port register 0x04 on your
88E6097? I don't have access to its datasheet.

For instance on 88E6185 bit 3 is reserved, on 88E6352 and 88E6390 bit
3:2 are "Egress Floods" and 0x2 means "Do not egress any frame with an
unknown unicast DA".

> Do you know if there is a reason why this bit isn't set for DSA type
> switches too? The patch would be extremely simple and it seems to work
> perfectly with this bit set on the CPU port.

All these family checks for bit masking are quite messy and ideally need
proper abstraction...

Can you give us the chunk of patch you are refering to?

Thanks,

        Vivien
