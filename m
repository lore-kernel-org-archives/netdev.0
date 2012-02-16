From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42754] New: BUG: sleeping function called from invalid
 context at mm/memory.c:3924
Date: Thu, 16 Feb 2012 16:24:59 +0100
Message-ID: <1329405899.10004.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <bug-42754-27@https.bugzilla.kernel.org/>
	 <20120209191317.2fbad57b.akpm@linux-foundation.org>
	 <20120210122657.GA9347@smp.if.uj.edu.pl>
	 <20120212175004.GM3737@linux.vnet.ibm.com> <1329310952.2293.80.camel@twins>
	 <20120216151019.GC19642@smp.if.uj.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	paulmck@linux.vnet.ibm.com,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	rostedt@goodmis.org, davej@redhat.com,
	David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>
To: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64523 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab2BPPZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 10:25:04 -0500
Received: by bkcjm19 with SMTP id jm19so2055774bkc.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 07:25:03 -0800 (PST)
In-Reply-To: <20120216151019.GC19642@smp.if.uj.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 16:10 +0100, Witold Baryluk a =C3=A9=
crit :
> On 02-15 14:02, Peter Zijlstra wrote:
> > On Sun, 2012-02-12 at 09:50 -0800, Paul E. McKenney wrote:
> > > > I do not know why lockdep is disabled, because I configured ker=
nel to
> > > > keep telling my about lock dependency problems even after showi=
ng first
> > > > one. AFAIK.=20
> >=20
> > That setting is only relevant to RCU, normal lockdep reports will a=
lways
> > disable lockdep.
>=20
> One more thing about a bug.
>=20
> I was able to reproduce bug yestarday , and again today.
>=20
> First one is again in NetworkManager process (just after loging in to
> gnome, exactly like previously), and again NetworkManager process is
> killed. And again restarting NM manually make it happy (and works
> without further problems). So indeed it looks to be problem with
> netlink, because netlink_recvmsg is common call here.
>=20
> Second one is also in netlink, but process is this time ip, and messa=
ge
> is
>=20
> [ 9136.204156] BUG: sleeping function called from invalid context at =
kernel/mutex.c:271
>=20
> full stacks bellow.
>=20
> Regards,
> Witek
>=20
> 1)
>=20
> [    0.000000] Linux version 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-d=
irty (baryluk@sredniczarny) (gcc version 4.6.2 (Debian 4.6.2-14) ) #22 =
SMP Sat Feb 11 23:16:44 CET 2012
> ..
> [ 1078.282836] BUG: sleeping function called from invalid context at =
mm/memory.c:3924
> [ 1078.282843] in_atomic(): 1, irqs_disabled(): 0, pid: 3953, name: N=
etworkManager
> [ 1078.282847] INFO: lockdep is turned off.
> [ 1078.282852] Pid: 3953, comm: NetworkManager Tainted: G        W  O=
 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
> [ 1078.282856] Call Trace:
> [ 1078.282868]  [<c107d554>] __might_sleep+0x124/0x1d0
> [ 1078.282875]  [<c11400ee>] might_fault+0x2e/0xb0
> [ 1078.282882]  [<c131d3ab>] copy_to_user+0x3b/0x60
> [ 1078.282889]  [<c1568172>] put_cmsg+0x52/0xd0
> [ 1078.282903]  [<c159a917>] netlink_recvmsg+0x287/0x340
> [ 1078.282910]  [<c1557aa3>] sock_recvmsg+0xd3/0x110
> [ 1078.282916]  [<c1140114>] ? might_fault+0x54/0xb0
> [ 1078.282921]  [<c15663bc>] ? verify_iovec+0x4c/0xc0
> [ 1078.282926]  [<c15579d0>] ? sock_sendmsg_nosec+0x100/0x100
> [ 1078.282931]  [<c15588f4>] __sys_recvmsg+0x114/0x1e0
> [ 1078.282938]  [<c1082752>] ? check_preempt_curr+0x72/0x90
> [ 1078.282943]  [<c1082be2>] ? ttwu_queue+0x42/0xc0
> [ 1078.282949]  [<c10b26f1>] ? __lock_acquired+0x2e1/0x330
> [ 1078.282956]  [<c1177a65>] ? fget_light+0xc5/0x410
> [ 1078.282961]  [<c1177a79>] ? fget_light+0xd9/0x410
> [ 1078.282965]  [<c11779e5>] ? fget_light+0x45/0x410
> [ 1078.282971]  [<c155a5b9>] sys_recvmsg+0x39/0x60
> [ 1078.282976]  [<c155ab13>] sys_socketcall+0x2e3/0x330
> [ 1078.282982]  [<c17adacd>] ? sysenter_exit+0xf/0x1a
> [ 1078.282988]  [<c131cba8>] ? trace_hardirqs_on_thunk+0xc/0x10
> [ 1078.282993]  [<c17ada98>] sysenter_do_call+0x12/0x38
> [ 1078.282999]  [<c17a007b>] ? trace_packet+0x104/0x154
> [ 1078.294339]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
> [ 1078.294344]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
> [ 1078.294349]  [<c1016ccd>] do_notify_resume+0x5d/0x80
> [ 1078.294354]  [<c17a5d6a>] work_notifysig+0x25/0x2b
> [ 1078.294359]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190

Yes, I am aware of this and I'll take a look.

Thanks
