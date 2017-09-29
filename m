From: Brandon Streiff <brandon.streiff@ni.com>
Subject: RE: [PATCH net-next RFC 6/9] net: dsa: forward timestamping callbacks
 to switch drivers
Date: Fri, 29 Sep 2017 15:30:44 +0000
Message-ID: <CO2PR04MB218477390A93C78B32F5BE099F7E0@CO2PR04MB2184.namprd04.prod.outlook.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-7-git-send-email-brandon.streiff@ni.com>
 <c4b98f32-c495-623a-53b0-56c1cdf9806a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c4b98f32-c495-623a-53b0-56c1cdf9806a@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Thursday, September 28, 2017 12:40 PM
>
> Can we also have a fast-path bypass in case time stamping is not
> supported by the switch so we don't have to even try to classify this
> packet only to realize we don't have a port_rxtsamp() operation later?
> You can either gate this with a compile-time option, or use e.g: a
> static key or something like an early test?

I was trying to follow the existing pattern for skb_defer_rx_timestamp, but=
 that function be turned into a stub by not configuring NETWORK_PHY_TIMESTA=
MPING. Maybe a similar compile-time token is appropriate.

> >
> > -   nskb =3D dst->rcv(skb, dev, pt);
> > +   nskb =3D dst->rcv(skb, dev, pt, &ds, &source_port);
>
> I don't think this is necessary, what dst->rcv() does is actually
> properly assign skb->dev to the correct dsa slave network device, which
> has the information about the port number already in its private context.

Yes, looking in that private context seems like it'd be a better approach (=
and avoids having to touch all the taggers). I'll look into that further.

> > +   type =3D ptp_classify_raw(skb);
> > +   if (type =3D=3D PTP_CLASS_NONE)
> > +           return;
>
> If we don't have a port_txtstamp option, is there even value in
> classifying this packet?

There isn't. This could also use a bypass just like the RX case.

-- brandon
