From: Ami Hadas <ami@tehutinetworks.net>
Subject: RE: Support for 2500BaseT and 5000BaseT patch
Date: Sun, 19 Feb 2017 08:11:46 +0000
Message-ID: <PS1PR0201MB1657CEFB9A85FE98B58EE6D7D25F0@PS1PR0201MB1657.apcprd02.prod.outlook.com>
References: <PS1PR0201MB1657688F726DABE0ED9A17F6D25B0@PS1PR0201MB1657.apcprd02.prod.outlook.com>
 <20170217144213.GB4284@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_002_PS1PR0201MB1657CEFB9A85FE98B58EE6D7D25F0PS1PR0201MB1657_"
Cc: Nir Sever <nir@tehutinetworks.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sg2apc01on0126.outbound.protection.outlook.com ([104.47.125.126]:3398
        "EHLO APC01-SG2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750760AbdBSIMA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 03:12:00 -0500
In-Reply-To: <20170217144213.GB4284@tuxdriver.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_PS1PR0201MB1657CEFB9A85FE98B58EE6D7D25F0PS1PR0201MB1657_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

OK,

Here it is again.

Thanks,
Ami

-----Original Message-----
From: John W. Linville [mailto:linville@tuxdriver.com]=20
Sent: Friday, February 17, 2017 4:42 PM
To: Ami Hadas <ami@tehutinetworks.net>
Subject: Re: Support for 2500BaseT and 5000BaseT patch

Well, I think the patch looks fine. But I will have to ask you to post it p=
ublicly to the netdev@vger.kernel.org mailing list.

Thanks,

John

On Wed, Feb 15, 2017 at 02:37:02PM +0000, Ami Hadas wrote:
> Hi,
>=20
>=20
> Here is the patch:
>=20
>=20
> The ethtool-copy.h is a copy of include/uapi/linux/ethtool.h from
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git which al=
ready include the new speeds.
>=20
>=20
> Ami
>=20

> From 7cc0357de4f5867be164afa917beff57c8094495 Mon Sep 17 00:00:00 2001
> From: tehuti <ami@tehutinetworks.net>
> Date: Wed, 15 Feb 2017 16:00:54 +0200
> Subject: [PATCH] Add support for 2500BaseT and 5000BaseT link modes=20
> according  to  IEEE 802.3bz standard.
> Signed-off-by: Ami Hadas  <ami@tehutinetworks.net>
>=20
> ---
>  ethtool-copy.h | 24 ++++++++++++++----------
>  ethtool.c      |  4 ++++
>  2 files changed, 18 insertions(+), 10 deletions(-)
>=20
> diff --git a/ethtool-copy.h b/ethtool-copy.h index 3d299e3..3dc91a4=20
> 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -10,14 +10,16 @@
>   * Portions Copyright (C) Sun Microsystems 2008
>   */
> =20
> -#ifndef _LINUX_ETHTOOL_H
> -#define _LINUX_ETHTOOL_H
> +#ifndef _UAPI_LINUX_ETHTOOL_H
> +#define _UAPI_LINUX_ETHTOOL_H
> =20
>  #include <linux/kernel.h>
>  #include <linux/types.h>
>  #include <linux/if_ether.h>
> =20
> +#ifndef __KERNEL__
>  #include <limits.h> /* for INT_MAX */
> +#endif
> =20
>  /* All structures exposed to userland should be defined such that they
>   * have the same layout for 32-bit and 64-bit userland.
> @@ -114,14 +116,14 @@ struct ethtool_cmd {
>  	__u32	reserved[2];
>  };
> =20
> -static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
> +static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
>  					 __u32 speed)
>  {
>  	ep->speed =3D (__u16)(speed & 0xFFFF);
>  	ep->speed_hi =3D (__u16)(speed >> 16);  }
> =20
> -static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd=20
> *ep)
> +static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
>  {
>  	return (ep->speed_hi << 16) | ep->speed;  } @@ -892,12 +894,12 @@=20
> struct ethtool_rx_flow_spec {
>  #define ETHTOOL_RX_FLOW_SPEC_RING	0x00000000FFFFFFFFLL
>  #define ETHTOOL_RX_FLOW_SPEC_RING_VF	0x000000FF00000000LL
>  #define ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF 32 -static __inline__ __u64=20
> ethtool_get_flow_spec_ring(__u64 ring_cookie)
> +static inline __u64 ethtool_get_flow_spec_ring(__u64 ring_cookie)
>  {
>  	return ETHTOOL_RX_FLOW_SPEC_RING & ring_cookie;  };
> =20
> -static __inline__ __u64 ethtool_get_flow_spec_ring_vf(__u64=20
> ring_cookie)
> +static inline __u64 ethtool_get_flow_spec_ring_vf(__u64 ring_cookie)
>  {
>  	return (ETHTOOL_RX_FLOW_SPEC_RING_VF & ring_cookie) >>
>  				ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF; @@ -1382,6 +1384,8 @@ enum=20
> ethtool_link_mode_bit_indices {
>  	ETHTOOL_LINK_MODE_10000baseLR_Full_BIT	=3D 44,
>  	ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT	=3D 45,
>  	ETHTOOL_LINK_MODE_10000baseER_Full_BIT	=3D 46,
> +	ETHTOOL_LINK_MODE_2500baseT_Full_BIT	=3D 47,
> +	ETHTOOL_LINK_MODE_5000baseT_Full_BIT	=3D 48,
> =20
> =20
>  	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit @@=20
> -1391,7 +1395,7 @@ enum ethtool_link_mode_bit_indices {
>  	 */
> =20
>  	__ETHTOOL_LINK_MODE_LAST
> -	  =3D ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
> +	  =3D ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
>  };
> =20
>  #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
> @@ -1498,7 +1502,7 @@ enum ethtool_link_mode_bit_indices {
> =20
>  #define SPEED_UNKNOWN		-1
> =20
> -static __inline__ int ethtool_validate_speed(__u32 speed)
> +static inline int ethtool_validate_speed(__u32 speed)
>  {
>  	return speed <=3D INT_MAX || speed =3D=3D SPEED_UNKNOWN;  } @@ -1508,7=
=20
> +1512,7 @@ static __inline__ int ethtool_validate_speed(__u32 speed)
>  #define DUPLEX_FULL		0x01
>  #define DUPLEX_UNKNOWN		0xff
> =20
> -static __inline__ int ethtool_validate_duplex(__u8 duplex)
> +static inline int ethtool_validate_duplex(__u8 duplex)
>  {
>  	switch (duplex) {
>  	case DUPLEX_HALF:
> @@ -1758,4 +1762,4 @@ struct ethtool_link_settings {
>  	 * __u32 map_lp_advertising[link_mode_masks_nwords];
>  	 */
>  };
> -#endif /* _LINUX_ETHTOOL_H */
> +#endif /* _UAPI_LINUX_ETHTOOL_H */
> diff --git a/ethtool.c b/ethtool.c
> index 7af039e..b36d40e 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -681,6 +681,10 @@ static void dump_link_caps(const char *prefix, const=
 char *an_prefix,
>  		  "10000baseLRM/Full" },
>  		{ 0, ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
>  		  "10000baseER/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_2500baseT_Full_BIT,
> +		  "2500baseT/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
> +		  "5000baseT/Full" },
>  	};
>  	int indent;
>  	int did1, new_line_pend, i;
> --
> 2.7.4
>=20


--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--_002_PS1PR0201MB1657CEFB9A85FE98B58EE6D7D25F0PS1PR0201MB1657_
Content-Type: application/octet-stream;
	name="0001-Add-support-for-2500BaseT-and-5000BaseT-link-modes-a.patch"
Content-Description: 0001-Add-support-for-2500BaseT-and-5000BaseT-link-modes-a.patch
Content-Disposition: attachment;
	filename="0001-Add-support-for-2500BaseT-and-5000BaseT-link-modes-a.patch";
	size=4023; creation-date="Wed, 15 Feb 2017 14:36:26 GMT";
	modification-date="Wed, 15 Feb 2017 14:37:03 GMT"
Content-Transfer-Encoding: base64

RnJvbSA3Y2MwMzU3ZGU0ZjU4NjdiZTE2NGFmYTkxN2JlZmY1N2M4MDk0NDk1IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiB0ZWh1dGkgPGFtaUB0ZWh1dGluZXR3b3Jrcy5uZXQ+CkRhdGU6
IFdlZCwgMTUgRmViIDIwMTcgMTY6MDA6NTQgKzAyMDAKU3ViamVjdDogW1BBVENIXSBBZGQgc3Vw
cG9ydCBmb3IgMjUwMEJhc2VUIGFuZCA1MDAwQmFzZVQgbGluayBtb2RlcyBhY2NvcmRpbmcKIHRv
ICBJRUVFIDgwMi4zYnogc3RhbmRhcmQuClNpZ25lZC1vZmYtYnk6IEFtaSBIYWRhcyAgPGFtaUB0
ZWh1dGluZXR3b3Jrcy5uZXQ+CgotLS0KIGV0aHRvb2wtY29weS5oIHwgMjQgKysrKysrKysrKysr
KystLS0tLS0tLS0tCiBldGh0b29sLmMgICAgICB8ICA0ICsrKysKIDIgZmlsZXMgY2hhbmdlZCwg
MTggaW5zZXJ0aW9ucygrKSwgMTAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZXRodG9vbC1j
b3B5LmggYi9ldGh0b29sLWNvcHkuaAppbmRleCAzZDI5OWUzLi4zZGM5MWE0IDEwMDY0NAotLS0g
YS9ldGh0b29sLWNvcHkuaAorKysgYi9ldGh0b29sLWNvcHkuaApAQCAtMTAsMTQgKzEwLDE2IEBA
CiAgKiBQb3J0aW9ucyBDb3B5cmlnaHQgKEMpIFN1biBNaWNyb3N5c3RlbXMgMjAwOAogICovCiAK
LSNpZm5kZWYgX0xJTlVYX0VUSFRPT0xfSAotI2RlZmluZSBfTElOVVhfRVRIVE9PTF9ICisjaWZu
ZGVmIF9VQVBJX0xJTlVYX0VUSFRPT0xfSAorI2RlZmluZSBfVUFQSV9MSU5VWF9FVEhUT09MX0gK
IAogI2luY2x1ZGUgPGxpbnV4L2tlcm5lbC5oPgogI2luY2x1ZGUgPGxpbnV4L3R5cGVzLmg+CiAj
aW5jbHVkZSA8bGludXgvaWZfZXRoZXIuaD4KIAorI2lmbmRlZiBfX0tFUk5FTF9fCiAjaW5jbHVk
ZSA8bGltaXRzLmg+IC8qIGZvciBJTlRfTUFYICovCisjZW5kaWYKIAogLyogQWxsIHN0cnVjdHVy
ZXMgZXhwb3NlZCB0byB1c2VybGFuZCBzaG91bGQgYmUgZGVmaW5lZCBzdWNoIHRoYXQgdGhleQog
ICogaGF2ZSB0aGUgc2FtZSBsYXlvdXQgZm9yIDMyLWJpdCBhbmQgNjQtYml0IHVzZXJsYW5kLgpA
QCAtMTE0LDE0ICsxMTYsMTQgQEAgc3RydWN0IGV0aHRvb2xfY21kIHsKIAlfX3UzMglyZXNlcnZl
ZFsyXTsKIH07CiAKLXN0YXRpYyBfX2lubGluZV9fIHZvaWQgZXRodG9vbF9jbWRfc3BlZWRfc2V0
KHN0cnVjdCBldGh0b29sX2NtZCAqZXAsCitzdGF0aWMgaW5saW5lIHZvaWQgZXRodG9vbF9jbWRf
c3BlZWRfc2V0KHN0cnVjdCBldGh0b29sX2NtZCAqZXAsCiAJCQkJCSBfX3UzMiBzcGVlZCkKIHsK
IAllcC0+c3BlZWQgPSAoX191MTYpKHNwZWVkICYgMHhGRkZGKTsKIAllcC0+c3BlZWRfaGkgPSAo
X191MTYpKHNwZWVkID4+IDE2KTsKIH0KIAotc3RhdGljIF9faW5saW5lX18gX191MzIgZXRodG9v
bF9jbWRfc3BlZWQoY29uc3Qgc3RydWN0IGV0aHRvb2xfY21kICplcCkKK3N0YXRpYyBpbmxpbmUg
X191MzIgZXRodG9vbF9jbWRfc3BlZWQoY29uc3Qgc3RydWN0IGV0aHRvb2xfY21kICplcCkKIHsK
IAlyZXR1cm4gKGVwLT5zcGVlZF9oaSA8PCAxNikgfCBlcC0+c3BlZWQ7CiB9CkBAIC04OTIsMTIg
Kzg5NCwxMiBAQCBzdHJ1Y3QgZXRodG9vbF9yeF9mbG93X3NwZWMgewogI2RlZmluZSBFVEhUT09M
X1JYX0ZMT1dfU1BFQ19SSU5HCTB4MDAwMDAwMDBGRkZGRkZGRkxMCiAjZGVmaW5lIEVUSFRPT0xf
UlhfRkxPV19TUEVDX1JJTkdfVkYJMHgwMDAwMDBGRjAwMDAwMDAwTEwKICNkZWZpbmUgRVRIVE9P
TF9SWF9GTE9XX1NQRUNfUklOR19WRl9PRkYgMzIKLXN0YXRpYyBfX2lubGluZV9fIF9fdTY0IGV0
aHRvb2xfZ2V0X2Zsb3dfc3BlY19yaW5nKF9fdTY0IHJpbmdfY29va2llKQorc3RhdGljIGlubGlu
ZSBfX3U2NCBldGh0b29sX2dldF9mbG93X3NwZWNfcmluZyhfX3U2NCByaW5nX2Nvb2tpZSkKIHsK
IAlyZXR1cm4gRVRIVE9PTF9SWF9GTE9XX1NQRUNfUklORyAmIHJpbmdfY29va2llOwogfTsKIAot
c3RhdGljIF9faW5saW5lX18gX191NjQgZXRodG9vbF9nZXRfZmxvd19zcGVjX3JpbmdfdmYoX191
NjQgcmluZ19jb29raWUpCitzdGF0aWMgaW5saW5lIF9fdTY0IGV0aHRvb2xfZ2V0X2Zsb3dfc3Bl
Y19yaW5nX3ZmKF9fdTY0IHJpbmdfY29va2llKQogewogCXJldHVybiAoRVRIVE9PTF9SWF9GTE9X
X1NQRUNfUklOR19WRiAmIHJpbmdfY29va2llKSA+PgogCQkJCUVUSFRPT0xfUlhfRkxPV19TUEVD
X1JJTkdfVkZfT0ZGOwpAQCAtMTM4Miw2ICsxMzg0LDggQEAgZW51bSBldGh0b29sX2xpbmtfbW9k
ZV9iaXRfaW5kaWNlcyB7CiAJRVRIVE9PTF9MSU5LX01PREVfMTAwMDBiYXNlTFJfRnVsbF9CSVQJ
PSA0NCwKIAlFVEhUT09MX0xJTktfTU9ERV8xMDAwMGJhc2VMUk1fRnVsbF9CSVQJPSA0NSwKIAlF
VEhUT09MX0xJTktfTU9ERV8xMDAwMGJhc2VFUl9GdWxsX0JJVAk9IDQ2LAorCUVUSFRPT0xfTElO
S19NT0RFXzI1MDBiYXNlVF9GdWxsX0JJVAk9IDQ3LAorCUVUSFRPT0xfTElOS19NT0RFXzUwMDBi
YXNlVF9GdWxsX0JJVAk9IDQ4LAogCiAKIAkvKiBMYXN0IGFsbG93ZWQgYml0IGZvciBfX0VUSFRP
T0xfTElOS19NT0RFX0xFR0FDWV9NQVNLIGlzIGJpdApAQCAtMTM5MSw3ICsxMzk1LDcgQEAgZW51
bSBldGh0b29sX2xpbmtfbW9kZV9iaXRfaW5kaWNlcyB7CiAJICovCiAKIAlfX0VUSFRPT0xfTElO
S19NT0RFX0xBU1QKLQkgID0gRVRIVE9PTF9MSU5LX01PREVfMTAwMDBiYXNlRVJfRnVsbF9CSVQs
CisJICA9IEVUSFRPT0xfTElOS19NT0RFXzUwMDBiYXNlVF9GdWxsX0JJVCwKIH07CiAKICNkZWZp
bmUgX19FVEhUT09MX0xJTktfTU9ERV9MRUdBQ1lfTUFTSyhiYXNlX25hbWUpCVwKQEAgLTE0OTgs
NyArMTUwMiw3IEBAIGVudW0gZXRodG9vbF9saW5rX21vZGVfYml0X2luZGljZXMgewogCiAjZGVm
aW5lIFNQRUVEX1VOS05PV04JCS0xCiAKLXN0YXRpYyBfX2lubGluZV9fIGludCBldGh0b29sX3Zh
bGlkYXRlX3NwZWVkKF9fdTMyIHNwZWVkKQorc3RhdGljIGlubGluZSBpbnQgZXRodG9vbF92YWxp
ZGF0ZV9zcGVlZChfX3UzMiBzcGVlZCkKIHsKIAlyZXR1cm4gc3BlZWQgPD0gSU5UX01BWCB8fCBz
cGVlZCA9PSBTUEVFRF9VTktOT1dOOwogfQpAQCAtMTUwOCw3ICsxNTEyLDcgQEAgc3RhdGljIF9f
aW5saW5lX18gaW50IGV0aHRvb2xfdmFsaWRhdGVfc3BlZWQoX191MzIgc3BlZWQpCiAjZGVmaW5l
IERVUExFWF9GVUxMCQkweDAxCiAjZGVmaW5lIERVUExFWF9VTktOT1dOCQkweGZmCiAKLXN0YXRp
YyBfX2lubGluZV9fIGludCBldGh0b29sX3ZhbGlkYXRlX2R1cGxleChfX3U4IGR1cGxleCkKK3N0
YXRpYyBpbmxpbmUgaW50IGV0aHRvb2xfdmFsaWRhdGVfZHVwbGV4KF9fdTggZHVwbGV4KQogewog
CXN3aXRjaCAoZHVwbGV4KSB7CiAJY2FzZSBEVVBMRVhfSEFMRjoKQEAgLTE3NTgsNCArMTc2Miw0
IEBAIHN0cnVjdCBldGh0b29sX2xpbmtfc2V0dGluZ3MgewogCSAqIF9fdTMyIG1hcF9scF9hZHZl
cnRpc2luZ1tsaW5rX21vZGVfbWFza3NfbndvcmRzXTsKIAkgKi8KIH07Ci0jZW5kaWYgLyogX0xJ
TlVYX0VUSFRPT0xfSCAqLworI2VuZGlmIC8qIF9VQVBJX0xJTlVYX0VUSFRPT0xfSCAqLwpkaWZm
IC0tZ2l0IGEvZXRodG9vbC5jIGIvZXRodG9vbC5jCmluZGV4IDdhZjAzOWUuLmIzNmQ0MGUgMTAw
NjQ0Ci0tLSBhL2V0aHRvb2wuYworKysgYi9ldGh0b29sLmMKQEAgLTY4MSw2ICs2ODEsMTAgQEAg
c3RhdGljIHZvaWQgZHVtcF9saW5rX2NhcHMoY29uc3QgY2hhciAqcHJlZml4LCBjb25zdCBjaGFy
ICphbl9wcmVmaXgsCiAJCSAgIjEwMDAwYmFzZUxSTS9GdWxsIiB9LAogCQl7IDAsIEVUSFRPT0xf
TElOS19NT0RFXzEwMDAwYmFzZUVSX0Z1bGxfQklULAogCQkgICIxMDAwMGJhc2VFUi9GdWxsIiB9
LAorCQl7IDAsIEVUSFRPT0xfTElOS19NT0RFXzI1MDBiYXNlVF9GdWxsX0JJVCwKKwkJICAiMjUw
MGJhc2VUL0Z1bGwiIH0sCisJCXsgMCwgRVRIVE9PTF9MSU5LX01PREVfNTAwMGJhc2VUX0Z1bGxf
QklULAorCQkgICI1MDAwYmFzZVQvRnVsbCIgfSwKIAl9OwogCWludCBpbmRlbnQ7CiAJaW50IGRp
ZDEsIG5ld19saW5lX3BlbmQsIGk7Ci0tIAoyLjcuNAoK

--_002_PS1PR0201MB1657CEFB9A85FE98B58EE6D7D25F0PS1PR0201MB1657_--
