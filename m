From: Ingo Molnar <mingo@elte.hu>
Subject: Re: vhost_dev_cleanup() crash: BUG: unable to handle kernel NULL
 pointer dereference
Date: Tue, 31 Aug 2010 13:14:13 +0200
Message-ID: <20100831111413.GB12853@elte.hu>
References: <20100831075705.GA4710@elte.hu>
 <1283251801.2550.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1283251801.2550.53.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 31 ao=FBt 2010 =E0 09:57 +0200, Ingo Molnar a =E9crit :
> > FYI, there's a new crash in the vnet driver that occasionally trigg=
ers=20
> > on ordinary host bootups as well, when (non-virtualized) networking=
=20
> > initializes:
> >=20
> >  [   86.563889]  [<ffffffff81b05655>] page_fault+0x25/0x30
> >  [   86.569065]  [<ffffffff8186d899>] ? vhost_poll_flush+0x11a/0x15=
6
> >  [   86.575119]  [<ffffffff8105f511>] ? kthread_stop+0xa/0x57
> >  [   86.580544]  [<ffffffff8186e535>] vhost_dev_cleanup+0x269/0x271
> >  [   86.586528]  [<ffffffff8186e974>] vhost_net_release+0x48/0x7f
> >  [   86.592359]  [<ffffffff810c5419>] fput+0x120/0x1d4
> >  [   86.597185]  [<ffffffff810c2a1d>] filp_close+0x63/0x6d
> >  [   86.602353]  [<ffffffff810c2acf>] sys_close+0xa8/0xe2
> >  [   86.607429]  [<ffffffff81008602>] system_call_fastpath+0x16/0x1=
b
> >=20
> > See the full crashlog below. Config attached.
> >=20
> > AFAICT this bug probably went upstream during the merge window.
> >=20
> > Thanks,
> >=20
> > 	Ingo
> >=20
> > [   86.262123] BUG: unable to handle kernel NULL pointer dereferenc=
e at 0000000000000010
> > [   86.265200] IP:ntry for device- [<ffffffff8105f511>] kthread_sto=
p+0xa/0x57
> > [   86.265200] PGD 3ad75067 PUD 3b352067 PMD 0=20
> > [   86.265200] Oops: 0002 [#1] SMP=20
> > [   86.265200] last sysfs file: /sys/devices/pnp0/00:0d/id
> > [   86.265200] CPU 0 mapper found
> > Is
> > [   86.265200] Pid: 1254, comm: multipath.stati Not tainted 2.6.36-=
rc3-tip+ #31158 A8N-E/System Product Name
> >  device-mapper d[   86.265200] RIP: 0010:[<ffffffff8105f511>]  [<ff=
ffffff8105f511>] kthread_stop+0xa/0x57
> > river missing fr[   86.265200] RSP: 0018:ffff88003ae83e58  EFLAGS: =
00010246
> > [   86.265200] RAX: ffff88003d1dc170 RBX: 0000000000000000 RCX: 000=
0000000000000
> > [   86.265200] RDX: ffff88003aa82030 RSI: 0000000000000001 RDI: 000=
0000000000000
> > om kernel?
> > devi[   86.265200] RBP: ffff88003ae83e68 R08: ffff88003ae83e68 R09:=
 0000000000000001
> > [   86.265200] R10: ffffffff8186d899 R11: 0000000000000246 R12: fff=
f88003d1dc8f0
> > [   86.265200] R13: 0000000000000002 R14: ffff88003b2a1000 R15: fff=
f88003aa82030
> > [   86.265200] FS:  0000000001fc5880(0063) GS:ffff88003fc00000(0000=
) knlGS:0000000000000000
> > ce-mapper: versi[   86.265200] CS:  0010 DS: 0000 ES: 0000 CR0: 000=
000008005003b
> > [   86.265200] CR2: 0000000000000010 CR3: 000000003b377000 CR4: 000=
00000000006f0
> > on ioctl failed:[   86.265200] DR0: 0000000000000000 DR1: 000000000=
0000000 DR2: 0000000000000000
> > [   86.265200] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [   86.265200] Process multipath.stati (pid: 1254, threadinfo ffff8=
8003ae82000, task ffff88003b3e8000)
> > [   86.265200] Stack:
> > [   86.265200]  ffff88003d1dc090 ffff88003d1dc8f0 ffff88003ae83e98 =
ffffffff8186e535
> > [   86.265200] <0> ffff88003ae83e98 ffff88003d1dc090 00000000000000=
00 0000000000000000
> > [   86.265200] <0> ffff88003ae83ec8 ffffffff8186e974 00000000000000=
08 ffff88003b3a6180
> > [   86.265200] Call Trace:
> > [   86.265200]  [<ffffffff8186e535>] vhost_dev_cleanup+0x269/0x271
> >  Operation not p[   86.265200]  [<ffffffff8186e974>] vhost_net_rele=
ase+0x48/0x7f
> > [   86.265200]  [<ffffffff810c5419>] fput+0x120/0x1d4
> > ermitted
> > [   86.265200]  [<ffffffff810c2a1d>] filp_close+0x63/0x6d
> > [   86.265200]  [<ffffffff810c2acf>] sys_close+0xa8/0xe2
> > [   86.265200]  [<ffffffff81008602>] system_call_fastpath+0x16/0x1b
> > [   86.265200] Code: 4c 8b 25 83 b4 16 01 49 81 fc 70 a9 1c 82 75 9=
4 48 c7 c7 80 a9 1c 82 e8 99 5b aa 00 e9 50 ff ff ff 55 48 89 e5 41 54 =
53 48 89 fb <f0> ff 47 10 4c 8b a7 00 05 00 00 48 83 bf 00 05 00 00 00 =
74 16=20
> > [   86.265200] RIP  [<ffffffff8105f511>] kthread_stop+0xa/0x57
> > [   86.265200]  RSP <ffff88003ae83e58>
> > [   86.265200] CR2: 0000000000000010
> > [   86.499743] ---[ end trace 433623c38ffeb225 ]---
> > [   86.504397] Kernel panic - not syncing: Fatal exception
> > [   86.509633] Pid: 1254, comm: multipath.stati Tainted: G      D  =
   2.6.36-rc3-tip+ #31158
> > [   86.517858] Call Trace:
> > [   86.520343]  [<ffffffff81b01c87>] panic+0x8c/0x196
> > [   86.525181]  [<ffffffff81048405>] ? kmsg_dump+0x126/0x140
> > [   86.530606]  [<ffffffff8100c43d>] oops_end+0x8f/0x9c
> > [   86.535611]  [<ffffffff8102d93d>] no_context+0x1f7/0x206
> > [   86.540948]  [<ffffffff8102dacb>] __bad_area_nosemaphore+0x17f/0=
x1a2
> > [   86.547334]  [<ffffffff8102db40>] bad_area+0x42/0x49
> > [   86.552329]  [<ffffffff8102de84>] do_page_fault+0x1fe/0x363
> > [   86.557925]  [<ffffffff81352dff>] ? do_raw_spin_lock+0x6b/0x122
> > [   86.563889]  [<ffffffff81b05655>] page_fault+0x25/0x30
> > [   86.569065]  [<ffffffff8186d899>] ? vhost_poll_flush+0x11a/0x156
> > [   86.575119]  [<ffffffff8105f511>] ? kthread_stop+0xa/0x57
> > [   86.580544]  [<ffffffff8186e535>] vhost_dev_cleanup+0x269/0x271
> > [   86.586528]  [<ffffffff8186e974>] vhost_net_release+0x48/0x7f
> > [   86.592359]  [<ffffffff810c5419>] fput+0x120/0x1d4
> > [   86.597185]  [<ffffffff810c2a1d>] filp_close+0x63/0x6d
> > [   86.602353]  [<ffffffff810c2acf>] sys_close+0xa8/0xe2
> > [   86.607429]  [<ffffffff81008602>] system_call_fastpath+0x16/0x1b
> > [   86.613516] Rebooting in 1 seconds..Press any key to enter the m=
enu
>=20
> Hi Ingo
>=20
> Seems to be commit c23f3445e68e1
> (vhost: replace vhost_workqueue with per-vhost kthread)
>=20
> following patch should cure it ?
>=20
> Thanks
>=20
> [PATCH] vhost: stop worker only if created
>=20
> Its illegal to call kthread_stop(NULL)
>=20
> Reported-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index e05557d..0a00121 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -323,7 +323,8 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
>  	dev->mm =3D NULL;
> =20
>  	WARN_ON(!list_empty(&dev->work_list));
> -	kthread_stop(dev->worker);
> +	if (dev->worker)
> +		kthread_stop(dev->worker);

Btw., i think this check should be pushed into kthread_stop() instead -=
=20
just like kfree(NULL) is possible as well - it simplifies cleanup=20
sequences.

Thanks,

	Ingo
