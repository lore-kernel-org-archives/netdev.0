From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/11][pull request] 40GbE Intel Wired LAN Driver
 Updates 2017-03-25
Date: Mon, 27 Mar 2017 16:38:23 -0700
Message-ID: <1490657903.24874.3.camel@intel.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-V1NA9v8ev5GX1EaQsj4b"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:42763 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752748AbdC0XjH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 19:39:07 -0400
In-Reply-To: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-V1NA9v8ev5GX1EaQsj4b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2017-03-25 at 01:12 -0700, Jeff Kirsher wrote:
> This series contains updates to i40e and i40evf only.
>=20
> Alex updates the driver code so that we can do bulk updates of the
> page
> reference count instead of just incrementing it by one reference at a
> time.=C2=A0=C2=A0Fixed an issue where we were not resetting skb back to N=
ULL
> when
> we have freed it.=C2=A0=C2=A0Cleaned up the i40e_process_skb_fields() to =
align
> with
> other Intel drivers.=C2=A0=C2=A0Removed FCoE code, since it is not suppor=
ted in
> any
> of the Fortville/Fortpark hardware, so there is not much point of
> carrying
> the code around, especially if it is broken and untested.
>=20
> Harshitha fixes a bug in the driver where the calculation of the RSS
> size
> was not taking into account the number of traffic classes enabled.
>=20
> Robert fixes a potential race condition during VF reset by
> eliminating
> IOMMU DMAR Faults caused by VF hardware and when the OS initiates a
> VF
> reset and before the reset is finished we modify the VF's settings.
>=20
> Carolyn adds a needed delay to accommodate the hardware needs.
>=20
> Bimmy removes a delay that is no longer needed, since it was only
> needed
> for preproduction hardware.
>=20
> Colin King fixes null pointer dereference, where VSI was being
> dereferenced before the VSI NULL check.
>=20
> Jake fixes an issue with the recent addition of the "client code" to
> the
> driver, where we attempt to use an uninitialized variable, so
> correctly
> initialize the params variable by calling i40e_client_get_params().

I will re-spin the series without Carolyn's patch, while she works on
the patch to update the documentation/explanation on her change.

>=20
> The following are changes since commit
> 2239cc634395ecce69dd047be9104f71edc417b4:
> =C2=A0 Merge branch 'epoll-busypoll'
> and are available in the git repository at:
> =C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
> 40GbE
>=20
> Alexander Duyck (5):
> =C2=A0 i40e/i40evf: Update code to better handle incrementing page count
> =C2=A0 i40e/i40evf: Fix use after free in Rx cleanup path
> =C2=A0 i40e/i40evf: Clean-up process_skb_fields
> =C2=A0 i40e: Drop FCoE code from core driver files
> =C2=A0 i40e: Drop FCoE code that always evaluates to false or 0
>=20
> Bimmy Pujari (1):
> =C2=A0 i40e: removed no longer needed delays
>=20
> Carolyn Wyborny (1):
> =C2=A0 i40e: fix for queue timing delays
>=20
> Colin Ian King (1):
> =C2=A0 i40evf: dereference VSI after VSI has been null checked
>=20
> Harshitha Ramamurthy (1):
> =C2=A0 i40e: fix configuration of RSS table with DCB
>=20
> Jacob Keller (1):
> =C2=A0 i40e: initialize params before notifying of l2_param_changes
>=20
> Robert Konklewski (1):
> =C2=A0 i40e: Fixed race conditions in VF reset
>=20
> =C2=A0drivers/net/ethernet/intel/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=
=A0=C2=A011 -
> =C2=A0drivers/net/ethernet/intel/i40e/Makefile=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A01 -
> =C2=A0drivers/net/ethernet/intel/i40e/i40e.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A062 -----
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_client.c=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A02 +
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_common.c=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0|=C2=A0=C2=A027 --
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_debugfs.c=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0|=C2=A0=C2=A019 --
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_ethtool.c=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0|=C2=A0=C2=A035 ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0| 297 ++---------
> ----------
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_osdep.h=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A03 -
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_prototype.h=C2=A0=C2=A0=C2=A0|=
=C2=A0=C2=A0=C2=A03 -
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_txrx.c=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A060 ++---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_txrx.h=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A024 +-
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_type.h=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0| 138 ----------
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |=C2=A0=C2=A043 =
++-
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |=C2=A0=C2=A0=C2=
=A01 -
> =C2=A0drivers/net/ethernet/intel/i40evf/i40e_txrx.c=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0|=C2=A0=C2=A033 ++-
> =C2=A0drivers/net/ethernet/intel/i40evf/i40e_txrx.h=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0|=C2=A0=C2=A019 +-
> =C2=A0drivers/net/ethernet/intel/i40evf/i40evf_client.c=C2=A0=C2=A0|=C2=
=A0=C2=A0=C2=A09 +-
> =C2=A018 files changed, 114 insertions(+), 673 deletions(-)
>=20

--=-V1NA9v8ev5GX1EaQsj4b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAljZom8ACgkQ5W/vlVpL
7c6T+w/8DJ6WhKpuTPOac7G/npxtQj8mXZGZMHPew9yLoF/6yAvGK3wWfwCQynVs
G1mKh94yzy2wGgXWUSZZyGt2z+CWBereg5522NVHl6VQWh44pecJWqSfE0T/gRXR
GJKKjsC3vuYtETgTrDCkovDm1lSSm+w3QddoR372qu4l1197Dfa0MwVBRfzKVTNV
KvQPSTvvS8VTxRuvsmvKeOCIJO3ZLSnXscTMDWQjN992AfG1LKFNmE6nCn36Cnyy
NNLRaelHYz/dNXRRvwCOM20nX34ySVYL/9UAwPTSrMsFsqs7MsdqDbsXC4o4GYsO
q2We3gWYklGB94bm3c3fhUaeXcVTvdIPCfIJJDHjiwfSJdKksrcEZRkWFFp4jLjC
QNkj0R0SAY2QDA9WWiLhg8yJWkrbq1qqhqhXkstKsUM5Ku3iSWCiqkYGLW5urcAQ
3s8udQh8LVMafMG8eJ815Oamd8zkxrIZ824TZV+Ob9dqUDNKcxkP53e5NiRsq4FO
Kc7L7MmS+b/QWI5CgTa4X1FsmhQeQ869B1VtVr5q7xmqP0EDnagCr+x6OFFuxIpA
+t9O3EjsRLvMQtmNl2Ne7jHlpKbAMM0tjrE37VCXCbluXzw6Pbu3sJCWgOgrW6YX
RmrlfKaxnqAXyYtNy3xfYGHsQQy4SHYJeoFeJiP0FoStfaXIjfY=
=kzJH
-----END PGP SIGNATURE-----

--=-V1NA9v8ev5GX1EaQsj4b--
