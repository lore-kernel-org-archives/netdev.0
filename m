From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: kernel bug at sched.c:564! + linux kernel 2.4.25
Date: Tue, 27 Jul 2004 21:50:27 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407272150.50664.vkondra@mail.ru>
References: <Xine.LNX.4.44.0407271439001.7805-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1175970.E4tr3HR44W";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>, Niranjan <niranjan_cs2905@yahoo.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0407271439001.7805-100000@dhcp83-76.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1175970.E4tr3HR44W
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 27 July 2004 21:39, James Morris wrote:
> On Tue, 27 Jul 2004, Vladimir Kondratiev wrote:
> > We also saw the same (crypto modules goes to sleep).
> > Due to this, we decided to not use cryptoapi for our wireless driver, but
> > compile the same crypto functions into the driver. I know this is code
> > duplication, but Tx and Rx paths work in BH context (I reschedule it on
> > IRQ Rx to use cheaper time).
> >
> > Do cryptoapi maintainers aware of this issue?
>
> The crypto functions should be safe to use in softirq context.
It should be, but:
<crypto/api.c:121>
struct crypto_tfm *crypto_alloc_tfm(const char *name, u32 flags)
{
        struct crypto_tfm *tfm = NULL;
        struct crypto_alg *alg;

        alg = crypto_alg_mod_lookup(name);
        if (alg == NULL)
                goto out;

        tfm = kmalloc(sizeof(*tfm) + alg->cra_ctxsize, GFP_KERNEL);

Note kmalloc(GFP_KERNEL)
>
>
> - James

--nextPart1175970.E4tr3HR44W
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBBqQKqxdj7mhC6o0RAl3yAJwNJTUOsn0X0pyZEXT3sL/pI2qfJQCfZV/k
dyuRi6ZO1SvSqalKaA8H+Hk=
=PWtG
-----END PGP SIGNATURE-----

--nextPart1175970.E4tr3HR44W--
