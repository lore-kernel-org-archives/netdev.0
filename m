From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Tue, 18 Jun 2013 11:18:58 +0300
Message-ID: <20130618081858.GD5461@arwen.pp.htv.fi>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
 <20130523022327.GB6159@kroah.com>
 <519D8876.9050405@suse.com>
 <51BF6BFF.7050705@suse.cz>
 <51BFE754.5080301@suse.cz>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NtwzykIc2mflq5ck"
Cc: Jiri Slaby <jslaby@suse.cz>, Jeff Mahoney <jeffm@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<jirislaby@gmail.com>, <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	<linux-usb@vger.kernel.org>,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	<linux-geode@lists.infradead.org>, <linux-fbdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	<tomi.valkeinen@ti.com>
To: Michal Marek <mmarek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:49061 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab3FRIVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 04:21:06 -0400
Content-Disposition: inline
In-Reply-To: <51BFE754.5080301@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--NtwzykIc2mflq5ck
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jun 18, 2013 at 06:51:32AM +0200, Michal Marek wrote:
> Dne 17.6.2013 22:05, Jiri Slaby napsal(a):
> > On 05/23/2013 05:09 AM, Jeff Mahoney wrote:
> >> On 5/22/13 10:23 PM, Greg Kroah-Hartman wrote:
> >>> On Wed, May 22, 2013 at 11:18:46AM +0200, Jiri Slaby wrote:
> >>>> Some drivers can be built on more platforms than they run on. This
> >>>> causes users and distributors packaging burden when they have to
> >>>> manually deselect some drivers from their allmodconfigs. Or sometimes
> >>>> it is even impossible to disable the drivers without patching the
> >>>> kernel.
> >>>>
> >>>> Introduce a new config option COMPILE_TEST and make all those drivers
> >>>> to depend on the platform they run on, or on the COMPILE_TEST option.
> >>>> Now, when users/distributors choose COMPILE_TEST=3Dn they will not h=
ave
> >>>> the drivers in their allmodconfig setups, but developers still can
> >>>> compile-test them with COMPILE_TEST=3Dy.
> >>>
> >>> I understand the urge, and it's getting hard for distros to handle th=
ese
> >>> drivers that just don't work on other architectures, but it's really
> >>> valuable to ensure that they build properly, for those of us that don=
't
> >>> have many/any cross compilers set up.
> >=20
> > But this is exactly what COMPILE_TEST will give us when set to "y", or
> > am I missing something?
> >=20
> >>>> Now the drivers where we use this new option:
> >>>> * PTP_1588_CLOCK_PCH: The PCH EG20T is only compatible with Intel At=
om
> >>>>   processors so it should depend on x86.
> >>>> * FB_GEODE: Geode is 32-bit only so only enable it for X86_32.
> >>>> * USB_CHIPIDEA_IMX: The OF_DEVICE dependency will be met on powerpc
> >>>>   systems -- which do not actually support the hardware via that
> >>>>   method.
> >>>
> >>> This seems ripe to start to get really messy, really quickly.  Should=
n't
> >>> "default configs" handle if this "should" be enabled for a platform or
> >>> not, and let the rest of us just build them with no problems?
> >>
> >> If every time a new Kconfig option is added, corresponding default
> >> config updates come with it, sure. I just don't see that happening,
> >> especially when it can be done much more clearly in the Kconfig while
> >> the developer is writing the driver.
> >>
> >>> What problems is this causing you?  Are you running out of space in
> >>> kernel packages with drivers that will never be actually used?
> >>
> >> Wasted build resources. Wasted disk space on /every/ system the kernel
> >> package is installed on. We're all trying to pare down the kernel
> >> packages to eliminate wasted space and doing it manually means a bunch
> >> of research, sometimes with incorrect assumptions about the results,
> >> needs to be done by someone not usually associated with that code. That
> >> research gets repeated by people maintaining kernel packages for pretty
> >> much every distro.
> >=20
> > I second all the above.
> >=20
> >>>> +config COMPILE_TEST
> >>>> +	bool "Compile also drivers which will not load" if EXPERT
> >>>
> >>> EXPERT is getting to be the "let's hide it here" option, isn't it...
> >>>
> >>> I don't know, if no one else strongly objects, I can be convinced that
> >>> this is needed, but so far, I don't see why it really is, or what this
> >>> is going to help with.
> >>
> >> I'm not convinced adding a || COMPILE_TEST option to every driver that
> >> may be arch specific is the best way to go either. Perhaps adding a new
> >> Kconfig verb called "archdepends on" or something that will evaluate as
> >> true if COMPILE_TEST is enabled but will evaluate the conditional if
> >> not. *waves hands*
> >=20
> > Sam Ravnborg (the kconfig ex-maintainer) once wrote that he doesn't want
> > to extend the kconfig language for this purpose (which I support). That
> > a config option is fine and sufficient in this case [1]. Except he
> > called the config option "SHOW_ALL_DRIVERS". Adding the current
> > maintainer to CCs ;).
>=20
> I agree with Sam. 'depends on XY || COMPILE_TEST' is quite
> self-explanatory. And even if it's not, you can look up the help text
> for COMPILE_TEST. With "archdepends on" or "available on", you need to
> know what to look for to override the dependency.

you will still end up with:

depends on (ARCH_OMAP || ARCH_EXYNOS || ARCH_DAVINCI || ARCH_PPC || ...)

And every now and again that particular line will be updated to add
another arch dependency.

--=20
balbi

--NtwzykIc2mflq5ck
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRwBfyAAoJEIaOsuA1yqRE8fsP/0KparYd4kOrkJQoec9iV7bY
b1TZdS3mBQm4upZrDpLntFhV7kCBQHjIsuCzY94B35eJKtFc8prKcxnbuj/aD45F
GO4MoiBD/5okW0iNFkKEOthidir2YgJhsdUaUM5NeetGU1zQXePII1Ob5huF7QsC
zMsnztJtJI8PAqIL3BfE0Wh8ObUXUTilBtlNiOrSIZwVXCQ298+g7phUAUB6C+bC
HNkAMLiMvTab3OjT2xUWZkstiVpedhN8w83YbGusfoiC/skV6QzkCM1ndnSb1Tbz
oxXZsNv8GF0pf9GhDht1YFBw/uiJdHawBJEoKpltpEEKWBtCemnokc/mKrPPGL9B
kvqclTpL5vmPYzIQ3v5YjKTYla47LyblmVwLbP2PXcHdQdW4kqhmBK1WVUZjDCJB
15qPkj4pwryyQthuE9cYdCg5jMjGJdPijjCIB8SbR7GYTQf+LYxxT9nD9Sa5HaPM
0TVhXvhTTqOHhGEFsMk+q2lGUFOTiPEeV7s9eWa7osCXnUU5zNg/JNpEqu2I9Qxt
FLLJmgNLPH+9tlPOdyiR2cDJ6xNphF09yBKObVtGMmFEK1Dfn1vLUgETdHx65Zgj
1YdO5K2qz3DWVJtYGM7z92geGJ3mEwn37cMLdePV0LOZFIVsVfG3vwSWKKfEZOMv
MqVL6eeUhbGbztylmW0I
=CtT/
-----END PGP SIGNATURE-----

--NtwzykIc2mflq5ck--
