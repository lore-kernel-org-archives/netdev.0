From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v3 0/6] Big C99 style initializer rework
Date: Tue, 28 Jun 2016 19:37:23 +0200
Message-ID: <20160628173723.GA6733@orbyte.nwl.cc>
References: <d6784d8bb2d84ceab6c1719e32e8fa8e@HQ1WP-EXMB11.corp.brocade.com>
 <20160627105912.7961c3f4@xeon-e3>
 <20160627182302.GB13664@orbyte.nwl.cc>
 <20160627141049.356c1eff@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48831 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523AbcF1Rft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 13:35:49 -0400
Content-Disposition: inline
In-Reply-To: <20160627141049.356c1eff@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 02:10:49PM -0700, Stephen Hemminger wrote:
> On Mon, 27 Jun 2016 20:23:02 +0200
> Phil Sutter <phil@nwl.cc> wrote:
>=20
> > Hi,
> >=20
> > On Mon, Jun 27, 2016 at 10:59:12AM -0700, Stephen Hemminger wrote:
> > > On Thu, 23 Jun 2016 17:34:08 +0000
> > > Phil Sutter <phil@nwl.cc> wrote:
> > >=20
> > > > This is v3 of my C99-style initializer related patch series. Th=
e changes
> > > > since v2 are:
> > [...]
> > >=20
> > > I like the idea and it makes code cleaner. But doing this introdu=
ces lots of warnings
> > > and that is not acceptable.
> > > ip
> > >     CC       ip.o
> > >     CC       ipaddress.o
> > > ipaddress.c: In function =E2=80=98print_queuelen=E2=80=99:
> > > ipaddress.c:175:10: warning: missing braces around initializer [-=
Wmissing-braces]
> > >    struct ifreq ifr =3D { 0 };
> > >           ^
> >=20
> > I saw these too with gcc-3.4.6 but not with 5.3.0. It appears to be=
 a
> > gcc bug[1]. One possible workaround is to match the brace level of =
the
> > first field, but it's quite ugly: [2]. Another way might be to
> > initialize one of the fields to zero, like so:
> >=20
> > | struct ifreq ifr =3D { .ifr_qlen =3D 0 };
> >=20
> > What do you think?
> >=20
> > Thanks, Phil
> >=20
> > [1] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D53119
> > [2] http://nwl.cc/cgi-bin/git/gitweb.cgi?p=3Diproute2.git;a=3Dcommi=
tdiff;h=3Da1cbf2b63c995b2f633c5b4699248ab308b201d2;hp=3D3809cfec65b0371=
6d1d0360338126df4b4f3fbf6
>=20
> I am using gcc on Debian stable which is 5.3.1.

Hmm. In a fresh install of Debian 8.5 I see the warnings as well, but i=
t
has gcc-4.9.2-10 as most recent version.

Another thing I noticed: Using empty braces ('{}') instead of the
universal zero initializer seems to work without causing warnings (at
least unless '-pedantic' is used).

Cheers, Phil
