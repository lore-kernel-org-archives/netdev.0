From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH v2] igb: Allow to remove
 administratively set MAC on VFs
Date: Mon, 10 Apr 2017 10:55:01 +0200
Message-ID: <20170410085501.GC26743@calimero.vinschen.de>
References: <CAKgT0UdHbfSL-5QM6sfH=j7adQLAscUss1GzN2oYZsLM1CgV3g@mail.gmail.com>
 <20170405134622.12227-1-vinschen@redhat.com>
 <1491591975.39459.1.camel@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        Alexander Duyck <alexander.duyck@gmail.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Corinna Vinschen <vinschen@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750989AbdDJIzI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 04:55:08 -0400
Content-Disposition: inline
In-Reply-To: <1491591975.39459.1.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Apr  7 12:06, Jeff Kirsher wrote:
> On Wed, 2017-04-05 at 15:46 +0200, Corinna Vinschen wrote:
> > =C2=A0 Before libvirt modifies the MAC address and vlan tag for an SRIOV
> > VF
> > =C2=A0 for use by a virtual machine (either using vfio device assignment
> > or
> > =C2=A0 macvtap passthru mode), it saves the current MAC address and vlan
> > tag
> > =C2=A0 so that it can reset them to their original value when the guest=
 is
> > =C2=A0 done.=C2=A0 Libvirt can't leave the VF MAC set to the value used=
 by the
> > =C2=A0 now-defunct guest since it may be started again later using a
> > =C2=A0 different VF, but it certainly shouldn't just pick any random
> > value,
> > =C2=A0 either. So it saves the state of everything prior to using the V=
F,
> > and
> > =C2=A0 resets it to that.
> >=20
> > =C2=A0 The igb driver initializes the MAC addresses of all VFs to
> > =C2=A0 00:00:00:00:00:00, and reports that when asked (via an RTM_GETLI=
NK
> > =C2=A0 netlink message, also visible in the list of VFs in the output of
> > "ip
> > =C2=A0 link show"). But when libvirt attempts to restore the MAC address
> > back
> > =C2=A0 to 00:00:00:00:00:00 (using an RTM_SETLINK netlink message) the
> > kernel
> > =C2=A0 responds with "Invalid argument".
> >=20
> > =C2=A0 Forbidding a reset back to the original value leaves the VF MAC =
at
> > the
> > =C2=A0 value set for the now-defunct virtual machine. Especially on a
> > system
> > =C2=A0 with NetworkManager enabled, this has very bad consequences, sin=
ce
> > =C2=A0 NetworkManager forces all interfacess to be IFF_UP all the time -
> > if
> > =C2=A0 the same virtual machine is restarted using a different VF (or e=
ven
> > on
> > =C2=A0 a different host), there will be multiple interfaces watching for
> > =C2=A0 traffic with the same MAC address.
> >=20
> > =C2=A0 To allow libvirt to revert to the original state, we need a way =
to
> > =C2=A0 remove the administrative set MAC on a VF, to allow normal host
> > =C2=A0 operation again, and to reset/overwrite the VF MAC via VF netdev.
> >=20
> > =C2=A0 This patch implements the outlined scenario by allowing to set t=
he
> > =C2=A0 VF MAC to 00:00:00:00:00:00 via RTM_SETLINK on the PF.
> > =C2=A0 igb_ndo_set_vf_mac resets the IGB_VF_FLAG_PF_SET_MAC flag to 0,
> > =C2=A0 so it's possible to reset the VF MAC back to the original value =
via
> > =C2=A0 the VF netdev.
> >=20
> > =C2=A0 Note: Recent patches to libvirt allow for a workaround if the NIC
> > =C2=A0 isn't capable of resetting the administrative MAC back to all 0,
> > but
> > =C2=A0 in theory the NIC should allow resetting the MAC in the first
> > place.
> >=20
> > Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
> > ---
> > =C2=A0drivers/net/ethernet/intel/igb/igb_main.c | 42
> > +++++++++++++++++++++++--------
> > =C2=A01 file changed, 31 insertions(+), 11 deletions(-)
>=20
> This patch does not apply (not even close).  Please make sure to base
> you patch off my dev-queue branch of my next-queue tree on kernel.org.

Right, I applied the patch against net-next.  Actually, only the
first hunk didn't apply to dev-queue because of the change from
igb_rar_set_qsel to igb_rar_set_index.

I'll send a v3 agains dev-queue in a bit.


Corinna

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJY60hkAAoJEPU2Bp2uRE+gqb0QAIZXDz/oj/AG3O6xSqJSIkRB
jWQ3FKrkG994Ncr69ndZ3noxSrF3gYdM+CJnupiPQStCP2SJ3GptYu4Hb3UrQBvL
/fUCVIE6LYrw1P4iPCmlF5sHHJSE1sfkdGI2uI1R3fTH4f8j3Y8cDX4bp1w200tA
nkMPzHls0WfOcphidVVhkWj48cIMYB17a/L+QtdQ/EZCpmvymwhlsan29U9RuG+2
Qy3JF9ozUAXz3RbZiluaRw/ljzGDnVqtLgXKTHNlMpvQowo0rJXQuZ0uXDK1eoca
DkYM1gdsc/seHGNMldHdtz9soGnsyiBQ2SdUnkbM8oSAWAvjtjTJOyPm4VVtNDaS
/veDtDShaLHO6h2HNacWr+mWw0ZXadjrPu7+K+sY3dDEAsAZIRmigf1PHodFfv+k
12JdZ3IFT4lrJhsn3OBsXhAhY/Czk38s3hRQoZAf7cRPQFkf0zHmgh+u0P95Paod
elhAwfH6YQ9CUOzFjRD49F171zrFbTmevH+/VX0m90PvoNKWDGDD/KOUnR1JXF6H
t1fZ6QXriQB0VA/2dpHiv6C3ckCl0jHvemqcECG1i1ST9FIvPRC4SaZaXCvyh7SG
7zs0xEqG+quxppQltYZxMR+dz5bChE4ZSSKomqSpA1OZeoXJzlbATpFXmGbaKzuc
z23QnH477/3Xcu04xGQV
=1LBy
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
