From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] can: xilinx: use readl/writel instead of
 ioread/iowrite
Date: Sun, 25 Oct 2015 21:32:12 +0100
Message-ID: <562D3C4C.60306@pengutronix.de>
References: <1445489163-11045-1-git-send-email-appanad@xilinx.com>
 <4061693.oBld7AKBIp@wuerfel> <56289CA6.1060809@pengutronix.de>
 <8460953.p47oezaZnR@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="ClwxVSbopbWhB9jXhkN1OciF1jgVOn3ms"
Cc: linux-arm-kernel@lists.infradead.org,
	Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	anirudh@xilinx.com, wg@grandegger.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, appanad@xilinx.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-can@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <8460953.p47oezaZnR@wuerfel>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ClwxVSbopbWhB9jXhkN1OciF1jgVOn3ms
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/22/2015 10:58 AM, Arnd Bergmann wrote:
>>> The two should really do the same thing: iowrite32() is just a static=
 inline
>>> calling writel() on both ARM32 and ARM64. On which kernel version did=
 you
>>> observe the difference? It's possible that an older version used
>>> CONFIG_GENERIC_IOMAP, which made this slightly more expensive.
>>>
>>> If there are barriers that you want to get rid of for performance rea=
sons,
>>> you should use writel_relaxed(), but be careful to synchronize them c=
orrectly
>>> with regard to DMA. It should be fine in this driver, as it does not
>>> perform any DMA, but be aware that there is no big-endian version of
>>> writel_relaxed() at the moment.
>>
>> We don't have DMA in CAN drivers, but usually a certain write triggers=

>> sending. Do we need a barrier before triggering the sending?
>=20
> No, the relaxed writes are not well-defined across architectures. On
> ARM, the CPU guarantees that stores to an MMIO area are still in order
> with respect to one another, the barrier is only needed for actual DMA,=

> so you are fine. I would expect the same to be true everywhere,
> otherwise a lot of other drivers would be broken too.

And the relaxed functions seem not to be available on all archs. This
driver should work on microblaze. Are __raw_writeX(), __raw_readX() an
alternative here?

> To be on the safe side, that last write() could remain a writel() inste=
ad
> of writel_relaxed(), and that would be guaranteed to work on all
> architectures even if they end relax the ordering between MMIO writes.
> If there is a measurable performance difference, just use writel_relaxe=
d()
> and add a comment.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--ClwxVSbopbWhB9jXhkN1OciF1jgVOn3ms
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWLTxMAAoJEP5prqPJtc/HPcIH/2zjYnyIiBUgX/zwfAN7QzPG
y+zDkh6kXiCc2caGlmiNMt7VYrGhuxV1dZud9vqzbtPDhaRCe4QU15a5tMPccapW
InPzE3/kkHnqXS0TYr91nezu2Lz+CspvpG9Jsrpc939ss3/sBBLZwATc5CgcEmlA
eHMXf8PXUgjODUvhGJxIJvSZLHqSgUFc8BDroohi7OHiK8cqTcrhQXSfssEprQFq
aTsPE1EBwZiygbSzvxmmk8jbHt2eMCcP9k9KOFXJt1xm/NPq2JIl2H9leo4j3Q2h
yyJLsJQ712+/m8i887H6Db6fpuWuNXh1Dy1K5mIoi5qxMdRY7HYihsDrFB9evJI=
=81G1
-----END PGP SIGNATURE-----

--ClwxVSbopbWhB9jXhkN1OciF1jgVOn3ms--
