From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/5] net: dsa: mv88e6xxx: Implement the 6390 external MDIO bus
Date: Tue, 24 Jan 2017 12:48:02 -0500
Message-ID: <871svscpt9.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch> <1485266031-4980-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45920 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbdAXRse (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 12:48:34 -0500
In-Reply-To: <1485266031-4980-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Sorry but the previous patches with a list of MDIO busses and refactored
PHY ops still seems too much complex to just toggle a bit.

We know which switch port has an external PHY attached to it, right?
So why not just something like this:

    struct mv88e6xxx_chip {
        ...
        u16 external_phys;
        ...
    }

    int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int phy,
                                  int reg, u16 *val)
    {
        u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA | (addr << 5) | reg;
        int err;

        if (chip->external_phys & BIT(phy))
            cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;

        ...
    }


Thanks!

        Vivien
