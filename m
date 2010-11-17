From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-2.6 PATCH] ipv6: fix missing in6_ifa_put in addrconf
Date: Wed, 17 Nov 2010 16:38:00 +0100
Message-ID: <1290008280.2687.49.camel@edumazet-laptop>
References: <20101116062921.31164.70903.stgit@jf-dev1-dcblab>
	 <1289889454.3364.122.camel@edumazet-laptop>
	 <1290007231.2222.10.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Anders Franzen <Anders.Franzen@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45170 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871Ab0KQPiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 10:38:05 -0500
Received: by wyb28 with SMTP id 28so2097645wyb.19
        for <netdev@vger.kernel.org>; Wed, 17 Nov 2010 07:38:04 -0800 (PST)
In-Reply-To: <1290007231.2222.10.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 novembre 2010 =C3=A0 16:20 +0100, Anders Franzen a =C3=A9=
crit :
> Hi, I was hunting for a bug that a colleague discovered.
> When we exit a network namespace, the ns was hanging with dangling
> references to dev lo.
>=20
> When I saw the patch below, I fetched the latest net-next from Daves
> repository.
>=20
> And the problem is gone. Was this really the fix, since it seems to m=
e
> that this is a fix to a recently added patch (dont remove address ...=
=2E).
>=20
> Did you fix anything else in the Ipv6 addrconf w.r.g dev_hold/dev_put=
?
>=20
> netns still have problems with slab corruption during exit though:
>=20
>  Nov 17 15:00:20 p04 user.err kernel: Slab corruption: size-4096
> start=3Dffff88000612a000, len=3D4096
> Nov 17 15:00:20 p04 user.err kernel: 020: 6b 6b 6b 6b 6b 6b
> Nov 17 15:00:20 p04 user.info kernel:  6b 6b 00 00 00 00 00 00 00
> Nov 17 15:00:20 p04 user.info kernel:  00
>=20
> BR
>   Anders
>=20
>=20

Hi Anders

Several patches of interest :


commit 9d82ca98f71fd686ef2f3017c5e3e6a4871b6e46
(ipv6: fix missing in6_ifa_put in addrconf)

commit 332dd96f7ac15e937088fe11f15cfe0210e8edd1
(net/dst: dst_dev_event() called after other notifiers)

commit ef885afbf8a37689afc1d9d545e2f3e7a8276c17
(net: use rcu_barrier() in rollback_registered_many)


