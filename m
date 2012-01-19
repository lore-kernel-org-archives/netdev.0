From: David Miller <davem@davemloft.net>
Subject: Re: inet6_dump_fib lock held when returning to user space
Date: Thu, 19 Jan 2012 13:07:33 -0500 (EST)
Message-ID: <20120119.130733.605355385139772621.davem@davemloft.net>
References: <201201191148.52121.hans.schillstrom@ericsson.com>
	<1326976399.2249.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hans.schillstrom@ericsson.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195Ab2ASSHk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 13:07:40 -0500
In-Reply-To: <1326976399.2249.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Jan 2012 13:33:19 +0100

> Le jeudi 19 janvier 2012 =E0 11:48 +0100, Hans Schillstrom a =E9crit =
:
>> Hello
>> Have this one been seen before ?
>> It happens during a container start i.e. in a netns,
>>=20
>> [   19.232941] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>> [   19.268785] [ BUG: lock held when returning to user space! ]
>> [   19.270146] 3.2.0+ #14 Tainted: G        W  =20
>> [   19.271217] ------------------------------------------------
>> [   19.272968] nsm/1042 is leaving the kernel with locks still held!
>> [   19.274603] 1 lock held by nsm/1042:
>> [   19.275524]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff8136a9b2=
>] inet6_dump_fib+0xbd/0x34a
>>=20
>=20
> Yep, Dave Jones reported this some days ago
>=20
> "Re: recvmsg sleeping from invalid context"
>=20
> I have no idea of what happens yet.

The only way I can this happening in inet6_dump_fib() is if we somehow
sleep during fib6_dump_table(), and then return to userspace in
another task.

But that makes no sense, since in such a case we should see the
warning instead when the task schedules out, not when the
inet6_dump_fib calling task goes back to userspace.

I wonder if Dave Jones's report is even related to this one.
