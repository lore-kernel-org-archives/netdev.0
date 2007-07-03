From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] netlink: allocate group bitmaps dynamically
Date: Tue, 03 Jul 2007 16:32:01 +0200
Message-ID: <1183473121.3722.16.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>
	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>
	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>
	 <1183124981.4089.69.camel@johannes.berg>  <46850EDE.5020804@trash.net>
	 <1183125924.4089.73.camel@johannes.berg>
	 <1183126739.4089.76.camel@johannes.berg>
	 <1183129006.4089.84.camel@johannes.berg>
	 <1183217536.5165.25.camel@localhost>
	 <1183365821.4089.94.camel@johannes.berg>  <4688F612.1060408@trash.net>
	 <1183386883.4089.120.camel@johannes.ber g>  <46890DF8.2020706@trash.net>
	 <1183387687.4089.124.camel@johannes.berg>
	 <1183414370.4089.141.camel@johannes.berg>
	 <1183457329.3841.0.camel@johannes.berg>  <468A3BA5.9050909@trash.net>
	 <1183471741.3722.6.camel@johannes.berg>  <468A5920.7070304@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-r5ujvxv+NXQeN7ZvQwBz"
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <468A5920.7070304@trash.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-r5ujvxv+NXQeN7ZvQwBz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-07-03 at 16:11 +0200, Patrick McHardy wrote:


> >>>-	nlk->groups =3D kzalloc(NLGRPSZ(groups), GFP_KERNEL);
> >>>-	if (nlk->groups =3D=3D NULL)
> >>>+	if (nlk->ngroups >=3D groups)
> >>>+		return 0;
> >>>+
> >>>+	new_groups =3D krealloc(nlk->groups, NLGRPSZ(groups), GFP_KERNEL);
> >>>+	if (new_groups =3D=3D NULL)
> >>> 		return -ENOMEM;
> >>>+	memset((char*)new_groups + NLGRPSZ(nlk->ngroups), 0,
> >>>+	       NLGRPSZ(groups) - NLGRPSZ(nlk->ngroups));
> >>>+	nlk->groups =3D new_groups;
> >>
> >>
> >>This should probably happen with the table grabbed to avoid races
> >>with concurrent broadcasts.
> >=20
> >=20
> > Hmm, possibly, I'll have to look again.
>=20
>=20
> do_one_broadcast locks the table and checks nlk->groups. The
> reallocation races with this without taking the lock or maybe
> using rcu.

Yeah, sounds about right, but since we lock the table anyway I see
little use in using RCU here. I'll look into it and also double-check
the first hunk of this patch.

johannes

--=-r5ujvxv+NXQeN7ZvQwBz
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGil3h/ETPhpq3jKURAhEJAJ9MWU9pQ5UY8xCggQrYdawlP/x5bACeIrYk
uGtclI03zpUG12wYeOXRHMU=
=Sg+H
-----END PGP SIGNATURE-----

--=-r5ujvxv+NXQeN7ZvQwBz--

