From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] ipv4: speedup inet_dump_ifaddr()
Date: Thu, 12 Nov 2009 11:12:18 -0800
Message-ID: <20091112111218.0a561166@nehalam>
References: <4AFC1798.1060501@gmail.com>
	<20091112091221.3d523253@nehalam>
	<4AFC4979.7030007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39280 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059AbZKLTMd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 14:12:33 -0500
In-Reply-To: <4AFC4979.7030007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 18:44:25 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > On Thu, 12 Nov 2009 15:11:36 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> >> When handling large number of netdevices, inet_dump_ifaddr()
> >> is very slow because it has O(N^2) complexity.
> >>
> >> Instead of scanning one single list, we can use the NETDEV_HASHENT=
RIES
> >> sub lists of the dev_index hash table, and RCU lookups.
> >>
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > You might be able to make RCU critical section smaller by moving
> > it into loop.
> >=20
>=20
> Indeed. But we dump at most one skb (<=3D 8192 bytes ?), so rcu_read_=
lock
> holding time is small, unless we meet many netdevices without
> addresses. I wonder if its really common...
>=20
> Thanks

One case where that might happen is:
  modprobe dummy numdummies=3D10000

But dummy device should really be added with netlink, not at boot time.

--=20
