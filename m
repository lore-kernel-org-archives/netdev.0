From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.37-rc1-git5 -- WARNING: at net/ipv4/devinet.c:137
 in_dev_finish_destroy+0x3d/0x6e()
Date: Mon, 08 Nov 2010 21:46:31 +0100
Message-ID: <1289249191.2790.3.camel@edumazet-laptop>
References: <AANLkTinVyf4CpxdzEWUn7zTyOrAMKY3H9Dct-HfopiSD@mail.gmail.com>
	 <20101108200600.GG4032@linux.vnet.ibm.com>
	 <1289248166.2790.1.camel@edumazet-laptop>
	 <20101108204240.GA1585@arch.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Miles Lane <miles.lane@gmail.com>,
	ilpo.jarvinen@helsinki.fi, LKML <linux-kernel@vger.kernel.org>,
	Len Brown <lenb@kernel.org>, netdev@vger.kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101108204240.GA1585@arch.trippelsdorf.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 08 novembre 2010 =C3=A0 21:42 +0100, Markus Trippelsdorf a =C3=
=A9crit :
> On Mon, Nov 08, 2010 at 09:29:26PM +0100, Eric Dumazet wrote:
> > Le lundi 08 novembre 2010 =C3=A0 12:06 -0800, Paul E. McKenney a =C3=
=A9crit :
> > > On Mon, Nov 08, 2010 at 02:56:06PM -0500, Miles Lane wrote:
> > > > WARNING: at net/ipv4/devinet.c:137 in_dev_finish_destroy+0x3d/0=
x6e()
> > > > Hardware name: UL50VT
> > > > Modules linked in: ipv6 snd_hda_codec_hdmi snd_hda_codec_realte=
k
> > > > snd_hda_intel snd_hda_codec snd_pcm_oss snd_hwdep snd_mixer_oss
> > > > snd_seq_dummy snd_pcm snd_seq_oss snd_seq_midi iwlagn snd_rawmi=
di
> > > > snd_seq_midi_event snd_seq iwlcore uvcvideo snd_timer mac80211
> > > > snd_seq_device videodev v4l1_compat v4l2_compat_ioctl32 i915 sn=
d
> > > > rtc_cmos rtc_core psmouse cfg80211 soundcore drm_kms_helper
> > > > snd_page_alloc rtc_lib asus_laptop video battery ac sparse_keym=
ap wmi
> > > > button rfkill processor power_supply led_class usb_storage sg s=
r_mod
> > > > sd_mod cdrom atl1c ehci_hcd uhci_hcd thermal thermal_sys hwmon
> > > > Pid: 0, comm: kworker/0:0 Not tainted 2.6.37-rc1-git5 #10
> > > > Call Trace:
> > > >  <IRQ>  [<ffffffff8103767e>] warn_slowpath_common+0x80/0x98
> > > >  [<ffffffff810376ab>] warn_slowpath_null+0x15/0x17
> > > >  [<ffffffff8130d549>] in_dev_finish_destroy+0x3d/0x6e
> > > >  [<ffffffff8130d58e>] in_dev_put+0x14/0x16
> > > >  [<ffffffff8130d5ab>] inet_rcu_free_ifa+0x1b/0x27
> > > >  [<ffffffff810834a8>] __rcu_process_callbacks+0x1a4/0x2bc
> > > >  [<ffffffff8108363b>] rcu_process_callbacks+0x7b/0x82
> > > >  [<ffffffff8103cb9c>] __do_softirq+0xb8/0x15a
> > > >  [<ffffffff8100394c>] call_softirq+0x1c/0x28
> > > >  [<ffffffff81005637>] do_softirq+0x38/0x81
> > > >  [<ffffffff8103cce9>] irq_exit+0x45/0x94
> > > >  [<ffffffff8101ac1f>] smp_apic_timer_interrupt+0x78/0x86
> > > >  [<ffffffff81003413>] apic_timer_interrupt+0x13/0x20
> > > >  <EOI>  [<ffffffff8134aff6>] ? _raw_spin_unlock_irqrestore+0x3c=
/0x69
> > > >  [<ffffffff81059cb3>] clockevents_notify+0x11e/0x12d
> > > >  [<ffffffffa008e561>] ? acpi_idle_enter_bm+0x236/0x271 [process=
or]
> > > >  [<ffffffffa008dfce>] lapic_timer_state_broadcast+0x41/0x43 [pr=
ocessor]
> > > >  [<ffffffffa008e588>] acpi_idle_enter_bm+0x25d/0x271 [processor=
]
> > > >  [<ffffffff8129db30>] cpuidle_idle_call+0x9e/0xda
> > > >  [<ffffffff810012ea>] cpu_idle+0xce/0x10c
> > > >  [<ffffffff81343ce8>] start_secondary+0x1fc/0x205
> > > > ---[ end trace 1d49bc8ff0266634 ]---
> > > > Freeing alive in_device ffff88013fe536d0
> > >=20
> > > Ilpo, thoughts?
> > >=20
> >=20
> > Hmm...=20
> >=20
> >     WARN_ON(idev->mc_list);
> >=20
> > Might be a problem with refcounts somewhere...
>=20
> I have similar warnings in my logs, although its at
> net/ipv4/devinet.c:136 in my case. Happened altogether three times in
> the last few days and they all look the same:
>=20
> Nov  5 17:31:35 arch kernel: WARNING: at net/ipv4/devinet.c:136 in_de=
v_finish_destroy+0x5c/0x90()
> Nov  5 17:31:35 arch kernel: Hardware name: System Product Name
> Nov  5 17:31:35 arch kernel: Pid: 0, comm: kworker/0:1 Not tainted 2.=
6.37-rc1-00027-gff8b16d-dirty #4
> Nov  5 17:31:35 arch kernel: Call Trace:
> Nov  5 17:31:35 arch kernel: <IRQ>  [<ffffffff8105c9f6>] ? warn_slowp=
ath_common+0x76/0xc0
> Nov  5 17:31:35 arch kernel: [<ffffffff8141889c>] ? in_dev_finish_des=
troy+0x5c/0x90
> Nov  5 17:31:35 arch kernel: [<ffffffff813c49e8>] ? dst_destroy+0x68/=
0x120
> Nov  5 17:31:35 arch kernel: [<ffffffff813e888f>] ? dst_rcu_free+0x1f=
/0x30
> Nov  5 17:31:35 arch kernel: [<ffffffff81090e0c>] ? __rcu_process_cal=
lbacks+0xfc/0x2f0
> Nov  5 17:31:35 arch kernel: [<ffffffff8109103f>] ? rcu_process_callb=
acks+0x3f/0x70
> Nov  5 17:31:35 arch kernel: [<ffffffff810621bc>] ? __do_softirq+0x9c=
/0x120
> Nov  5 17:31:35 arch kernel: [<ffffffff81030fc9>] ? timer_interrupt+0=
x19/0x30
> Nov  5 17:31:35 arch kernel: [<ffffffff8102ea4c>] ? call_softirq+0x1c=
/0x30
> Nov  5 17:31:35 arch kernel: [<ffffffff8103080d>] ? do_softirq+0x4d/0=
x80
> Nov  5 17:31:35 arch kernel: [<ffffffff8106232d>] ? irq_exit+0x8d/0x9=
0
> Nov  5 17:31:35 arch kernel: [<ffffffff810306c7>] ? do_IRQ+0x67/0xe0
> Nov  5 17:31:35 arch kernel: [<ffffffff8144a153>] ? ret_from_intr+0x0=
/0xa
> Nov  5 17:31:35 arch kernel: <EOI>  [<ffffffff81035ba0>] ? default_id=
le+0x20/0x40
> Nov  5 17:31:35 arch kernel: [<ffffffff81035c12>] ? c1e_idle+0x52/0xf=
0
> Nov  5 17:31:35 arch kernel: [<ffffffff8102c12c>] ? cpu_idle+0x4c/0xa=
0
> Nov  5 17:31:35 arch kernel: ---[ end trace 143683935de8f41f ]---
> Nov  5 17:31:35 arch kernel: Freeing alive in_device ffff88011ffba600
>=20

Hmm....

Is commit 1f1b9c9990205759aae31b7734b0ede41a867f32 present in your
kernel ? (fib: fib_result_assign() should not change fib refcounts)

Could you provide some information ?

ifconfig -a

ip ro

Thanks
