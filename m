From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH v2] igb: Allow to remove
 administratively set MAC on VFs
Date: Fri, 07 Apr 2017 12:06:15 -0700
Message-ID: <1491591975.39459.1.camel@intel.com>
References: <CAKgT0UdHbfSL-5QM6sfH=j7adQLAscUss1GzN2oYZsLM1CgV3g@mail.gmail.com>
         <20170405134622.12227-1-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-WVMygOieQaJHCI+Fu3at"
To: Corinna Vinschen <vinschen@redhat.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        Alexander Duyck <alexander.duyck@gmail.com>, Duyck@vinschen.de,
        Alexander H <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:2686 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933069AbdDGTGW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 15:06:22 -0400
In-Reply-To: <20170405134622.12227-1-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WVMygOieQaJHCI+Fu3at
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-04-05 at 15:46 +0200, Corinna Vinschen wrote:
> =C2=A0 Before libvirt modifies the MAC address and vlan tag for an SRIOV
> VF
> =C2=A0 for use by a virtual machine (either using vfio device assignment
> or
> =C2=A0 macvtap passthru mode), it saves the current MAC address and vlan
> tag
> =C2=A0 so that it can reset them to their original value when the guest i=
s
> =C2=A0 done.=C2=A0 Libvirt can't leave the VF MAC set to the value used b=
y the
> =C2=A0 now-defunct guest since it may be started again later using a
> =C2=A0 different VF, but it certainly shouldn't just pick any random
> value,
> =C2=A0 either. So it saves the state of everything prior to using the VF,
> and
> =C2=A0 resets it to that.
>=20
> =C2=A0 The igb driver initializes the MAC addresses of all VFs to
> =C2=A0 00:00:00:00:00:00, and reports that when asked (via an RTM_GETLINK
> =C2=A0 netlink message, also visible in the list of VFs in the output of
> "ip
> =C2=A0 link show"). But when libvirt attempts to restore the MAC address
> back
> =C2=A0 to 00:00:00:00:00:00 (using an RTM_SETLINK netlink message) the
> kernel
> =C2=A0 responds with "Invalid argument".
>=20
> =C2=A0 Forbidding a reset back to the original value leaves the VF MAC at
> the
> =C2=A0 value set for the now-defunct virtual machine. Especially on a
> system
> =C2=A0 with NetworkManager enabled, this has very bad consequences, since
> =C2=A0 NetworkManager forces all interfacess to be IFF_UP all the time -
> if
> =C2=A0 the same virtual machine is restarted using a different VF (or eve=
n
> on
> =C2=A0 a different host), there will be multiple interfaces watching for
> =C2=A0 traffic with the same MAC address.
>=20
> =C2=A0 To allow libvirt to revert to the original state, we need a way to
> =C2=A0 remove the administrative set MAC on a VF, to allow normal host
> =C2=A0 operation again, and to reset/overwrite the VF MAC via VF netdev.
>=20
> =C2=A0 This patch implements the outlined scenario by allowing to set the
> =C2=A0 VF MAC to 00:00:00:00:00:00 via RTM_SETLINK on the PF.
> =C2=A0 igb_ndo_set_vf_mac resets the IGB_VF_FLAG_PF_SET_MAC flag to 0,
> =C2=A0 so it's possible to reset the VF MAC back to the original value vi=
a
> =C2=A0 the VF netdev.
>=20
> =C2=A0 Note: Recent patches to libvirt allow for a workaround if the NIC
> =C2=A0 isn't capable of resetting the administrative MAC back to all 0,
> but
> =C2=A0 in theory the NIC should allow resetting the MAC in the first
> place.
>=20
> Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
> ---
> =C2=A0drivers/net/ethernet/intel/igb/igb_main.c | 42
> +++++++++++++++++++++++--------
> =C2=A01 file changed, 31 insertions(+), 11 deletions(-)

This patch does not apply (not even close).  Please make sure to base
you patch off my dev-queue branch of my next-queue tree on kernel.org.
--=-WVMygOieQaJHCI+Fu3at
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAljn4ycACgkQ5W/vlVpL
7c4VOxAAiEWwVnNnsH1rosTUQYBfGG93IHA0ReBgwXIuYR6F+PcMYRaersa86Fk/
4WctkLrqvc64lTvmaZXe2Z4LCF97FpuDOejwpZNbjoUoe1L1lBJglbvrAa0A9zXX
dFAD7e8u+BZ9BnrVd2lH3ZHoiIreTUvWDrKRqqkzYz63PImuByRW8Y1nZKchZVtj
IOsXSOq/d5+fSWrPhmyN3URw278JleoVifvCwLkEz+zT4B3pOnnUefQhGR8Fl+sc
QKfnUJMGLxkIcqq+wuRg7UTt49vNgxlDdXf2UlchrL97KfJgcrzM4SxEOnErhnPP
QrSoXMmOCkJnzIchutNeWO1YdVpTFc/lxC6rm+/MKlTvrlLP7VSmz1e+H0tdfHAQ
VOQLM77X8bVHaHoBC3DxCjuwqDgNSIVNIbV9Lhlfp+wtUVgZzW5kr3ivVRnbkeOb
xVLpNB6n41ZHntLyjKnHzB901lkLynIOvzOB5cIPTBOz2DE6Ry2fVS9A+/5eApQc
ym9w1QQHGaMo9l2Lyp1HFIrghSow1T2ri8wKUYiVBfcY3LxGewsGFcqckKUbEs3s
oqYYwIzoULQjqffimuu+NxlNtkv9iDiU7YoMTHkqffjEPnDzxS1SpTA+sgI067X3
ue/RrvbE8pbhgKGMV2jXoGf9Pk/ALfufVEgmAVBlGlxB2OrJSPk=
=8Uhq
-----END PGP SIGNATURE-----

--=-WVMygOieQaJHCI+Fu3at--
