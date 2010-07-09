From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Fri, 9 Jul 2010 23:33:02 +0200
Message-ID: <201007092333.02581.rjw@sisk.pl>
References: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera> <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>,
	Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>,
	Dave Airlie <airlied-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday, July 09, 2010, Linus Torvalds wrote:
> On Thu, Jul 8, 2010 at 4:33 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote=
:
> >
> > Unresolved regressions
> > ----------------------
> >
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1635=
3
> > Subject         : 2.6.35 regression
> > Submitter       : Zeev Tarantov <zeev.tarantov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-07-05 13:04 (4 days old)
> > Message-ID      : <loom.20100705T144459-919-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1278360027=
02522&w=3D2
>=20
> This is a gcc-4.5 issue. Whether it's also something that we should
> change in the kernel is unclear, but at least as of now, the rule is
> that you cannot compile the kernel with gcc-4.5. No idea whether the
> compiler is just entirely broken, or whether it's just that it
> triggers something iffy by being overly clever.

This claims to fix it, though: https://patchwork.kernel.org/patch/11098=
8/

> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1634=
6
> > Subject         : 2.6.35-rc3-git8 - include/linux/fdtable.h:88 invo=
ked rcu_dereference_check() without protection!
> > Submitter       : Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-07-04 22:04 (5 days old)
> > Message-ID      : <AANLkTinof0k28rk4rMr66aubxcRL2rFa5ZEArj1lqD3o@ma=
il.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1278281078=
15930&w=3D2
>=20
> I'm not entirely sure if these RCU proving things should count as reg=
ressions.
>=20
> Sure, the option to enable RCU proving is new, but the things it
> reports about generally are not new - and they are usually not even
> bugs in the sense that they necessarily cause any real problems.
>=20
> That particular one is in the single-thread optimizated case for fget=
_light, ie
>=20
>         if (likely((atomic_read(&files->count) =3D=3D 1))) {
>                 file =3D fcheck_files(files, fd);
>=20
> where I think it should be entirely safe in all ways without any
> locking. So I think it's a false positive too.

OK, so I'm going to close these bugs.

=2E..
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1633=
3
> > Subject         : iwl3945: HARDWARE GONE??
> > Submitter       : Priit Laes <plaes-q/aMd4JkU83YtjvyW6yDsg@public.gmane.org>
> > Date            : 2010-07-02 16:02 (7 days old)
> > Message-ID      : <1278086575.2889.8.camel@chi>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1278086597=
05983&w=3D2
>=20
> This either got fixed, or will be practically impossible to debug. Th=
e
> reporter ends up being unable to reproduce the issue.

Closed as unreproducible.

=2E..
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1633=
0
> > Subject         : Dynamic Debug broken on 2.6.35-rc3?
> > Submitter       : Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
> > Date            : 2010-07-01 15:44 (8 days old)
> > Message-ID      : <201007011744.19564.trenn-l3A5Bk7waGM@public.gmane.org>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277999072=
18877&w=3D2
>=20
> There's a suggested patch in
>=20
>   http://marc.info/?l=3Dlinux-kernel&m=3D127862524404291&w=3D2
>=20
> but no reply to it yet.

Patch information added to the bug entry (it's been confirmed to work).

> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1632=
9
> > Subject         : 2.6.35-rc3: Load average climbing to 3+ with no a=
pparent reason: CPU 98% idle, with hardly no I/O
> > Submitter       : T=F6r=F6k Edwin <edwintorok-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-07-01 7:40 (8 days old)
> > Message-ID      : <20100701104022.404410d6@debian>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277970050=
30536&w=3D2
>=20
> This seems to be partly a confusion about what "load average" is. It'=
s
> not a CPU load, it's a system load average, and disk-wait processes
> count towards it. He has some problem with his CD-ROM, and it sounds
> like it might be hardware on the verge of going bad.

Closed.

> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1632=
4
> > Subject         : Oops while running fs_racer test on a POWER6 box =
against latest git
> > Submitter       : divya <dipraksh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > Date            : 2010-06-30 11:34 (9 days old)
> > Message-ID      : <4C2B28F3.7000006-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277896973=
03061&w=3D2
>=20
> I wonder if this is the writeback problem. That POWER crash dump is
> unreadable, so it's hard to tell, but the load in question makes that
> at least likely.
>=20
> If so, it should hopefully be fixed in today's git (commit
> 83ba7b071f30f7c01f72518ad72d5cd203c27502 and friends).

OK, closed.

> > Bug-entry    : http://bugzilla.kernel.org/show_bug.cgi?id=3D16323
> > Subject         : 2.6.35-rc3-git4 - kernel/sched.c:616 invoked rcu_=
dereference_check() without protection!
> > Submitter       : Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-07-01 12:21 (8 days old)
> > Message-ID      : <AANLkTini6hz2LFeZi8CMUmY3xw1MU7NxmyesuxZ4oCdo@ma=
il.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277986931=
25541&w=3D2
>=20
> See earlier about these being marked as regressions, but it should be
> fixed by commit dc61b1d6 ("sched: Fix PROVE_RCU vs cpu_cgroup").

Closed.

=2E..
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1630=
9
> > Subject         : 2.6.35-rc3 oops trying to suspend.
> > Submitter       : Andrew Hendry <andrew.hendry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-06-27 12:40 (12 days old)
> > Message-ID      : <AANLkTinUH2p33-AWxOVDrLsNkn9rgEVrlwn5mfK7P8NH@ma=
il.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277642499=
26781&w=3D2
>=20
> I'm pretty sure this was fixed by Nick in commit 57439f878afa ("fs:
> fix superblock iteration race").

Closed.

=2E..
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1630=
4
> > Subject         : i915 - high number of wakeups
> > Submitter       : Enrico Bandiello <enban-c0jvKHQHzSzx4jp4WZvp5g@public.gmane.org>
> > Date            : 2010-06-27 09:52 (12 days old)
>=20
> Duplicate of that 16307 one.

Closed.

=2E..
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1623=
0
> > Subject         : inconsistent IN-HARDIRQ-W -> HARDIRQ-ON-W usage: =
fasync, 2.6.35-rc3
> > Submitter       : Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
> > Date            : 2010-06-13 9:53 (26 days old)
> > Message-ID      : <20100613095305.GA13231-S7uyTPAaJ/sb6pqDj42GsMgv3T4z79SOs0AfqQuZ5sE@public.gmane.org=
t>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1276422822=
08277&w=3D2
>=20
> Fixed by commit f4985dc714d7.

Closed.

=2E..
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1620=
5
> > Subject         : acpi: freeing invalid memtype bf799000-bf79a000
> > Submitter       : Marcin Slusarz <marcin.slusarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-06-09 20:09 (30 days old)
> > Message-ID      : <20100609200910.GA2876-OI9uyE9O0yo@public.gmane.org>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1276114270=
29914&w=3D2
> >                  http://marc.info/?l=3Dlinux-kernel&m=3D12768839851=
3862&w=3D2
>=20
> This should be fixed by commit b945d6b2554d ("rbtree: Undo augmented
> trees performance damage and regression").

Yup, closed.

> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1619=
9
> > Subject         : 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invo=
ked rcu_dereference_check() without protection!
> > Submitter       : Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-06-07 18:14 (32 days old)
> > Message-ID      : <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@ma=
il.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1275934478=
12015&w=3D2
>=20
> Another RCU proving thing.  And this one looks the same as the 16323
> one above, and fixed by the same commit as that one.

Closed.

> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1619=
7
> > Subject         : [BUG on 2.6.35-rc2] sysfs: cannot create duplicat=
e filename '/devices/pci0000:00/0000:00:11.0/0000:02:03.0/slot'
> > Submitter       : Ryan Wang <openspace.wang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-06-07 0:23 (32 days old)
> > Message-ID      : <AANLkTincwMZPnYW3S4uz4k2GOn52RpgBIBRfzyD010Yo@ma=
il.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1275870222=
19378&w=3D2
>=20
> These should all be gone. See commit 3be434f0244ee by Jesse ('Revert
> "PCI: create function symlinks in /sys/bus/pci/slots/N/"').

Yes, I've already closed it.=20

=2E..
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1617=
5
> > Subject         : 2.6.35-rc1 system oom, many processes killed but =
memory not free
> > Submitter       : andrew hendry <andrew.hendry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-06-05 0:46 (34 days old)
> > Message-ID      : <AANLkTim7CiW-yfugZUAHZCqLvXKgt9CwolCvbLGdCLAk@ma=
il.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1275698777=
14937&w=3D2
>=20
> Not a regression or a kernel bug at all. See the thread. Big ramdisk
> filled up all of memory when it was filled by the builds.

Closed.

> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1614=
5
> > Subject         : Unable to boot unless "notsc" or "clocksource=3Dh=
pet", or acpi_pad disabling the TSC
> > Submitter       : Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
> > Date            : 2010-06-07 13:11 (32 days old)
> > Handled-By      : Venkatesh Pallipadi <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> >                  Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>=20
> This is not a regression. See the full bugzilla details. The same
> problem persists at least back to 2.6.30 with his config. So it's
> somehow specific to his particular config use that requires "notsc" t=
o
> boot.

Dropped from the list.

Thanks,
Rafael
