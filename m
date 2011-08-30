From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: 3.1-rc2: WARNING: at net/sched/sch_generic.c:255dev_watchdog+0x23f/0x250()
 (with frame pointers enabled)
Date: Tue, 30 Aug 2011 05:20:00 -0400 (EDT)
Message-ID: <alpine.DEB.2.02.1108300516570.5636@p34.internal.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Alan Piszcz <ap@solarrain.com>
To: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:41365 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740Ab1H3JUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 05:20:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

While performing some rsyncs and dumps, the igb driver had a problem
under kernel 3.1-rc2 / Debian Testing:

Any clue what is going on here?

[122150.696831] ------------[ cut here ]------------
[122150.699843] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x23f/0x250()
[122150.702625] Hardware name: X8DTH-i/6/iF/6F
[122150.705397] NETDEV WATCHDOG: eth0 (igb): transmit queue 1 timed out
[122150.708091] Modules linked in: dm_mod tcp_diag parport_pc ppdev lp parport inet_diag pl2303 ftdi_sio snd_usb_audio snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_hwdep snd_usbmidi_lib snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd soundcore ub cdc_acm usbserial joydev serio_raw nouveau ttm drm_kms_helper drm agpgart i2c_algo_bit mxm_wmi wmi i7core_edac edac_core video
[122150.714350] Pid: 83, comm: ksoftirqd/19 Not tainted 3.1.0-rc2 #2
[122150.717267] Call Trace:
[122150.720173]  [<ffffffff8103798a>] warn_slowpath_common+0x7a/0xb0
[122150.723076]  [<ffffffff81037a61>] warn_slowpath_fmt+0x41/0x50
[122150.725999]  [<ffffffff815d55e4>] ? schedule+0x2e4/0x950
[122150.728964]  [<ffffffff814e39af>] dev_watchdog+0x23f/0x250
[122150.731735]  [<ffffffff81043832>] run_timer_softirq+0xf2/0x220
[122150.734565]  [<ffffffff814e3770>] ? qdisc_reset+0x50/0x50
[122150.737369]  [<ffffffff8103d1c8>] __do_softirq+0x98/0x120
[122150.740115]  [<ffffffff8103d305>] run_ksoftirqd+0xb5/0x160
[122150.742846]  [<ffffffff8103d250>] ? __do_softirq+0x120/0x120
[122150.745611]  [<ffffffff81052277>] kthread+0x87/0x90
[122150.748378]  [<ffffffff815d9b34>] kernel_thread_helper+0x4/0x10
[122150.751308]  [<ffffffff810521f0>] ? kthread_worker_fn+0x130/0x130
[122150.754089]  [<ffffffff815d9b30>] ? gs_change+0xb/0xb
[122150.756810] ---[ end trace 1dba0c59497c20e3 ]---
[122150.759653] igb 0000:01:00.0: eth0: Reset adapter
[122151.388904] usb 2-2.1: usbfs: USBDEVFS_CONTROL failed cmd usbhid-ups rqt 161 rq 1 len 3 ret -110
[122153.630957] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
[122155.392801] usb 2-2.1: usbfs: USBDEVFS_CONTROL failed cmd usbhid-ups rqt 161 rq 1 len 2 ret -110
[122159.396797] usb 2-2.1: usbfs: USBDEVFS_CONTROL failed cmd usbhid-ups rqt 161 rq 1 len 2 ret -110
[122163.400706] usb 2-2.1: usbfs: USBDEVFS_CONTROL failed cmd usbhid-ups rqt 161 rq 1 len 2 ret -110
[122167.404632] usb 2-2.1: usbfs: USBDEVFS_CONTROL failed cmd usbhid-ups rqt 161 rq 1 len 2 ret -110
[122168.417001] BUG: soft lockup - CPU#5 stuck for 23s! [dump:26074]
[122168.419327] Modules linked in: dm_mod tcp_diag parport_pc ppdev lp parport inet_diag pl2303 ftdi_sio snd_usb_audio snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_hwdep snd_usbmidi_lib snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd soundcore ub cdc_acm usbserial joydev serio_raw nouveau ttm drm_kms_helper drm agpgart i2c_algo_bit mxm_wmi wmi i7core_edac edac_core video
[122168.424566] CPU 5 
[122168.424579] Modules linked in: dm_mod tcp_diag parport_pc ppdev lp parport inet_diag pl2303 ftdi_sio snd_usb_audio snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_hwdep snd_usbmidi_lib snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd soundcore ub cdc_acm usbserial joydev serio_raw nouveau ttm drm_kms_helper drm agpgart i2c_algo_bit mxm_wmi wmi i7core_edac edac_core video
[122168.432567] 
[122168.435238] Pid: 26074, comm: dump Tainted: G        W   3.1.0-rc2 #2 Supermicro X8DTH-i/6/iF/6F/X8DTH
[122168.437973] RIP: 0010:[<ffffffff81084480>]  [<ffffffff81084480>] find_get_pages+0x60/0x130
[122168.440752] RSP: 0018:ffff88036b821ce8  EFLAGS: 00000246
[122168.443496] RAX: ffff88089a601760 RBX: 000000000000000d RCX: 0000000000000000
[122168.446251] RDX: ffff88036b821d88 RSI: 000000000000000e RDI: ffffea0027b4da50
[122168.448983] RBP: ffff88036b821d38 R08: 0000000000000000 R09: ffff88036b821ca8
[122168.451784] R10: 00000000011801db R11: 000000000000000d R12: ffffffff8108a23d
[122168.454561] R13: ffff88036b821c68 R14: dead000000100100 R15: ffff88036b821d88
[122168.457319] FS:  00007f57b6572760(0000) GS:ffff88063fca0000(0000) knlGS:0000000000000000
[122168.460087] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[122168.462851] CR2: 00007f694be73370 CR3: 00000004c8bf5000 CR4: 00000000000006e0
[122168.465523] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[122168.468273] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[122168.470986] Process dump (pid: 26074, threadinfo ffff88036b820000, task ffff8800632191f0)
[122168.473708] Stack:
[122168.476427]  ffff88063fcad560 0000000000000005 ffff8806270baed8 ffffea0027ba06d8
[122168.479163]  ffff88036b821d38 ffff88036b821d78 000000000000bbce ffffffffffffffff
[122168.481883]  ffff8806270baed8 ffffea0027ba06d8 ffff88036b821d58 ffffffff8108c6ed
[122168.484665] Call Trace:
[122168.487449]  [<ffffffff8108c6ed>] pagevec_lookup+0x1d/0x30
[122168.490247]  [<ffffffff8108e490>] invalidate_mapping_pages+0x70/0x1b0
[122168.493074]  [<ffffffff810eca63>] invalidate_bdev+0x33/0x40
[122168.495901]  [<ffffffff812daa41>] blkdev_ioctl+0x6c1/0x720
[122168.498691]  [<ffffffff810f277b>] block_ioctl+0x3b/0x40
[122168.501472]  [<ffffffff810d4afe>] do_vfs_ioctl+0x8e/0x4e0
[122168.504249]  [<ffffffff810c390f>] ? do_sys_open+0x16f/0x1d0
[122168.507009]  [<ffffffff810d4f9a>] sys_ioctl+0x4a/0x80
[122168.509753]  [<ffffffff815d80bb>] system_call_fastpath+0x16/0x1b
[122168.512521] Code: 0f 84 c5 00 00 00 48 89 da 31 c9 45 31 ff 0f 1f 44 00 00 48 8b 02 48 8b 38 48 85 ff 74 3e 40 f6 c7 03 75 5f 44 8b 47 1c 45 85 c0 
[122168.512826]  ec 45 8d 48 01 44 89 c0 4c 8d 57 1c f0 44 0f b1 4f 1c 44 39 
[122168.518570] Call Trace:
[122168.521472]  [<ffffffff8108c6ed>] pagevec_lookup+0x1d/0x30
[122168.524389]  [<ffffffff8108e490>] invalidate_mapping_pages+0x70/0x1b0
[122168.527311]  [<ffffffff810eca63>] invalidate_bdev+0x33/0x40
[122168.530208]  [<ffffffff812daa41>] blkdev_ioctl+0x6c1/0x720
[122168.533034]  [<ffffffff810f277b>] block_ioctl+0x3b/0x40
[122168.535935]  [<ffffffff810d4afe>] do_vfs_ioctl+0x8e/0x4e0
[122168.538829]  [<ffffffff810c390f>] ? do_sys_open+0x16f/0x1d0
[122168.541733]  [<ffffffff810d4f9a>] sys_ioctl+0x4a/0x80
[122168.544652]  [<ffffffff815d80bb>] system_call_fastpath+0x16/0x1b
[122168.704524] BUG: soft lockup - CPU#9 stuck for 22s! [dump:26073]
[122168.708120] Modules linked in: dm_mod tcp_diag parport_pc ppdev lp parport inet_diag pl2303 ftdi_sio snd_usb_audio snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_hwdep snd_usbmidi_lib snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd soundcore ub cdc_acm usbserial joydev serio_raw nouveau ttm drm_kms_helper drm agpgart i2c_algo_bit mxm_wmi wmi i7core_edac edac_core video
[122168.715998] CPU 9 
[122168.716013] Modules linked in: dm_mod tcp_diag parport_pc ppdev lp parport inet_diag pl2303 ftdi_sio snd_usb_audio snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_hwdep snd_usbmidi_lib snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd soundcore ub cdc_acm usbserial joydev serio_raw nouveau ttm drm_kms_helper drm agpgart i2c_algo_bit mxm_wmi wmi i7core_edac edac_core video
[122168.728349] 
[122168.732359] Pid: 26073, comm: dump Tainted: G        W   3.1.0-rc2 #2 Supermicro X8DTH-i/6/iF/6F/X8DTH
[122168.736393] RIP: 0010:[<ffffffff8108447d>]  [<ffffffff8108447d>] find_get_pages+0x5d/0x130
[122168.740349] RSP: 0018:ffff880297ca9ce8  EFLAGS: 00000246
[122168.744217] RAX: ffff880ad266b790 RBX: 000000000000000e RCX: 0000000000000000
[122168.748065] RDX: ffff880297ca9d88 RSI: 000000000000000e RDI: ffffea0020aaa9f0
[122168.751937] RBP: ffff880297ca9d38 R08: 0000000000000000 R09: ffff880297ca9ca8
[122168.755955] R10: 0000000000f80b21 R11: 000000000000000d R12: ffffffff8108a23d
[122168.759954] R13: ffff880297ca9c68 R14: dead000000100100 R15: ffff880297ca9d88
[122168.763971] FS:  00007f57b6572760(0000) GS:ffff880c3fc60000(0000) knlGS:0000000000000000
[122168.767978] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[122168.772030] CR2: ffffffffff600400 CR3: 000000012fce7000 CR4: 00000000000006e0
[122168.776111] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[122168.780212] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[122168.784309] Process dump (pid: 26073, threadinfo ffff880297ca8000, task ffff8800a1f746f0)
[122168.788426] Stack:
[122168.792550]  ffff880c3fc6d560 0000000000000005 ffff8806270baed8 ffffea00229c7800
[122168.796827]  ffff880297ca9d38 ffff880297ca9d78 000000000000192d ffffffffffffffff
[122168.801015]  ffff8806270baed8 ffffea00229c7800 ffff880297ca9d58 ffffffff8108c6ed
[122168.801019] Call Trace:
[122168.801024]  [<ffffffff8108c6ed>] pagevec_lookup+0x1d/0x30
[122168.801027]  [<ffffffff8108e490>] invalidate_mapping_pages+0x70/0x1b0
[122168.801031]  [<ffffffff810eca63>] invalidate_bdev+0x33/0x40
[122168.801034]  [<ffffffff812daa41>] blkdev_ioctl+0x6c1/0x720
[122168.801037]  [<ffffffff810f277b>] block_ioctl+0x3b/0x40
[122168.801041]  [<ffffffff810d4afe>] do_vfs_ioctl+0x8e/0x4e0
[122168.801044]  [<ffffffff810c390f>] ? do_sys_open+0x16f/0x1d0
[122168.801047]  [<ffffffff810d4f9a>] sys_ioctl+0x4a/0x80
[122168.801051]  [<ffffffff815d80bb>] system_call_fastpath+0x16/0x1b
[122168.801052] Code: c0 89 c6 0f 84 c5 00 00 00 48 89 da 31 c9 45 31 ff 0f 1f 44 00 00 48 8b 02 48 8b 38 48 85 ff 74 3e 40 f6 c7 03 75 5f 44 8b 47 1c 
[122168.801059]  85 c0 74 ec 45 8d 48 01 44 89 c0 4c 8d 57 1c f0 44 0f b1 4f 
[122168.801063] Call Trace:
[122168.801065]  [<ffffffff8108c6ed>] pagevec_lookup+0x1d/0x30
[122168.801068]  [<ffffffff8108e490>] invalidate_mapping_pages+0x70/0x1b0
[122168.801070]  [<ffffffff810eca63>] invalidate_bdev+0x33/0x40
[122168.801072]  [<ffffffff812daa41>] blkdev_ioctl+0x6c1/0x720
[122168.801076]  [<ffffffff810f277b>] block_ioctl+0x3b/0x40
[122168.801079]  [<ffffffff810d4afe>] do_vfs_ioctl+0x8e/0x4e0
[122168.801081]  [<ffffffff810c390f>] ? do_sys_open+0x16f/0x1d0
[122168.801084]  [<ffffffff810d4f9a>] sys_ioctl+0x4a/0x80
[122168.801086]  [<ffffffff815d80bb>] system_call_fastpath+0x16/0x1b
[122171.658213] usb 2-2.1: usbfs: USBDEVFS_CONTROL failed cmd usbhid-ups rqt 161 rq 1 len 2 ret -110
[122175.662216] usb 2-2.1: usbfs: USBDEVFS_CONTROL failed cmd usbhid-ups rqt 161 rq 1 len 2 ret -110
[122179.666176] usb 2-2.1: usbfs: USBDEVFS_CONTROL failed cmd usbhid-ups rqt 161 rq 1 len 7 ret -110
[122181.658123] igb 0000:01:00.1: eth1: Reset adapter
[122184.820779] igb: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX

Justin.
