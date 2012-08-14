From: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 01/16] hashtable: introduce a small and naive hashtable
Date: Wed, 15 Aug 2012 09:25:23 +1000
Message-ID: <20120815092523.00a909ef@notabene.brown>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
	<1344961490-4068-2-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/WaPYDSkmDZTaSUO/RNup8tR"; protocol="application/pgp-signature"
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1344961490-4068-2-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Sig_/WaPYDSkmDZTaSUO/RNup8tR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 14 Aug 2012 18:24:35 +0200 Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
wrote:


> +static inline void hash_init_size(struct hlist_head *hashtable, int bits)
> +{
> +	int i;
> +
> +	for (i =3D 0; i < HASH_SIZE(bits); i++)
> +		INIT_HLIST_HEAD(hashtable + i);
> +}

This seems like an inefficient way to do "memset(hashtable, 0, ...);".
And in many cases it isn't needed as the hash table is static and initialis=
ed
to zero.
I note that in the SUNRPC/cache patch you call hash_init(), but in the lockd
patch you don't.  You don't actually need to in either case.

I realise that any optimisation here is for code that is only executed once
per boot, so no big deal, and even the presence of extra code making the
kernel bigger is unlikely to be an issue.  But I'd at least like to see
consistency: Either use hash_init everywhere, even when not needed, or only
use it where absolutely needed which might be no-where because static tables
are already initialised, and dynamic tables can use GFP_ZERO.

And if you keep hash_init_size I would rather see a memset(0)....

Thanks,
NeilBrown

--Sig_/WaPYDSkmDZTaSUO/RNup8tR
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUCreYznsnt1WYoG5AQJjuA//cxInQBsHXHRtWYyYJpxwOX9hqpSDNaZ2
37aTlFSGjdhr1yn+RcwmtWh9nEj+oHEFlds46gW/woLpGFSXuCPD85CDtZDjPSpL
7VNXdZ1i3+EEPR0K2vjMaUs1cpdz2KIx8KZjIXfQVnARaZNfts7EuaTCpGM+5bac
G4CX6uoFtPc/A4LVEiYbowLzhUG+GmxcofMjd9ZJ4Ug0Xg4sl8xXtYg8YDkSn3LJ
zef9ltlJ1WxLSTtBm6+jyH25Xlb31P7TT3BUgNcStSz9Jak2wdggbUE79iOb3GJL
sP6/meXapGELz7IE8PVo/cdYdfBcskH6M8ai8pNNYTguSh/2VSRnjR1hPqXhgUYn
FDKLL8galmS5OxQMwv4mb3zhUIHIiTT7tWBq6eYXo3xUzInU5VufAyLIcpRX3fXm
VNLnnDOyaoWJCP/fUDrmHskSWPhLQA5/1YtiSI1NYwbY2C+OCybFHYixcWe5CT4w
YvQ2TTweApDjk5JRndjiO0/j4++kAYvQ8KwC7oo7CUK13dH/9h8rxzV3H4zAhxkh
4F6FzPEagR1CzKpSkJEA46DJQNIdAbbyCM0VkHORy7gTUa0MA3MsjW8dOKSnBnux
xsx1GI08WW16NEf1TyGrkqdE/caa4WtDDoLNG3cpwLTZNlMACcZOHXQmgeQu3Ija
TqL1y22gF/Q=
=lYgD
-----END PGP SIGNATURE-----

--Sig_/WaPYDSkmDZTaSUO/RNup8tR--
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
