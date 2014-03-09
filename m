From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next V4 1/2] net: Utility function to get
 affinity_hint by policy
Date: Sun, 09 Mar 2014 21:10:38 +0000
Message-ID: <1394399438.15968.45.camel@deadeye.wl.decadent.org.uk>
References: <1394350749-30522-1-git-send-email-amirv@mellanox.com>
	 <1394350749-30522-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EJ7H4C09q2knlihjl0h3"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Prarit Bhargava <prarit@redhat.com>,
	Govindarajulu Varadarajan <gvaradar@cisco.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51510 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751741AbaCIVKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 17:10:54 -0400
In-Reply-To: <1394350749-30522-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EJ7H4C09q2knlihjl0h3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-03-09 at 09:39 +0200, Amir Vadai wrote:
> This function sets the affinity_mask according to a numa aware policy.
> affinity_mask could be used as an affinity hint for the IRQ related to
> this rx queue.
> Current policy is to spread rx queues accross cores - local cores first.
> It could be extended in the future.
[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2117,6 +2117,63 @@ EXPORT_SYMBOL(netif_set_real_num_rx_queues);
>  #endif
> =20
>  /**
> + * netif_set_rx_queue_affinity_hint - set affinity hint of rx queue
> + * @rxq: index of rx queue

Well, there is nothing net-specific here, so it could be a queue index
within any multiqueue device, right?

If this doesn't specifically relate to net devices, it probably belongs
in genirq (kernel/irq/*) and you should send this to Thomas Gleixner and
LKML too.

> + * @numa_node: prefered numa_node
> + * @affinity_mask: the relevant cpu bit is set according to the policy
> +
> + * This function sets the affinity_mask according to a numa aware policy=
.
> + * affinity_mask coulbe used as an affinity hint for the IRQ related to =
this

Typo: coulbe =3D> could be

> + * rx queue.
> + * The policy is to spread rx queues accross cores - local cores first.

Typo: accross =3D> across

> + *
> + * Returns 0 on success, or a negative error code.
> + */
> +int netif_set_rx_queue_affinity_hint(int rxq, int numa_node,
> +				     cpumask_var_t affinity_mask)

cpumask_var_t is for local variable definitions; you should use
cpumask_t * here.

> +{
> +	const struct cpumask *p_numa_cores_mask;
> +	cpumask_var_t non_numa_cores_mask =3D NULL;

This may be a syntax error - cpumask_var_t can be either a pointer or an
array, depending on the value of NR_CPUS.

I think you should either add a flag to indicate whether this has been
initialised, or restructure the code so that that's implicit.

> +	int affinity_cpu;
> +	int ret =3D 0;
> +
> +	rxq %=3D num_online_cpus();
> +
> +	p_numa_cores_mask =3D cpumask_of_node(numa_node);
> +	if (!p_numa_cores_mask)
> +		p_numa_cores_mask =3D cpu_online_mask;
> +
> +	for_each_cpu(affinity_cpu, p_numa_cores_mask) {
> +		if (--rxq < 0)
> +			goto out;
> +	}
[...]

What if some CPUs on the device's node are offline?

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-EJ7H4C09q2knlihjl0h3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxzYzue/yOyVhhEJAQrLFQ//XwQWIwZXLLPOtEAwBOTumPp5mRBv4j4m
BegRHueZu1nR1iJyw5p5VHiwy8Hd9jsifTHnlpKKIJ7TnPQPPkgTWg4dfMAm88DL
wrTd/ApCTlLfhTWont2g15jk+TPXPZ1oXm+Gm+lNSHDglOJQ7oJi6OYdXBwCiOMO
Q5wgsPUtrEJHv9cYwrFuiOONcbCLa7CH/IVEkpHvzB717puzGInsTk3fGh12nN0O
Bahu1D+WqHN4DUOHvZ5xcbowHXlZRyycuTP7xWglelXj62l7lOFQOrDmWHPrWthM
T3dnXlnwT48TyBNIsbzbERKyxsNERB0NzQ25Q01bbiMaV6r7rdbuvDyILRxb84lN
9i6op9j8frVvY8qFM4DnQdQvNSoq5sKrMdZHPQDUuuG46lX1j1Y/v4BRliGaKwYc
ge89ABZ+gmYy3YA85jCZosVnAFpPkE44X0R8/OtzuDbPU8SbzDWSxMyvoBa4bsOq
44SxaGryhFjeZUhlh0jAqqeCyTlnDxYd3wIFvhVEhRVL+c8SiCjVB7Dc5O1ZWwFK
wm4ZewECC8Ybh/M1iJ8+bpvgPVdudE1ccozTk/dIuiMWAEk65Sdimbo6OqUIx5hr
GWQgEkmlVYhRgJHT/7XPoBnyPRPJtKu7PyjEUfHZVVaHHlMzfnziE3B/8aBdaIiu
HFyKCft0pfs=
=/poW
-----END PGP SIGNATURE-----

--=-EJ7H4C09q2knlihjl0h3--
