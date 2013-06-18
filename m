From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v2] net: fec: Fix build for MCF5272
Date: Tue, 18 Jun 2013 09:32:32 -0700
Message-ID: <20130618163232.GA10097@roeck-us.net>
References: <1371569885-9054-1-git-send-email-linux@roeck-us.net>
 <CAOMZO5DW_e33MbfJhNG0ouf5g5o04AF7UchD3xwJV30GLovoNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOMZO5DW_e33MbfJhNG0ouf5g5o04AF7UchD3xwJV30GLovoNg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 18, 2013 at 01:23:13PM -0300, Fabio Estevam wrote:
> On Tue, Jun 18, 2013 at 12:38 PM, Guenter Roeck <linux@roeck-us.net> =
wrote:
> > Commits 4c09eed9 (net: fec: Enable imx6 enet checksum acceleration)=
 and
> > baa70a5c (net: fec: enable pause frame to improve rx prefomance for=
 1G
> > network) introduced functionality into the FEC driver which is not
> > supported on MCF5272. The registers used to implement this function=
ality
> > do not exist on MCF5272. Since register defines for MCF5272 are sep=
arate
> > from register defines for other chips, building images for MCF5272 =
fails,
> > complaining about several undefined symbols.
> >
> > Adding the missing register defines is not an option, since the reg=
isters
> > do not exist on MCF5272. Disable the added functionality for MCF527=
2 builds.
>=20
> Can you please show the build error message you got?
>=20
> Also, it would be nice if FEC could be enabled by default on some m68=
k
> defconfig, so that we could spot issues like this earlier.
>=20
Try building m5272c3_defconfig; this is actually how I found the proble=
m when
test-building v3.9.6-rc1.

make ARCH=3Dm68k CROSS_COMPILE=3Dm68k-linux-gnu- mrproper
make ARCH=3Dm68k CROSS_COMPILE=3Dm68k-linux-gnu- m5272c3_defconfig
make ARCH=3Dm68k CROSS_COMPILE=3Dm68k-linux-gnu-

results in:

drivers/net/ethernet/freescale/fec_main.c: In function =E2=80=98fec_res=
tart=E2=80=99:
drivers/net/ethernet/freescale/fec_main.c:520:8: error: =E2=80=98FEC_RA=
CC=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/freescale/fec_main.c:520:8: note: each undeclared =
identifier is reported only once for each function it appears in
drivers/net/ethernet/freescale/fec_main.c:585:3: error: =E2=80=98FEC_R_=
=46IFO_RSEM=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/freescale/fec_main.c:586:3: error: =E2=80=98FEC_R_=
=46IFO_RSFL=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/freescale/fec_main.c:587:3: error: =E2=80=98FEC_R_=
=46IFO_RAEM=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/freescale/fec_main.c:588:3: error: =E2=80=98FEC_R_=
=46IFO_RAFL=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/freescale/fec_main.c:591:3: error: =E2=80=98FEC_OP=
D=E2=80=99 undeclared (first use in this function)

with v3.10-rc6,

and

drivers/net/ethernet/freescale/fec.c: In function =E2=80=98fec_restart=E2=
=80=99:
drivers/net/ethernet/freescale/fec.c:530:3: error: =E2=80=98FEC_R_FIFO_=
RSEM=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/freescale/fec.c:530:3: note: each undeclared ident=
ifier is reported only once for each function it appears in
drivers/net/ethernet/freescale/fec.c:531:3: error: =E2=80=98FEC_R_FIFO_=
RSFL=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/freescale/fec.c:532:3: error: =E2=80=98FEC_R_FIFO_=
RAEM=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/freescale/fec.c:533:3: error: =E2=80=98FEC_R_FIFO_=
RAFL=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/freescale/fec.c:536:3: error: =E2=80=98FEC_OPD=E2=80=
=99 undeclared (first use in this function)

with 3.9.6.
=20
Want me to add it to the commit log ?

Guenter
