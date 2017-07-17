From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196399] New: WARNING at net/sched/sch_generic.c:316
 dev_watchdog[...] when suspending
Date: Mon, 17 Jul 2017 08:38:25 -0700
Message-ID: <20170717083825.7fc26834@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34843 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdGQPid (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 11:38:33 -0400
Received: by mail-pg0-f54.google.com with SMTP id v190so23652563pgv.2
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 08:38:33 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id d185sm28800320pgc.39.2017.07.17.08.38.32
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jul 2017 08:38:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 17 Jul 2017 08:34:16 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196399] New: WARNING at net/sched/sch_generic.c:316 dev_watchdog[...] when suspending


https://bugzilla.kernel.org/show_bug.cgi?id=196399

            Bug ID: 196399
           Summary: WARNING at net/sched/sch_generic.c:316
                    dev_watchdog[...] when suspending
           Product: Networking
           Version: 2.5
    Kernel Version: 4.11+
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: martin.peres@free.fr
        Regression: No

Hello,

We have found out that since at least 4.11-rc1, some machines in the Intel GFX
CI lab have been generating the following warning when suspending to s4
(suspend to disk):

[  287.212825] ------------[ cut here ]------------
[  287.212829] WARNING: CPU: 0 PID: 3165 at net/sched/sch_generic.c:316
dev_watchdog+0x218/0x220
[  287.212830] Modules linked in: mcs7830 usbnet mii snd_hda_codec_hdmi
snd_hda_codec_realtek snd_hda_codec_generic i915 x86_pkg_temp_thermal
intel_powerclamp coretemp crct10dif_pclmul crc32_pclmul snd_hda_intel
snd_hda_codec snd_hwdep ghash_clmulni_intel snd_hda_core snd_pcm
i2c_designware_platform i2c_designware_core mei_me mei prime_numbers i2c_hid
pinctrl_sunrisepoint pinctrl_intel
[  287.212864] CPU: 0 PID: 3165 Comm: gem_exec_suspen Tainted: G     U         
4.12.0-CI-CI_DRM_2829+ #1
[  287.212865] Hardware name: Dell Inc. XPS 13 9360/093TW6, BIOS 1.3.2
01/18/2017
[  287.212867] task: ffff8801b4084f40 task.stack: ffffc900001d8000
[  287.212869] RIP: 0010:dev_watchdog+0x218/0x220
[  287.212870] RSP: 0018:ffff88027e403e38 EFLAGS: 00010292
[  287.212872] RAX: 000000000000005a RBX: 0000000000000000 RCX:
0000000000000000
[  287.212874] RDX: 0000000000000002 RSI: ffffffff81cbcf89 RDI:
ffffffff81c9c627
[  287.212875] RBP: ffff88027e403e68 R08: 0000000000000000 R09:
0000000000000001
[  287.212876] R10: 0000000028e9c215 R11: 0000000000000000 R12:
ffff88026e08a848
[  287.212877] R13: 0000000000000000 R14: ffff88026e050020 R15:
0000000000000001
[  287.212878] FS:  00007f345056a8c0(0000) GS:ffff88027e400000(0000)
knlGS:0000000000000000
[  287.212880] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  287.212881] CR2: 00000000008d7008 CR3: 00000001b4314000 CR4:
00000000003406f0
[  287.212882] Call Trace:
[  287.212883]  <IRQ>
[  287.212886]  ? qdisc_rcu_free+0x40/0x40
[  287.212888]  ? qdisc_rcu_free+0x40/0x40
[  287.212891]  call_timer_fn+0x8e/0x370
[  287.212894]  ? qdisc_rcu_free+0x40/0x40
[  287.212896]  expire_timers+0x150/0x1f0
[  287.212899]  run_timer_softirq+0x7c/0x160
[  287.212903]  __do_softirq+0x116/0x4a0
[  287.212906]  irq_exit+0xa9/0xc0
[  287.212909]  smp_apic_timer_interrupt+0x38/0x50
[  287.212912]  apic_timer_interrupt+0x90/0xa0
[  287.212914] RIP: 0010:delay_tsc+0x33/0xc0
[  287.212916] RSP: 0018:ffffc900001dbcd8 EFLAGS: 00000286 ORIG_RAX:
ffffffffffffff10
[  287.212918] RAX: 0000000080000000 RBX: 00000005964f23a0 RCX:
0000000000000001
[  287.212919] RDX: 0000000080000001 RSI: ffffffff81c8e23a RDI:
00000000ffffffff
[  287.212920] RBP: ffffc900001dbcf8 R08: 0000000000000000 R09:
0000000000000001
[  287.212921] R10: 0000000000000000 R11: 0000000000000000 R12:
000000059633478e
[  287.212922] R13: 0000000000249f13 R14: 0000000000000000 R15:
ffff880272eac008
[  287.212924]  </IRQ>
[  287.212929]  ? delay_tsc+0x6b/0xc0
[  287.212932]  __delay+0xa/0x10
[  287.212934]  __const_udelay+0x31/0x40
[  287.212936]  hibernation_debug_sleep+0x20/0x30
[  287.212938]  hibernation_snapshot+0x2bc/0x5f0
[  287.212940]  hibernate+0x159/0x2f0
[  287.212943]  state_store+0xe0/0xf0
[  287.212947]  kobj_attr_store+0xf/0x20
[  287.212949]  sysfs_kf_write+0x40/0x50
[  287.212951]  kernfs_fop_write+0x130/0x1b0
[  287.212955]  __vfs_write+0x23/0x120
[  287.212957]  ? rcu_read_lock_sched_held+0x75/0x80
[  287.212959]  ? rcu_sync_lockdep_assert+0x2a/0x50
[  287.212961]  ? __sb_start_write+0xfa/0x1f0
[  287.212964]  vfs_write+0xc5/0x1d0
[  287.212966]  ? trace_hardirqs_on_caller+0xe7/0x1c0
[  287.212969]  SyS_write+0x44/0xb0
[  287.212972]  entry_SYSCALL_64_fastpath+0x1c/0xb1
[  287.212973] RIP: 0033:0x7f344ed4a4a0
[  287.212974] RSP: 002b:00007ffef50dfaa8 EFLAGS: 00000246 ORIG_RAX:
0000000000000001
[  287.212977] RAX: ffffffffffffffda RBX: ffffffff81470683 RCX:
00007f344ed4a4a0
[  287.212978] RDX: 0000000000000004 RSI: 000000000041d211 RDI:
0000000000000006
[  287.212979] RBP: ffffc900001dbf88 R08: 00000000008d6a50 R09:
0000000000000000
[  287.212980] R10: 0000000000000000 R11: 0000000000000246 R12:
000000000041d211
[  287.212981] R13: 0000000000000006 R14: 0000000000000000 R15:
0000000000000000
[  287.212984]  ? __this_cpu_preempt_check+0x13/0x20
[  287.212988] Code: 63 8e 18 04 00 00 eb 93 4c 89 f7 c6 05 77 5c 77 00 01 e8
dc 7f fd ff 89 d9 48 89 c2 4c 89 f6 48 c7 c7 18 f4 cf 81 e8 f1 c4 9d ff <0f> ff
eb c3 0f 1f 40 00 48 c7 47 08 00 00 00 00 55 48 c7 07 00 
[  287.213051] ---[ end trace b6016dcc7544a681 ]---

This is caught while running the intel-gpu-tools test named
'igt@gem_exec_suspend@basic-s4-devices' on the following machines:

 - Intel Kaby Lake-R RVP: Failure rate 123/135 run(s) (91%), last occurence:
https://intel-gfx-ci.01.org/CI/CI_DRM_2828/fi-kbl-r/igt@gem_exec_suspend@basic-s4-devices.html
 - Intel Kaby Lake i7-7560u: Failure rate 196/305 run(s) (64%), last occurence:
https://intel-gfx-ci.01.org/CI/CI_DRM_2827/fi-kbl-7560u/igt@gem_exec_suspend@basic-s4-devices.html 
 - Intel Skylake i7-6600u: Failure rate 23/75 run(s) (30%), last occurence:
https://intel-gfx-ci.01.org/CI/CI_DRM_2824/fi-skl-6600u/igt@gem_exec_suspend@basic-s4-devices.html
 - Intel Sandy Bridge i7-2600: Failure rate 10/293 run(s) (3%), last occurence:
https://intel-gfx-ci.01.org/CI/CI_DRM_2816/fi-snb-2600/igt@gem_exec_suspend@basic-s4-devices.html 

We have plenty of other machines that do not trigger this warning at all.

The bug used to live in fd.o's bugzilla, but it had no business being there:
https://bugs.freedesktop.org/show_bug.cgi?id=100125

Let me know if I can help in some ways.

-- 
You are receiving this mail because:
You are the assignee for the bug.
