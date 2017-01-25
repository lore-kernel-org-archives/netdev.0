From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Wed, 25 Jan 2017 14:37:46 -0500
Message-ID: <87lgtz3p85.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch> <1485309314-23942-2-git-send-email-andrew@lunn.ch> <87sho7123x.fsf@free-electrons.com> <87o9yvyqwr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <87r33r3tkw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170125193040.GE6611@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55108 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdAYTiS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:38:18 -0500
In-Reply-To: <20170125193040.GE6611@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>>           if (reg == MII_PHYSID2 && (*val & 0xfff0) == 0)
>
> This should be 0x3f0. There are 10 bits for the device model, of which
> Marvell uses the lowest 4 for version.
>
>>               *val |= chip->info->prod_num << 4;
>
> #define PORT_SWITCH_ID_PROD_NUM_6190    0x190
> #define PORT_SWITCH_ID_PROD_NUM_6190X   0x0a0
> #define PORT_SWITCH_ID_PROD_NUM_6191    0x191
> #define PORT_SWITCH_ID_PROD_NUM_6290    0x290
> #define PORT_SWITCH_ID_PROD_NUM_6390    0x390
> #define PORT_SWITCH_ID_PROD_NUM_6390X   0x0a1
>
> That still gives us 6 different PHY IDs, and the shift will cause is
> to modify the OUI, so it is no longer a Marvell OUI.

OK, this is fine with the Marvell mask then. Can you move the check in
the higher mv88e6xxx_phy_read() function when you respin please?

Thanks!

        Vivien
