From: Brandon Streiff <brandon.streiff@ni.com>
Subject: RE: [PATCH net-next RFC 3/9] net: dsa: mv88e6xxx: add support for
 GPIO configuration
Date: Fri, 29 Sep 2017 15:30:08 +0000
Message-ID: <CO2PR04MB2184CC589E0ED269A34279959F7E0@CO2PR04MB2184.namprd04.prod.outlook.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-4-git-send-email-brandon.streiff@ni.com>
 <659c4254-d0b7-52dc-dd9b-3921cd2f20c0@gmail.com>
 <20170928180111.GF14940@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928180111.GF14940@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, September 28, 2017 1:01 PM
>
> > With the write and read acquiring and then releasing the lock
> > immediately, is no there room for this sequence to be interrupted in th=
e
> > middle and end-up returning inconsistent reads?
>=20
> The general pattern in this code is that the lock chip->reg_lock is
> taken at a higher level. That protects against other threads. The
> driver tends to do that at the highest levels, at the entry points
> into the driver. I've not yet checked this code follows the pattern
> yet. However, we have a check in the low level to ensure the lock has
> been taken. So it seems likely the lock is held.

Yes, the expectation here is that an upper layer takes the reg_lock. All th=
e functions in ptp.c that call this function do that. If they did not, then=
 assert_reg_lock() gets very angry. :)

Perhaps using __must_hold() and similar annotations would also help documen=
t the requirements, but we don't seem to use those in this driver today.
=20
-- brandon
