From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Mon, 16 Aug 2010 12:42:41 +0200
Message-ID: <1281955361.2524.35.camel@edumazet-laptop>
References: <20100816095325.GA8547@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47060 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab0HPKmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 06:42:46 -0400
In-Reply-To: <20100816095325.GA8547@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 ao=C3=BBt 2010 =C3=A0 09:53 +0000, Jarek Poplawski a =C3=A9=
crit :
> Eric Dumazet wrote:
> > Le dimanche 15 aou^t 2010 a` 12:55 +0200, Eric Dumazet a =C3=A9crit=
 :
> ...
> > [PATCH] netfilter: {ip,ip6,arp}_tables: avoid lockdep false positiv=
e
> >=20
> > After commit 24b36f019 (netfilter: {ip,ip6,arp}_tables: dont block
> > bottom half more than necessary), lockdep can raise a warning
> > because we attempt to lock a spinlock with BH enabled, while
> > the same lock is usually locked by another cpu in a softirq context=
=2E
>=20
> Btw, could you remind us how get_counters() are serialized (I guess
> you can't have them on 2 cpus at the same time)?
>=20

get_counters() is serialized by the xt_find_table_lock() done from
get_entries(). This use a mutex to guard against changes.

You are right that if we ever allow two concurrent "iptables -nvL"
operations in the future (using a read lock on a rwlock instead of a
mutex), then we must disable BH even for summing data from the other
cpus.

Thanks


