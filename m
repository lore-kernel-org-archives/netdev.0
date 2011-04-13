From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Wed, 13 Apr 2011 04:55:27 +0200
Message-ID: <1302663327.2811.55.camel@edumazet-laptop>
References: <bug-32832-10286@https.bugzilla.kernel.org/>
	 <20110412161556.0641bdae.akpm@linux-foundation.org>
	 <20110412.161744.27803776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64133 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755701Ab1DMCze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 22:55:34 -0400
Received: by wwa36 with SMTP id 36so209240wwa.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 19:55:33 -0700 (PDT)
In-Reply-To: <20110412.161744.27803776.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 16:17 -0700, David Miller a =C3=A9crit :
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Tue, 12 Apr 2011 16:15:56 -0700
>=20
> >=20
> > (switched to email.  Please respond via emailed reply-to-all, not v=
ia the
> > bugzilla web interface).
>=20
> Stephen Hemminger forwarded this to the list last week, and Eric
> Dumazet is actively working on a fix.

I worked on it this week end to discover FreeBSD 8.1 would not allow
several CLOSE sockets bound to same port even with REUSEADDR.

So haproxy claim is a bit wrong (its trick doesnt work on FreeBSD), and
used an undocumented linux feature.

I feel this case is a call for SO_REUSEPORT, eventually.

http://www.unixguide.net/network/socketfaq/4.11.shtml

  SO_REUSEADDR allows your server to bind to an address which is in a
  TIME_WAIT state.  It does not allow more than one server to bind to
  the same address.  It was mentioned that use of this flag can create =
a
  security risk because another server can bind to a the same port, by
  binding to a specific address as opposed to INADDR_ANY.  The
  SO_REUSEPORT flag allows multiple processes to bind to the same
  address provided all of them use the SO_REUSEPORT option.


Since SO_REUSEPORT is not a 'stable fix', I suggest we revert the patch=
,
and eventually work on SO_REUSEPORT on net-next-2.6

What do you think ?


