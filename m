From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [RFC PATCH 1/4] PHY Abstraction Layer III (now with more
	splitiness)
Date: Thu, 28 Jul 2005 11:18:37 +0200
Message-ID: <20050728091837.GC25033@wohnheim.fh-wedel.de>
References: <1122500059.28777@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Netdev <netdev@vger.kernel.org>,
	linuxppc-embedded <linuxppc-embedded@ozlabs.org>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Content-Disposition: inline
In-Reply-To: <1122500059.28777@shark.he.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, 27 July 2005 14:34:19 -0700, Randy Dunlap wrote:
> >=20
> > Ok, here I won't agree to disagree with you.  !foo as a check for =20
> > NULL is a reasonable idea, but not my style.  If that's the preferred=
 =20
> > style for the kernel, I will do that.
> >=20
> > But (var =3D=3D constant) is a style that asks for errors.  By puttin=
g =20
> > the constant first in these checks, you never run the risk of leaving=
 =20
> > a bug like this:
> >=20
> > if (dev =3D NULL)
> >      ...
> >=20
> > This kind of error is quite frustrating to detect, and the eye will =20
> > often miss it when scanning for errors.  If you follow constant =3D=3D=
 =20
> > var, though, then the bug looks like this:
> >=20
> > if (NULL =3D dev)
> >=20
> > which is instantly caught by the compiler.
> >=20
> > Just my 32 cents
>=20
> Yes, we know about that argument.  :)

The counter-argument basically goes like this:

1. All relevant compilers (GCC) warn on "if (dev =3D NULL)", so you will
only miss the bug if you ignore compiler warnings.  Ignoring compiler
warnings is not generally endorsed by the kernel crowd.

2. Very hard to read, "if (NULL =3D dev)" is.  Reversing the order is a
fun thing to do for small green characters in fantasy and scifi
stories and fairly popular in peotry as well.  But understanding the
meaning of reverse order sentences takes more time.  In the kernel,
peer review is an important aspect and making the code hard to read
hurts peer review.

And maybe you can add another one:

3. Im my personal experience, reverse order comparisons were a good
indicator of buggy code.

J=F6rn

--=20
Schr=F6dinger's cat is <BLINK>not</BLINK> dead.
-- Illiad
