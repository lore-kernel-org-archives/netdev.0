From: Soeren Sonnenburg <kernel@nn7.de>
Subject: Re: 2.6.25-rc8: WARNING: at net/ipv4/tcp_input.c:2173
	tcp_mark_head_lost+0x11d/0x150()
Date: Thu, 03 Apr 2008 15:40:08 +0200
Message-ID: <1207230008.4513.14.camel@localhost>
References: <1207199456.7616.3.camel@localhost>
	 <Pine.LNX.4.64.0804031616330.21524@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758391AbYDCNk2@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804031616330.21524@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-04-03 at 16:26 +0300, Ilpo J=E4rvinen wrote:
> On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:
>=20
> > trying to download things, I am seeing this (ignore the tainted, it=
 is
> > from madwifi and although the module is loaded the device was never
> > used)
> >=20
> > Could anyone make sense of this please?
>=20
> ...I'm just trying to find out who and where invariants of the TCP co=
de
> are broken. These were relatively recently enabled (pre-2.6.24 just d=
idn't=20
> care too much). A number of long standing issues plus bugs from my=20
> modifications have been fixed because of the more rigid checking :-).
>=20
> > ------------[ cut here ]------------
> > WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x11d/0x15=
0()
>=20
> > ------------[ cut here ]------------
> > WARNING: at net/ipv4/tcp_input.c:1771 tcp_enter_frto+0x267/0x270()
>=20
> > ------------[ cut here ]------------
> > WARNING: at net/ipv4/tcp_input.c:2532 tcp_ack+0x1a6f/0x1d60()
>=20
> Can you reproduce it?=20

Yes, by massively downloading things :-) But I have no real recipe to
make it easily reproducible...

Looks like you are in fact interested in:
grep WARNING: /var/log/kern.log | cut -c 40- | sort -u

net/ipv4/tcp_input.c:1771 tcp_enter_frto+0x267/0x270()
net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x11d/0x150()
net/ipv4/tcp_input.c:2532 tcp_ack+0x1a6f/0x1d60()
net/ipv4/tcp_input.c:3067 tcp_ack+0x1d2b/0x1d60()

> Please include netdev next time while report networking related probl=
ems.

OK
Soeren
