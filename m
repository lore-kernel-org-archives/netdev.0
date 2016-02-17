From: Antonio Quartulli <a@unstable.cc>
Subject: Re: [B.A.T.M.A.N.] pull request [net]: batman-adv 20160216
Date: Wed, 17 Feb 2016 12:20:59 +0800
Message-ID: <20160217042059.GA30168@prodigo.lan>
References: <1455634888-29400-1-git-send-email-a@unstable.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="XsQoSWH+UP9D9v3l"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:33690 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755530AbcBQEXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 23:23:19 -0500
Content-Disposition: inline
In-Reply-To: <1455634888-29400-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 16, 2016 at 11:01:25PM +0800, Antonio Quartulli wrote:
> Hello David,
>=20
> this pull request is intended for net.

David,

when merging net into net-next these patches will create a conflict which g=
it
should try to fix on its own.
However, it will still ask you to confirm something. Here are the relevant
chunks:

--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@@ -544,11 -527,12 +544,17 @@@ void batadv_gw_node_update(struct batad
                 * gets dereferenced.
                 */
                spin_lock_bh(&bat_priv->gw.list_lock);
-               hlist_del_init_rcu(&gw_node->list);
+               if (!hlist_unhashed(&gw_node->list)) {
+                       hlist_del_init_rcu(&gw_node->list);
+                       batadv_gw_node_free_ref(gw_node);
+               }
                spin_unlock_bh(&bat_priv->gw.list_lock);
 =20
++<<<<<<< HEAD
 +              batadv_gw_node_put(gw_node);
 +
++=3D=3D=3D=3D=3D=3D=3D
++>>>>>>> maint



if you have this conflict, please keep the "maint" block.
Moreover, make sure that every reference to
batadv_gw_node_free_ref() in this file is substituted with
batadv_gw_node_put() (there should be only one).



diff --cc net/batman-adv/translation-table.c
index 2fd5b28,7301a92..0000000
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@@ -346,12 -311,14 +346,18 @@@ static void batadv_tt_global_size_mod(s
 =20
        if (atomic_add_return(v, &vlan->tt.num_entries) =3D=3D 0) {
                spin_lock_bh(&orig_node->vlan_list_lock);
-               hlist_del_init_rcu(&vlan->list);
+               if (!hlist_unhashed(&vlan->list)) {
+                       hlist_del_init_rcu(&vlan->list);
+                       batadv_orig_node_vlan_free_ref(vlan);
+               }
                spin_unlock_bh(&orig_node->vlan_list_lock);
++<<<<<<< HEAD
 +              batadv_orig_node_vlan_put(vlan);
++=3D=3D=3D=3D=3D=3D=3D
++>>>>>>> maint



if you have this conflict, please keep the "maint" block.
Moreover, make sure that every reference to
batadv_orig_node_vlan_free_ref() in this file is substituted with
batadv_orig_node_vlan_put() (there should be only one).



Obviously, I can check the final result after your merge operation.
Thanks!


Cheers,


--=20
Antonio Quartulli

--XsQoSWH+UP9D9v3l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWw/UrAAoJENpFlCjNi1MRikIQAJ3BJWA35WhHc2SgFuQkz3e5
MgLyB9Dkz9zsOhJzg03BLl9/VMtZ1vOWtHRKOfZY/wow55rpszqnmCwtQcVT80cF
lfgh6cgQEiA7MDU998uDk/MKkLSF7+7Srr6xP82FBH8n3a/75CQC8lq8YPm48cpF
pOz+AdhDCTKHQdpEV0VL8HHBXULxSf21yJViBgyS8WDd28jBQPBR25nzkCqXV0Cp
yL2W6YuKBUmNVeC3aRNbYEnN5rAHqWuiJgLsyyNjOvZhDQEWyP/RYh78o82OT+/7
kLD4mTsPRSjhlKXR3He9xFI+DlTo4FpXixjXKf/ZNx6nBQIrB1WXovr2b1IczXf/
i1ikv2hXFMqAVmzaKsFg4/gmkYdW3vEpmBoPMLby+SF1wM/M1A1gjBwQzBONScln
l6NfWxejCpO7C+7eV5Q7ttYriTrdsIK7t8Pxpe8P0jA7CcmcEb3uTiDybx85KGbV
CsxF48/KE1gqrdQIRjiIoFLN1lrlot/8k7TbiyDKCACLDUs6ywr0AJaA0uUUoDMR
L0GP8e5koctrotblSdmexOteE8Nap+IeE2drFq1oIgbDBRhQdokDCmHnhcRcrZNa
qq+wLtsOKL+V/Ju2zUB6MrQPJPxl6Zy2KKncXPXk9Eh/dm2vBxR3Ni8n1OHDaJNZ
rDjDkXbqIfnXXJAfSd4o
=I7m2
-----END PGP SIGNATURE-----

--XsQoSWH+UP9D9v3l--
