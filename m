From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sleeping function called from invalid context (rtnetlink)
Date: Thu, 1 Mar 2012 16:53:32 -0800
Message-ID: <CAL4WiirCK6a5pgHCZyL7WAC6xrOnBWnx+6tw73x0StWfoPdaHw@mail.gmail.com>
References: <bug-799099-176318@bugzilla.redhat.com>
	<20120301235928.GA28088@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40988 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756921Ab2CBAxd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 19:53:33 -0500
Received: by iagz16 with SMTP id z16so1572482iag.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 16:53:32 -0800 (PST)
In-Reply-To: <20120301235928.GA28088@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 1 mars 2012 15:59, Dave Jones <davej@redhat.com> a =E9crit :
> Just had this reported by a Fedora user.
> It's against 3.3-rc4, but afaik, the only changes to rtnetlink
> since then wouldn't have fixed this unless I've overlooked something.
>
> https://bugzilla.redhat.com/show_bug.cgi?id=3D799099
>
> BUG: sleeping function called from invalid context at kernel/mutex.c:=
271
> in_atomic(): 1, irqs_disabled(): 0, pid: 10451, name: NetworkManager
> INFO: lockdep is turned off.
> Pid: 10451, comm: NetworkManager Not tainted 3.3.0-0.rc4.git1.4.fc17.=
x86_64 #1
> Call Trace:
> =A0[<ffffffff810966fc>] __might_sleep+0x13c/0x200
> =A0[<ffffffff8154c470>] ? sock_def_readable+0x30/0x1c0
> =A0[<ffffffff8169a81e>] mutex_lock_nested+0x2e/0x3a0
> =A0[<ffffffff81571100>] ? rtnetlink_net_init+0x50/0x50
> =A0[<ffffffff8158e25c>] ? netlink_dump_start+0xdc/0x180
> =A0[<ffffffff81571100>] ? rtnetlink_net_init+0x50/0x50
> =A0[<ffffffff81571897>] rtnl_lock+0x17/0x20
> =A0[<ffffffff81573ef8>] rtnetlink_rcv_msg+0x1f8/0x2e0
> =A0[<ffffffff81571897>] ? rtnl_lock+0x17/0x20
> =A0[<ffffffff81573d00>] ? __rtnl_unlock+0x20/0x20
> =A0[<ffffffff815901b1>] netlink_rcv_skb+0xa1/0xb0
> =A0[<ffffffff815718c5>] rtnetlink_rcv+0x25/0x40
> =A0[<ffffffff8158fafd>] netlink_unicast+0x19d/0x1f0
> =A0[<ffffffff8158fe2b>] netlink_sendmsg+0x2db/0x360
> =A0[<ffffffff8154c66d>] ? sock_update_netprioidx+0x6d/0x250
> =A0[<ffffffff81544888>] sock_sendmsg+0xf8/0x130
> =A0[<ffffffff81545f9d>] ? sock_recvmsg+0xfd/0x130
> =A0[<ffffffff811745d5>] ? might_fault+0xa5/0xb0
> =A0[<ffffffff8117458c>] ? might_fault+0x5c/0xb0
> =A0[<ffffffff81555266>] ? verify_iovec+0x56/0xd0
> =A0[<ffffffff81545e8e>] __sys_sendmsg+0x42e/0x440
> =A0[<ffffffff811bd612>] ? fget_light+0x62/0x4a0
> =A0[<ffffffff811bd6a0>] ? fget_light+0xf0/0x4a0
> =A0[<ffffffff811bd612>] ? fget_light+0x62/0x4a0
> =A0[<ffffffff81548c59>] sys_sendmsg+0x49/0x90
> =A0[<ffffffff816a74a9>] system_call_fastpath+0x16/0x1b
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

Yes, this is on my TODO list, it should be done in a couple of days.

Thanks
