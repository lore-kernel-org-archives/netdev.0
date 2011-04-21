From: Daniele Venzano <venza@brownhat.org>
Subject: Re: sis900 transmit timeouts
Date: Thu, 21 Apr 2011 10:34:41 +0200
Message-ID: <BANLkTikt+JoeZkHaC1G-=T14n_X9zmoFDQ@mail.gmail.com>
References: <BANLkTinTZoTgkNhjhwv=vHwLVgCKQNvKSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: cwillu <cwillu@cwillu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.infomaniak.ch ([84.16.68.89]:50820 "EHLO
	smtp1.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471Ab1DUIpm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 04:45:42 -0400
Received: from mail-bw0-f46.google.com (mail-bw0-f46.google.com [209.85.214.46])
	(authenticated bits=0)
	by smtp1.infomaniak.ch (8.14.2/8.14.2) with ESMTP id p3L8Yglb028851
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 10:34:43 +0200
Received: by bwz15 with SMTP id 15so1236619bwz.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 01:34:42 -0700 (PDT)
In-Reply-To: <BANLkTinTZoTgkNhjhwv=vHwLVgCKQNvKSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I do not the sis900 chipset documentation on hand right now, so I
cannot decode the TX status numbers. I did not receive any more
reports apart from yours and the original one, so it is either a very
nasty bug that happens in very particular conditions or an hardware
problem.

At the time I placed my bets on the 64bit arch because they were rare
enough to make the bug difficult to reproduce.

I'll let you know if your logs give me some hint.

Thanks,
Daniele.

2011/4/21 cwillu <cwillu@cwillu.com>:
> Hi; I'm trying to figure out why the onboard nic on what just became
> my primary desktop disconnects for a few seconds every hour or so.
> After some googling, I came across the "Transmit timeouts" section of
> http://www.brownhat.org/sis900.html, which said to make contact if
> anyone sees this. =C2=A0Granted that that was some time ago, but here=
's
> hoping somebody still cares :)
>
> I'm running a vanilla 2.6.38 kernel, on 32bit (site said 64bit, but
> given that I see it...).
>
>
> Relevant dmesg:
>
> [ =C2=A0 =C2=A02.391521] sata_sis 0000:00:05.0: version 1.0
> [ =C2=A0 =C2=A02.391543] sata_sis 0000:00:05.0: PCI INT A -> GSI 17 (=
level, low) -> IRQ 17
> [ =C2=A0 =C2=A02.391549] sata_sis 0000:00:05.0: Detected SiS 180/181/=
964 chipset
> in SATA mode
> [ =C2=A0 =C2=A02.411447] scsi2 : sata_sis
> [ =C2=A0 =C2=A02.413472] sis900.c: v1.08.10 Apr. 2 2006
> [ =C2=A0 =C2=A02.415877] scsi3 : sata_sis
> [ =C2=A0 =C2=A02.415991] ata3: SATA max UDMA/133 cmd 0xe900 ctl 0xea0=
0 bmdma 0xed00 irq 17
> [ =C2=A0 =C2=A02.415997] ata4: SATA max UDMA/133 cmd 0xeb00 ctl 0xec0=
0 bmdma 0xed08 irq 17
> [ =C2=A0 =C2=A02.416187] sis900 0000:00:04.0: PCI INT A -> GSI 19 (le=
vel, low) -> IRQ 19
> [ =C2=A0 =C2=A02.417375] 0000:00:04.0: Realtek RTL8201 PHY transceive=
r found at address 1.
> [ =C2=A0 =C2=A02.427022] 0000:00:04.0: Using transceiver found at add=
ress 1 as default
> [ =C2=A0 =C2=A02.438283] eth0: SiS 900 PCI Fast Ethernet at 0xe400, I=
RQ 19,
> 00:01:6c:e6:a7:f7
> [ =C2=A0 =C2=A02.448194] usb 2-2: new low speed USB device using ohci=
_hcd and address 2
> <snip>
> [ 2337.396544] eth2: Corrupted packet received, buffer status =3D 0x9=
0880313/787.
> [ 2794.401995] eth2: Transmit error, Tx status 0420004e.
> [ 2870.495324] eth2: Transmit error, Tx status 04200092.
> [ 5351.151451] eth2: Transmit error, Tx status 04200042.
> [ 5591.280818] eth2: Transmit error, Tx status 04200226.
> [ 5612.560354] eth2: Media Link Off
> [ 5622.016027] ------------[ cut here ]------------
> [ 5622.016044] WARNING: at
> /home/kernel-ppa/COD/linux/net/sched/sch_generic.c:256
> dev_watchdog+0x257/0x260()
> [ 5622.016048] Hardware name:
> [ 5622.016051] NETDEV WATCHDOG: eth2 (sis900): transmit queue 0 timed=
 out
> [ 5622.016054] Modules linked in: xt_multiport iptable_filter
> ip_tables x_tables binfmt_misc nfsd lockd nfs_acl auth_rpcgss sunrpc
> exportfs ipx p8023 tuner_simple tuner_types wm8775 tda9887 tda8290
> nouveau tea5767 tuner snd_intel8x0 cx25840 ttm drm_kms_helper ivtv dr=
m
> snd_ac97_codec ac97_bus snd_pcm snd_seq_midi cx2341x snd_rawmidi
> v4l2_common snd_seq_midi_event snd_seq ppdev i2c_algo_bit videodev
> snd_timer parport_pc video tveeprom psmouse snd_seq_device lp parport
> snd soundcore shpchp snd_page_alloc k8temp serio_raw usbhid hid
> sata_sis sis900 floppy raid10 raid1 raid0 multipath linear btrfs
> zlib_deflate libcrc32c
> [ 5622.016117] Pid: 6623, comm: queue0:src Not tainted
> 2.6.38-02063802-generic #201103281246
> [ 5622.016120] Call Trace:
> [ 5622.016127] =C2=A0[<c1449357>] ? dev_watchdog+0x257/0x260
> [ 5622.016134] =C2=A0[<c104fd61>] ? warn_slowpath_common+0x81/0xa0
> [ 5622.016140] =C2=A0[<c1449357>] ? dev_watchdog+0x257/0x260
> [ 5622.016145] =C2=A0[<c104fe23>] ? warn_slowpath_fmt+0x33/0x40
> [ 5622.016150] =C2=A0[<c1449357>] ? dev_watchdog+0x257/0x260
> [ 5622.016155] =C2=A0[<c1068845>] ? __queue_work+0xd5/0x250
> [ 5622.016161] =C2=A0[<c150c10d>] ? _raw_spin_lock+0xd/0x10
> [ 5622.016166] =C2=A0[<c105c904>] ? call_timer_fn+0x34/0xe0
> [ 5622.016171] =C2=A0[<c10f3461>] ? shmem_i_callback+0x21/0x30
> [ 5622.016175] =C2=A0[<c10f3461>] ? shmem_i_callback+0x21/0x30
> [ 5622.016180] =C2=A0[<c1449100>] ? dev_watchdog+0x0/0x260
> [ 5622.016185] =C2=A0[<c105e13c>] ? run_timer_softirq+0xfc/0x1c0
> [ 5622.016189] =C2=A0[<c1449100>] ? dev_watchdog+0x0/0x260
> [ 5622.016195] =C2=A0[<c1055f12>] ? __do_softirq+0x92/0x1a0
> [ 5622.016200] =C2=A0[<c1055e80>] ? __do_softirq+0x0/0x1a0
> [ 5622.016202] =C2=A0<IRQ> =C2=A0[<c105608c>] ? irq_exit+0x6c/0x80
> [ 5622.016211] =C2=A0[<c15134c8>] ? smp_apic_timer_interrupt+0x38/0x4=
2
> [ 5622.016216] =C2=A0[<c150cb89>] ? apic_timer_interrupt+0x31/0x38
> [ 5622.016223] =C2=A0[<c112630d>] ? do_sync_write+0x9d/0xf0
> [ 5622.016229] =C2=A0[<c11264be>] ? rw_verify_area+0x6e/0x130
> [ 5622.016233] =C2=A0[<c1081343>] ? do_futex+0x193/0x1c0
> [ 5622.016238] =C2=A0[<c112682b>] ? vfs_write+0x9b/0x160
> [ 5622.016243] =C2=A0[<c1126270>] ? do_sync_write+0x0/0xf0
> [ 5622.016247] =C2=A0[<c1126e62>] ? sys_write+0x42/0x70
> [ 5622.016253] =C2=A0[<c1002e1f>] ? sysenter_do_call+0x12/0x28
> [ 5622.016257] ---[ end trace 4f85204a75110ff3 ]---
> [ 5622.016262] eth2: Transmit timeout, status 00000004 00000000
> [ 5622.576937] eth2: Media Link On 100mbps full-duplex
>



--=20
Daniele Venzano
venza@brownhat.org
http://www.brownhat.org
