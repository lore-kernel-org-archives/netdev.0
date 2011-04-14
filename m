From: Simon Horman <horms@verge.net.au>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Thu, 14 Apr 2011 10:34:29 +0800
Message-ID: <20110414023428.GD5167@verge.net.au>
References: <bug-32832-10286@https.bugzilla.kernel.org/>
 <20110412161556.0641bdae.akpm@linux-foundation.org>
 <20110412.161744.27803776.davem@davemloft.net>
 <1302663327.2811.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:32996 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854Ab1DNFyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 01:54:44 -0400
Content-Disposition: inline
In-Reply-To: <1302663327.2811.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2011 at 04:55:27AM +0200, Eric Dumazet wrote:
> Le mardi 12 avril 2011 =C3=A0 16:17 -0700, David Miller a =C3=A9crit =
:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Tue, 12 Apr 2011 16:15:56 -0700
> >=20
> > >=20
> > > (switched to email.  Please respond via emailed reply-to-all, not=
 via the
> > > bugzilla web interface).
> >=20
> > Stephen Hemminger forwarded this to the list last week, and Eric
> > Dumazet is actively working on a fix.
>=20
> I worked on it this week end to discover FreeBSD 8.1 would not allow
> several CLOSE sockets bound to same port even with REUSEADDR.
>=20
> So haproxy claim is a bit wrong (its trick doesnt work on FreeBSD), a=
nd
> used an undocumented linux feature.
>=20
> I feel this case is a call for SO_REUSEPORT, eventually.
>=20
> http://www.unixguide.net/network/socketfaq/4.11.shtml
>=20
>   SO_REUSEADDR allows your server to bind to an address which is in a
>   TIME_WAIT state.  It does not allow more than one server to bind to
>   the same address.  It was mentioned that use of this flag can creat=
e a
>   security risk because another server can bind to a the same port, b=
y
>   binding to a specific address as opposed to INADDR_ANY.  The
>   SO_REUSEPORT flag allows multiple processes to bind to the same
>   address provided all of them use the SO_REUSEPORT option.
>=20
>=20
> Since SO_REUSEPORT is not a 'stable fix', I suggest we revert the pat=
ch,
> and eventually work on SO_REUSEPORT on net-next-2.6
>=20
> What do you think ?

Not entirely related, but FWIW I think that SO_REUSEPORT would
be rather useful for haproxy.

I've been working on allowing haproxy to be reconfigured without droppi=
ng
or reusing connections. I have done this by re-using open sockets. But =
it
would have been rather a lot easier to achieve using SO_REUSEPORT -
assuming that I understand SO_REUSEPORT correctly.

