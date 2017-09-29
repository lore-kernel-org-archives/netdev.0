From: Brandon Streiff <brandon.streiff@ni.com>
Subject: RE: [PATCH net-next RFC 0/9] net: dsa: PTP timestamping for mv88e6xxx
Date: Fri, 29 Sep 2017 15:34:05 +0000
Message-ID: <CO2PR04MB21849E4C11EE858177DB86019F7E0@CO2PR04MB2184.namprd04.prod.outlook.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <20170928173629.GD14940@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928173629.GD14940@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, September 28, 2017 12:36 PM
>
> I assume ptp already has the core code to use pinctrl and Linux
> standard GPIOs? What does the device tree binding look like? How do
> you specify the GPIOs to use?
>=20
> What we want to avoid is defining an ABI now, otherwise it is going to
> be hard to swap to pinctrl later.

A ptp_clock_info has an array of struct ptp_pin_desc which defines "pins" w=
ith a name ("Hardware specific human readable pin name"), an index, and a b=
itmask of valid functions. The ptp_pin_desc structure is shared with usermo=
de for the PTP_PIN_GETFUNC and PTP_PIN_SETFUNC ioctls. The pins are also ex=
posed in sysfs (see Documentation/ABI/testing/sysfs-ptp). The underlying im=
plementation for configuring the hardware is left up to the PHC driver. I d=
on't see any drivers today that use the PHC pin API as a layer over pinctrl=
/gpiochip, but there's no reason that that couldn't be the case.

For mv88e6xxx, we name the pins using the pattern "mv88e6xxx_gpio%d"; this =
appears to be in line with current practice (igb_ptp.c uses "SDP%d", mlx5 d=
river uses "mlx5_pps%d"). Usermode code appears to be expected to determine=
 which pin it needs to use. (Our current userspace code, for instance, know=
s that it needs to find "mv88e6xxx_gpio8".)

For mv88e6xxx, Device Tree does feel like a better option here for declarin=
g names, functions, and pin usages. Not all platforms that use the PTP API =
use Device Tree though.

-- brandon
