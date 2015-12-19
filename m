From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC 3/5] net/ethtool: support set coalesce per queue
Date: Sat, 19 Dec 2015 03:38:55 +0000
Message-ID: <1450496335.30687.15.camel@decadent.org.uk>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
	 <1450335081-3012-3-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-eiNdG6x5CXNagDlEG81S"
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net
To: kan.liang@intel.com, netdev@vger.kernel.org, davem@davemloft.net,
	bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53558 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752780AbbLSDjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 22:39:01 -0500
In-Reply-To: <1450335081-3012-3-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eiNdG6x5CXNagDlEG81S
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-12-17 at 06:51 +0000, kan.liang@intel.com wrote:
[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1778,6 +1778,37 @@ static int ethtool_get_per_queue_coalesce(struct n=
et_device *dev,
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> +static int ethtool_set_per_queue_coalesce(struct net_device *dev,
> +					=C2=A0=C2=A0void __user *useraddr,
> +					=C2=A0=C2=A0struct ethtool_per_queue_op *per_queue_opt)
> +{
> +	u64 queue_mask;
> +	int bit, i, ret;
> +
> +	if (!dev->ethtool_ops->set_per_queue_coalesce)
> +		return -EOPNOTSUPP;
> +
> +	useraddr +=3D sizeof(*per_queue_opt);
> +	for (i =3D 0; i < MAX_QUEUE_MASK; i++) {
> +		queue_mask =3D per_queue_opt->queue_mask[i];
> +		if (queue_mask > 0) {
> +			for_each_set_bit(bit, (unsigned long *)&queue_mask, 64) {
> +				struct ethtool_coalesce coalesce;
> +
> +				if (copy_from_user(&coalesce, useraddr, sizeof(coalesce)))
> +					return -EFAULT;
> +
> +				ret =3D dev->ethtool_ops->set_per_queue_coalesce(dev, bit + i * 64, =
&coalesce);
> +				if (ret !=3D 0)
> +					return ret;
[...]

So there's no attempt to roll back on failure?

Then, what is the benefit of doing this iteration in the kernel rather
than userland?

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.
--=-eiNdG6x5CXNagDlEG81S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVnTRT+e/yOyVhhEJAQpCtg/8CP22RdCOCwxEAg/v7Ke+wJGDY/j3I9a5
/8Rrn6phYXwmIR2FBp4O1i/T6uxRWGOz5u6ACcS6nycIGqSWJZAJQzEPxwJnnTyP
BDEm+aXaQUM5VGOYxbOVfZ7toPdG2tGZR/swHzj1bVbUCnlbpzbuwE4We9y1OVcF
crTMbDDqUydZ5xz1HgINahwiptuZluAOIkvAzbnMQS5rP+YmUTreM0/Xo/4iaPFf
qKQq9IB0tCY/bHSi+06+s3ArbmLZ6eGoo4I0l4kDYNhJoifmLiL6sT+WsRePNTao
Bqt3efNybJnZHFIMxm7px7JDBJk/ZVwtd3uAiiwcBTp6Gu8qpm2+wNKZIZvkm+Zg
dlHReIgMzEG9rYQXSjEIa+fNwQKp6LcziHmifzhCBKfR5Y68R2YqW1redcqs6GP2
KyqeUU7Tfx/hZPeoCvG19rpc/okXh/ts8eJm89B+GG/YD0WgprCRK1pY1yBw5ZaV
TmDH9noYkjIMCZZBTjB9egFZZ2IgeWThRSbITJ9YdEF2L9YPfgcd9gPpLWBKJsVO
UnFPs9S6ff9JFXoc0fe7GjrNjhbFkUnnhK6jdFsZCElcYN93YW74sJ0ggjkjYbxR
ZFTHN8Ci1J+fFNBCdFERzeGgI8F44UOcTA+dNnye3/ghxmWVtvAjsTVb35JMs99A
sfQ+1k5DRxA=
=RkL5
-----END PGP SIGNATURE-----

--=-eiNdG6x5CXNagDlEG81S--
