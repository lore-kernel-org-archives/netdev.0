From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Mon, 08 Nov 2010 08:33:32 +0100
Message-ID: <1289201612.2478.371.camel@edumazet-laptop>
References: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
	 <1289172456.3090.184.camel@Dan> <20101107235610.GE17592@basil.fritz.box>
	 <20101107.180108.71121019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@firstfloor.org, drosenberg@vsecurity.com,
	chas3@users.sourceforge.net, tytso@mit.edu,
	torvalds@linux-foundation.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com,
	netdev@vger.kernel.org, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47154 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043Ab0KHHdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 02:33:38 -0500
Received: by wyb36 with SMTP id 36so3166867wyb.19
        for <netdev@vger.kernel.org>; Sun, 07 Nov 2010 23:33:37 -0800 (PST)
In-Reply-To: <20101107.180108.71121019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 07 novembre 2010 =C3=A0 18:01 -0800, David Miller a =C3=A9c=
rit :
> From: Andi Kleen <andi@firstfloor.org>
> Date: Mon, 8 Nov 2010 00:56:10 +0100
>=20
> > I would just remove the pointers from /proc and supply=20
> > gdb macros that extract the equivalent information from /proc/kcore=
=2E
> > This is a bit racy, but for debugging it should be no
> > problem to run them multiple times as needed.
>=20
> I do not think at all that this is tenable for the kind of
> things people use the socket pointers for when debugging
> problems.
>=20
> I defeinitely prefer the inode number to this idea.

We currently have no guarantee of sockets inode numbers unicity.
I admit chances of clash are low.

When a printk() happens right before a BUG(), how are we going to check
the dumped registers are possibly close the socket involved, if we dont
have access to the machine, and only the crashlog ?

BTW, any local user can look at "dmesg", and crash reports. These
reports are even published on a remote site (bugzilla) so that hostile
hackers can be feeded.

I am OK to delete socket pointers from /proc files for non root users
(after checking things like lsof continue to work correctly).
I dont remember using them while doing debugging stuff.

BTW, rtnetlink also expose socket pointers to non root users :

$ ss -e dst 192.168.20.108
State      Recv-Q Send-Q    Local Address:Port    Peer Address:Port  =20
ESTAB      0      0         10.150.51.210:46979   192.168.20.108:ssh=20
timer:(keepalive,119min,0) ino:136919 sk:ffff88002129d7c0


Mixing in same patch /proc pointers removal and printk() pointers
removal seems wrong to me. Very different problems.



