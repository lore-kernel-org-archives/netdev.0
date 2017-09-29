From: Brandon Streiff <brandon.streiff@ni.com>
Subject: RE: [PATCH net-next RFC 2/9] net: dsa: mv88e6xxx: expose switch time
 as a PTP hardware clock
Date: Fri, 29 Sep 2017 15:17:02 +0000
Message-ID: <CO2PR04MB218426561C8915B89947A79E9F7E0@CO2PR04MB2184.namprd04.prod.outlook.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
 <20170928170329.GC14940@lunn.ch>
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
In-Reply-To: <20170928170329.GC14940@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, September 28, 2017 12:03 PM
>=20
> > +	bool timeout =3D time_is_before_jiffies(chip->last_overflow_check +
> > +					      MV88E6XXX_TAI_OVERFLOW_PERIOD);
> > +
> > +	if (timeout) {
>=20
> Why do you need this timeout? Do you think the kernel will call this
> more often than required?
>=20
> Also, if it did call this function early, you skip the read, and
> reschedule. There is then a danger the next read is after the
> wraparound.....

That was, conceptually, a copy-paste from ixgbe_ptp.c as I was looking for =
how to implement the overflow accounting; that driver has a similar time_is=
_before_jiffies check in ixgbe_ptp_overflow_check.
=20
Although now that I'm looking it over again, I'm also not certain of the ne=
ed. Even if we're called more frequently than we expect, that doesn't seem =
to be harmful with regard to timekeeping. Hmm.

-- brandon
