From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net: Introduce dev_get_by_index_rcu()
Date: Tue, 20 Oct 2009 14:06:32 +0900
Message-ID: <20091020140632.79efb738@s6510>
References: <4ADD3794.8030906@gmail.com>
	<20091019.212018.79580287.davem@davemloft.net>
	<4ADD3B5A.1080905@gmail.com>
	<20091019.212855.179405364.davem@davemloft.net>
	<4ADD44B0.8030204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49537 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbZJTFGh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 01:06:37 -0400
In-Reply-To: <4ADD44B0.8030204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Oct 2009 07:03:44 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> David Miller a =C3=A9crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 20 Oct 2009 06:23:54 +0200
> >=20
> >> I wonder if the whole thing could use RCU somehow, since some
> >> workloads hit this dev_base_lock rwlock pretty hard...
> >=20
> > True, but for now we'll put your fix in :-)
>=20
> [PATCH net-next-2.6] net: Introduce dev_get_by_index_rcu()
>=20
> Some workloads hit dev_base_lock rwlock pretty hard.
> We can use RCU lookups to avoid touching this rwlock.
>=20
> netdevices are already freed after a RCU grace period, so this patch
> adds no penalty at device dismantle time.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

All usage dev_base_lock should be replaceable by using combination of r=
tnl_mutex
and RCU?
