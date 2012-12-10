From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: ixgbe:  pci_get_device() call without counterpart call of pci_dev_put()
Date: Sun, 09 Dec 2012 23:17:44 -0800
Message-ID: <50C58C98.2030509@gmail.com>
References: <01b301cdd5f2$3a9b2360$afd16a20$@toganetworks.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig72804A5186C375976B5AE300"
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	Greg Rose <gregory.v.rose@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: Elena Gurevich <elena.gurevich@toganetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18353 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910Ab2LJHRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 02:17:46 -0500
In-Reply-To: <01b301cdd5f2$3a9b2360$afd16a20$@toganetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig72804A5186C375976B5AE300
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/09/2012 01:47 AM, Elena Gurevich wrote:
> Hi all,
> I am pioneer in linux device drivers here and using Intel 82599 NIC as
> reference model,=20
> During investigation to drivers sources I found the suspicious code: =20
>
> Is code sequence (1)   and (2) the possible device reference count leak=
age
> ???
>
>
> Thanks a lot in advance
> Lena
>
> --------snipped from ixgbe_main.c  file function ixgbe_io_error_detecte=
d()
> -----------
>
> . . .=20
> 		/* Find the pci device of the offending VF */
> 		vfdev =3D pci_get_device(PCI_VENDOR_ID_INTEL, device_id,
> NULL);
> 		while (vfdev) {
> 			if (vfdev->devfn =3D=3D (req_id & 0xFF))
> 				break;
> <------------------------------      (1) leaves the loop with successfu=
l get
> call  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
>
> 			vfdev =3D pci_get_device(PCI_VENDOR_ID_INTEL,
> 					       device_id, vfdev);
> 		}
> 		/*
> 		 * There's a slim chance the VF could have been hot plugged,
> 		 * so if it is no longer present we don't need to issue the
> 		 * VFLR.  Just clean up the AER in that case.
> 		 */
> 		if (vfdev) {
> 			e_dev_err("Issuing VFLR to VF %d\n", vf);
> 			pci_write_config_dword(vfdev, 0xA8, 0x00008000);
> 		}
>
> 		pci_cleanup_aer_uncorrect_error_status(pdev);
> 	}
>
> 	/*
> 	 * Even though the error may have occurred on the other port
> 	 * we still need to increment the vf error reference count for
> 	 * both ports because the I/O resume function will be called
> 	 * for both of them.
> 	 */
> 	adapter->vferr_refcount++;
>
> 	return PCI_ERS_RESULT_RECOVERED;
> <--------------------------------------------  (2) leaves the function
> without put call !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
> ----------------------------------  snipped
> -----------------------------------
>
Added Greg Rose (ixgbevf maintainer) & Don Skidmore (ixgbe maintainer)

Since the code you have questions about is dealing with the vf, Greg
will most likely be able to shed some light to your questions.


--------------enig72804A5186C375976B5AE300
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJQxYyYAAoJEOVv75VaS+3OEgcP/RpOfIpiqvHMsLjNb0JEY9nK
1S1xIiYPuaxC15Q7abM5EUEm1GLdx4TV4Pc3m2kMTm+o+B3zu/Zd486rfpv1+LUo
rBIF1Kudo9bdAHo9GP5Mw49mbXYQm6INHq27vp1PCd+1y1L7XBCUbIY/bExVX7mo
f+BIrrNHvo87tdi5SV07FKQUuzM3RcHY4qCZKwvGLD2VJlTdPuw20RUKLHDNyz+m
IokyiRNZlc4DZFdrkWq1LS45Z3UK9XjMi4TL3s2u8IZNxVjVEpl/magk005vZE5v
0OVSpviws9GyGxk1FKllsMimBjoiDDISr7Qx3sm2x2QsChbQA23l2+DZ93ytAgha
fmhE39ZaEw13KnuUm0s37+6akAE57qw5S7EwfLduAgP99fBLMtmU/UIkjoyleaPk
gFSihadZkR1Hz4K60NOAe/nVpyS1g3P+Ja6mdTU2DV2n4zf+AUod3zQMYW2chvoR
nsFYaLMpsXG4Jtoi9PSdfU7MWOaYLgrsAdhZb5aicqqETj3cDarRai+cmC87gG2p
7E6a8EQcuqPqIf4KuLG7k8tvBs7y9GA5tt/5FGtNOwhXgGHFnFCDIMe7GSjH6Uzt
nZO5DiQ6MWdjwpj4g1z6w8jRzFxJwYKXWPddBxQ66ltNBKO+DOMMOzSUG0Ttldva
ips560usY2/hHc+XommQ
=+Nky
-----END PGP SIGNATURE-----

--------------enig72804A5186C375976B5AE300--
