From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH v3 0/6] Big C99 style initializer rework
Date: Mon, 27 Jun 2016 14:10:49 -0700
Message-ID: <20160627141049.356c1eff@xeon-e3>
References: <d6784d8bb2d84ceab6c1719e32e8fa8e@HQ1WP-EXMB11.corp.brocade.com>
	<20160627105912.7961c3f4@xeon-e3>
	<20160627182302.GB13664@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38796 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751638AbcF0VK4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 17:10:56 -0400
In-Reply-To: <20160627182302.GB13664@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jun 2016 20:23:02 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Hi,
>=20
> On Mon, Jun 27, 2016 at 10:59:12AM -0700, Stephen Hemminger wrote:
> > On Thu, 23 Jun 2016 17:34:08 +0000
> > Phil Sutter <phil@nwl.cc> wrote:
> >=20
> > > This is v3 of my C99-style initializer related patch series. The =
changes
> > > since v2 are:
> [...]
> >=20
> > I like the idea and it makes code cleaner. But doing this introduce=
s lots of warnings
> > and that is not acceptable.
> > ip
> >     CC       ip.o
> >     CC       ipaddress.o
> > ipaddress.c: In function =E2=80=98print_queuelen=E2=80=99:
> > ipaddress.c:175:10: warning: missing braces around initializer [-Wm=
issing-braces]
> >    struct ifreq ifr =3D { 0 };
> >           ^
>=20
> I saw these too with gcc-3.4.6 but not with 5.3.0. It appears to be a
> gcc bug[1]. One possible workaround is to match the brace level of th=
e
> first field, but it's quite ugly: [2]. Another way might be to
> initialize one of the fields to zero, like so:
>=20
> | struct ifreq ifr =3D { .ifr_qlen =3D 0 };
>=20
> What do you think?
>=20
> Thanks, Phil
>=20
> [1] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D53119
> [2] http://nwl.cc/cgi-bin/git/gitweb.cgi?p=3Diproute2.git;a=3Dcommitd=
iff;h=3Da1cbf2b63c995b2f633c5b4699248ab308b201d2;hp=3D3809cfec65b03716d=
1d0360338126df4b4f3fbf6

I am using gcc on Debian stable which is 5.3.1.
