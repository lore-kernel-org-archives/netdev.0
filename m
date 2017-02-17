From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/6] net: dsa: mv88e6xxx: move ATU code in
 its own file
Date: Fri, 17 Feb 2017 23:36:51 +0100
Message-ID: <20170217223651.GN6096@lunn.ch>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
 <20170217150531.2181-3-vivien.didelot@savoirfairelinux.com>
 <20170217213518.GH6096@lunn.ch>
 <87fujcmqj9.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fujcmqj9.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Note that we are very close from 4.10, so unless there is a major issue
> in the patchset, I'd prefer not to respin new versions. I'd gladly send
> cosmetics fixup later though. I'm waiting for this patchset to land in
> net-next to send the second one ready for cross-chip bridging in DSA.

I know we are very close to v4.10. But i don't think these changes
alone make the 6390 work properly. It appears that we still have:

       if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
            mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
            mv88e6xxx_6320_family(chip) || mv88e6xxx_6341_family(chip)) {
                /* Port ATU control: disable limiting the number of
                 * address database entries that this port is allowed
                 * to use.
                 */
                err = mv88e6xxx_port_write(chip, port, PORT_ATU_CONTROL,
                                           0x0000);
                /* Priority Override: disable DA, SA and VTU priority
                 * override.
                 */
                err = mv88e6xxx_port_write(chip, port, PORT_PRI_OVERRIDE,
                                           0x0000);
                if (err)
                        return err;
        }

to deal with. I have been working on 6390 for a long time, and would
like to see it working properly, but i'm not happy with the
non-obvious changes here, and the structure of these patches.

Please take your time to do this right. Lots of small patches, which
are obviously correct.

       Andrew
