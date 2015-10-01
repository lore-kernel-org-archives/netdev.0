From: Vinson Lee <vlee@twopensource.com>
Subject: GPF in do_raw_spin_lock on Linux 4.1
Date: Wed, 30 Sep 2015 17:49:47 -0700
Message-ID: <CAHTgTXVdvTJHg3Sj5bGcfsB8FUwwqnP6mCGGMcF0cQ0U7fVrEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Fan Du <fan.du@intel.com>, Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:35175 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137AbbJAAtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 20:49:49 -0400
Received: by laer8 with SMTP id r8so65306730lae.2
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 17:49:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

We've hit this GPF on several different machines on Linux 4.1.

general protection fault: 0000 [#1] SMP
Modules linked in: sch_htb cls_basic act_mirred cls_u32 veth
sch_ingress netconsole configfs cpufreq_ondemand ipv6 dm_multipath
scsi_dh video sbs sbshc hed acpi_pad acpi_ipmi sch_fq_codel parport_pc
lp parport tcp_diag inet_diag ipmi_devintf sg iTCO_wdt
iTCO_vendor_support igb serio_raw hpwdt hpilo i2c_algo_bit i2c_core
ptp pps_core wmi ipmi_si ipmi_msghandler lpc_ich mfd_core sb_edac
ioatdma dca edac_core shpchp microcode acpi_cpufreq ahci libahci
libata sd_mod scsi_mod
CPU: 8 PID: 45989 Comm: kworker/u128:0 Not tainted 4.1.1 #1
Workqueue: netns cleanup_net
task: ffff8809973d1890 ti: ffff880c96cc4000 task.ti: ffff880c96cc4000
RIP: 0010:[<ffffffff8109c107>]  [<ffffffff8109c107>] do_raw_spin_lock+0x9/0x21
RSP: 0018:ffff880c96cc7bc8  EFLAGS: 00010286
RAX: 0000000000000100 RBX: dead000000100060 RCX: 0000000000000007
RDX: 0000000000000012 RSI: 00000000fffffe01 RDI: dead0000001000d0
RBP: ffff880c96cc7bc8 R08: 0000000000000000 R09: ffffffffa043f6b0
R10: ffffffff8145dac7 R11: ffff8809843423f8 R12: ffff880528fa2800
R13: dead0000001000d0 R14: ffffffff81ac9460 R15: ffff88080f219148
FS:  0000000000000000(0000) GS:ffff88103f840000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffffff600000 CR3: 0000000fab9e7000 CR4: 00000000001407e0
Stack:
 ffff880c96cc7bd8 ffffffff8150290a ffff880c96cc7c08 ffffffffa043f041
 0000000000000007 00000000ffffffee 0000000000000006 ffff880c96cc7ca0
 ffff880c96cc7c48 ffffffff810815d6 ffff880c96cc7b38 0000000000000000
Call Trace:
 [<ffffffff8150290a>] _raw_spin_lock_bh+0x19/0x1b
 [<ffffffffa043f041>] mirred_device_event+0x41/0x82 [act_mirred]
 [<ffffffff810815d6>] notifier_call_chain+0x3e/0x61
 [<ffffffff8108166b>] raw_notifier_call_chain+0x14/0x16
 [<ffffffff814515ac>] call_netdevice_notifiers_info+0x53/0x5b
 [<ffffffff814515ca>] call_netdevice_notifiers+0x16/0x18
 [<ffffffff81455e52>] rollback_registered_many+0x15a/0x25a
 [<ffffffff81456537>] unregister_netdevice_many+0x19/0x64
 [<ffffffff814566a7>] default_device_exit_batch+0x125/0x139
 [<ffffffff810977a0>] ? abort_exclusive_wait+0x8e/0x8e
 [<ffffffff8144e750>] ops_exit_list+0x2b/0x57
 [<ffffffff8144f71f>] cleanup_net+0x153/0x1e0
 [<ffffffff8107c1a9>] process_one_work+0x16e/0x294
 [<ffffffff8107c814>] worker_thread+0x1dd/0x2bb
 [<ffffffff8107c637>] ? cancel_delayed_work_sync+0x15/0x15
 [<ffffffff8107c637>] ? cancel_delayed_work_sync+0x15/0x15
 [<ffffffff81080ab6>] kthread+0xae/0xb6
 [<ffffffff81080000>] ? add_sysfs_param.isra.4+0x8e/0x18c
 [<ffffffff81080a08>] ? __kthread_parkme+0x61/0x61
 [<ffffffff81502f52>] ret_from_fork+0x42/0x70
 [<ffffffff81080a08>] ? __kthread_parkme+0x61/0x61
Code: dd 88 ca 38 cb 88 de 75 16 8d 8a 00 01 00 00 89 d0 f0 66 0f b1
0f 66 39 d0 0f 94 c0 0f b6 c0 5b 5d c3 55 b8 00 01 00 00 48 89 e5 <f0>
66 0f c1 07 0f b6 d4 38 c2 74 0a 8a 07 38 d0 74 04 f3 90 eb
RIP  [<ffffffff8109c107>] do_raw_spin_lock+0x9/0x21
 RSP <ffff880c96cc7bc8>


Cheers,
Vinson
