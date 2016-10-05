From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [net-next 08/13] fsl/fman: check pcsphy pointer before use
Date: Wed, 5 Oct 2016 09:08:23 +0000
Message-ID: <AM4PR04MB1604A090118C4C344A1685F5ECC40@AM4PR04MB1604.eurprd04.prod.outlook.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
 <1475566379-5078-9-git-send-email-madalin.bucur@nxp.com>
 <063D6719AE5E284EB5DD2968C1650D6DB01E2ED3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linuxdev.baldrick@gmail.com" <linuxdev.baldrick@gmail.com>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB01E2ED3@AcuExch.aculab.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Tuesday, October 04, 2016 5:44 PM
> To: Madalin-Cristian Bucur <madalin.bucur@nxp.com>;
> netdev@vger.kernel.org
> Cc: linuxdev.baldrick@gmail.com; linuxppc-dev@lists.ozlabs.org;
> davem@davemloft.net; linux-kernel@vger.kernel.org
> Subject: RE: [net-next 08/13] fsl/fman: check pcsphy pointer before use
>=20
> From: Madalin Bucur
> > Sent: 04 October 2016 08:33
> > Subject: [net-next 08/13] fsl/fman: check pcsphy pointer before use
> ..
> > --- a/drivers/net/ethernet/freescale/fman/fman_memac.c
> > +++ b/drivers/net/ethernet/freescale/fman/fman_memac.c
> > @@ -507,6 +507,9 @@ static void setup_sgmii_internal_phy(struct
> fman_mac *memac,
> >  {
> >  	u16 tmp_reg16;
> >
> > +	if (WARN_ON(!memac->pcsphy))
> > +		return;
> > +
>=20
> Why?
>=20
> Either it can validly be NULL in which case you don't want the message.
> Or it shouldn't be NULL in which case you need to find and fix the bug.
> The later kernel OOPS will make the bug much easier to find.
>=20
> 	David

You can get into that situation if you have a broken device tree, state int=
o
which someone may get while trying to create the device tree for a new
board. Avoiding a crash here allows the user to look at the device trees as
seen by the kernel / add some debug code if needed.

Madalin
