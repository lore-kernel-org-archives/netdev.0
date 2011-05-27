From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Fri, 27 May 2011 05:10:41 +0200
Message-ID: <1306465841.2543.52.camel@edumazet-laptop>
References: <20110525232921.GD19633@outflux.net>
	 <20110525.215040.47969627064310792.davem@davemloft.net>
	 <20110527001449.GS19633@outflux.net>
	 <20110526.224427.433160775431725543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kees.cook@canonical.com, joe@perches.com, mingo@elte.hu,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eugeneteo@kernel.org, jmorris@namei.org,
	tgraf@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53328 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab1E0DKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 23:10:49 -0400
Received: by wya21 with SMTP id 21so942914wya.19
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 20:10:48 -0700 (PDT)
In-Reply-To: <20110526.224427.433160775431725543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 mai 2011 =C3=A0 22:44 -0400, David Miller a =C3=A9crit :
> From: Kees Cook <kees.cook@canonical.com>
> Date: Thu, 26 May 2011 17:14:49 -0700
> >=20
> > We got this dropped from the /proc view; why can't we do the same f=
or
> > this netlink interface?
>=20
> Because it's not only an opaque "output" blob, it's also an input key
> for lookups which the user can trigger.

Yes, we wan add a layer to obfuscate the real pointers. We dont trust
values given by user, only match them.

Either we use a XOR with a boot time random value (but let the NULL
cookie being the NULL one), or we generate an unique 64bit socket id fo=
r
the cookie (and keep a 64bit cookie in all sockets, increasing ram
usage)



