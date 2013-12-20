From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 11/16] i40e: remove chatty log messages
Date: Fri, 20 Dec 2013 10:00:57 -0800
Message-ID: <1387562457.2183.90.camel@jtkirshe-mobl>
References: <1387557965-13241-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387557965-13241-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <52B489ED.3010704@cogentembedded.com>
	 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654E34C9@FMSMSX113.amr.corp.intel.com>
	 <1387562360.2353.51.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-u+5eHbJ9kvo9gGG9xYr4"
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35433 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752575Ab3LTSBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 13:01:47 -0500
In-Reply-To: <1387562360.2353.51.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-u+5eHbJ9kvo9gGG9xYr4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-12-20 at 09:59 -0800, Joe Perches wrote:
> On Fri, 2013-12-20 at 17:40 +0000, Williams, Mitch A wrote:
> > > -----Original Message-----
> > > From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> []
> > > > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> []
> > > > @@ -2988,21 +2988,11 @@ static int i40e_vsi_control_tx(struct
> i40e_vsi
> > > *vsi, bool enable)
> > > >                   } while (j-- && ((tx_reg >>
> I40E_QTX_ENA_QENA_REQ_SHIFT)
> > > >                                  ^ (tx_reg >>
> I40E_QTX_ENA_QENA_STAT_SHIFT)) & 1);
> > > >
> > > > -         if (enable) {
> > > > -                 /* is STAT set ? */
> > > > -                 if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
> > > > -                         dev_info(&pf->pdev->dev,
> > > > -                                  "Tx %d already enabled\n",
> i);
> > > > +         /* Skip if the queue is already in the requested state
> */
> > > > +         if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> > > >                                   continue;
> > >=20
> > >     This line seems over-indented now.
> > >=20
> > > > -                 }
> > > > -         } else {
> > > > -                 /* is !STAT set ? */
> > > > -                 if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
> > > > -                         dev_info(&pf->pdev->dev,
> > > > -                                  "Tx %d already disabled\n",
> i);
> > > > +         if (!enable && !(tx_reg &
> I40E_QTX_ENA_QENA_STAT_MASK))
> > > >                                   continue;
> > >=20
> > >     This one too.
> []
> > Sergei, if you look at the source instead of the patch, you'll see
> > that these are correct. The whole thing is inside a for loop, so it
> > should properly be indented two tabs.
>=20
> I looked at the source.
> Both continue statements _are_ overly indented.
> 4 tabs should be 3.
>=20
> Also, this code is inconsistent and might be
> nicer using the same form:
>=20
>                 /* Skip if the queue is already in the requested state
> */
>                 if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
>                         continue;
>                 if (!enable && !(tx_reg &
> I40E_QTX_ENA_QENA_STAT_MASK))
>                         continue;

Sergei was right.  I will get this fixed up and re-submit v3.

--=-u+5eHbJ9kvo9gGG9xYr4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJStIXZAAoJEOVv75VaS+3OsSQP/jaMrKUoOrIyQdXcZrAOtqxI
b0LH6eWZx/8iFzdhsT+ebPrShbJVZdGKLxw/jIT6uo1prDzqEXTvmM4BRwuYr5UX
gTwDwsMoi3GqAj5QOIQFjAzLpj+ZtTPdJi45RX8wwiFpV8tFou89YGKfYyoBXzgw
9SQ8b3uWeKi+enPUNSXOAWGrc+Qc//uSNKqC3kNfapIvRMqnJqCEsPm0UxbnpIIw
smifnxw8BhIzDkpriKdgnEcRI/5bYti8mbDBL/fzpgejk7YZ6vM2qP7nF4+u1iE1
vwK1UNKBDZCYvBa1X64u09WUy+zIr7eD52lAz5N1BacmFpY6Pc2OARRR9nf4fsGw
7y2XoT2cjk5u0kQYmzPW9iFKxGnpZKgKDr+0T56U4D+2FYJoPDUo7BbrUKfdpDrV
+I2heCkOSNvd1m2HBW4v32WjWbCMcVTupfF5TWfkw011FNDuCuxZTdpfW06ZcPvb
MfeitkQG6/5wgjrPe5QTDuYdnQ7rwI8FtnnRVE4+SsHmWjS4ghWUwRRguYbpR7WT
a0s5CwTPdKnLb9k/MIiEF82zlvYBrKj3CNaqyEwQ6WD5cnx9gfrw9ZFOYO7ASUk7
Oeb8Oe/dFiRlPabw3nLwGyf8PEaJ4IxVUIsXcruWHQatjr4+AFRNwysyu1fdWDu+
AROPvNW2MkryXafBQO5N
=vqxc
-----END PGP SIGNATURE-----

--=-u+5eHbJ9kvo9gGG9xYr4--
