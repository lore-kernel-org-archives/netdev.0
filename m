From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 0/5] net: sysctl: share ipv4/ipv6 sysctl tables
Date: Sat, 5 Feb 2011 16:26:48 +0200
Message-ID: <20110205142648.GA9814@p183.telecom.by>
References: <cover.1296793770.git.lucian.grijincu@gmail.com>
 <AANLkTi=3kKhWRzM7S_f18YJ=jx1P7bN9zVo9yGC7zwN_@mail.gmail.com>
 <AANLkTik=a3NmibvYM6NxvqCiSiaE0oUFNtRaqn4+g_+D@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43799 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291Ab1BEO05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Feb 2011 09:26:57 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTik=a3NmibvYM6NxvqCiSiaE0oUFNtRaqn4+g_+D@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 04, 2011 at 05:59:24PM +0200, Lucian Adrian Grijincu wrote:
> On Fri, Feb 4, 2011 at 12:49 PM, Alexey Dobriyan <adobriyan@gmail.com=
> wrote:
> >> Finally share the leaf sysctl tables for ipv4/ipv6:
> >>
> >> =A0[PATCH 4/5] ipv4: share sysctl net/ipv4/conf/DEVNAME/ tables
> >> =A0[PATCH 5/5] ipv6: share sysctl net/ipv6/conf/DEVNAME/ tables
> >
> > Meh.
> >
> > First you remove ->parent, then heroically pass "struct file *"
> > to sysctl handlers which duplicates all information already passed
> > and brings dcache into picture.
> >
> > Binary sysctl rewrite confused you into thinking that d_name.name
> > is the way, but it isn't.
> > For binary sysctl(2) you wouldn't get d_name.name.
>=20
>=20
> Are you really sure?
>=20
> I ran this code on a machine with and without these patches. It seems
> to work fine.
>=20
> It reads the value from /proc/sys/net/ipv4/conf/default/tag and write=
s 42 back.
>=20
> I'm not sure what I have to do to pass the name of a device (e.g.
> "eth0") instead of "default" but at least "default" and "all" work an=
d
> have valid dentries.

You do ->parent->procname.

But, but you removed parent.
