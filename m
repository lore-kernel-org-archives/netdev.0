From: Shawn Starr <shawn.starr@rogers.com>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Thu, 8 Jul 2010 23:36:25 -0400
Message-ID: <201007082336.25201.shawn.starr@rogers.com>
References: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera> <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Dave Airlie <airlied@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, Jens Axboe <axboe@kernel.dk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, July 08, 2010 09:34:25 pm Linus Torvalds wrote:
> On Thu, Jul 8, 2010 at 4:33 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote=
:
> > Unresolved regressions
> > ----------------------
> >=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1635=
3
> > Subject         : 2.6.35 regression
> > Submitter       : Zeev Tarantov <zeev.tarantov@gmail.com>
> > Date            : 2010-07-05 13:04 (4 days old)
> > Message-ID      : <loom.20100705T144459-919@post.gmane.org>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1278360027=
02522&w=3D2
>=20
> This is a gcc-4.5 issue. Whether it's also something that we should
> change in the kernel is unclear, but at least as of now, the rule is
> that you cannot compile the kernel with gcc-4.5. No idea whether the
> compiler is just entirely broken, or whether it's just that it
> triggers something iffy by being overly clever.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1634=
6
> > Subject         : 2.6.35-rc3-git8 - include/linux/fdtable.h:88 invo=
ked
> > rcu_dereference_check() without protection! Submitter       : Miles=
 Lane
> > <miles.lane@gmail.com>
> > Date            : 2010-07-04 22:04 (5 days old)
> > Message-ID      :
> > <AANLkTinof0k28rk4rMr66aubxcRL2rFa5ZEArj1lqD3o@mail.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1278281078=
15930&w=3D2
>=20
> I'm not entirely sure if these RCU proving things should count as
> regressions.
>=20
> Sure, the option to enable RCU proving is new, but the things it
> reports about generally are not new - and they are usually not even
> bugs in the sense that they necessarily cause any real problems.
>=20
> That particular one is in the single-thread optimizated case for
> fget_light, ie
>=20
>         if (likely((atomic_read(&files->count) =3D=3D 1))) {
>                 file =3D fcheck_files(files, fd);
>=20
> where I think it should be entirely safe in all ways without any
> locking. So I think it's a false positive too.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1633=
4
> > Subject         : reiserfs locking (v2)
> > Submitter       : Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Date            : 2010-07-02 9:34 (7 days old)
> > Message-ID      : <20100702093451.GA3973@swordfish.minsk.epam.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1278063063=
03590&w=3D2
>=20
> Frederic? Al? I assume this is some late fallout from the BKL removal
> ages ago.. It's the old filldir-vs-mmap crud, but normally it should
> be impossible to trigger because the inode for a directory should
> never be mmap'able, so we should never have the same i_mutex lock use=
d
> for both mmap and for filldir protection.
>=20
> We saw some of that oddity long ago, I wonder if it's lockdep being
> confused about some inodes.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1633=
3
> > Subject         : iwl3945: HARDWARE GONE??
> > Submitter       : Priit Laes <plaes@plaes.org>
> > Date            : 2010-07-02 16:02 (7 days old)
> > Message-ID      : <1278086575.2889.8.camel@chi>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1278086597=
05983&w=3D2
>=20
> This either got fixed, or will be practically impossible to debug. Th=
e
> reporter ends up being unable to reproduce the issue.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1633=
2
> > Subject         : Kernel crashes in tty code (tty_open)
> > Submitter       : werner@guyane.yi.org
> > Date            : 2010-07-02 3:34 (7 days old)
> > Message-ID      : <1278041650.12788@guyane.yi.org>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1278041675=
11930&w=3D2
>=20
> This seems to be due to CONFIG_MRST (Moorestown).
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1633=
0
> > Subject         : Dynamic Debug broken on 2.6.35-rc3?
> > Submitter       : Thomas Renninger <trenn@suse.de>
> > Date            : 2010-07-01 15:44 (8 days old)
> > Message-ID      : <201007011744.19564.trenn@suse.de>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277999072=
18877&w=3D2
>=20
> There's a suggested patch in
>=20
>   http://marc.info/?l=3Dlinux-kernel&m=3D127862524404291&w=3D2
>=20
> but no reply to it yet.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1632=
9
> > Subject         : 2.6.35-rc3: Load average climbing to 3+ with no
> > apparent reason: CPU 98% idle, with hardly no I/O Submitter       :
> > T=F6r=F6k Edwin <edwintorok@gmail.com>
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
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1632=
4
> > Subject         : Oops while running fs_racer test on a POWER6 box
> > against latest git Submitter       : divya <dipraksh@linux.vnet.ibm=
=2Ecom>
> > Date            : 2010-06-30 11:34 (9 days old)
> > Message-ID      : <4C2B28F3.7000006@linux.vnet.ibm.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277896973=
03061&w=3D2
>=20
> I wonder if this is the writeback problem. That POWER crash dump is
> unreadable, so it's hard to tell, but the load in question makes that
> at least likely.
>=20
> If so, it should hopefully be fixed in today's git (commit
> 83ba7b071f30f7c01f72518ad72d5cd203c27502 and friends).
>=20
> > Bug-entry    : http://bugzilla.kernel.org/show_bug.cgi?id=3D16323
> > Subject         : 2.6.35-rc3-git4 - kernel/sched.c:616 invoked
> > rcu_dereference_check() without protection! Submitter       : Miles=
 Lane
> > <miles.lane@gmail.com>
> > Date            : 2010-07-01 12:21 (8 days old)
> > Message-ID      :
> > <AANLkTini6hz2LFeZi8CMUmY3xw1MU7NxmyesuxZ4oCdo@mail.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277986931=
25541&w=3D2
>=20
> See earlier about these being marked as regressions, but it should be
> fixed by commit dc61b1d6 ("sched: Fix PROVE_RCU vs cpu_cgroup").
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1632=
2
> > Subject         : WARNING: at /arch/x86/include/asm/processor.h:100=
5
> > read_measured_perf_ctrs+0x5a/0x70() Submitter       : boris64
> > <bugzilla.kernel.org@boris64.net>
> > Date            : 2010-07-01 13:54 (8 days old)
> > Handled-By      : H. Peter Anvin <hpa@zytor.com>
>=20
> Magic. Strange and dark magic.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1631=
1
> > Subject         : [REGRESSION][SUSPEND] 2.6.35-rcX won't suspend Le=
novo
> > W500 laptop Submitter       : Shawn Starr <shawn.starr@rogers.com>
> > Date            : 2010-06-28 0:45 (11 days old)
> > Message-ID      : <201006272045.17004.shawn.starr@rogers.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277686337=
05286&w=3D2
>=20
> I think this might be usefully bisected. Shawn?
>=20
I'll have to try bisecting this weekend. It continues in Linux sh0n.net=
=20
2.6.35-rc4+ #1 SMP Wed Jul 7 23:58:41 EDT 2010 x86_64 x86_64 x86_64 GNU=
/Linux


> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1630=
9
> > Subject         : 2.6.35-rc3 oops trying to suspend.
> > Submitter       : Andrew Hendry <andrew.hendry@gmail.com>
> > Date            : 2010-06-27 12:40 (12 days old)
> > Message-ID      :
> > <AANLkTinUH2p33-AWxOVDrLsNkn9rgEVrlwn5mfK7P8NH@mail.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277642499=
26781&w=3D2
>=20
> I'm pretty sure this was fixed by Nick in commit 57439f878afa ("fs:
> fix superblock iteration race").
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1630=
7
> > Subject         : i915 in kernel 2.6.35-rc3, high number of wakeups
> > Submitter       : Enrico Bandiello <enban@postal.uv.es>
> > Date            : 2010-06-26 16:57 (13 days old)
> > Message-ID      : <4C26317A.5070309@postal.uv.es>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277574034=
04259&w=3D2
>=20
> I don't think anybody noticed this one. Jesse?
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1630=
4
> > Subject         : i915 - high number of wakeups
> > Submitter       : Enrico Bandiello <enban@postal.uv.es>
> > Date            : 2010-06-27 09:52 (12 days old)
>=20
> Duplicate of that 16307 one.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1628=
4
> > Subject         : Hitting WARN_ON in hw_breakpoint code
> > Submitter       : Paul Mackerras <paulus@samba.org>
> > Date            : 2010-06-23 12:57 (16 days old)
> > Message-ID      : <20100623125740.GA3368@brick.ozlabs.ibm.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1277297891=
13432&w=3D2
>=20
> This has "I have a fix, will post it very soon." in the thread from
> Frederic, but I'm not seeing anything else. Frederic?
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1626=
5
> > Subject         : Why is kslowd accumulating so much CPU time?
> > Submitter       : Theodore Ts'o <tytso@mit.edu>
> > Date            : 2010-06-09 18:36 (30 days old)
> > First-Bad-Commit:
> > http://git.kernel.org/linus/fbf81762e385d3d45acad057b654d56972acf58=
c
> > Message-ID      : <E1OMQ88-0002a1-Gb@closure.thunk.org>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1276108578=
19033&w=3D4
>=20
> Dave, Jesse?
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1623=
4
> > Subject         : [2.6.35-rc3] reboot mutex 'bug'...
> > Submitter       : Daniel J Blueman <daniel.blueman@gmail.com>
> > Date            : 2010-06-14 15:16 (25 days old)
> > Message-ID      :
> > <AANLkTimDcTnyEPmt2ZcCM1UWtn4AYKotiqyjobJApkO7@mail.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1276528611=
18933&w=3D2
>=20
> Ok, this is definitely harmless. Whether we should silence the warnin=
g
> somehow is a separate question.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1623=
0
> > Subject         : inconsistent IN-HARDIRQ-W -> HARDIRQ-ON-W usage:
> > fasync, 2.6.35-rc3 Submitter       : Dominik Brodowski
> > <linux@dominikbrodowski.net> Date            : 2010-06-13 9:53 (26 =
days
> > old)
> > Message-ID      : <20100613095305.GA13231@comet.dominikbrodowski.ne=
t>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1276422822=
08277&w=3D2
>=20
> Fixed by commit f4985dc714d7.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1622=
8
> > Subject         : BUG/boot failure on Dell Precision T3500
> > (pci/ahci_stop_engine) Submitter       : Brian Bloniarz
> > <phunge0@hotmail.com>
> > Date            : 2010-06-16 17:57 (23 days old)
> > Handled-By      : Bjorn Helgaas <bjorn.helgaas@hp.com>
>=20
> This has a butt-ugly suggested patch that certainly won't be applied.
> I saw the thread, but lost sight of it. Jesse, did that end up with
> some resolution?
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1622=
1
> > Subject         : 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* i=
nvalid
> > framebuffer id Submitter       : Miles Lane <miles.lane@gmail.com>
> > Date            : 2010-06-11 20:31 (28 days old)
> > Message-ID      :
> > <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG@mail.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1276288281=
19623&w=3D2
>=20
> I dunno. Old, and apparently seen by two people. Dave?
>=20
> Might be helped by bisection.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1620=
5
> > Subject         : acpi: freeing invalid memtype bf799000-bf79a000
> > Submitter       : Marcin Slusarz <marcin.slusarz@gmail.com>
> > Date            : 2010-06-09 20:09 (30 days old)
> > Message-ID      : <20100609200910.GA2876@joi.lan>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1276114270=
29914&w=3D2
> >                  http://marc.info/?l=3Dlinux-kernel&m=3D12768839851=
3862&w=3D2
>=20
> This should be fixed by commit b945d6b2554d ("rbtree: Undo augmented
> trees performance damage and regression").
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1619=
9
> > Subject         : 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invo=
ked
> > rcu_dereference_check() without protection! Submitter       : Miles=
 Lane
> > <miles.lane@gmail.com>
> > Date            : 2010-06-07 18:14 (32 days old)
> > Message-ID      :
> > <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1275934478=
12015&w=3D2
>=20
> Another RCU proving thing.  And this one looks the same as the 16323
> one above, and fixed by the same commit as that one.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1619=
7
> > Subject         : [BUG on 2.6.35-rc2] sysfs: cannot create duplicat=
e
> > filename '/devices/pci0000:00/0000:00:11.0/0000:02:03.0/slot' Submi=
tter
> >       : Ryan Wang <openspace.wang@gmail.com>
> > Date            : 2010-06-07 0:23 (32 days old)
> > Message-ID      :
> > <AANLkTincwMZPnYW3S4uz4k2GOn52RpgBIBRfzyD010Yo@mail.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1275870222=
19378&w=3D2
>=20
> These should all be gone. See commit 3be434f0244ee by Jesse ('Revert
> "PCI: create function symlinks in /sys/bus/pci/slots/N/"').
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1618=
7
> > Subject         : Carrier detection failed in dhcpcd when link is u=
p
> > Submitter       : Christian Casteyde <casteyde.christian@free.fr>
> > Date            : 2010-06-12 15:15 (27 days old)
> > First-Bad-Commit:
> > http://git.kernel.org/linus/10708f37ae729baba9b67bd134c3720709d4ae6=
2
> > Handled-By      : Andrew Morton <akpm@linux-foundation.org>
>=20
> David? This bisects to a networking commit. Doesn't look sensible, bu=
t
> what do I know?
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1618=
4
> > Subject         : Container, X86-64, i386, iptables rule
> > Submitter       : Jean-Marc Pigeon <jmp@safe.ca>
> > Date            : 2010-06-12 04:17 (27 days old)
> > Handled-By      : Patrick McHardy <kaber@trash.net>
>=20
> Patrick, Davem? Ping?
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1617=
9
> > Subject         : 2.6.35-rc2 completely hosed on intel gfx?
> > Submitter       : Norbert Preining <preining@logic.at>
> > Date            : 2010-06-06 11:55 (33 days old)
> > Message-ID      : <20100606115534.GA9399@gamma.logic.tuwien.ac.at>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1275825349=
31581&w=3D2
>=20
> Hmm. That one is the vt.c bug coupled with another problem, which in
> turn got opened as a separate bugzilla entry:
>=20
>    http://bugzilla.kernel.org/show_bug.cgi?id=3D16252
>=20
> which in turn then got closed. I dunno.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1617=
5
> > Subject         : 2.6.35-rc1 system oom, many processes killed but =
memory
> > not free Submitter       : andrew hendry <andrew.hendry@gmail.com>
> > Date            : 2010-06-05 0:46 (34 days old)
> > Message-ID      :
> > <AANLkTim7CiW-yfugZUAHZCqLvXKgt9CwolCvbLGdCLAk@mail.gmail.com>
> > References      : http://marc.info/?l=3Dlinux-kernel&m=3D1275698777=
14937&w=3D2
>=20
> Not a regression or a kernel bug at all. See the thread. Big ramdisk
> filled up all of memory when it was filled by the builds.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1614=
5
> > Subject         : Unable to boot unless "notsc" or "clocksource=3Dh=
pet", or
> > acpi_pad disabling the TSC Submitter       : Tom Gundersen <teg@jkl=
m.no>
> > Date            : 2010-06-07 13:11 (32 days old)
> > Handled-By      : Venkatesh Pallipadi <venki@google.com>
> >                  Len Brown <lenb@kernel.org>
>=20
> This is not a regression. See the full bugzilla details. The same
> problem persists at least back to 2.6.30 with his config. So it's
> somehow specific to his particular config use that requires "notsc" t=
o
> boot.
>=20
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1612=
2
> > Subject         : 2.6.35-rc1: WARNING at fs/fs-writeback.c:1142
> > __mark_inode_dirty+0x103/0x170 Submitter       : Larry Finger
> > <Larry.Finger@lwfinger.net>
> > Date            : 2010-06-04 13:18 (35 days old)
> > Handled-By      : Jens Axboe <axboe@kernel.dk>
>=20
> This looks like a duplicate of that 16312 bugzilla entry. Jens, has
> this been resolved?
>=20
>                                Linus
