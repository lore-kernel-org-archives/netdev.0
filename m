From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 1/3] gianfar: Less function calls in
 gfar_ethflow_to_filer_table() after error detection
Date: Fri, 15 Jan 2016 02:37:09 -0800
Message-ID: <1452854229.8586.48.camel@perches.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	 <56866E7F.8080609@users.sourceforge.net>
	 <5698C53C.8060204@users.sourceforge.net>
	 <5698C5CB.80305@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5698C5CB.80305@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-01-15 at 11:11 +0100, SF Markus Elfring wrote:
> The kfree() function was called in one case by the
> gfar_ethflow_to_filer_table() function during error handling
> even if a passed variable contained a null pointer.
>=20
> * Return directly if a memory allocation failed at the beginning.
>=20
> * Adjust jump targets according to the Linux coding style convention.
>=20
> This issue was detected by using the Coccinelle software.

Is this really better?

Perhaps this particular static analysis isn't too useful.

Why not just allocate once and assign a second pointer?

	local_rqfpr =3D kmalloc_array(2 * (MAX_FILER_IDX + 1),
				=A0 =A0 sizeof(unsigned int), GFP_KERNEL);
	if (!local_rqfpr)
		goto err;

	local_rqfcr =3D &local_rqfpr[MAX_FILER_IDX + 1];

Perhaps this would be better removing the ret variable
and using something like:

int gfar_ethflow_to_filer_table(...)
{
	...

	return 0;

err:
	kfree(local_rqfpt);
	return 1;
}
