From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: recvmsg sleeping from invalid context
Date: Sun, 22 Jan 2012 08:54:59 +0100
Message-ID: <201201220854.59968.maciej.rutecki@gmail.com>
References: <20120113182401.GA25885@redhat.com>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Dave Jones <davej@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120113182401.GA25885@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On pi=C4=85tek, 13 stycznia 2012 o 19:24:01 Dave Jones wrote:
> getting a ton of these on the latest head
> (099469502f62fbe0d7e4f0b83a2f22538367f734)
>=20
> BUG: sleeping function called from invalid context at mm/memory.c:390=
5
> in_atomic(): 0, irqs_disabled(): 0, pid: 1067, name: NetworkManager
> INFO: lockdep is turned off.
> Pid: 1067, comm: NetworkManager Not tainted 3.2.0+ #22
> Call Trace:
>  [<ffffffff81099415>] __might_sleep+0x145/0x200
>  [<ffffffff811752a4>] might_fault+0x34/0xb0
>  [<ffffffff81551555>] ? sock_def_readable+0x25/0x1a0
>  [<ffffffff8155c387>] put_cmsg+0x77/0x120
>  [<ffffffff8159379c>] netlink_recvmsg+0x35c/0x480
>  [<ffffffff8155201a>] ? sock_update_classid+0x9a/0x260
>  [<ffffffff81552052>] ? sock_update_classid+0xd2/0x260
>  [<ffffffff81549fbd>] sock_recvmsg+0x11d/0x140
>  [<ffffffff811752c3>] ? might_fault+0x53/0xb0
>  [<ffffffff8117530c>] ? might_fault+0x9c/0xb0
>  [<ffffffff811752c3>] ? might_fault+0x53/0xb0
>  [<ffffffff8154b1b3>] __sys_recvmsg+0x153/0x2d0
>  [<ffffffff811bc39a>] ? fget_light+0x5a/0x470
>  [<ffffffff8109fd11>] ? get_parent_ip+0x11/0x50
>  [<ffffffff816ac23d>] ? sub_preempt_count+0x9d/0xd0
>  [<ffffffff811bc43b>] ? fget_light+0xfb/0x470
>  [<ffffffff811bc39a>] ? fget_light+0x5a/0x470
>  [<ffffffff8154e2e9>] sys_recvmsg+0x49/0x90
>  [<ffffffff816b00e9>] system_call_fastpath+0x16/0x1b
>=20
>=20
> BUG: sleeping function called from invalid context at kernel/mutex.c:=
271
> in_atomic(): 0, irqs_disabled(): 0, pid: 1067, name: NetworkManager
> INFO: lockdep is turned off.
> Pid: 1067, comm: NetworkManager Not tainted 3.2.0+ #22
> Call Trace:
>  [<ffffffff81099415>] __might_sleep+0x145/0x200
>  [<ffffffff816a529e>] mutex_lock_nested+0x2e/0x50
>  [<ffffffff812022d0>] inotify_poll+0x30/0x60
>  [<ffffffff811d16f0>] do_sys_poll+0x280/0x500
>  [<ffffffff811d01b0>] ? poll_freewait+0xe0/0xe0
>  [<ffffffff811d02a0>] ? __pollwait+0xf0/0xf0
>  [<ffffffff811d02a0>] ? __pollwait+0xf0/0xf0
>  [<ffffffff811d02a0>] ? __pollwait+0xf0/0xf0
>  [<ffffffff811d02a0>] ? __pollwait+0xf0/0xf0
>  [<ffffffff811d02a0>] ? __pollwait+0xf0/0xf0
>  [<ffffffff811d02a0>] ? __pollwait+0xf0/0xf0
>  [<ffffffff811d02a0>] ? __pollwait+0xf0/0xf0
>  [<ffffffff8109fd11>] ? get_parent_ip+0x11/0x50
>  [<ffffffff816ac23d>] ? sub_preempt_count+0x9d/0xd0
>  [<ffffffff811bc39a>] ? fget_light+0x5a/0x470
>  [<ffffffff8154dc2b>] ? sys_sendto+0x15b/0x190
>  [<ffffffff810b776d>] ? ktime_get_ts+0xad/0xe0
>  [<ffffffff811d049a>] ? poll_select_set_timeout+0x7a/0x90
>  [<ffffffff811d1a56>] sys_poll+0x76/0x110
>  [<ffffffff816b00e9>] system_call_fastpath+0x16/0x1b
>=20

I created a Bugzilla entry at=20
https://bugzilla.kernel.org/show_bug.cgi?id=3D42629
for your bug report, please add your address to the CC list in there, t=
hanks!

--=20
Maciej Rutecki
http://www.mrutecki.pl
