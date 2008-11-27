From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 12/39] wimax: API call to reset a WiMAX device
Date: Thu, 27 Nov 2008 10:58:30 +0100
Message-ID: <1227779910.3809.48.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <938311fe52f5b0eb7797fff7c761cc3240c63fe5.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-L9W9IdyppwH8zQVhWnh5"
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:51262 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbYK0J7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:59:16 -0500
In-Reply-To: <938311fe52f5b0eb7797fff7c761cc3240c63fe5.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-L9W9IdyppwH8zQVhWnh5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> Provides wimax_reset() for the kernel to reset a wimax device as
> needed.
>=20
> Exports wimax_reset() over generic netlink to user space.

> +struct genl_ops wimax_gnl_reset =3D {
> +	.cmd =3D WIMAX_GNL_OP_RESET,
> +	.flags =3D 0,

permission check again

> +       /* Execute the operation and send the result back to user space *=
/
> +       result =3D wimax_reset(wimax_dev);
> +       result2 =3D wimax_gnl_send_rp_result(wimax_dev, info, result);
> +       if (result2 < 0)
> +               dev_err(dev, "WIMAX_GNL_RESET: can't send result %d to "
> +                       "userspace: %d\n", result, result2);
> +       result =3D 0;
> +       dev_put(wimax_dev->net_dev);
> +error_no_wimax_dev:
> +error_perm:
> +       d_fnend(3, NULL, "(skb %p info %p) =3D %d\n", skb, info, result);
> +       return result;

This is strange. Can you show your corresponding userspace code? It
shouldn't be necessary with generic netlink to explicitly send the
result, if you just return the result from wimax_reset() it'll be part
of the ACK message and thus already be relayed to userspace. I think
you're not using genl correctly here.

johannes

--=-L9W9IdyppwH8zQVhWnh5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLm9DAAoJEKVg1VMiehFYkJAP/0Rc7lx2lcnU5WUOlTlFfWCk
LR/RV9EZik6utytZZhdu20PSAY57CyQDedSBZ0eklj0W78ZaYC8Fxhat6uNbxNCS
uMQtl6ggPvY0lStj4DDwK3u6sUPuIAZSa6bMBORASiuhdK8BQaHdQoWcJbKUOphH
+LVriNpExphhUvJgBHT3xY1iYtRFqV3zXt22BpDzOC7DWEwa2ieGVZx+qDwq9yWl
mU3xx9gUtLjIkr94WS/IK2S860AOQ2sIzsjH1rvQ//bO2Rdni2C8a/V2vZ/mO12O
SPD/wZWi9wjnF/kBEXA4GFuPg8d3cSgEZnHL7wWQD/T9c9bg7+cZ9YEHHVHX4hOC
LjYWcFy980962hXL7wDO+0JrRxn6kT19BLoaUIVIwuffYsGh02W9/AVri0ZOmbro
MsXaRF+bN4QkbxuQicUArKDD5uobGuhyxnfJsdFIiQWY3ufhI2M4BSk0YwK9kJre
i3OW0C/ewq0jf9N0+iXdrlin8zuFYkXh/X+XC296Qo3++ztlfP5v9qUyhz0ROz6I
+5b1kM8DGbgOOyPJwiOfzqPTpvUbCCZx57AlUsgWVbcJiSW4wRfhFjoxFqPvWEx+
GP7tGNx6n9N7cDqS0QnV7l79hPlLZmmYK5i3KJc41ppQ1jzetWoMVLD3eoSCnZzA
nlP6EFNM5i9tdQs6MbRY
=BDkQ
-----END PGP SIGNATURE-----

--=-L9W9IdyppwH8zQVhWnh5--

