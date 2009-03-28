From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Sat, 28 Mar 2009 10:55:14 +0100
Message-ID: <20090328095514.GA2599@gentoox2.trippelsdorf.de>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi> <20090328045056.GA2394@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, corbet@lwn.net
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-44.synserver.de ([217.119.50.44]:1587 "HELO
	smtp-out-44.synserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753340AbZC1JzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 05:55:21 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 28, 2009 at 10:29:58AM +0200, Ilpo J=E4rvinen wrote:
> On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:
>=20
> > On Sat, Mar 28, 2009 at 01:05:09AM +0200, Ilpo J=E4rvinen wrote:
> > > On Fri, 27 Mar 2009, Markus Trippelsdorf wrote:
> > >=20
> > > > I'm running the latest git kernel (2.6.29-03321-gbe0ea69) and I=
've got
> > > > this warning twice in the last few hours.:
> > >=20
> > > What did you run previously?
> >=20
> > 2.6.29
>=20
> Ok, just wanted to confirm it wasn't some from 2.6.veryold transition=
,=20
> where veryold didn't even have tracking for that invariant.
>=20
> > > > Mar 27 21:37:00 [kernel] ------------[ cut here ]------------
> > > > Mar 27 21:37:00 [kernel] WARNING: at net/ipv4/tcp_input.c:2927 =
tcp_ack+0xd55/0x1991()
> > >=20
> > > This one may or may not be a new one... Starting from the point w=
hen the=20
> > > warning was added it has been seen and some of those miscounts go=
t tracked=20
> > > down but there is still something remaining (and that has been th=
e state=20
> > > for couple of version already). It seems to require some particul=
arly hard=20
> > > to reproduce network behavior people usually hit once in a lifeti=
me.=20
> > > However, those miscount alone should not cause crashes, stalled T=
CP at=20
> > > worst but even that is quite unlikely to happen if fackets_out wa=
s not=20
> > > counted right.
> >=20
> > The only unusual thing in my setup is that I use two Internet provi=
ders
> > at the same time:
> >=20
> > # ip route show
> > 192.168.1.0/24 dev eth1  proto kernel  scope link  src 192.168.1.2
> > 192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.2
> > 127.0.0.0/8 via 127.0.0.1 dev lo
> > default equalize
> >         nexthop via 192.168.1.1  dev eth1 weight 10
> >         nexthop via 192.168.0.1  dev eth0 weight 1
>=20
> Right. But I meant even larger picture, ie., the whole path(s) with t=
he=20
> remote hosts you're communicating with.
>=20
> > > > The machine hangs afterwards.
> > >=20
> > > Is it really related to the warning for sure? I find it hard to=20
> > > believe...
> >=20
> > The machine is normally running stable for days. Switching back to =
2.6.29
> > solves the problem...
>=20
> Sure, but does is hang right after printing that warning or much late=
r on,
> e.g., one minute is already a very long time for the crash to be rela=
ted=20
> to that warning... Even 5 seconds is a long time but I'd immediately =
say=20
> it's not related then :-).

I really can't tell you. In both occurrences of the warning the machine
was already unusable when I noticed. I then rebooted and the last entry
in the logs was that warning.

>=20
> So you never saw this warning before within 2.6.29 or 2.6.28-26 timef=
rame?

Thats right.

> Anyway, if it turns out that the warning is unrelated to the crash an=
d at=20
> the same time seems that you can so easily reproduce the warning it i=
s=20
> worth of tracking its cause down as well but lets track the crash dow=
n=20
> first and see what to do once it is solved.
>=20
> > > We even fixed that miscount for you when the warning was printed =
out (and=20
> > > the miscount alone wouldn't be able to cause crash anyway). Obvio=
usly=20
> > > there could something that got broken but reading through all pos=
t 2.6.29=20
> > > tcp material doesn't reveal anything particularly suspicious or e=
ven=20
> > > tricky... Only one thing that is remotely related to the warning =
that gets=20
> > > printed out is d3d2ae454501a4dec360995649e1b002a2ad90c5 but even =
that has=20
> > > very strong foundation as it does not have any potential to intro=
duce=20
> > > stale references, rest of the effects would be just stalled tcp c=
onnection=20
> > > at worst.
> > >=20
> > > Please add some debugging things, at least lockdep (CONFIG_PROVE_=
LOCKING)=20
> > > and soft lockup detector (CONFIG_DETECT_SOFTLOCKUP) to find out i=
f we can=20
> > > get some info about the actual place of hang, some other debug th=
ings=20
> > > might also end up being useful.
> >=20
> > Ok, will try this later today and report back. (It takes ~1 hour to
> > reproduce the problem with a big torrent download).
>=20
> Thanks, there are plenty of other changes in the range in question=20
> already:
>=20
> ijjarvin@pointhope:~/linux/mainline$ git-diff --stat v2.6.29..be0ea69=
 |=20
> tail -n 1
>  2871 files changed, 216209 insertions(+), 131463 deletions(-)
> ijjarvin@pointhope:~/linux/mainline$=20
>=20
> ...So the crash could well be because of something else. It's probabl=
y=20
> worth of tracking bug fixes by keeping up with mainline and if crashe=
s=20
> vanish we know that somebody solved the (same) problem.

Yes, you might be right, because running with CONFIG_PROVE_LOCKING and=20
CONFIG_DETECT_SOFTLOCKUP enabled points to a possible bug in the BKL
removal patches (fasync) by Jonathan Corbet. (I wasn't able so far to
reproduce the original WARNING.)

Here is one example:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ INFO: possible irq lock inversion dependency detected ]
2.6.29-03321-gbe0ea69 #7
---------------------------------------------------------
swapper/0 just changed the state of lock:
 (fasync_lock){..+.}, at: [<ffffffff8028a2ac>] kill_fasync+0x24/0x45
but this lock took another, hard-irq-unsafe lock in the past:
 (&f->f_lock){--..}

and interrupts could create inverse lock ordering between them.


other info that might help us debug this:
3 locks held by swapper/0:
 #0:  (&dev->event_lock){++..}, at: [<ffffffff804134ad>] input_event+0x=
3a/0x79
 #1:  (rcu_read_lock){..--}, at: [<ffffffff80411eb6>] input_pass_event+=
0x0/0xc9
 #2:  (rcu_read_lock){..--}, at: [<ffffffff80415a04>] evdev_event+0x0/0=
xee

the first lock's dependencies:
-> (fasync_lock){..+.} ops: 0 {
   initial-use  at:
                        [<ffffffff8025047d>] __lock_acquire+0x6b4/0x155=
2
                        [<ffffffff80251370>] lock_acquire+0x55/0x71
                        [<ffffffff804dac84>] _write_lock_irq+0x32/0x41
                        [<ffffffff80289e53>] fasync_helper+0x52/0x10f
                        [<ffffffff80378686>] tty_fasync+0x5a/0x10c
                        [<ffffffff8037abe9>] tty_release_dev+0x60/0x4c0
                        [<ffffffff8037b062>] tty_release+0x19/0x24
                        [<ffffffff8027ffea>] __fput+0xe3/0x191
                        [<ffffffff802800b0>] fput+0x18/0x1a
                        [<ffffffff8027d611>] filp_close+0x63/0x6d
                        [<ffffffff8027d6c3>] sys_close+0xa8/0xe2
                        [<ffffffff8020b41b>] system_call_fastpath+0x16/=
0x1b
                        [<ffffffffffffffff>] 0xffffffffffffffff
   in-hardirq-R at:
                        [<ffffffffffffffff>] 0xffffffffffffffff
 }
 ... key      at: [<ffffffff805db2b8>] fasync_lock+0x18/0x30
 -> (&f->f_lock){--..} ops: 0 {
    initial-use  at:
                          [<ffffffff8025047d>] __lock_acquire+0x6b4/0x1=
552
                          [<ffffffff80251370>] lock_acquire+0x55/0x71
                          [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                          [<ffffffff80289ecf>] fasync_helper+0xce/0x10f
                          [<ffffffff80378686>] tty_fasync+0x5a/0x10c
                          [<ffffffff8037abe9>] tty_release_dev+0x60/0x4=
c0
                          [<ffffffff8037b062>] tty_release+0x19/0x24
                          [<ffffffff8027ffea>] __fput+0xe3/0x191
                          [<ffffffff802800b0>] fput+0x18/0x1a
                          [<ffffffff8027d611>] filp_close+0x63/0x6d
                          [<ffffffff8027d6c3>] sys_close+0xa8/0xe2
                          [<ffffffff8020b41b>] system_call_fastpath+0x1=
6/0x1b
                          [<ffffffffffffffff>] 0xffffffffffffffff
    softirq-on-W at:
                          [<ffffffff80250468>] __lock_acquire+0x69f/0x1=
552
                          [<ffffffff80251370>] lock_acquire+0x55/0x71
                          [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                          [<ffffffff8028a736>] sys_fcntl+0x2c2/0x394
                          [<ffffffff8020b41b>] system_call_fastpath+0x1=
6/0x1b
                          [<ffffffffffffffff>] 0xffffffffffffffff
    hardirq-on-W at:
                          [<ffffffff80250447>] __lock_acquire+0x67e/0x1=
552
                          [<ffffffff80251370>] lock_acquire+0x55/0x71
                          [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                          [<ffffffff8028a736>] sys_fcntl+0x2c2/0x394
                          [<ffffffff8020b41b>] system_call_fastpath+0x1=
6/0x1b
                          [<ffffffffffffffff>] 0xffffffffffffffff
  }
  ... key      at: [<ffffffff80c94368>] __key.20253+0x0/0x8
 ... acquired at:
   [<ffffffff80250fb6>] __lock_acquire+0x11ed/0x1552
   [<ffffffff80251370>] lock_acquire+0x55/0x71
   [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
   [<ffffffff80289ecf>] fasync_helper+0xce/0x10f
   [<ffffffff80378686>] tty_fasync+0x5a/0x10c
   [<ffffffff8037abe9>] tty_release_dev+0x60/0x4c0
   [<ffffffff8037b062>] tty_release+0x19/0x24
   [<ffffffff8027ffea>] __fput+0xe3/0x191
   [<ffffffff802800b0>] fput+0x18/0x1a
   [<ffffffff8027d611>] filp_close+0x63/0x6d
   [<ffffffff8027d6c3>] sys_close+0xa8/0xe2
   [<ffffffff8020b41b>] system_call_fastpath+0x16/0x1b
   [<ffffffffffffffff>] 0xffffffffffffffff


the second lock's dependencies:
-> (&f->f_lock){--..} ops: 0 {
   initial-use  at:
                        [<ffffffff8025047d>] __lock_acquire+0x6b4/0x155=
2
                        [<ffffffff80251370>] lock_acquire+0x55/0x71
                        [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                        [<ffffffff80289ecf>] fasync_helper+0xce/0x10f
                        [<ffffffff80378686>] tty_fasync+0x5a/0x10c
                        [<ffffffff8037abe9>] tty_release_dev+0x60/0x4c0
                        [<ffffffff8037b062>] tty_release+0x19/0x24
                        [<ffffffff8027ffea>] __fput+0xe3/0x191
                        [<ffffffff802800b0>] fput+0x18/0x1a
                        [<ffffffff8027d611>] filp_close+0x63/0x6d
                        [<ffffffff8027d6c3>] sys_close+0xa8/0xe2
                        [<ffffffff8020b41b>] system_call_fastpath+0x16/=
0x1b
                        [<ffffffffffffffff>] 0xffffffffffffffff
   softirq-on-W at:
                        [<ffffffff80250468>] __lock_acquire+0x69f/0x155=
2
                        [<ffffffff80251370>] lock_acquire+0x55/0x71
                        [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                        [<ffffffff8028a736>] sys_fcntl+0x2c2/0x394
                        [<ffffffff8020b41b>] system_call_fastpath+0x16/=
0x1b
                        [<ffffffffffffffff>] 0xffffffffffffffff
   hardirq-on-W at:
                        [<ffffffff80250447>] __lock_acquire+0x67e/0x155=
2
                        [<ffffffff80251370>] lock_acquire+0x55/0x71
                        [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                        [<ffffffff8028a736>] sys_fcntl+0x2c2/0x394
                        [<ffffffff8020b41b>] system_call_fastpath+0x16/=
0x1b
                        [<ffffffffffffffff>] 0xffffffffffffffff
 }
 ... key      at: [<ffffffff80c94368>] __key.20253+0x0/0x8

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.29-03321-gbe0ea69 #7
Call Trace:
 <IRQ>  [<ffffffff8024e7fa>] print_irq_inversion_bug+0x174/0x182
 [<ffffffff8024e89e>] check_usage_forwards+0x96/0x9e
 [<ffffffff8024ed7b>] mark_lock+0x43a/0x955
 [<ffffffff802503a2>] __lock_acquire+0x5d9/0x1552
 [<ffffffff802510f7>] ? __lock_acquire+0x132e/0x1552
 [<ffffffff8024de15>] ? trace_hardirqs_off+0xd/0xf
 [<ffffffff80251370>] lock_acquire+0x55/0x71
 [<ffffffff8028a2ac>] ? kill_fasync+0x24/0x45
 [<ffffffff804dadde>] _read_lock+0x2f/0x3e
 [<ffffffff8028a2ac>] ? kill_fasync+0x24/0x45
 [<ffffffff8028a2ac>] kill_fasync+0x24/0x45
 [<ffffffff804156fe>] evdev_pass_event+0x66/0x6f
 [<ffffffff80415a92>] evdev_event+0x8e/0xee
 [<ffffffff80415a04>] ? evdev_event+0x0/0xee
 [<ffffffff80411f40>] input_pass_event+0x8a/0xc9
 [<ffffffff80411eb6>] ? input_pass_event+0x0/0xc9
 [<ffffffff8041264f>] input_handle_event+0x355/0x364
 [<ffffffff804134ce>] input_event+0x5b/0x79
 [<ffffffff80424a0e>] hidinput_hid_event+0x251/0x27b
 [<ffffffff8042168f>] hid_process_event+0xa8/0xdc
 [<ffffffff80421a31>] hid_report_raw_event+0x36e/0x382
 [<ffffffff80421b0d>] hid_input_report+0xc8/0xdc
 [<ffffffff8042864a>] hid_irq_in+0x94/0x185
 [<ffffffff803f66e8>] usb_hcd_giveback_urb+0x60/0x94
 [<ffffffff80407324>] uhci_giveback_urb+0x112/0x1a2
 [<ffffffff80407a79>] uhci_scan_schedule+0x5ab/0x86d
 [<ffffffff80409975>] uhci_irq+0x126/0x142
 [<ffffffff803f6221>] usb_hcd_irq+0x38/0x8e
 [<ffffffff80256ddb>] handle_IRQ_event+0x64/0x99
 [<ffffffff80258087>] handle_fasteoi_irq+0x8b/0xcb
 [<ffffffff8020dc7b>] do_IRQ+0x69/0xd6
 [<ffffffff8020bdd3>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff802452f9>] lock_hrtimer_base+0x25/0x4b
 [<ffffffff802466d0>] ? __atomic_notifier_call_chain+0x0/0x86
 [<ffffffff80211913>] ? default_idle+0x32/0x4c
 [<ffffffff80211911>] ? default_idle+0x30/0x4c
 [<ffffffff8020a5a5>] cpu_idle+0x57/0x9a


And another one:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ INFO: possible irq lock inversion dependency detected ]
2.6.29-03321-gbe0ea69 #7
---------------------------------------------------------
X/2567 just changed the state of lock:
 (fasync_lock){..+.}, at: [<ffffffff8028a2ac>] kill_fasync+0x24/0x45
but this lock took another, hard-irq-unsafe lock in the past:
 (&f->f_lock){--..}

and interrupts could create inverse lock ordering between them.


other info that might help us debug this:
3 locks held by X/2567:
 #0:  (&dev->event_lock){++..}, at: [<ffffffff804134ad>] input_event+0x=
3a/0x79
 #1:  (rcu_read_lock){..--}, at: [<ffffffff80411eb6>] input_pass_event+=
0x0/0xc9
 #2:  (rcu_read_lock){..--}, at: [<ffffffff80415a04>] evdev_event+0x0/0=
xee

the first lock's dependencies:
-> (fasync_lock){..+.} ops: 0 {
   initial-use  at:
                        [<ffffffff8025047d>] __lock_acquire+0x6b4/0x155=
2
                        [<ffffffff80251370>] lock_acquire+0x55/0x71
                        [<ffffffff804dac84>] _write_lock_irq+0x32/0x41
                        [<ffffffff80289e53>] fasync_helper+0x52/0x10f
                        [<ffffffff80378686>] tty_fasync+0x5a/0x10c
                        [<ffffffff8037abe9>] tty_release_dev+0x60/0x4c0
                        [<ffffffff8037b062>] tty_release+0x19/0x24
                        [<ffffffff8027ffea>] __fput+0xe3/0x191
                        [<ffffffff802800b0>] fput+0x18/0x1a
                        [<ffffffff8027d611>] filp_close+0x63/0x6d
                        [<ffffffff8027d6c3>] sys_close+0xa8/0xe2
                        [<ffffffff8020b41b>] system_call_fastpath+0x16/=
0x1b
                        [<ffffffffffffffff>] 0xffffffffffffffff
   in-hardirq-R at:
                        [<ffffffffffffffff>] 0xffffffffffffffff
 }
 ... key      at: [<ffffffff805db2b8>] fasync_lock+0x18/0x30
 -> (&f->f_lock){--..} ops: 0 {
    initial-use  at:
                          [<ffffffff8025047d>] __lock_acquire+0x6b4/0x1=
552
                          [<ffffffff80251370>] lock_acquire+0x55/0x71
                          [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                          [<ffffffff80289ecf>] fasync_helper+0xce/0x10f
                          [<ffffffff80378686>] tty_fasync+0x5a/0x10c
                          [<ffffffff8037abe9>] tty_release_dev+0x60/0x4=
c0
                          [<ffffffff8037b062>] tty_release+0x19/0x24
                          [<ffffffff8027ffea>] __fput+0xe3/0x191
                          [<ffffffff802800b0>] fput+0x18/0x1a
                          [<ffffffff8027d611>] filp_close+0x63/0x6d
                          [<ffffffff8027d6c3>] sys_close+0xa8/0xe2
                          [<ffffffff8020b41b>] system_call_fastpath+0x1=
6/0x1b
                          [<ffffffffffffffff>] 0xffffffffffffffff
    softirq-on-W at:
                          [<ffffffff80250468>] __lock_acquire+0x69f/0x1=
552
                          [<ffffffff80251370>] lock_acquire+0x55/0x71
                          [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                          [<ffffffff8028a736>] sys_fcntl+0x2c2/0x394
                          [<ffffffff8020b41b>] system_call_fastpath+0x1=
6/0x1b
                          [<ffffffffffffffff>] 0xffffffffffffffff
    hardirq-on-W at:
                          [<ffffffff80250447>] __lock_acquire+0x67e/0x1=
552
                          [<ffffffff80251370>] lock_acquire+0x55/0x71
                          [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                          [<ffffffff8028a736>] sys_fcntl+0x2c2/0x394
                          [<ffffffff8020b41b>] system_call_fastpath+0x1=
6/0x1b
                          [<ffffffffffffffff>] 0xffffffffffffffff
  }
  ... key      at: [<ffffffff80c94368>] __key.20253+0x0/0x8
 ... acquired at:
   [<ffffffff80250fb6>] __lock_acquire+0x11ed/0x1552
   [<ffffffff80251370>] lock_acquire+0x55/0x71
   [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
   [<ffffffff80289ecf>] fasync_helper+0xce/0x10f
   [<ffffffff80378686>] tty_fasync+0x5a/0x10c
   [<ffffffff8037abe9>] tty_release_dev+0x60/0x4c0
   [<ffffffff8037b062>] tty_release+0x19/0x24
   [<ffffffff8027ffea>] __fput+0xe3/0x191
   [<ffffffff802800b0>] fput+0x18/0x1a
   [<ffffffff8027d611>] filp_close+0x63/0x6d
   [<ffffffff8027d6c3>] sys_close+0xa8/0xe2
   [<ffffffff8020b41b>] system_call_fastpath+0x16/0x1b
   [<ffffffffffffffff>] 0xffffffffffffffff


the second lock's dependencies:
-> (&f->f_lock){--..} ops: 0 {
   initial-use  at:
                        [<ffffffff8025047d>] __lock_acquire+0x6b4/0x155=
2
                        [<ffffffff80251370>] lock_acquire+0x55/0x71
                        [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                        [<ffffffff80289ecf>] fasync_helper+0xce/0x10f
                        [<ffffffff80378686>] tty_fasync+0x5a/0x10c
                        [<ffffffff8037abe9>] tty_release_dev+0x60/0x4c0
                        [<ffffffff8037b062>] tty_release+0x19/0x24
                        [<ffffffff8027ffea>] __fput+0xe3/0x191
                        [<ffffffff802800b0>] fput+0x18/0x1a
                        [<ffffffff8027d611>] filp_close+0x63/0x6d
                        [<ffffffff8027d6c3>] sys_close+0xa8/0xe2
                        [<ffffffff8020b41b>] system_call_fastpath+0x16/=
0x1b
                        [<ffffffffffffffff>] 0xffffffffffffffff
   softirq-on-W at:
                        [<ffffffff80250468>] __lock_acquire+0x69f/0x155=
2
                        [<ffffffff80251370>] lock_acquire+0x55/0x71
                        [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                        [<ffffffff8028a736>] sys_fcntl+0x2c2/0x394
                        [<ffffffff8020b41b>] system_call_fastpath+0x16/=
0x1b
                        [<ffffffffffffffff>] 0xffffffffffffffff
   hardirq-on-W at:
                        [<ffffffff80250447>] __lock_acquire+0x67e/0x155=
2
                        [<ffffffff80251370>] lock_acquire+0x55/0x71
                        [<ffffffff804daafc>] _spin_lock+0x2c/0x3b
                        [<ffffffff8028a736>] sys_fcntl+0x2c2/0x394
                        [<ffffffff8020b41b>] system_call_fastpath+0x16/=
0x1b
                        [<ffffffffffffffff>] 0xffffffffffffffff
 }
 ... key      at: [<ffffffff80c94368>] __key.20253+0x0/0x8

stack backtrace:
Pid: 2567, comm: X Not tainted 2.6.29-03321-gbe0ea69 #7
Call Trace:
 <IRQ>  [<ffffffff8024e7fa>] print_irq_inversion_bug+0x174/0x182
 [<ffffffff8024e89e>] check_usage_forwards+0x96/0x9e
 [<ffffffff8024ed7b>] mark_lock+0x43a/0x955
 [<ffffffff802503a2>] __lock_acquire+0x5d9/0x1552
 [<ffffffff802510f7>] ? __lock_acquire+0x132e/0x1552
 [<ffffffff80251370>] lock_acquire+0x55/0x71
 [<ffffffff8028a2ac>] ? kill_fasync+0x24/0x45
 [<ffffffff804dadde>] _read_lock+0x2f/0x3e
 [<ffffffff8028a2ac>] ? kill_fasync+0x24/0x45
 [<ffffffff8028a2ac>] kill_fasync+0x24/0x45
 [<ffffffff804156fe>] evdev_pass_event+0x66/0x6f
 [<ffffffff80415a92>] evdev_event+0x8e/0xee
 [<ffffffff80415a04>] ? evdev_event+0x0/0xee
 [<ffffffff80411f40>] input_pass_event+0x8a/0xc9
 [<ffffffff80411eb6>] ? input_pass_event+0x0/0xc9
 [<ffffffff8041264f>] input_handle_event+0x355/0x364
 [<ffffffff804134ce>] input_event+0x5b/0x79
 [<ffffffff80424a0e>] hidinput_hid_event+0x251/0x27b
 [<ffffffff8042168f>] hid_process_event+0xa8/0xdc
 [<ffffffff80421a31>] hid_report_raw_event+0x36e/0x382
 [<ffffffff80421b0d>] hid_input_report+0xc8/0xdc
 [<ffffffff8042864a>] hid_irq_in+0x94/0x185
 [<ffffffff803f66e8>] usb_hcd_giveback_urb+0x60/0x94
 [<ffffffff80407324>] uhci_giveback_urb+0x112/0x1a2
 [<ffffffff80407a79>] uhci_scan_schedule+0x5ab/0x86d
 [<ffffffff80409975>] uhci_irq+0x126/0x142
 [<ffffffff803f6221>] usb_hcd_irq+0x38/0x8e
 [<ffffffff80256ddb>] handle_IRQ_event+0x64/0x99
 [<ffffffff80258087>] handle_fasteoi_irq+0x8b/0xcb
 [<ffffffff8020dc7b>] do_IRQ+0x69/0xd6
 [<ffffffff8020bdd3>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff8031bb35>] ? delay_tsc+0x14/0x3f
 [<ffffffff8031ba55>] ? __delay+0xa/0xc
 [<ffffffff8031ba9a>] ? __const_udelay+0x43/0x45
 [<ffffffff803a27e6>] ? radeon_freelist_get+0xed/0x12f
 [<ffffffff803a2914>] ? radeon_cp_buffers+0xec/0x167
 [<ffffffff8039434d>] ? drm_ioctl+0x1af/0x292
 [<ffffffff803a2828>] ? radeon_cp_buffers+0x0/0x167
 [<ffffffff80394397>] ? drm_ioctl+0x1f9/0x292
 [<ffffffff804da99b>] ? _spin_unlock_irq+0x2b/0x31
 [<ffffffff8028aab6>] ? vfs_ioctl+0x6a/0x82
 [<ffffffff8022c4be>] ? finish_task_switch+0x7f/0xde
 [<ffffffff8028af31>] ? do_vfs_ioctl+0x463/0x4a4
 [<ffffffff804d8446>] ? thread_return+0x3d/0xdc
 [<ffffffff8020b44c>] ? sysret_check+0x27/0x62
 [<ffffffff8028afb4>] ? sys_ioctl+0x42/0x65
 [<ffffffff8020b41b>] ? system_call_fastpath+0x16/0x1b
--=20
Markus
