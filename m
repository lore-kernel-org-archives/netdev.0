From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Subject: Re: [PATCHSET v3] netfilter, cgroup: implement cgroup2 path match in
 xt_cgroup
Date: Mon, 23 Nov 2015 09:54:32 +0100
Message-ID: <5652D448.3080002@bmw-carit.de>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <5652BC3A.1010701@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <kernel-team-b10kYP2dOMg@public.gmane.org>,
	<ninasc-b10kYP2dOMg@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	<kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>, <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	<nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5652BC3A.1010701-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/23/2015 08:11 AM, Daniel Wagner wrote:
> [    3.217648] systemd[1]: tmp.mount: Directory /tmp to mount over is not empty, mounting anyway.
> [    3.224665] BUG: spinlock bad magic on CPU#1, systemd/1
> [    3.225653]  lock: cgroup_sk_update_lock+0x0/0x60, .magic: 00000000, .owner: systemd/1, .owner_cpu: 1
> [    3.227034] CPU: 1 PID: 1 Comm: systemd Not tainted 4.4.0-rc1+ #195
> [    3.227862] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
> [    3.228906]  ffffffff834a2160 ffff88007c043ad0 ffffffff81551edc ffff88007c028000
> [    3.229512]  ffff88007c043af0 ffffffff81136868 ffffffff834a2160 ffff88007aff5940
> [    3.230105]  ffff88007c043b08 ffffffff81136b05 ffffffff834a2160 ffff88007c043b20
> [    3.230716] Call Trace:
> [    3.230906]  [<ffffffff81551edc>] dump_stack+0x4e/0x82
> [    3.231289]  [<ffffffff81136868>] spin_dump+0x78/0xc0
> [    3.231642]  [<ffffffff81136b05>] do_raw_spin_unlock+0x75/0xd0
> [    3.232039]  [<ffffffff81bced77>] _raw_spin_unlock+0x27/0x50
> [    3.232431]  [<ffffffff819b1848>] update_classid_sock+0x68/0x80
> [    3.232836]  [<ffffffff812855c1>] iterate_fd+0x71/0x150
> [    3.233197]  [<ffffffff819b1757>] update_classid+0x47/0x80
> [    3.233571]  [<ffffffff819b17d4>] cgrp_attach+0x14/0x20
> [    3.233929]  [<ffffffff81188951>] cgroup_taskset_migrate+0x1e1/0x330
> [    3.234366]  [<ffffffff81188b95>] cgroup_migrate+0xf5/0x190
> [    3.234747]  [<ffffffff81188aa5>] ? cgroup_migrate+0x5/0x190
> [    3.235130]  [<ffffffff81188da6>] cgroup_attach_task+0x176/0x200
> [    3.235543]  [<ffffffff81188c35>] ? cgroup_attach_task+0x5/0x200
> [    3.235953]  [<ffffffff8118922d>] __cgroup_procs_write+0x2ad/0x460
> [    3.236377]  [<ffffffff81188fde>] ? __cgroup_procs_write+0x5e/0x460
> [    3.236805]  [<ffffffff81189414>] cgroup_procs_write+0x14/0x20
> [    3.237205]  [<ffffffff81185ae5>] cgroup_file_write+0x35/0x1c0
> [    3.237600]  [<ffffffff812e25e1>] kernfs_fop_write+0x141/0x190
> [    3.237998]  [<ffffffff81265e78>] __vfs_write+0x28/0xe0
> [    3.238361]  [<ffffffff811292c7>] ? percpu_down_read+0x57/0xa0
> [    3.238761]  [<ffffffff81268b04>] ? __sb_start_write+0xb4/0xf0
> [    3.239154]  [<ffffffff81268b04>] ? __sb_start_write+0xb4/0xf0
> [    3.239554]  [<ffffffff812665ec>] vfs_write+0xac/0x1a0
> [    3.239930]  [<ffffffff81285fa6>] ? __fget_light+0x66/0x90
> [    3.240308]  [<ffffffff81266f09>] SyS_write+0x49/0xb0
> [    3.240656]  [<ffffffff81bcfb32>] entry_SYSCALL_64_fastpath+0x12/0x76

I have enabled a few additional cgroup controllers as well, because I was
trying to figure out why I only see the 'memory' cgroup controller in 
cgroup.controllers. pid and io show up but not net_prio or net_cls.
Not sure why systemd (v227) is not mounting them.

Though, after a while a similar call trace is produced. I guess this
has nothing to do with the current changes.

[   11.594536] ------------[ cut here ]------------
[   11.595274] WARNING: CPU: 1 PID: 1 at kernel/cgroup_pids.c:97 pids_cancel.constprop.6+0x31/0x40()
[   11.595958] Modules linked in:
[   11.596199] CPU: 1 PID: 1 Comm: systemd Not tainted 4.4.0-rc1+ #196
[   11.596689] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[   11.597632]  ffffffff81f66d8b ffff88007c04bb90 ffffffff8155ccdc 0000000000000000
[   11.598234]  ffff88007c04bbc8 ffffffff810de202 ffff8800793dda00 ffff88007a096800
[   11.598877]  ffff88007c04bc80 ffff88007a6b6200 0000000000000001 ffff88007c04bbd8
[   11.599547] Call Trace:
[   11.599784]  [<ffffffff8155ccdc>] dump_stack+0x4e/0x82
[   11.600197]  [<ffffffff810de202>] warn_slowpath_common+0x82/0xc0
[   11.600705]  [<ffffffff810de2fa>] warn_slowpath_null+0x1a/0x20
[   11.601208]  [<ffffffff8118e261>] pids_cancel.constprop.6+0x31/0x40
[   11.601764]  [<ffffffff8118e32d>] pids_can_attach+0x6d/0xf0
[   11.602245]  [<ffffffff811887fa>] cgroup_taskset_migrate+0x6a/0x330
[   11.602795]  [<ffffffff81188bb5>] cgroup_migrate+0xf5/0x190
[   11.603276]  [<ffffffff81188ac5>] ? cgroup_migrate+0x5/0x190
[   11.603788]  [<ffffffff81188dc6>] cgroup_attach_task+0x176/0x200
[   11.604308]  [<ffffffff81188c55>] ? cgroup_attach_task+0x5/0x200
[   11.604831]  [<ffffffff8118924d>] __cgroup_procs_write+0x2ad/0x460
[   11.605367]  [<ffffffff81188ffe>] ? __cgroup_procs_write+0x5e/0x460
[   11.605929]  [<ffffffff81189434>] cgroup_procs_write+0x14/0x20
[   11.606448]  [<ffffffff81185af5>] cgroup_file_write+0x35/0x1c0
[   11.606931]  [<ffffffff812e94f1>] kernfs_fop_write+0x141/0x190
[   11.607401]  [<ffffffff81269b18>] __vfs_write+0x28/0xe0
[   11.607834]  [<ffffffff811292d7>] ? percpu_down_read+0x57/0xa0
[   11.608366]  [<ffffffff8126c7a4>] ? __sb_start_write+0xb4/0xf0
[   11.608874]  [<ffffffff8126c7a4>] ? __sb_start_write+0xb4/0xf0
[   11.609343]  [<ffffffff8126a28c>] vfs_write+0xac/0x1a0
[   11.609843]  [<ffffffff81289db6>] ? __fget_light+0x66/0x90
[   11.610315]  [<ffffffff8126aba9>] SyS_write+0x49/0xb0
[   11.610756]  [<ffffffff81bdb4f2>] entry_SYSCALL_64_fastpath+0x12/0x76
[   11.611305] ---[ end trace 7f953d0ce5af99ea ]---
