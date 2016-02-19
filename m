From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH V7 0/8] ethtool per queue parameters support
Date: Fri, 19 Feb 2016 13:50:18 -0800
Message-ID: <1455918618.3016.36.camel@intel.com>
References: <1455891846-12271-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1eCrVoVFGLDN8RUwXTru"
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, mitch.a.williams@intel.com,
	ogerlitz@mellanox.com, edumazet@google.com, jiri@mellanox.com,
	sfeldma@gmail.com, gospo@cumulusnetworks.com,
	sasha.levin@oracle.com, dsahern@gmail.com, tj@kernel.org,
	cascardo@redhat.com, corbet@lwn.net, decot@googlers.com
To: Kan Liang <kan.liang@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bwh@kernel.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:9818 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030331AbcBSVuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 16:50:35 -0500
In-Reply-To: <1455891846-12271-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1eCrVoVFGLDN8RUwXTru
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-19 at 09:23 -0500, Kan Liang wrote:
> Modern network interface controllers usually support multiple receive
> and transmit queues. Each queue may have its own parameters. For
> example, Intel XL710/X710 hardware supports per queue interrupt
> moderation. However, current ethtool does not support per queue
> parameters option. User has to set parameters for the whole NIC.
> This series extends ethtool to support per queue parameters option.
>=20
> Since the support of per queue parameters vary with different cards,
> it is impossible to address all cards in one patch. This series only
> supports per queue coalesce options on i40e driver. The framework
> used
> in the patch can be easily extended to other cards and parameters.
>=20
> The lib bitmap needs to be extended to facilitate exchanging queue
> bitmaps
> between user space and kernel space. Two patches from David's latest
> V8
> patch series are also cited in this series. You may refer to
> https://lkml.org/lkml/2016/2/9/919=C2=A0for more details.
>=20
> Changes since V6:
> =C2=A0- Rebase on commit 76d13b568776. Did minor change in patch 6.
>=20
> Changes since V5:
> =C2=A0- Add test_bitmap.c and bitmap.sh in the series. They are forgot
> =C2=A0=C2=A0 to be added previously.
> =C2=A0- Update the first two patches to David's latest V8 version. The
> changes
> =C2=A0=C2=A0 include
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 - bitmap u32 API returns number of bits co=
pied, unit tests
> updated
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 - module_exit in test_bitmap
> =C2=A0- Also change the mode of bitmap.sh to 755 according to Ben's
> suggestion
>=20
> Changes since V4:
> =C2=A0- Modify set/get_per_queue_coalesce function description
> =C2=A0- Change the queue number to be u32
> =C2=A0- Correct an error of calculating coalesce backup buffer address
> =C2=A0- Rename queue_num to n_queues
> =C2=A0- Don't log error message in __i40e_get_coalesce
>=20
> Changes since V3:
> =C2=A0- Based on David's lib bitmap.
> =C2=A0- ETHTOOL_PERQUEUE should be handled before the containing switch
> =C2=A0- Make the rollback code unconditional
> =C2=A0- some minor changes according to Ben's feedback
>=20
> Changes since V2:
> =C2=A0- Add queue-specific settings for interrupt moderation in i40e
>=20
> Changes since V1:
> =C2=A0- Checking the sub-command number to determine whether the command
> =C2=A0=C2=A0 requires CAP_NET_ADMIN
> =C2=A0- Refine the struct ethtool_per_queue_op and improve the comments
> =C2=A0- Use bitmap functions to parse queue mask
> =C2=A0- Improve comments
> =C2=A0- Use bitmap functions to parse queue mask
> =C2=A0- Improve comments
> =C2=A0- Add rollback support
> =C2=A0- Correct the way to find the vector for specific queue.
>=20
> David Decotigny (2):
> =C2=A0 lib/bitmap.c: conversion routines to/from u32 array
> =C2=A0 test_bitmap: unit tests for lib/bitmap.c
>=20
> Kan Liang (6)
> =C2=A0 net/ethtool: introduce a new ioctl for per queue setting
> =C2=A0 net/ethtool: support get coalesce per queue
> =C2=A0 net/ethtool: support set coalesce per queue
> =C2=A0 i40e: queue-specific settings for interrupt moderation
> =C2=A0 i40e/ethtool: support coalesce getting by queue
> =C2=A0 i40e/ethtool: support coalesce setting by queue
>=20
> =C2=A0drivers/net/ethernet/intel/i40e/i40e.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0 7 -
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_debugfs.c |=C2=A0 15 +-
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 151 +++++++----
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c=C2=A0=C2=A0=C2=A0 |=C2=
=A0 12 +-
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_txrx.c=C2=A0=C2=A0=C2=A0 |=C2=
=A0=C2=A0 9 +-
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_txrx.h=C2=A0=C2=A0=C2=A0 |=C2=
=A0=C2=A0 8 +

Dave, I have pretty much cleared out my i40e queue of patches, so I am
fine if you want to apply the entire series (of course after proper
review) :-)
--=-1eCrVoVFGLDN8RUwXTru
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWx44bAAoJEOVv75VaS+3OXD0P/0liN6DCN1ira9T1L4RI6/PY
3A5LdLAi7DjXHiKOucxPOlBrZCX8wHqnJ09hc8n873Sy9YAJ5LKxnnMjsJBoRBWK
SoDfI0fxl5vZ3O2iOzcRZ4YLT7ke39YH49SbLwdj0y9VlzBwXuDOuXRQki2fnGr3
1frWcWqM8Pzk1DPICADiN4cq848s82Sy1789K5TSVk+HZecqI/zSJg4hCt+i8JJb
jUmKdylv/KleArB/Ha9YMqzKy1NaGFNhmq8dmCxfot6cl2uo1cM2MsKO1hJ/1/KN
3oENE3cKC6BxVNvzFFtkK/X7OcHHYoCaPeXbIaMx8E750gOSmhpG+gxsNKb2lRdK
W9fV9Zm7iH5GlHfoUdLteMqzbHdlnUtO60XWkBmRRDLNk8LUrV8/YPZShc7trxaR
uMw+TuapjVjj9BIi8A4Ykx3oh1uGiTpWEuDHD3qliksHp2cO9XOvvUpOOwSWWsRG
JZTnf3shMAXlVn2xeJLU0Yku8seFUaS2HY7U8OzCokkuRaWLUJMpqwrJzD8YNvdZ
I4lyTwizwmryexRxqI/vfVHCTHOTd2jS79FCacUe8kcvuZWfL+0Q0hY+Sv85Sos2
Bl3e45WJgQQVviSUTIDsfnLgtnwlJNFbdY0VUsutj9ixEG+85gEo/MGq8zoCTke9
kTHsCFB3HSwKCDEHvNLj
=1BP6
-----END PGP SIGNATURE-----

--=-1eCrVoVFGLDN8RUwXTru--
