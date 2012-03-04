From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sleeping function called from invalid context (rtnetlink)
Date: Sat, 03 Mar 2012 21:00:14 -0800
Message-ID: <1330837214.2730.6.camel@edumazet-laptop>
References: <bug-799099-176318@bugzilla.redhat.com>
	 <20120301235928.GA28088@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:52545 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab2CDFAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 00:00:20 -0500
Received: by dadp12 with SMTP id p12so3550039dad.11
        for <netdev@vger.kernel.org>; Sat, 03 Mar 2012 21:00:19 -0800 (PST)
In-Reply-To: <20120301235928.GA28088@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 mars 2012 =C3=A0 18:59 -0500, Dave Jones a =C3=A9crit :
> Just had this reported by a Fedora user.
> It's against 3.3-rc4, but afaik, the only changes to rtnetlink
> since then wouldn't have fixed this unless I've overlooked something.
>=20
> https://bugzilla.redhat.com/show_bug.cgi?id=3D799099
>=20
> BUG: sleeping function called from invalid context at kernel/mutex.c:=
271
> in_atomic(): 1, irqs_disabled(): 0, pid: 10451, name: NetworkManager
> INFO: lockdep is turned off.
> Pid: 10451, comm: NetworkManager Not tainted 3.3.0-0.rc4.git1.4.fc17.=
x86_64 #1
> Call Trace:
>  [<ffffffff810966fc>] __might_sleep+0x13c/0x200
>  [<ffffffff8154c470>] ? sock_def_readable+0x30/0x1c0
>  [<ffffffff8169a81e>] mutex_lock_nested+0x2e/0x3a0
>  [<ffffffff81571100>] ? rtnetlink_net_init+0x50/0x50
>  [<ffffffff8158e25c>] ? netlink_dump_start+0xdc/0x180
>  [<ffffffff81571100>] ? rtnetlink_net_init+0x50/0x50
>  [<ffffffff81571897>] rtnl_lock+0x17/0x20
>  [<ffffffff81573ef8>] rtnetlink_rcv_msg+0x1f8/0x2e0
>  [<ffffffff81571897>] ? rtnl_lock+0x17/0x20
>  [<ffffffff81573d00>] ? __rtnl_unlock+0x20/0x20
>  [<ffffffff815901b1>] netlink_rcv_skb+0xa1/0xb0
>  [<ffffffff815718c5>] rtnetlink_rcv+0x25/0x40
>  [<ffffffff8158fafd>] netlink_unicast+0x19d/0x1f0
>  [<ffffffff8158fe2b>] netlink_sendmsg+0x2db/0x360
>  [<ffffffff8154c66d>] ? sock_update_netprioidx+0x6d/0x250
>  [<ffffffff81544888>] sock_sendmsg+0xf8/0x130
>  [<ffffffff81545f9d>] ? sock_recvmsg+0xfd/0x130
>  [<ffffffff811745d5>] ? might_fault+0xa5/0xb0
>  [<ffffffff8117458c>] ? might_fault+0x5c/0xb0
>  [<ffffffff81555266>] ? verify_iovec+0x56/0xd0
>  [<ffffffff81545e8e>] __sys_sendmsg+0x42e/0x440
>  [<ffffffff811bd612>] ? fget_light+0x62/0x4a0
>  [<ffffffff811bd6a0>] ? fget_light+0xf0/0x4a0
>  [<ffffffff811bd612>] ? fget_light+0x62/0x4a0
>  [<ffffffff81548c59>] sys_sendmsg+0x49/0x90
>  [<ffffffff816a74a9>] system_call_fastpath+0x16/0x1b
>=20

I took a look at this and couldnt find a reason for this error.

Thats pretty strange...
