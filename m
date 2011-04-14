From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Thu, 14 Apr 2011 04:17:59 +0200
Message-ID: <1302747479.3549.10.camel@edumazet-laptop>
References: <20110412.161744.27803776.davem@davemloft.net>
	 <1302663327.2811.55.camel@edumazet-laptop>
	 <1302663608.2811.62.camel@edumazet-laptop>
	 <20110413.120929.28806842.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37584 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756652Ab1DNCSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 22:18:05 -0400
Received: by wya21 with SMTP id 21so1002411wya.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 19:18:04 -0700 (PDT)
In-Reply-To: <20110413.120929.28806842.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 avril 2011 =C3=A0 12:09 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 13 Apr 2011 05:00:08 +0200
>=20
> > Le mercredi 13 avril 2011 =C3=A0 04:55 +0200, Eric Dumazet a =C3=A9=
crit :
> >=20
> >> Since SO_REUSEPORT is not a 'stable fix', I suggest we revert the =
patch,
> >> and eventually work on SO_REUSEPORT on net-next-2.6
> >>=20
> >> What do you think ?
> >>=20
> >=20
> > Sorry, I should have mentioned commit id : c191a836a908d1dd6
> > (tcp: disallow bind() to reuse addr/port)
>=20
> I'm commiting the revert as follows to net-2.6, and will queue
> it up for -stable as well:
>=20
> --------------------
> Revert "tcp: disallow bind() to reuse addr/port"
>=20
> This reverts commit c191a836a908d1dd6b40c503741f91b914de3348.
>=20
> It causes known regressions for programs that expect to be able to us=
e
> SO_REUSEADDR to shutdown a socket, then successfully rebind another
> socket to the same ID.
>=20
> Programs such as haproxy and amavisd expect this to work.
>=20
> This should fix kernel bugzilla 32832.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Thanks David, I was planning to submit this revert this morning, you
beat me ;)



