From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/2] Move hwmon support out of switch and into PHYs.
Date: Wed, 11 Jan 2017 12:06:11 -0500
Message-ID: <87vatljzlo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Guenter Roeck <linux@roeck-us.net>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47032 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbdAKRGe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 12:06:34 -0500
In-Reply-To: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Marvell Ethernet switches contain temperature sensors. They are inside
> the embedded PHYs. Move the code into the PHY driver, so that discrete
> PHY drivers also export there temperature sensor.

This message is not correct. The Marvell Ethernet switches contain only
one temperature sensor for the entire chip (please adjust the cover
letter and commit messages when you respin.)

The temperature and threshold are accessed through the embedded PHY
registers of any port, as long as the port is not disabled.

Even unlikely to be used, an interrupt can be generated when the
temperature exceeds a certain threshold. It should be enabled on only
one port at a time since there is only one temperature sensor.

To sum up briefly, the temperature chip is physically inside the switch
chip, but its access is via the embedded PHYs of the switch.

I'd prefer to see the temperature code in the PHY driver as well, but I
prefer we make sure that privileging the data access over the physical
representation is the correct thing to do before moving code around.

Thanks,

        Vivien
