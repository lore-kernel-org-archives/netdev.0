From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH net-next v5] cadence: Add LSO support.
Date: Tue, 15 Nov 2016 07:07:14 +0000
Message-ID: <BN3PR07MB251641C606D02892E2196960C9BF0@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <BN3PR07MB2516C30913D2FB8D4788071AC9BC0@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20161114.123038.1075174354580074536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161114.123038.1075174354580074536.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > If UFO is in use it should not silently disable UDP checksums.
> > >=20
> > > If you cannot support UFO with proper checksumming, then you cannot e=
nable support for that feature.
> >=20
> > According Cadence Gigabit Ethernet MAC documentation:
> >=20
> > "Hardware will not calculate the UDP checksum or modify the UDP=20
> > checksum field. Therefore software must set a value of zero in the=20
> > checksum field in the UDP header (in the first payload buffer) to indic=
ate to the receiver that the UDP datagram does not include a checksum."
> >=20
> > It is hardware requirement.
>
> I do not doubt that it is a hardware restriction.
>
> But I am saying that you cannot enable this feature under Linux if this i=
s how it operates on your hardware.

Would it be good to enable UFO conditionally with some internal define? Ex.=
:

+#ifdef MACB_ENABLE_UFO
+#define MACB_NETIF_LSO         (NETIF_F_TSO | NETIF_F_UFO)
+#else
+#define MACB_NETIF_LSO         (NETIF_F_TSO)
+#endif

I could add precise comment here that ufo is possible only without checksum=
.

Or maybe I could enable it from module_params or device-tree (like: drivers=
/net/ethernet/neterion/s2io.c).
