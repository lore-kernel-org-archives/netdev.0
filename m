From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence
 GEM.
Date: Mon, 2 Jan 2017 09:36:10 +0000
Message-ID: <BN3PR07MB2516815EDE69ACDCE27F81A3C96F0@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "punnaia@xilinx.com" <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        "anirudh@xilinx.com" <anirudh@xilinx.com>,
        "boris.brezillon@free-electrons.com"
        <boris.brezillon@free-electrons.com>,
        "alexandre.belloni@free-electrons.com"
        <alexandre.belloni@free-electrons.com>,
        "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>
To: Andrei Pistirica <andrei.pistirica@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "harinikatakamlinux@gmail.com" <harinikatakamlinux@gmail.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Rafal Ozieblo=20
> Sent: 28 grudnia 2016 14:23
> Subject: RE: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadenc=
e GEM.
>=20
> > +static void gem_ptp_tx_hwtstamp(struct macb *bp, struct sk_buff *skb,
> > +				int peer_ev)
> > +{
> > +	struct skb_shared_hwtstamps *shhwtstamps =3D skb_hwtstamps(skb);
> > +	struct timespec64 ts;
> > +	u64 ns;
> > +
> > +	/* PTP Peer Event Frame packets */
> > +	if (peer_ev) {
> > +		ts.tv_sec =3D gem_readl(bp, PEFTSL);
> > +		ts.tv_nsec =3D gem_readl(bp, PEFTN);
> > +
> > +	/* PTP Event Frame packets */
> > +	} else {
> > +		ts.tv_sec =3D gem_readl(bp, EFTSL);
> > +		ts.tv_nsec =3D gem_readl(bp, EFTN);
> > +	}
> I'm wondering what is a difference between timestamp in transmit buffer d=
escriptor (Word 2 and 3) and PTP Event Frame Transmitted Seconds/Nanosecond=
s Register (0x1E0, 0x1E4).
>=20
According Cadence Hardware team:
"It is just that some customers prefer to have the time in the descriptors =
as that is provided per frame.
The registers are simply overwritten when a new event frame is transmitted/=
received and so software could miss it."
The question is are you sure that you read timestamp for current frame? (no=
t for the next frame).
