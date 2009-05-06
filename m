From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13258] New: After few hours (less than 3)
 Network module crash and I need to reboot
Date: Wed, 6 May 2009 12:21:40 -0700
Message-ID: <20090506122140.9d5f0e71.akpm@linux-foundation.org>
References: <bug-13258-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>, mich.nolly@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45401 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753778AbZEFTY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 15:24:28 -0400
In-Reply-To: <bug-13258-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

A forcedeth tx timeout.

On Wed, 6 May 2009 19:05:47 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13258
> 
>            Summary: After few hours (less than 3) Network module crash and
>                     I need to reboot
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.29.2-52.fc10.i686 #1 SMP Mon Apr 27 16:29:14 EDT
>                     2009 i686 athlon i386 GNU/Linux
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: mich.nolly@gmail.com
>         Regression: No
> 
> 
> Since few kernel release from fedora 10 repo, kernel crash when network is
> sollicited : long download, or reading a movie from samba server.
> 
> I tried noapic option : no change
> noapic and nolapic options : nochange
> 
> I tried with an addon network pci card accton en1207 and just noapic : ok (it
> failed without noapic)
> cpu model name    : AMD Athlon(tm) 64 Processor 3000+
> ram is 2x512 MB
> network is onboard nforce3 network (forcedeth driver)
> 
> Here is the kernel tracelog (napic and nolapic options used)
> 
> 
> May  6 18:13:25 mybecane kernel: WARNING: at net/sched/sch_generic.c:226
> dev_watchdog+0xac/0x140() (Not tainted)
> May  6 18:13:25 mybecane kernel: Hardware name: SN85V30
> May  6 18:13:25 mybecane kernel: NETDEV WATCHDOG: eth0 (forcedeth): transmit
> timed out
> May  6 18:13:25 mybecane kernel: Modules linked in: fuse sunrpc ipv6
> nf_conntrack_netbios_ns cpufreq_ondemand powernow_k8 dm_multipath uinput
> snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss
> snd_seq_midi_event snd_seq snd_seq_device ppdev snd_pcm_oss snd_mixer_oss
> pcspkr floppy snd_pcm firewire_ohci firewire_core k8temp hwmon snd_timer snd
> forcedeth i2c_nforce2 crc_itu_t soundcore parport_pc i2c_core snd_page_alloc
> parport pata_amd ata_generic pata_acpi sata_nv [last unloaded: scsi_wait_scan]
> May  6 18:13:25 mybecane kernel: Pid: 0, comm: swapper Not tainted
> 2.6.29.2-52.fc10.i686 #1
> May  6 18:13:25 mybecane kernel: Call Trace:
> May  6 18:13:25 mybecane kernel: [<c042e5c4>] warn_slowpath+0x77/0xb4
> May  6 18:13:25 mybecane kernel: [<c0424f59>] ? enqueue_entity+0x295/0x29d
> May  6 18:13:25 mybecane kernel: [<c04220f8>] ?
> check_preempt_wakeup+0x167/0x1ad
> May  6 18:13:25 mybecane kernel: [<c06d7946>] ?
> _spin_unlock_irqrestore+0x22/0x38
> May  6 18:13:25 mybecane kernel: [<c04287a4>] ? try_to_wake_up+0x22e/0x239
> May  6 18:13:25 mybecane kernel: [<c04287ba>] ? default_wake_function+0xb/0xd
> May  6 18:13:25 mybecane kernel: [<c043f146>] ?
> autoremove_wake_function+0xf/0x33
> May  6 18:13:25 mybecane kernel: [<c05308b2>] ? strlcpy+0x17/0x49
> May  6 18:13:25 mybecane kernel: [<c0662eb0>] dev_watchdog+0xac/0x140
> May  6 18:13:25 mybecane kernel: [<c0410068>] ?
> speedstep_detect_processor+0xf9/0x1fd
> May  6 18:13:25 mybecane kernel: [<f7d3c955>] ? nv_napi_poll+0x4ce/0x4d9
> [forcedeth]
> May  6 18:13:25 mybecane kernel: [<c04364b8>] run_timer_softirq+0x14b/0x1bb
> May  6 18:13:25 mybecane kernel: [<c0662e04>] ? dev_watchdog+0x0/0x140
> May  6 18:13:25 mybecane kernel: [<c0662e04>] ? dev_watchdog+0x0/0x140
> May  6 18:13:25 mybecane kernel: [<c04332b2>] __do_softirq+0x98/0x136
> May  6 18:13:25 mybecane kernel: [<c043321a>] ? __do_softirq+0x0/0x136
> May  6 18:13:25 mybecane kernel: <IRQ>  [<c0432f7e>] ? irq_exit+0x44/0x72
> May  6 18:13:25 mybecane kernel: [<c041486d>] ?
> smp_apic_timer_interrupt+0x74/0x82
> May  6 18:13:25 mybecane kernel: [<c04044e1>] ? apic_timer_interrupt+0x2d/0x34
> May  6 18:13:25 mybecane kernel: [<c041ab47>] ? native_safe_halt+0x5/0x7
> May  6 18:13:25 mybecane kernel: [<c04091d6>] ? default_idle+0x4a/0x84
> May  6 18:13:25 mybecane kernel: [<c0402dfc>] ? cpu_idle+0x6b/0x8b
> May  6 18:13:25 mybecane kernel: [<c06c67fb>] ? rest_init+0x53/0x55
> May  6 18:13:25 mybecane kernel: ---[ end trace 07f9a974f431ff39 ]---
> May  6 18:13:25 mybecane kernel: eth0: Got tx_timeout. irq: 00000000
> May  6 18:13:25 mybecane kernel: eth0: Ring at 36489000
> May  6 18:13:25 mybecane kernel: eth0: Dumping tx registers
> May  6 18:13:25 mybecane kernel:  0: 00000000 000000ff 00000003 025703ca
> 00000000 00000000 00000000 00000000
> May  6 18:13:25 mybecane kernel: 20: 00000000 00000000 00000000 00000000
> 00000000 00000000 00000000 00000000
> May  6 18:13:25 mybecane kernel: 40: 0420e20e 00000855 00000000 00000000
> 00000000 00000000 00000000 00000000
> May  6 18:13:25 mybecane kernel: 60: 00000000 00000000 00000000 00000000
> 00000000 00000000 00000000 00000000
> May  6 18:13:25 mybecane kernel: 80: 003b0f3c 00000001 00040000 007f0028
> 0000061c 00000001 00200000 80007f53
> May  6 18:13:25 mybecane kernel: a0: 0015050f 00000016 b71b3000 00000801
> 00000001 00000000 4800cccd 000004fc
> May  6 18:13:25 mybecane kernel: c0: 00000001 00000001 00000001 00000001
> 00000001 00000001 00000001 00000001
> May  6 18:13:25 mybecane kernel: e0: 00000001 00000001 00000001 00000001
> 00000001 00000001 00000001 00000001
> May  6 18:13:25 mybecane kernel: 100: 36489400 36489000 007f00ff 00008000
> 00010064 00000000 00000043 364896f0
> May  6 18:13:25 mybecane kernel: 120: 364890e0 21707400 a000ffe1 00000000
> 00000000 364896ec 364890e4 01e08000
> May  6 18:13:25 mybecane kernel: 140: 003041c0 00002500 00000000 00000000
> 00000000 00000000 00000000 00000000
> May  6 18:13:25 mybecane kernel: 160: 00000000 00000000 00000000 00000000
> 00000000 00000000 00000000 00000000
> May  6 18:13:25 mybecane kernel: 180: 00000016 00000008 0194786d 00008103
> 00000025 000045e1 0194786d 0000c5e3
> May  6 18:13:25 mybecane kernel: 1a0: 00000016 00000008 0194786d 00008103
> 00000025 000045e1 0194786d 0000c5e3
> May  6 18:13:25 mybecane kernel: 1c0: 00000016 00000008 0194786d 00008103
> 00000025 000045e1 0194786d 0000c5e3
> May  6 18:13:25 mybecane kernel: 1e0: 00000016 00000008 0194786d 00008103
> 00000025 000045e1 0194786d 0000c5e3
> May  6 18:13:25 mybecane kernel: 200: 00000000 00000000 00000000 00000000
> 00000000 00000000 00000000 00000000
> May  6 18:13:25 mybecane kernel: 220: 00000000 00000000 00000000 00000000
> 00000000 00000000 00000000 00000000
> May  6 18:13:25 mybecane kernel: 240: 00000000 00000000 00000000 00000000
> 00000000 00000000 00000000 00000000
> May  6 18:13:25 mybecane kernel: 260: 00000000 00000000 fe020001 00000100
> 00000000 00000000 fe020001 00000100
> May  6 18:13:25 mybecane kernel: eth0: Dumping tx ring
> May  6 18:13:25 mybecane kernel: 000: 216e08fa a0000035 // 216e0cfa a0000035 //
> 216e1402 ac0000a8 // 216d3e02 ac00005c
> May  6 18:13:25 mybecane kernel: 004: 2153e002 ac00004c // 2153e202 ac00005c //
> 216e193e 8c000041 // 21520631 a000059f
> May  6 18:13:25 mybecane kernel: 008: 216e1d3e 8c000041 // 2148fe73 8000018c //
> 215fc000 a00002b1 // 2153e402 ac00005c
> May  6 18:13:25 mybecane kernel: 00c: 2153e602 ac00005c // 2153e802 ac00005c //
> 2153ea02 ac00004c // 2153ec02 ac00005c
> May  6 18:13:25 mybecane kernel: 010: 2153ee02 ac00005c // 2167054a 8c000035 //
> 2168a0c1 a00005b3 // 215ae602 ac000051
> May  6 18:13:25 mybecane kernel: 014: 215ae202 ac00005c // 215ae002 ac00005c //
> 215ae402 ac00005c // 2167113e 8c000041
> May  6 18:13:25 mybecane kernel: 018: 21589e3a 800001c5 // 21707000 a00003e1 //
> 2167153e 8c000041 // 2151aa33 a0000487
> May  6 18:13:25 mybecane kernel: 01c: 21671d3e 8c000041 // 2166f604 a0000513 //
> 216a813e 8c000041 // 340cf5eb a000059f
> May  6 18:13:25 mybecane kernel: 020: 216a854a 8c000035 // 2163521f a000002d //
> 215ae802 ac000055 // 215aea02 ac00005c
> May  6 18:13:25 mybecane kernel: 024: 215aec02 ac00005c // 2154f002 ac00005c //
> 216a88ee a0000041 // 216a8d3e 8c000041
> May  6 18:13:25 mybecane kernel: 028: 21746744 a00005a7 // 216a98fa a0000035 //
> 2154f802 ac00004c // 2154f202 ac00005c
> May  6 18:13:25 mybecane kernel: 02c: 2154fa02 ac00004c // 2154f402 ac00005c //
> 340d08e6 a0000049 // 216a9cfa a0000035
> May  6 18:13:25 mybecane kernel: 030: 070c00fa a0000035 // 070c04ee a0000041 //
> 2154f602 ac000051 // 2154fc02 ac000051
> May  6 18:13:25 mybecane kernel: 034: 2154fe02 ac000051 // 070c093e 8c000041 //
> 2157539d a0000513 // 070c0cee a0000041
> May  6 18:13:25 mybecane kernel: 038: 070c10fa a0000035 // 215aee02 ac00005c //
> 21783002 ac00005c // 070c1802 ac00007a
> May  6 18:13:25 mybecane kernel: 03c: 070c1c02 ac00007a // 21783202 ac00005c //
> 21783402 ac00005c // 070c213e 8c000041
> May  6 18:13:25 mybecane kernel: 040: 21520631 a000059f // 070c24fa a0000035 //
> 070c293e 8c000041 // 216b11cc a00004f5
> May  6 18:13:25 mybecane kernel: 044: 070c2d3e 8c000041 // 216c5b3a 800004c5 //
> 2177d000 a000004d // 070c313e 8c000041
> May  6 18:13:25 mybecane kernel: 048: 21588d7a 80000285 // 21510000 a0000319 //
> 070c353e 8c000041 // 2151031a a0000315
> May  6 18:13:25 mybecane kernel: 04c: 070c393e 8c000041 // 21510630 a000059f //
> 070c813e 8c000041 // 2148fe73 8000018c
> May  6 18:13:25 mybecane kernel: 050: 215fc000 a00002b1 // 21783602 ac000055 //
> 21783802 ac00005c // 21783a02 ac00005c
> May  6 18:13:25 mybecane kernel: 054: 21783c02 ac00005c // 21783e02 ac00004c //
> 070c853e 8c000041 // 21588d7a 80000285
> May  6 18:13:25 mybecane kernel: 058: 21510000 a0000319 // 070c894a 8c000035 //
> 2168a0c1 a00005b3 // 21730202 ac00005c
> May  6 18:13:25 mybecane kernel: 05c: 21589e3a 00000000 // 21707000 a00003e1 //
> 364294ee a0000041 // 36230cee a0000041
> May  6 18:13:25 mybecane kernel: 060: 341d18ee a0000041 // 2167a0ee a0000041 //
> 2167b0fa a0000035 // 2167b8fa a0000035
> May  6 18:13:25 mybecane kernel: 064: 3434e4fa a0000035 // 215774fa a0000035 //
> 3634c0fa a0000035 // 2148c8ee a0000041
> May  6 18:13:25 mybecane kernel: 068: 2148c0ee a0000041 // 34125d3e 8c000041 //
> 215df0c5 a000002e // 342da13e 8c000041
> May  6 18:13:25 mybecane kernel: 06c: 21495098 a000002e // 342da53e 8c000041 //
> 214ea162 a000002e // 342dad3e 8c000041
> May  6 18:13:25 mybecane kernel: 070: 216ae080 a000002e // 342db13e 8c000041 //
> 2175eb13 a000002d // 3613ed3e 91478041
> May  6 18:13:25 mybecane kernel: 074: 216b1be0 8000041f // 215c4000 a000061b //
> 21576d3e 8c000041 // 215efc80 8000037f
> May  6 18:13:25 mybecane kernel: 078: 21625000 a0000193 // 342db8fa a0000035 //
> 342dbd3e 8c000041 // 21520631 a000059f
> May  6 18:13:25 mybecane kernel: 07c: 2157013e 8c000041 // 21520bd1 a0000283 //
> 2157093e 8c000041 // 2148fe73 8000018c
> May  6 18:13:25 mybecane kernel: 080: 215fc000 a00002b1 // 21570d3e 8c000041 //
> 215fc2b2 a000059f // 215714ee a0000041
> May  6 18:13:25 mybecane kernel: 084: 2157194a 8c000035 // 2168a0c1 a00005b3 //
> 21571d4a 8c000035 // 2168a675 a0000473
> May  6 18:13:25 mybecane kernel: 088: 2157653e 8c000041 // 21746744 a00005a7 //
> 2160013e 8c000041 // 214ea162 a000002e
> May  6 18:13:25 mybecane kernel: 08c: 2160053e 8c000041 // 21495098 a000002e //
> 3613f4fa a0000035 // 21600d3e 8c000041
> May  6 18:13:25 mybecane kernel: 090: 21520631 a000059f // 3613f93e 91680041 //
> 2158d45b a0000b3f // 2160153e 8c000041
> May  6 18:13:25 mybecane kernel: 094: 2166f604 a0000513 // 2160193e 8c000041 //
> 2148fe73 8000018c // 215fc000 a00002b1
> May  6 18:13:25 mybecane kernel: 098: 342db53e 91478041 // 215c461c 800009e3 //
> 215be000 a0000057 // 2168c14a 8c000035
> May  6 18:13:25 mybecane kernel: 09c: 2168a0c1 a00005b3 // 2157713e 8c000041 //
> 2151aa33 a0000487 // 2168c402 ac0000b8
> May  6 18:13:25 mybecane kernel: 0a0: 36142e02 ac00004c // 2168c802 ac00007a //
> 36142602 ac00004c // 36142c02 ac00005c
> May  6 18:13:25 mybecane kernel: 0a4: 2168ccee a0000041 // 3613e93e 8c000041 //
> 340cf5eb a000059f // 2168d53e 8c000041
> May  6 18:13:25 mybecane kernel: 0a8: 2166f604 a0000513 // 2168d93e 8c000041 //
> 21520631 a000059f // 21601d3e 91478041
> May  6 18:13:25 mybecane kernel: 0ac: 215be058 a0000a3b // 214f40fa a0000035 //
> 214f453e 8c000041 // 2148fe73 8000018c
> May  6 18:13:25 mybecane kernel: 0b0: 215fc000 a00002b1 // 214f493e 8c000041 //
> 215efc80 8000037f // 21625000 a0000193
> May  6 18:13:25 mybecane kernel: 0b4: 214f4d4a 8c000035 // 2168a0c1 a00005b3 //
> 214f513e 8c000041 // 21746744 a00005a7
> May  6 18:13:25 mybecane kernel: 0b8: 341d1d3e 8c000041 // 2157539d a0000513 //
> 2168dd3e 91478041 // 215bea94 8000056b
> May  6 18:13:25 mybecane kernel: 0bc: 21550000 a00004cf // 3629fe02 ac00004c //
> 21536402 ac00007a // 341be802 ac00004c
> May  6 18:13:25 mybecane kernel: 0c0: 21536802 ac00007a // 214c7002 ac00004c //
> 21536cfa a0000035 // 2153714a 8c000035
> May  6 18:13:25 mybecane kernel: 0c4: 215f8404 a000002d // 2153753e 8c000041 //
> 21589e3a 800001c5 // 21707000 a00003e1
> May  6 18:13:25 mybecane kernel: 0c8: 215378fa a0000035 // 21537d3e 8c000041 //
> 21520631 a000059f // 214f5cee a0000041
> May  6 18:13:25 mybecane kernel: 0cc: 214f553e 8c000041 // 2148fe73 8000018c //
> 215fc000 a00002b1 // 2166a0ee a0000041
> May  6 18:13:25 mybecane kernel: 0d0: 2166a94a 8c000035 // 2168a0c1 a00005b3 //
> 2166a53e 8c000041 // 2151aa33 a0000487
> May  6 18:13:25 mybecane kernel: 0d4: 214c7802 ac00005c // 2166ac02 ac00007a //
> 36244c02 ac00004c // 342dd402 ac00005c
> May  6 18:13:25 mybecane kernel: 0d8: 2153613e 91478041 // 215504d0 a0000a3b //
> 2166b53e 8c000041 // 340cf5eb a000059f
> May  6 18:13:25 mybecane kernel: 0dc: 3613e53e 8c000041 // 216b11cc a00004f5 //
> 36322602 ac000051 // 2166b93e 8c000041
> May  6 18:13:25 mybecane kernel: 0e0: 216c5b3a 800004c5 // 2177d000 a000004d //
> 2166bcfa a0000035 // 215fe13e 8c000041
> May  6 18:13:25 mybecane kernel: 0e4: 21746744 a00005a7 // 215fe53e 8c000041 //
> 216c5b3a 800004c5 // 2177d000 a000004d
> May  6 18:13:25 mybecane kernel: 0e8: 215fe802 ac0000b8 // 340e7402 ac00005c //
> 340f1002 ac00005c // 3629f202 ac00005c
> May  6 18:13:25 mybecane kernel: 0ec: 215fecee a0000041 // 215ff0fa a0000035 //
> 215ff4ee a0000041 // 215ff8fa a0000035
> May  6 18:13:25 mybecane kernel: 0f0: 34192202 ac000051 // 3411d602 ac000051 //
> 3616c402 ac000051 // 214c7202 ac000051
> May  6 18:13:25 mybecane kernel: 0f4: 342dd602 ac000051 // 36322c02 ac000051 //
> 36142a02 ac000051 // 216d3002 ac000051
> May  6 18:13:25 mybecane kernel: 0f8: 216d3202 ac000051 // 216d3402 ac000051 //
> 216d3602 ac000051 // 216d3802 ac000051
> May  6 18:13:25 mybecane kernel: 0fc: 216d3a02 ac000051 // 216d3c02 ac000051 //
> 216e00ee a0000041 // 216e04ee a0000041
> May  6 18:14:25 mybecane kernel: eth0: Got tx_timeout. irq: 00000000
> 

