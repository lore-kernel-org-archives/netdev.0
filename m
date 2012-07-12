From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH] ixgbevf - Prevent RX/TX statistics getting reset to zero
Date: Thu, 12 Jul 2012 11:26:18 -0700
Message-ID: <4FFF16CA.1090705@gmail.com>
References: <E31FB011129F30488D5861F38390491520D00B9F01@BLRX7MCDC201.AMER.DELL.COM>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigD00488C33B21AF8E2931FFE2"
Cc: netdev@vger.kernel.org
To: Narendra_K@Dell.com, gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3710 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932690Ab2GLS0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 14:26:19 -0400
In-Reply-To: <E31FB011129F30488D5861F38390491520D00B9F01@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD00488C33B21AF8E2931FFE2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/12/2012 06:55 AM, Narendra_K@Dell.com wrote:
> Hello,
>
> [Apologies if you are receiving this message twice. I am resending the =
message, as I got message delivery failure note].
>
> While exploring SR-IOV on Intel 82599EB 10-Gigabit SFP+ adapter, I had =
the following observation.  I enabled two VFs by passing 'max_vfs=3D2' to=
 ixgbe driver. One of the VFs was assigned to a guest.
> In the guest, the ifconfig and ip tools reported 'RX packets' and 'TX p=
ackets' as zero, after pinging to a remote host. Looking into it further,=
 the commit 4197aa7bb81877ebb06e4f2cc1b5fea2da23a7bd implements 64 bit pe=
r ring statistics. It seemed like the 'total_bytes' and 'total_packets' o=
f RX and TX ring were being reset to zero by the RX and TX interrupt hand=
lers, resulting in the user space tools reporting zero RX and TX bytes.=20
>
> The attached patch addresses the issue by preventing the resetting of R=
X and TX ring statistics to zero. The patch was taken against latest main=
line 3.5-rc6 kernel.
>
> I tested the patch by pinging  from the guest OS to a remote host.
>
> ping -f <remote host> -c 10000
>
> The ip and ifcofig showed the statistics increased by 10000 packets. =20
>
> # lspci | grep 82599
> 04:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFP+ =
Network Connection (rev 01)
> 04:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFP+ =
Network Connection (rev 01)
> 04:10.0 Ethernet controller: Intel Corporation 82599 Ethernet Controlle=
r Virtual Function (rev 01)
> 04:10.1 Ethernet controller: Intel Corporation 82599 Ethernet Controlle=
r Virtual Function (rev 01)
> 04:10.2 Ethernet controller: Intel Corporation 82599 Ethernet Controlle=
r Virtual Function (rev 01)
> 04:10.3 Ethernet controller: Intel Corporation 82599 Ethernet Controlle=
r Virtual Function (rev 01)
>
> # lspci -s 04:00.0 -n
> 04:00.0 0200: 8086:154d (rev 01)
> # lspci -s 04:10.0 -n
> 04:10.0 0200: 8086:10ed (rev 01)=20
>
> Please let me know if additional details and logs are required.=20
>
> With regards,
> Narendra K
>
>
>

Thanks, I will add the patch to my queue



--------------enigD00488C33B21AF8E2931FFE2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJP/xbKAAoJEOVv75VaS+3O1eIQAJ664yhU1HvX6ZNeIB3ly8wZ
ZoWGBLNvgRFA7vl4ee4GOPJmEAMfbPRf7cZGF3pfnbtbOpI+zphrQuaNY9ftHhdi
Hp3hCd4S1fOUawKRlfYeYQG+sZEeLMNA76hefcgNBjxceJW5mUc7rTKx2G02IejJ
uZCC2O6uBfLdh97mm/MnWs5zRBpQzfwcJfybHGmV/2jKXiRrt9E3b7eKm+ONUmwb
6cl0cwiEbzasTR6+gHRNkRLcznWVc9wBEv0nBrjwvFzs23V1tJ6dntYWG6Zn3PbI
RctNGLJGdRsgA2L5+Sk5czFO6Nb+qlNGgKVThIiyyU6hC37vO+I+SYmYplSu1Vq0
tE1nuyEQfX3ySub8kYx1KWxSAHRKPCGAblST1rON90cIr07nGYybX5Ph9nDjU1Km
jhE5Osm14ayPYnIshCeM8ueFwA2I4zINbswdF/2wdiQsvv6Tvo7LM/CBIh/M+c/F
MurSk+UBT89kLngi+uFWNkm/37VWamIZboC6DmpRsupD6zygQWEenuR27L0TIjoe
dNvZsr6cF7obGR5JgbPH+thFilDBqEh2vp4z5Rv5NCVx9K3CIZdZlGYUrYsdGXoC
JoVEQqovnibl5GkGY0n7jhJr4BAcwfK12rc7Z1h7r1852vjPm3XjvieFOVXgcGZB
W5Omqaq1U8kxqG9lfO4v
=oa+C
-----END PGP SIGNATURE-----

--------------enigD00488C33B21AF8E2931FFE2--
