From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Flood broadcast frames in hardware
Date: Wed, 27 Sep 2017 14:59:49 -0400
Message-ID: <871smsotlm.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch> <1506464764-12699-7-git-send-email-andrew@lunn.ch> <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170927183650.GC12394@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41728 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750739AbdI0TD3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 15:03:29 -0400
In-Reply-To: <20170927183650.GC12394@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> Adding the broadcast address to an Ethernet switch's FDB is pretty
>> generic and mv88e6xxx mustn't be the only driver doing this.
>
> Actually, it is. All the others seem to do this in hardware without
> needing an FDB. Since mv88e6xxx is the only one requiring it, it has
> to be done in the mv88e6xxx driver.

Adding the broadcast address from the DSA layer wouldn't hurt and make
things pretty obvious. This would also avoid drivers to get
unnecessarily complex. A .port_vlan_add implementation must remain
simple and mustn't do more than adding a VLAN entry.

Don't forget that we want the DSA drivers to be dump and have the core
logic of Ethernet switch handling resides in DSA core itself.

If some switch chips can flood broadcast without an FDB entry, good for
them, they can skip it. We will have the same issue for special L2
Multicast destination addresses, some switches have special bits to
consider them as management, some others don't and require to load the
ATU with them.

Regarding Marvell, what value do you have for the global FloodBC bit
(Global 2, offset 0x05)?


Thanks,

        Vivien
