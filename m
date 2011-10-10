From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] macvlan: handle fragmented multicast frames
Date: Mon, 10 Oct 2011 18:41:31 +0200
Message-ID: <1318264891.3227.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E8C89EE.3090600@candelatech.com>
	 <1317844449.3457.3.camel@edumazet-laptop>
	 <4E8CB990.1010406@candelatech.com>
	 <1317845835.3457.5.camel@edumazet-laptop>
	 <4E8CBBD6.3080500@candelatech.com>
	 <1317846693.3457.11.camel@edumazet-laptop>
	 <4E8CC474.7050803@candelatech.com>
	 <1317850603.3457.21.camel@edumazet-laptop>
	 <4E8CD180.5010905@candelatech.com>  <4E8CDB9B.6010900@candelatech.com>
	 <1317932911.3457.31.camel@edumazet-laptop>
	 <4E931CEC.5050404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:46828 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562Ab1JJQlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 12:41:16 -0400
Received: by yxl31 with SMTP id 31so5534629yxl.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 09:41:15 -0700 (PDT)
In-Reply-To: <4E931CEC.5050404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 octobre 2011 =C3=A0 09:27 -0700, Ben Greear a =C3=A9crit :

> I applied this to Linus' top-of-tree this morning and it does appear
> to fix the problem for mac-vlans.
>=20

Thanks for testing

> I do see this error, but I doubt it has anything to do with your
> patch:
>=20
> device eth0 entered promiscuous mode
> device rddVR10 entered promiscuous mode
> ADDRCONF(NETDEV_CHANGE): rddVR1b: link becomes ready
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
> [ BUG: lock held when returning to user space! ]
> ------------------------------------------------
> ip/3452 is leaving the kernel with locks still held!
> 1 lock held by ip/3452:
>   #0:  (rcu_read_lock){.+.+..}, at: [<f8c5336f>] rcu_read_lock+0x0/0x=
26 [ipv6]
> ADDRCONF(NETDEV_CHANGE): rddVR4b: link becomes ready
> ADDRCONF(NETDEV_CHANGE): rddVR5b: link becomes ready
>=20
>=20
> I have no idea why it doesn't print out a more useful stack
> trace.  It seems repeatable (2 of 2 reboots so far).  I'm
> configuring a pretty complex virtual network, with veth devices,
> xorp instances running ipv4 and ipv6 routing protocols, etc.
>=20

Do you have LOCKDEP enabled ?

> This is a clean upstream kernel with no outside patches aside from yo=
ur
> own.

Hmm, it seems we have an rcu_read_unlock() missing...

Any idea what was done by this "ip" command ?
