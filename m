From: =?ISO-8859-2?Q?Micha=B3_Margula?= <alchemyx@uznam.net.pl>
Subject: Re: Fw: [Bugme-new] [Bug 3747] New: HTB causes machine lockups
Date: Mon, 22 Nov 2004 19:10:11 +0100
Message-ID: <41A22B83.2050002@uznam.net.pl>
References: <20041115122059.4cfcd213.akpm@osdl.org> <20041115233806.GC31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041115233806.GC31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf napisa=B3(a):

>Did you ever experience the same problems with other classful qdiscs suc=
h as
>CBQ? Would it be possible for you to run a similar CBQ setup on a dummy =
device
>and see if it happens as well? Is anything going on at the time of the
>deadlocks like an interface going down etc.?
>
> =20
>
At the moment I can't make such CBQ configuration, because I have no=20
free time, too much work. But in about few weeks I am going to convert=20
that box 2.6.x kernels. After that if hangs don't stop, we can think=20
about converting that to CBQ, ok?

And by the way, today I got that in my logs:

Nov 22 17:50:01 sauron kernel: Unable to handle kernel NULL pointer=20
dereference at virtual address 00000000
Nov 22 17:50:01 sauron kernel:  printing eip:
Nov 22 17:50:01 sauron kernel: f89cb555
Nov 22 17:50:01 sauron kernel: *pde =3D 00000000
Nov 22 17:50:01 sauron kernel: Oops: 0000
Nov 22 17:50:01 sauron kernel: CPU:    3
Nov 22 17:50:01 sauron kernel: EIP:   =20
0010:[cls_u32:__insmod_cls_u32_O/lib/modules/2.4.26/kernel/net/sched/cls_=
+-146091/96]   =20
Not tainted
Nov 22 17:50:01 sauron kernel: EFLAGS: 00010202
Nov 22 17:50:01 sauron kernel: eax: 000000b0   ebx: 00000000   ecx:=20
c02f9888   edx: 000000b0
Nov 22 17:50:01 sauron kernel: esi: f04a7dd8   edi: f4eb5068   ebp:=20
f4eb5068   esp: f04a7d90
Nov 22 17:50:01 sauron kernel: ds: 0018   es: 0018   ss: 0018
Nov 22 17:50:01 sauron kernel: Process tc (pid: 6600, stackpage=3Df04a700=
0)
Nov 22 17:50:01 sauron kernel: Stack: f4eb5000 00000930 c57fd824=20
c57fd800 f4eb5068 00000000 f4eb5060 c02021c5
Nov 22 17:50:01 sauron kernel:        f4eb5000 f04a7dd8 e6eb8880=20
c92aab00 c57fd800 c92aab00 c57fd818 dc9a8e90
Nov 22 17:50:01 sauron kernel:        f7ceb000 0000092f 00000000=20
00000000 00000001 c02020b4 e6eb8880 c57fd800
Nov 22 17:50:01 sauron kernel: Call Trace:    [tc_dump_tclass+221/304]=20
[qdisc_class_dump+0/52] [netlink_dump+130/464] [skb_free_datagram+29/36]=20
[netlink_recvmsg+190/300]
Nov 22 17:50:01 sauron kernel:   [netlink_recvmsg+229/300]=20
[sock_recvmsg+61/188] [sys_recvmsg+356/516] [handle_mm_fault+92/188]=20
[schedule+1115/1312] [pipe_write+518/616]
Nov 22 17:50:01 sauron kernel:   [sys_socketcall+501/512]=20
[system_call+51/56]
Nov 22 17:50:01 sauron kernel:
Nov 22 17:50:01 sauron kernel: Code: 8b 03 0f 18 00 39 fb 75 c2 83 44 24=20
10 08 83 c5 08 ff 44 24
Nov 22 17:50:01 sauron kernel:  <6>HTB init, kernel part version 3.16

And my HTB rules stopped working.

--=20
Micha=B3 Margula, alchemyx@uznam.net.pl, http://alchemyx.uznam.net.pl/
"W =BFyciu pi=EAkne s=B1 tylko chwile" [Ryszard Riedel]
