From: Justin Mattock <justinmattock@gmail.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x1f2/0x200()
Date: Sun, 18 Mar 2012 21:01:01 -0700
Message-ID: <CAKFRV=NghW3kokuD-VBAzVJf09r-9ePMG+L7qDYfqmuHwWo4mg@mail.gmail.com>
References: <20120205134050.7e135bb231b613806a2e0b70@gmail.com>
	<4F2F0065.9040909@lwfinger.net>
	<20120205222141.GA26223@electric-eye.fr.zoreil.com>
	<20120205145913.194746473361e324bda1eb4a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120205145913.194746473361e324bda1eb4a@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 5, 2012 at 2:59 PM, Justin P. Mattock
<justinmattock@gmail.com> wrote:
> On Sun, 5 Feb 2012 23:21:41 +0100
> Francois Romieu <romieu@fr.zoreil.com> wrote:
>
>> Larry Finger <Larry.Finger@lwfinger.net> :
>> > On 02/05/2012 03:40 PM, Justin P. Mattock wrote:
>> > >
>> > >this showed up as I woke the machine up from suspend. machine is =
connected
>> > >I just see networkmanager constantly spinning trying to connect t=
hen telling me
>> > >the wired network is not connected(even though its just wireless =
that I have).
>>
>> [ 1273.447349] r8169 0000:06:00.0: Refused to change power state, cu=
rrently in D3
>> [ 1273.571024] psmouse serio1: elantech: retrying ps2 command 0xf8 (=
2).
>> [ 1273.656709] r8169 0000:06:00.0: eth0: link up
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0^^^^^^^
>>
>> Justin, you did not ever connect a cable, did you ?
>
> nope! was using wireless the whole time.
>
>>
>> [...]
>> > The error clearly comes from r8169, not from ath9k. If you unload
>> > r8169 before suspending, does this still happen? My suspicion is
>> > that NM is getting confused.
>>
>> It could hide the problem but the D3 + link up messages are nonethel=
ess
>> a bit unexpected.
>>
>> > P.S. Unless it happens with just the ath9k active, this ML is like=
ly
>> > not the correct one.
>>
>> Yes, please Cc: netdev@vger.kernel.org + me instead.
>>
>> Thanks.
>>
>> --
>> Ueimor
>
> removed linux-wireless and added netdev to the cc's
> will monitor this and report anything that shows up.
>
> --
> Justin P. Mattock <justinmattock@gmail.com>

seems I see this with the latest linux-next:

[21731.149774] wlan0: associate with 00:1e:2a:62:6b:1e (try 1/3)
[21731.152858] wlan0: RX AssocResp from 00:1e:2a:62:6b:1e (capab=3D0x31
status=3D0 aid=3D7)
[21731.152867] wlan0: associated
[21740.306348] ------------[ cut here ]------------
[21740.306363] WARNING: at net/sched/sch_generic.c:256
dev_watchdog+0x1f2/0x200()
[21740.306367] Hardware name: 0914
[21740.306370] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed ou=
t
[21740.306374] Modules linked in: dm_crypt xt_limit xt_tcpudp
xt_addrtype snd_hda_codec_hdmi xt_state joydev arc4
snd_hda_codec_conexant ath9k nf_conntrack_netbios_ns
nf_conntrack_broadcast snd_hda_intel snd_hda_codec mac80211 nf_nat_ftp
nf_nat snd_hwdep nf_conntrack_ipv4 nf_defrag_ipv4 snd_pcm
nf_conntrack_ftp snd_seq_midi ath9k_common ath9k_hw nf_conntrack
iptable_filter snd_rawmidi snd_seq_midi_event uvcvideo ath ip_tables
videobuf2_core videodev psmouse x_tables ideapad_laptop serio_raw
snd_seq cfg80211 lp snd_timer snd_seq_device snd videobuf2_vmalloc
videobuf2_memops soundcore parport sparse_keymap intel_ips
snd_page_alloc usb_storage uas i915 drm_kms_helper drm i2c_algo_bit
r8169 intel_agp intel_gtt agpgart video
[21740.306469] Pid: 0, comm: swapper/2 Not tainted 3.3.0-rc7-next-20120=
316 #1
[21740.306473] Call Trace:
[21740.306483]  [<c1049072>] warn_slowpath_common+0x72/0xa0
[21740.306489]  [<c14e00a2>] ? dev_watchdog+0x1f2/0x200
[21740.306493]  [<c14e00a2>] ? dev_watchdog+0x1f2/0x200
[21740.306498]  [<c1049143>] warn_slowpath_fmt+0x33/0x40
[21740.306503]  [<c14e00a2>] dev_watchdog+0x1f2/0x200
[21740.306520]  [<c1059c12>] run_timer_softirq+0x132/0x540
[21740.306525]  [<c1059b98>] ? run_timer_softirq+0xb8/0x540
[21740.306529]  [<c14dfeb0>] ? pfifo_fast_init+0x60/0x60
[21740.306534]  [<c1050e67>] __do_softirq+0x97/0x360
[21740.306539]  [<c1050dd0>] ? local_bh_enable+0xd0/0xd0
[21740.306542]  <IRQ>  [<c10513d6>] ? irq_exit+0x86/0xb0
[21740.306552]  [<c159f179>] ? smp_apic_timer_interrupt+0x59/0x88
[21740.306559]  [<c12cf1a8>] ? trace_hardirqs_off_thunk+0xc/0x14
[21740.306565]  [<c1597682>] ? apic_timer_interrupt+0x36/0x3c
[21740.306572]  [<c10a007b>] ? clocks_calc_mult_shift+0xfb/0x100
[21740.306580]  [<c1319fd9>] ? intel_idle+0xc9/0x130
[21740.306588]  [<c1495655>] ? cpuidle_enter+0x15/0x20
[21740.306592]  [<c1495b5a>] ? cpuidle_idle_call+0x8a/0x320
[21740.306600]  [<c10152c5>] ? cpu_idle+0xa5/0xf0
[21740.306607]  [<c1585d2d>] ? start_secondary+0x209/0x20f
[21740.306611] ---[ end trace 9a4d94a7e2dfb4d0 ]---
[21740.318685] r8169 0000:06:00.0: eth0: link up
[21752.292679] r8169 0000:06:00.0: eth0: link up
[21764.268569] r8169 0000:06:00.0: eth0: link up
[21776.254393] r8169 0000:06:00.0: eth0: link up
[21788.235797] r8169 0000:06:00.0: eth0: link up
[21800.196524] r8169 0000:06:00.0: eth0: link up
[21812.172497] r8169 0000:06:00.0: eth0: link up

one thing I have noticed these few weeks is once I wake the machine
up, wireless connects, but Networkmanager keeps trying to connect
ethernet(switching ethernet off in preferences or waiting a while
resolves this issue from the daemon), so I think there must be some
strange thing with NM
causing this(disabling "auto connect" gets rid of this issue)
the system is ubuntu(oneiric)


--=20
Justin P. Mattock
