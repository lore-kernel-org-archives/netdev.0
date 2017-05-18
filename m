From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] qed: Utilize FW 8.20.0.0
Date: Thu, 18 May 2017 15:28:21 +0000
Message-ID: <BLUPR0701MB20044DA1ADB765CB620121778DE40@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <1495049920-22782-1-git-send-email-Yuval.Mintz@cavium.com>
        <20170518.103428.1194147893495615244.davem@davemloft.net>
 <20170518.104300.795177460216894201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-7"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "Tayar, Tomer" <Tomer.Tayar@cavium.com>,
        "Rangankar, Manish" <Manish.Rangankar@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20170518.104300.795177460216894201.davem@davemloft.net>
Content-Language: en-US
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> This pushes qed [and as result, all qed* drivers] into using 8.20.0.0
> >> firmware. The changes are mostly contained in qed with minor changes
> >> to qedi due to some HSI changes.
> >>
> >> Content-wise, the firmware contains fixes to various issues exposed
> >> since the release of the previous firmware, including:
> >>  - Corrects iSCSI fast retransmit when data digest is enabled.
> >>  - Stop draining packets when receiving several consecutive PFCs.
> >>  - Prevent possible assertion when consecutively opening/closing
> >>    many connections.
> >>  - Prevent possible assertion due to too long BDQ fetch time.
> >>
> >> In addition, the new firmware would allow us to later add iWARP
> >> support in qed and qedr.
> >>
> >> Signed-off-by: Chad Dupuis <Chad.Dupuis@cavium.com>
> >> Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
> >> Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
> >> Signed-off-by: Manish Rangankar <Manish.Rangankar@cavium.com>
> >> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> >
> > Applied.
>=20
> Actually I had to revert.  Please look at the compiler output before
> submitting changes:
>=20
> drivers/net/ethernet/qlogic/qed/qed_debug.c: In function =A1qed_grc_dump=
=A2:
> drivers/net/ethernet/qlogic/qed/qed_debug.c:2425:6: warning: =A1addr=A2 m=
ay
> be used uninitialized in this function [-Wmaybe-uninitialized]
>   u32 byte_addr =3D DWORDS_TO_BYTES(addr), offset =3D 0, i;
>       ^
> drivers/net/ethernet/qlogic/qed/qed_debug.c:3534:7: note: =A1addr=A2 was
> declared here
>    u32 addr, size =3D RSS_REG_RSS_RAM_DATA_SIZE;
>        ^
>=20
> 'addr' is never, ever, assigned a value, yet it is passed into a function=
 as an
> argument.

Sorry about that. Will send v2 [hopefully] later today.
