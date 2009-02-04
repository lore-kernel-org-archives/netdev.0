From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: Re: 2.6.29-rc: unable to compile e100 firmware into kernel
Date: Wed, 4 Feb 2009 19:45:29 +0300
Message-ID: <200902041945.36632.arvidjaar@mail.ru>
References: <200901311900.00851.arvidjaar@mail.ru> <4807377b0902011105l29e846c3r140212ac654efb93@mail.gmail.com> <1233754384.19223.183.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7914482.lB7CaGVr5o";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	linux-kbuild@vger.kernel.org, netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1233754384.19223.183.camel@macbook.infradead.org>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart7914482.lB7CaGVr5o
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 4 of February 2009 16:33:04 David Woodhouse wrote:
> On Sun, 2009-02-01 at 11:05 -0800, Jesse Brandeburg wrote:
> > On Sat, Jan 31, 2009 at 7:59 AM, Andrey Borzenkov=20
<arvidjaar@mail.ru> wrote:
> > > {pts/2}% LC_ALL=3DC make -C ~/src/linux-git
> > > O=3D$HOME/build/linux-2.6.29 make: Entering directory
> > > `/home/bor/src/linux-git'
> > >  Using /home/bor/src/linux-git as source for kernel
> > > ln -fsn /home/bor/src/linux-git source
> >
> > I think (seem to recall something on the list) there have been
> > multiple people reporting the make O=3D option doesn't work with
> > CONFIG_FIRMWARE_IN_KERNEL,
>
> That shouldn't be the case -- it works fine here.
>
> Andrey, what version of make are you using?

OK, build error was likely result of something I did before (I suspect=20
what, but after I cleaned up build firmware/e100 it rebuilds OK now).=20
But even after I verified that firmware *was* built in kernel loading=20
still failed. This is genuine bug caused by config option mismatch.

I had CONFIG_FW_LOADER=3Dm. I do not remember ever setting it explicitly,=20
so I suspect it was selected by some other driver in the past (I do make=20
oldconfig for at least ten past releases if not more). This cannot work=20
with CONFIG_FIRMWARE_IN_KERNEL=3Dy because of this code in=20
drivers/base/firmware_class.c:

#ifdef CONFIG_FW_LOADER
extern struct builtin_fw __start_builtin_fw[];
extern struct builtin_fw __end_builtin_fw[];
#else /* Module case. Avoid ifdefs later; it'll all optimise out */
static struct builtin_fw *__start_builtin_fw;
static struct builtin_fw *__end_builtin_fw;
#endif

IOW CONFIG_FIRMWARE_IN_KERNEL must force CONFIG_FW_LOADER=3Dy. I do not=20
understand Kconfig enough to offer a patch.

--nextPart7914482.lB7CaGVr5o
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkmJxiwACgkQR6LMutpd94zT8ACguCB4BNMcm2EpgbfqthRcxBjU
B2QAn2XTi2/yJieX5xJS87CoUGtUO7b/
=4wIb
-----END PGP SIGNATURE-----

--nextPart7914482.lB7CaGVr5o--
