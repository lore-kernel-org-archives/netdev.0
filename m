From: Joe Perches <joe@perches.com>
Subject: Re: gianfar: Less function calls in gfar_ethflow_to_filer_table()
 after error detection
Date: Fri, 15 Jan 2016 04:03:49 -0800
Message-ID: <1452859429.8586.52.camel@perches.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	 <56866E7F.8080609@users.sourceforge.net>
	 <5698C53C.8060204@users.sourceforge.net>
	 <5698C5CB.80305@users.sourceforge.net>
	 <1452854229.8586.48.camel@perches.com>
	 <5698DC52.4050808@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <5698DC52.4050808@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-01-15 at 12:47 +0100, SF Markus Elfring wrote:
> > > * Return directly if a memory allocation failed at the beginning.
> > >=20
> > > * Adjust jump targets according to the Linux coding style
> > > convention.
> > >=20
> > > This issue was detected by using the Coccinelle software.
> >=20
> > Is this really better?
> >=20
> > Perhaps this particular static analysis isn't too useful.
>=20
> The opinions are still evolving for such a kind of search pattern.
>=20
>=20
> > Why not just allocate once and assign a second pointer?
> >=20
> > 	local_rqfpr =3D kmalloc_array(2 * (MAX_FILER_IDX + 1),
> > 				=A0=A0=A0=A0sizeof(unsigned int), GFP_KERNEL);
> > 	if (!local_rqfpr)
> > 		goto err;
> >=20
> > 	local_rqfcr =3D &local_rqfpr[MAX_FILER_IDX + 1];
>=20
> Do you suggest to use only one array (instead of two as before) here?

That's a possibility.

If, as your title suggests, you really want fewer function
calls, (which as far as I saw, you didn't do) that could
be a mechanism to remove both an allocation and a free.

--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
