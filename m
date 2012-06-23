From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH 0/2 net] Bug fixes for batman-adv
	2012-06-23
Date: Sat, 23 Jun 2012 17:45:12 +0200
Message-ID: <20120623154512.GA14022@ritirata.org>
References: <1340465459-2949-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1340465459-2949-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 23, 2012 at 05:30:57 +0200, Antonio Quartulli wrote:
> Hello David,
>=20
> here are two fixes intended for net/linux-3.5.
>=20
> Patch 1 is a fix for the AP-Isolation feature. A wrong check made all the
> broadcast packets coming from any client be dropped before delivery to the
> interface.
> Patch 2 instead fixes a "real" race condition in the TranslationTable cod=
e.
>=20
> Please, tell me if there is any problem.
> Thank you,
> 	Antonio
>=20
>=20
>=20
> The following changes since commit a18e08bdcf845efb7344cea146e683df746bbf=
b4:
>=20
>   net: sh_eth: fix the condition to fix the cur_tx/dirty_rx (2012-06-22 2=
1:50:37 -0700)
>=20
> are available in the git repository at:
>=20
>   git://git.open-mesh.org/linux-merge.git batman-adv/maint
>=20
> for you to fetch changes up to 8b8e4bc0391f8abbcdb9e1c54415bcc0f4f5a2a0:
>=20
>   batman-adv: fix race condition in TT full-table replacement (2012-06-23=
 17:21:35 +0200)
>=20

Hello David,

after pulling these patchset in net, you should hit a conflict while trying=
 to
merge net into net-next. The conflict is caused by the renaming patches tha=
t you
already have in the next tree.

Here are our instructions about how to solve it. Hope they will help.
Thank you.


Conflict 1:
<<<<<<<
	orig_entry =3D container_of(rcu, struct batadv_tt_orig_list_entry, rcu);
	atomic_dec(&orig_entry->orig_node->tt_size);
	batadv_orig_node_free_ref(orig_entry->orig_node);
=3D=3D=3D=3D=3D=3D=3D
	orig_entry =3D container_of(rcu, struct tt_orig_list_entry, rcu);
	orig_node_free_ref(orig_entry->orig_node);
>>>>>>>

Resolves to:
=3D=3D=3D=3D=3D=3D=3D
	orig_entry =3D container_of(rcu, struct batadv_tt_orig_list_entry, rcu);
	batadv_orig_node_free_ref(orig_entry->orig_node);
=3D=3D=3D=3D=3D=3D=3D


Conflict 2:
<<<<<<<
	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
=3D=3D=3D=3D=3D=3D=3D
	/* to avoid race conditions, immediately decrease the tt counter */
	atomic_dec(&orig_entry->orig_node->tt_size);
	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
>>>>>>>

Resolves to:
=3D=3D=3D=3D=3D=3D=3D
	/* to avoid race conditions, immediately decrease the tt counter */
	atomic_dec(&orig_entry->orig_node->tt_size);
	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
=3D=3D=3D=3D=3D=3D=3D


Conflict 3:
<<<<<<<
	struct batadv_tt_local_entry *tt_local_entry =3D NULL;
	struct batadv_tt_global_entry *tt_global_entry =3D NULL;
	bool ret =3D true;
=3D=3D=3D=3D=3D=3D=3D
	struct tt_local_entry *tt_local_entry =3D NULL;
	struct tt_global_entry *tt_global_entry =3D NULL;
	bool ret =3D false;
>>>>>>>

Resolves to:
=3D=3D=3D=3D=3D=3D=3D
	struct batadv_tt_local_entry *tt_local_entry =3D NULL;
	struct batadv_tt_global_entry *tt_global_entry =3D NULL;
	bool ret =3D false;
=3D=3D=3D=3D=3D=3D=3D


Conflict 4:
<<<<<<<
	if (_batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
=3D=3D=3D=3D=3D=3D=3D
	if (!_is_ap_isolated(tt_local_entry, tt_global_entry))
>>>>>>>

Resolves to:
=3D=3D=3D=3D=3D=3D=3D
	if (!_batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
=3D=3D=3D=3D=3D=3D=3D


--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAk/l5IgACgkQpGgxIkP9cwd1DwCfeyUhDeaWN8ywaknMeuawwHUN
b+QAn1VABoLYH37EG43uQaiXOLSU4UqC
=5no+
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
