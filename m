From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 16:53:49 +0200
Message-ID: <1271948029.7895.5707.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net>  <1271946961.7895.5665.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:59601 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432Ab0DVOyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 10:54:02 -0400
In-Reply-To: <1271946961.7895.5665.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 16:36 +0200, Eric Dumazet a =C3=A9crit :

> If one hash slot is under attack, then there is a bug somewhere.
>=20
> If we cannot avoid this, we can fallback to a secure mode at the seco=
nd
> retry, and take the spinlock.
>=20
> Tis way, most of lookups stay lockless (one pass), and some might tak=
e
> the slot lock to avoid the possibility of a loop.
>=20
> I suspect a bug elsewhere, quite frankly !
>=20
> We have a chain that have an end pointer that doesnt match the expect=
ed
> one.
>=20

On normal situation, we always finish the lookup :

1) If we found the thing we were looking at.

2) We get the list end (item not found), we then check if it is the
expected end.

It is _not_ the expected end only if some writer deleted/inserted an
element in _this_ chain during our lookup.

Because our lookup is lockless, we then have to redo it because we migh=
t
miss the object we are looking for.

If we can do the 'retry' a 10 times, it means the attacker was really
clever enough to inject new packets (new conntracks) at the right
moment, in the right hash chain, and this sounds so higly incredible
that I cannot believe it at all :)



