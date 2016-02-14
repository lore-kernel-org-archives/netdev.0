From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V4 4/8] net/ethtool: support get coalesce per queue
Date: Sun, 14 Feb 2016 18:47:57 +0000
Message-ID: <1455475677.2801.142.camel@decadent.org.uk>
References: <1454917540-10648-1-git-send-email-kan.liang@intel.com>
	 <1454917540-10648-5-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vIY5IRMO82ewy/p08vND"
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com
To: Kan Liang <kan.liang@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58067 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751010AbcBNSsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2016 13:48:15 -0500
In-Reply-To: <1454917540-10648-5-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vIY5IRMO82ewy/p08vND
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-08 at 02:45 -0500, Kan Liang wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> This patch implements sub command ETHTOOL_GCOALESCE for ioctl
> ETHTOOL_PERQUEUE. It introduces an interface get_per_queue_coalesce to
> get coalesce of each masked queue from device driver. Then the interrupt
> coalescing parameters will be copied back to user space one by one.
>=20
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
> =C2=A0include/linux/ethtool.h | 10 +++++++++-
> =C2=A0net/core/ethtool.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 34 ++++++++=
+++++++++++++++++++++++++-
> =C2=A02 files changed, 42 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 653dc9c..a83566f 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -201,6 +201,13 @@ static inline u32 ethtool_rxfh_indir_default(u32 ind=
ex, u32 n_rx_rings)
> =C2=A0 * @get_module_eeprom: Get the eeprom information from the plug-in =
module
> =C2=A0 * @get_eee: Get Energy-Efficient (EEE) supported and status.
> =C2=A0 * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
> + * @get_per_queue_coalesce: Get interrupt coalescing parameters per queu=
e.
> + *	It needs to do range check for the input queue number. Only if
> + *	neither RX nor TX queue number is in the range, a negative error code
> + *	returns. For the case that only RX or only TX is not in the range,
> + *	zero should return. But related unavailable fields should be set to ~=
0,
> + *	which indicates RX or TX is not in the range.

This is poorly worded. =C2=A0I suggest:

"It must check that the given queue number=C2=A0is valid. If neither a RX
nor a TX queue has this number, return -EINVAL. If only a RX queue or a
TX queue has this number, set the inapplicable fields to ~0 and return
0."

> + *	Returns a negative error code or zero.
> =C2=A0 *
> =C2=A0 * All operations are optional (i.e. the function pointer may be se=
t
> =C2=A0 * to %NULL) and callers must take this into account.=C2=A0=C2=A0Ca=
llers must
> @@ -279,7 +286,8 @@ struct ethtool_ops {
> =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0const struct ethtool_t=
unable *, void *);
> =C2=A0	int	(*set_tunable)(struct net_device *,
> =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0const struct ethtool_t=
unable *, const void *);
> -
> +	int	(*get_per_queue_coalesce)(struct net_device *, int,
> +					=C2=A0=C2=A0struct ethtool_coalesce *);
[...]

Please change the queue number to be unsigned, so driver authors don't
need to consider whether they need to check for negative values.

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
--=-vIY5IRMO82ewy/p08vND
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsDL3ee/yOyVhhEJAQr/MRAAhD2AYZldzH9XvgIZZ2QNrCRodJE4da1o
EBM6MvbUIasDYt6OMwizfRZTZYhV9+I79g3N+dzKtf2WRiCSu1uN1zV0zlyldkLG
OglvaGicmoJtWzWyVFvp37qr1B7JL4d73v6XFrr9F3yPAGgj1tLbRJN7aodmuOBu
kfuvlXblKMssp4oaXtp+e0kyV7IbJ2kQHdQXrknR3Ugp3i1vqCLS7zqah9WiIC+w
F7B/H1sVyP4D+VcLZmUi7gc/rzq6Zszq0KnZ+xk4wCFdyqgx/JSBoXmWfpOuQrob
iki3LuCuhSNqkwED6O9Fciy1k9yTxR7I1RgW3HBkJ1WL/JQgSwERMtcZcj+kRUUG
78o97yqOAKLTTatPAfQ1bw4ETEoALog2BrX1l+ynYzfQdqIznwAhNtJr20LJix4O
rlVkMle9x9FKSPsX9h5OEy8F+s9y4ifIX9mWRP24kp0UyPGqZqtaT6loEO6OnKac
rzOCQ8WLzweYKoJQ+RdpcpcW3R1GawhC0G0xxlGVrCPsKhZYw9mLVkhcP6KZWLDk
ffZRIwoSl6j/MZUtBdBjuP6L/kUNqH/saIEV3EPmB7/ICq4kMOMQMSj52+NuC51w
1qY561Gb0yGHU0fPqbb0pKVWjr6MQEnt3JrhoVI0dYAdenbcxTi1I6tB2ahlL40P
bQk37umyhTQ=
=0XU+
-----END PGP SIGNATURE-----

--=-vIY5IRMO82ewy/p08vND--
