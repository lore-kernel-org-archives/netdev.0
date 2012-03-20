From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: netlink: 12 bytes leftover after parsing attributes - triggered
 by iproute2 libnetlink's rtnl_dump_request()
Date: Tue, 20 Mar 2012 08:09:17 -0700
Message-ID: <20120320080917.77765344@nehalam.linuxnetplumber.net>
References: <20120320134107.6acea83c@pluto.restena.lu>
	<20120320074140.39a1b3f0@nehalam.linuxnetplumber.net>
	<20120320160023.621e948a@pluto.restena.lu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>
To: Bruno =?ISO-8859-1?B?UHLpbW9udA==?= <bonbons@linux-vserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38531 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756702Ab2CTPJX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 11:09:23 -0400
In-Reply-To: <20120320160023.621e948a@pluto.restena.lu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Mar 2012 16:00:23 +0100
Bruno Pr=E9mont <bonbons@linux-vserver.org> wrote:

> On Tue, 20 Mar 2012 07:41:40 Stephen Hemminger wrote:
> > > Should this get fixed at kernel level, iproute2 libnetlink level =
or
> > > at end-user level (e.g. collectd)?
> > > Three lines every 10 seconds is a damn lot!
> > >=20
> > > Thanks,
> > > Bruno
> >=20
> > Netlink is supposed to be encoded as Type-Length-Value and correctl=
y written
> > programs ignore types they don't understand. So either the library =
is getting
> > confused by the type or the attribute is not encoded correctly.
> >=20
> >=20
> > The issue could be in libnetlink library. What version of collectd =
and libnetlink
> > are you using?
>=20
> I've used collectd-5.0.x and collectd-4.10.3 with 3.3 kernels.
> The stub code I listed is what collectd's netlink plugin does with
> libnetlink (processing of netlink reply factored out for short-ness)
>=20
> In all cases, linked against libnetlink from iproute2-2.6.38 (on
> Gentoo)
>=20
>=20
> From looking at git history of both collectd and iproute2, on both
> sides there has not been any changes that would affect the result.
>=20
> Collectd:
>   http://git.verplant.org/?p=3Dcollectd.git;a=3Dhistory;f=3Dsrc/netli=
nk.c;hb=3DHEAD

It is most likely in the libnetlink code, I'll look there.  Since libne=
tlink
is not really an exported API, I wish applications would use a real
library like libmnl instead rather than copying it out of iproute2.
