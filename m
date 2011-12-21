From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netlink: use vzalloc()
Date: Wed, 21 Dec 2011 18:00:23 -0500 (EST)
Message-ID: <20111221.180023.188534491320564804.davem@davemloft.net>
References: <20111221134833.76af35e6@nehalam.linuxnetplumber.net>
	<1324505551.2621.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109Ab1LUXA0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 18:00:26 -0500
In-Reply-To: <1324505551.2621.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2011 23:12:31 +0100

> Le mercredi 21 d=E9cembre 2011 =E0 13:48 -0800, Stephen Hemminger a =E9=
crit :
>> The netlink pid hash can be allocated using vzalloc() rather than di=
rect
>> access to get_free_pages. It is also safe for nl_pid_hash_zalloc to =
use
>> GFP_KERNEL since it is only called from netlink_proto_init and
>> nl_pid_hash_rehash. The former is already allocating table with GFP_=
KERNEL,
>> and the latter is called from netlink_insert() which already could=20
>> sleep in netlink_table_grab()
>>=20
>=20
>=20
> But netlink_table_grab() returns with write_lock_irq(&nl_table_lock);
>=20
> So we are not allowed to sleep in a
> netlink_table_grab()/netlink_table_ungrab() section .

Right.
