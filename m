From: Alex Bennee <kernel-hacker@bennee.com>
Subject: Re: r8169 ethernet hangs after a pm-suspend (and resume)
Date: Thu, 10 Sep 2009 07:49:13 +0100
Message-ID: <b2cdc9f30909092349j3255ead6x69dac38944871b14@mail.gmail.com>
References: <b2cdc9f30909090013q1741da26la73da66f1eef975f@mail.gmail.com>
	 <20090909092822.GA18355@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755171AbZIJGtO@vger.kernel.org>
In-Reply-To: <20090909092822.GA18355@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/9/9 Francois Romieu <romieu@fr.zoreil.com>:
> Alex Bennee <kernel-hacker@bennee.com> :
> [...]
>> I've just recently gotten suspend working on my system. Unfortunately
>> after the resume event I loose access to the network.
>> As far as the system is concerned the network is configured properly
>> but every attempt to ping local nodes fails with "Host not reachable".
>
> Can the problem be described as "gigabit link setting does not survive
> suspend/resume" ?

Further experimentation shows the failure is intermittent. The
following dmesg shows a successful resume with working 'net:

[  475.800017] ACPI: Waking up from system sleep state S3
[  475.800726] HDA Intel 0000:00:1b.0: restoring config space at
offset 0x1 (was 0x100006, writing 0x100002)
[  475.800747] pcieport-driver 0000:00:1c.0: restoring config space at
offset 0xf (was 0x60100, writing 0x6010a)
[  475.800762] pcieport-driver 0000:00:1c.0: restoring config space at
offset 0x1 (was 0x100107, writing 0x100507)
[  475.800799] pci 0000:00:1d.0: restoring config space at offset 0x1
(was 0x2800005, writing 0x2800001)
[  475.800819] pci 0000:00:1d.1: restoring config space at offset 0x1
(was 0x2800005, writing 0x2800001)
[  475.800840] pci 0000:00:1d.2: restoring config space at offset 0x1
(was 0x2800005, writing 0x2800001)
[  475.800861] pci 0000:00:1d.3: restoring config space at offset 0x1
(was 0x2800005, writing 0x2800001)
[  475.800889] pci 0000:00:1d.7: restoring config space at offset 0x1
(was 0x2900006, writing 0x2900002)
[  475.800967] PIIX_IDE 0000:00:1f.1: restoring config space at offset
0x1 (was 0x2880005, writing 0x2800005)
[  475.801050] r8169 0000:02:00.0: restoring config space at offset
0x3 (was 0x4, writing 0x8)
[  475.801056] r8169 0000:02:00.0: restoring config space at offset
0x1 (was 0x100007, writing 0x100407)
[  475.803466] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[  475.803470] i915 0000:00:02.0: setting latency timer to 64
[  475.864097] [drm] DAC-6: set mode 1440x900 2a
[  475.936922] [drm] TMDS-8: set mode 1680x1050 2b
[  476.108887] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 19 (level,
low) -> IRQ 19
[  476.108892] HDA Intel 0000:00:1b.0: setting latency timer to 64
[  476.548200] pci 0000:00:1d.7: PME# disabled
[  476.548207] pci 0000:00:1e.0: setting latency timer to 64
[  476.548216] PIIX_IDE 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[  476.548223] PIIX_IDE 0000:00:1f.1: setting latency timer to 64
[  476.548235] ata_piix 0000:00:1f.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[  476.548248] ata_piix 0000:00:1f.2: setting latency timer to 64
[  476.548352] r8169 0000:02:00.0: PME# disabled
[  476.564404] r8169: eth0: link up

And now compare with a return from suspend that failed:

[12397.816024] ACPI: Waking up from system sleep state S3
[12397.816693] agpgart-intel 0000:00:00.0: restoring config space at
offset 0x1 (was 0x30900006, writing 0x20900006)
[12397.816737] HDA Intel 0000:00:1b.0: restoring config space at
offset 0x1 (was 0x100006, writing 0x100002)
[12397.816757] pcieport-driver 0000:00:1c.0: restoring config space at
offset 0xf (was 0x60100, writing 0x6010a)
[12397.816768] pcieport-driver 0000:00:1c.0: restoring config space at
offset 0x7 (was 0x2000e0e0, writing 0xe0e0)
[12397.816776] pcieport-driver 0000:00:1c.0: restoring config space at
offset 0x1 (was 0x100107, writing 0x100507)
[12397.816813] uhci_hcd 0000:00:1d.0: restoring config space at offset
0x1 (was 0x2800005, writing 0x2800001)
[12397.816835] uhci_hcd 0000:00:1d.1: restoring config space at offset
0x1 (was 0x2800005, writing 0x2800001)
[12397.816856] uhci_hcd 0000:00:1d.2: restoring config space at offset
0x1 (was 0x2800005, writing 0x2800001)
[12397.816877] uhci_hcd 0000:00:1d.3: restoring config space at offset
0x1 (was 0x2800005, writing 0x2800001)
[12397.816906] pci 0000:00:1d.7: restoring config space at offset 0x1
(was 0x2900006, writing 0x2900002)
[12397.816929] pci 0000:00:1e.0: restoring config space at offset 0x7
(was 0x2280d0d0, writing 0xa280d0d0)
[12397.816987] PIIX_IDE 0000:00:1f.1: restoring config space at offset
0x1 (was 0x2880005, writing 0x2800005)
[12397.832040] r8169 0000:02:00.0: restoring config space at offset
0xf (was 0xffffffff, writing 0x10a)
[12397.832045] r8169 0000:02:00.0: restoring config space at offset
0xe (was 0xffffffff, writing 0x0)
[12397.832050] r8169 0000:02:00.0: restoring config space at offset
0xd (was 0xffffffff, writing 0x40)
[12397.832055] r8169 0000:02:00.0: restoring config space at offset
0xc (was 0xffffffff, writing 0xdffc0000)
[12397.832061] r8169 0000:02:00.0: restoring config space at offset
0xb (was 0xffffffff, writing 0x81aa1043)
[12397.832066] r8169 0000:02:00.0: restoring config space at offset
0xa (was 0xffffffff, writing 0x0)
[12397.832071] r8169 0000:02:00.0: restoring config space at offset
0x9 (was 0xffffffff, writing 0x0)
[12397.832076] r8169 0000:02:00.0: restoring config space at offset
0x8 (was 0xffffffff, writing 0xdeff000c)
[12397.832081] r8169 0000:02:00.0: restoring config space at offset
0x7 (was 0xffffffff, writing 0x0)
[12397.832086] r8169 0000:02:00.0: restoring config space at offset
0x6 (was 0xffffffff, writing 0xdffff004)
[12397.832091] r8169 0000:02:00.0: restoring config space at offset
0x5 (was 0xffffffff, writing 0x0)
[12397.832096] r8169 0000:02:00.0: restoring config space at offset
0x4 (was 0xffffffff, writing 0xe801)
[12397.832101] r8169 0000:02:00.0: restoring config space at offset
0x3 (was 0xffffffff, writing 0x8)
[12397.832106] r8169 0000:02:00.0: restoring config space at offset
0x2 (was 0xffffffff, writing 0x2000002)
[12397.832111] r8169 0000:02:00.0: restoring config space at offset
0x1 (was 0xffffffff, writing 0x100407)
[12397.832117] r8169 0000:02:00.0: restoring config space at offset
0x0 (was 0xffffffff, writing 0x816810ec)
[12397.834527] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[12397.834531] i915 0000:00:02.0: setting latency timer to 64
[12397.895209] [drm] DAC-6: set mode 1440x900 2a
[12397.968038] [drm] TMDS-8: set mode 1680x1050 2b
[12398.140006] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 19 (level,
low) -> IRQ 19
[12398.140011] HDA Intel 0000:00:1b.0: setting latency timer to 64
[12398.580194] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[12398.580200] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[12398.580224] usb usb2: root hub lost power or was reset
[12398.580250] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[12398.580255] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[12398.580273] usb usb3: root hub lost power or was reset
[12398.580291] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[12398.580296] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[12398.580314] usb usb4: root hub lost power or was reset
[12398.580332] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[12398.580337] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[12398.580355] usb usb5: root hub lost power or was reset
[12398.580374] pci 0000:00:1d.7: PME# disabled
[12398.580380] pci 0000:00:1e.0: setting latency timer to 64
[12398.580387] PIIX_IDE 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[12398.580394] PIIX_IDE 0000:00:1f.1: setting latency timer to 64
[12398.580403] ata_piix 0000:00:1f.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[12398.580407] ata_piix 0000:00:1f.2: setting latency timer to 64
[12398.580512] r8169 0000:02:00.0: PME# disabled
[12398.660050] firewire_core: skipped bus generations, destroying all nodes
[12398.664833] hda: host max PIO4 wanted PIO255(auto-tune) selected PIO4
[12398.665625] hda: skipping word 93 validity check
[12398.665627] hda: UDMA/66 mode selected
[12398.687404] sd 0:0:0:0: [sda] Starting disk
[12399.419164] r8169: eth0: link up

which has an oops further on:

[12434.816100] ------------[ cut here ]------------
[12434.816111] WARNING: at net/sched/sch_generic.c:246
dev_watchdog+0x132/0x1da()
[12434.816114] Hardware name: System Product Name
[12434.816117] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
[12434.816120] Modules linked in: bridge stp llc bnep rfcomm l2cap
bluetooth ipv6 snd_pcm_oss snd_mixer_oss snd_seq_oss
snd_seq_midi_event snd_seq snd_seq_device kvm_intel kvm acpi_cpufreq
snd_hda_codec_analog snd_hda_intel uhci_hcd snd_hda_codec snd_hwdep
snd_pcm snd_timer ide_cd_mod firewire_ohci firewire_core snd soundcore
usbcore r8169 cdrom processor crc_itu_t nls_base snd_page_alloc mii
evdev thermal pcspkr unix [last unloaded: ehci_hcd]
[12434.816164] Pid: 0, comm: swapper Not tainted
2.6.31-rc9-ajb-00012-g3ff323f-dirty #86
[12434.816167] Call Trace:
[12434.816169]  <IRQ>  [<ffffffff812aa117>] ? dev_watchdog+0x132/0x1da
[12434.816180]  [<ffffffff8103eb72>] warn_slowpath_common+0x7c/0xa9
[12434.816185]  [<ffffffff8103ec1e>] warn_slowpath_fmt+0x69/0x6b
[12434.816190]  [<ffffffff81039e47>] ? default_wake_function+0x12/0x14
[12434.816195]  [<ffffffff8102c24c>] ? __wake_up_common+0x4b/0x7b
[12434.816200]  [<ffffffff8102f793>] ? __wake_up+0x48/0x54
[12434.816205]  [<ffffffff81298b7d>] ? netdev_drivername+0x48/0x4f
[12434.816209]  [<ffffffff812aa117>] dev_watchdog+0x132/0x1da
[12434.816214]  [<ffffffff810510f2>] ? __queue_work+0x3a/0x43
[12434.816218]  [<ffffffff812a9fe5>] ? dev_watchdog+0x0/0x1da
[12434.816223]  [<ffffffff81048d76>] run_timer_softirq+0x198/0x20d
[12434.816229]  [<ffffffff8101d0c6>] ? lapic_next_event+0x1d/0x21
[12434.816234]  [<ffffffff8104464f>] __do_softirq+0xd6/0x19a
[12434.816239]  [<ffffffff8100c19c>] call_softirq+0x1c/0x28
[12434.816242]  [<ffffffff8100d51d>] do_softirq+0x39/0x77
[12434.816246]  [<ffffffff8104430c>] irq_exit+0x44/0x7e
[12434.816252]  [<ffffffff81305914>] smp_apic_timer_interrupt+0x8d/0x9b
[12434.816258]  [<ffffffff8100bb73>] apic_timer_interrupt+0x13/0x20
[12434.816260]  <EOI>  [<ffffffff810117ac>] ? mwait_idle+0xb9/0xf0
[12434.816269]  [<ffffffff81303df5>] ? atomic_notifier_call_chain+0x13/0x15
[12434.816273]  [<ffffffff8100a30a>] ? cpu_idle+0x57/0x98
[12434.816278]  [<ffffffff812f0612>] ? rest_init+0x66/0x68
[12434.816283]  [<ffffffff815299da>] ? start_kernel+0x343/0x34e
[12434.816288]  [<ffffffff8152903a>] ? x86_64_start_reservations+0xaa/0xae
[12434.816292]  [<ffffffff8152911f>] ? x86_64_start_kernel+0xe1/0xe8
[12434.816295] ---[ end trace 1353478188007667 ]---
[12435.635167] r8169: eth0: link up

At this point even unloading and reloading the r8169 module couldn't
bring the network back. I even tried unloading the module, doing a
pm-hibernate and restore reload and still nothing which was odd as I
though the power cycle should have un-wedged any hardware.

A couple of questions:

1. It seems the failure case has a lot more "restoring config space"
going on. Is this a wider range problem that just happens to hit r8169
harder?

2. Is the oops a red herring or could the failure to resume be because
the shutdown occurs before the hardware has flushed all in flight
packets?


-- 
Alex, homepage: http://www.bennee.com/~alex/
http://www.half-llama.co.uk
