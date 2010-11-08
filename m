From: Miles Lane <miles.lane@gmail.com>
Subject: Re: 2.6.37-rc1-git5 -- WARNING: at net/ipv4/devinet.c:137 in_dev_finish_destroy+0x3d/0x6e()
Date: Mon, 8 Nov 2010 15:50:09 -0500
Message-ID: <AANLkTim83Qqa==q6ZZYi2AxETThOrr5n4DkDPm1mrPFU@mail.gmail.com>
References: <AANLkTinVyf4CpxdzEWUn7zTyOrAMKY3H9Dct-HfopiSD@mail.gmail.com>
	<20101108200600.GG4032@linux.vnet.ibm.com>
	<1289248166.2790.1.camel@edumazet-laptop>
	<20101108204240.GA1585@arch.trippelsdorf.de>
	<1289249191.2790.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
	paulmck@linux.vnet.ibm.com, ilpo.jarvinen@helsinki.fi,
	LKML <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289249191.2790.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

# ifconfig -a
eth0      Link encap:Ethernet  HWaddr e0:cb:4e:0a:ba:16
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
          Interrupt:48

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:720 (720.0 B)  TX bytes:720 (720.0 B)

wlan0     Link encap:Ethernet  HWaddr 00:1e:64:06:05:96
          inet addr:192.168.1.104  Bcast:192.168.1.255  Mask:255.255.25=
5.0
          inet6 addr: fe80::21e:64ff:fe06:596/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:86889 errors:0 dropped:1 overruns:0 frame:0
          TX packets:53180 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:88241580 (88.2 MB)  TX bytes:10132172 (10.1 MB)

# ip ro
192.168.1.0/24 dev wlan0  proto kernel  scope link  src 192.168.1.104  =
metric 2
169.254.0.0/16 dev wlan0  scope link  metric 1000
default via 192.168.1.1 dev wlan0  proto static


On Mon, Nov 8, 2010 at 3:46 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le lundi 08 novembre 2010 =E0 21:42 +0100, Markus Trippelsdorf a =E9c=
rit :
>> On Mon, Nov 08, 2010 at 09:29:26PM +0100, Eric Dumazet wrote:
>> > Le lundi 08 novembre 2010 =E0 12:06 -0800, Paul E. McKenney a =E9c=
rit :
>> > > On Mon, Nov 08, 2010 at 02:56:06PM -0500, Miles Lane wrote:
>> > > > WARNING: at net/ipv4/devinet.c:137 in_dev_finish_destroy+0x3d/=
0x6e()
>> > > > Hardware name: UL50VT
>> > > > Modules linked in: ipv6 snd_hda_codec_hdmi snd_hda_codec_realt=
ek
>> > > > snd_hda_intel snd_hda_codec snd_pcm_oss snd_hwdep snd_mixer_os=
s
>> > > > snd_seq_dummy snd_pcm snd_seq_oss snd_seq_midi iwlagn snd_rawm=
idi
>> > > > snd_seq_midi_event snd_seq iwlcore uvcvideo snd_timer mac80211
>> > > > snd_seq_device videodev v4l1_compat v4l2_compat_ioctl32 i915 s=
nd
>> > > > rtc_cmos rtc_core psmouse cfg80211 soundcore drm_kms_helper
>> > > > snd_page_alloc rtc_lib asus_laptop video battery ac sparse_key=
map wmi
>> > > > button rfkill processor power_supply led_class usb_storage sg =
sr_mod
>> > > > sd_mod cdrom atl1c ehci_hcd uhci_hcd thermal thermal_sys hwmon
>> > > > Pid: 0, comm: kworker/0:0 Not tainted 2.6.37-rc1-git5 #10
>> > > > Call Trace:
>> > > > =A0<IRQ> =A0[<ffffffff8103767e>] warn_slowpath_common+0x80/0x9=
8
>> > > > =A0[<ffffffff810376ab>] warn_slowpath_null+0x15/0x17
>> > > > =A0[<ffffffff8130d549>] in_dev_finish_destroy+0x3d/0x6e
>> > > > =A0[<ffffffff8130d58e>] in_dev_put+0x14/0x16
>> > > > =A0[<ffffffff8130d5ab>] inet_rcu_free_ifa+0x1b/0x27
>> > > > =A0[<ffffffff810834a8>] __rcu_process_callbacks+0x1a4/0x2bc
>> > > > =A0[<ffffffff8108363b>] rcu_process_callbacks+0x7b/0x82
>> > > > =A0[<ffffffff8103cb9c>] __do_softirq+0xb8/0x15a
>> > > > =A0[<ffffffff8100394c>] call_softirq+0x1c/0x28
>> > > > =A0[<ffffffff81005637>] do_softirq+0x38/0x81
>> > > > =A0[<ffffffff8103cce9>] irq_exit+0x45/0x94
>> > > > =A0[<ffffffff8101ac1f>] smp_apic_timer_interrupt+0x78/0x86
>> > > > =A0[<ffffffff81003413>] apic_timer_interrupt+0x13/0x20
>> > > > =A0<EOI> =A0[<ffffffff8134aff6>] ? _raw_spin_unlock_irqrestore=
+0x3c/0x69
>> > > > =A0[<ffffffff81059cb3>] clockevents_notify+0x11e/0x12d
>> > > > =A0[<ffffffffa008e561>] ? acpi_idle_enter_bm+0x236/0x271 [proc=
essor]
>> > > > =A0[<ffffffffa008dfce>] lapic_timer_state_broadcast+0x41/0x43 =
[processor]
>> > > > =A0[<ffffffffa008e588>] acpi_idle_enter_bm+0x25d/0x271 [proces=
sor]
>> > > > =A0[<ffffffff8129db30>] cpuidle_idle_call+0x9e/0xda
>> > > > =A0[<ffffffff810012ea>] cpu_idle+0xce/0x10c
>> > > > =A0[<ffffffff81343ce8>] start_secondary+0x1fc/0x205
>> > > > ---[ end trace 1d49bc8ff0266634 ]---
>> > > > Freeing alive in_device ffff88013fe536d0
>> > >
>> > > Ilpo, thoughts?
>> > >
>> >
>> > Hmm...
>> >
>> > =A0 =A0 WARN_ON(idev->mc_list);
>> >
>> > Might be a problem with refcounts somewhere...
>>
>> I have similar warnings in my logs, although its at
>> net/ipv4/devinet.c:136 in my case. Happened altogether three times i=
n
>> the last few days and they all look the same:
>>
>> Nov =A05 17:31:35 arch kernel: WARNING: at net/ipv4/devinet.c:136 in=
_dev_finish_destroy+0x5c/0x90()
>> Nov =A05 17:31:35 arch kernel: Hardware name: System Product Name
>> Nov =A05 17:31:35 arch kernel: Pid: 0, comm: kworker/0:1 Not tainted=
 2.6.37-rc1-00027-gff8b16d-dirty #4
>> Nov =A05 17:31:35 arch kernel: Call Trace:
>> Nov =A05 17:31:35 arch kernel: <IRQ> =A0[<ffffffff8105c9f6>] ? warn_=
slowpath_common+0x76/0xc0
>> Nov =A05 17:31:35 arch kernel: [<ffffffff8141889c>] ? in_dev_finish_=
destroy+0x5c/0x90
>> Nov =A05 17:31:35 arch kernel: [<ffffffff813c49e8>] ? dst_destroy+0x=
68/0x120
>> Nov =A05 17:31:35 arch kernel: [<ffffffff813e888f>] ? dst_rcu_free+0=
x1f/0x30
>> Nov =A05 17:31:35 arch kernel: [<ffffffff81090e0c>] ? __rcu_process_=
callbacks+0xfc/0x2f0
>> Nov =A05 17:31:35 arch kernel: [<ffffffff8109103f>] ? rcu_process_ca=
llbacks+0x3f/0x70
>> Nov =A05 17:31:35 arch kernel: [<ffffffff810621bc>] ? __do_softirq+0=
x9c/0x120
>> Nov =A05 17:31:35 arch kernel: [<ffffffff81030fc9>] ? timer_interrup=
t+0x19/0x30
>> Nov =A05 17:31:35 arch kernel: [<ffffffff8102ea4c>] ? call_softirq+0=
x1c/0x30
>> Nov =A05 17:31:35 arch kernel: [<ffffffff8103080d>] ? do_softirq+0x4=
d/0x80
>> Nov =A05 17:31:35 arch kernel: [<ffffffff8106232d>] ? irq_exit+0x8d/=
0x90
>> Nov =A05 17:31:35 arch kernel: [<ffffffff810306c7>] ? do_IRQ+0x67/0x=
e0
>> Nov =A05 17:31:35 arch kernel: [<ffffffff8144a153>] ? ret_from_intr+=
0x0/0xa
>> Nov =A05 17:31:35 arch kernel: <EOI> =A0[<ffffffff81035ba0>] ? defau=
lt_idle+0x20/0x40
>> Nov =A05 17:31:35 arch kernel: [<ffffffff81035c12>] ? c1e_idle+0x52/=
0xf0
>> Nov =A05 17:31:35 arch kernel: [<ffffffff8102c12c>] ? cpu_idle+0x4c/=
0xa0
>> Nov =A05 17:31:35 arch kernel: ---[ end trace 143683935de8f41f ]---
>> Nov =A05 17:31:35 arch kernel: Freeing alive in_device ffff88011ffba=
600
>>
>
> Hmm....
>
> Is commit 1f1b9c9990205759aae31b7734b0ede41a867f32 present in your
> kernel ? (fib: fib_result_assign() should not change fib refcounts)
>
> Could you provide some information ?
>
> ifconfig -a
>
> ip ro
>
> Thanks
>
>
>
