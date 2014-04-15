From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: 3.15 drivers/net/ethernet/broadcom/cnic.c:576 suspicious
 rcu_dereference_check() usage!
Date: Tue, 15 Apr 2014 08:17:01 -0400
Message-ID: <CA+5PVA6C7W3wd9t0CVrVDo+qGvHOZGTL_Z8LFe84BMXjwOmn_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Eddie Wai <eddie.wai@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

We've had a report [1] of the bnx2i/cnic driver(s) throwing suspicious
RCU usage with 3.15 merge window kernels on an i686 machine.  This
corresponds to Linux v3.14-12812-g321d03c86732.  I've included the
dump below.

Has anyone seen this issue before?

josh

[1] https://bugzilla.redhat.com/show_bug.cgi?id=1087813

[   90.432418] ===============================
[   90.511920] [ INFO: suspicious RCU usage. ]
[   90.511922] 3.15.0-0.rc0.git13.1.fc21.i686 #1 Not tainted
[   90.511922] -------------------------------
[   90.511923] drivers/net/ethernet/broadcom/cnic.c:576 suspicious
rcu_dereference_check() usage!
[   90.511923]
[   90.511923] other info that might help us debug this:
[   90.511923]
[   90.511924]
[   90.511924] rcu_scheduler_active = 1, debug_locks = 0
[   90.511925] 3 locks held by anaconda/1320:
[   90.511932]  #0:  (rtnl_mutex){+.+.+.}, at: [<c09c6474>] rtnl_lock+0x14/0x20
[   90.511937]  #1:  (&bnx2i_dev_lock){+.+...}, at: [<f80d45df>]
bnx2i_ulp_init+0x2f/0x140 [bnx2i]
[   90.511940]  #2:  (cnic_lock){+.+...}, at: [<f80c8328>]
cnic_register_device+0x38/0x2d0 [cnic]
[   90.511941]
[   90.511941] stack backtrace:
[   90.511942] CPU: 3 PID: 1320 Comm: anaconda Not tainted
3.15.0-0.rc0.git13.1.fc21.i686 #1
[   90.511943] Hardware name: HP ProLiant DL360 G7, BIOS P68 01/28/2011
[   90.511946]  00000000 2cd0aecd 00000000 dc0d3cf4 c0ae271d 00000001
dc0d3d1c c04ac226
[   90.511948]  c0cb548e c0cdb161 00000001 00000000 dc160000 00000001
ec75a2c0 ec75a32c
[   90.511950]  dc0d3d90 f80c8442 00000003 f80d45df 00000001 df49393c
00000000 ec75a330
[   90.511951] Call Trace:
[   90.511956]  [<c0ae271d>] dump_stack+0x48/0x60
[   90.511959]  [<c04ac226>] lockdep_rcu_suspicious+0xd6/0x100
[   90.511961]  [<f80c8442>] cnic_register_device+0x152/0x2d0 [cnic]
[   90.511967]  [<f80d45df>] ? bnx2i_ulp_init+0x2f/0x140 [bnx2i]
[   90.511969]  [<c04add2b>] ? trace_hardirqs_on+0xb/0x10
[   90.511972]  [<f80d45df>] ? bnx2i_ulp_init+0x2f/0x140 [bnx2i]
[   90.511974]  [<f80d45df>] ? bnx2i_ulp_init+0x2f/0x140 [bnx2i]
[   90.511977]  [<f80d45f9>] bnx2i_ulp_init+0x49/0x140 [bnx2i]
[   90.511979]  [<f80c65e1>] cnic_register_driver+0xe1/0x180 [cnic]
[   90.511982]  [<f7d93000>] ? 0xf7d92fff
[   90.511984]  [<f7d9308b>] bnx2i_mod_init+0x8b/0x1000 [bnx2i]
[   90.511986]  [<f7d93000>] ? 0xf7d92fff
[   90.511988]  [<c040049a>] do_one_initcall+0xca/0x1a0
[   90.511990]  [<f7d93000>] ? 0xf7d92fff
[   90.511992]  [<c0445777>] ? set_memory_ro+0x37/0x40
[   90.511995]  [<c04e3b96>] load_module+0x1fe6/0x2480
[   90.511999]  [<c04dfb99>] ? copy_module_from_fd.isra.45+0x109/0x1a0
[   90.512001]  [<c04e41ed>] SyS_finit_module+0x8d/0xd0
[   90.512003]  [<c04a97ab>] ? up_write+0x1b/0x30
[   90.512005]  [<c056defb>] ? vm_mmap_pgoff+0x9b/0xc0
[   90.512010]  [<c0af39df>] sysenter_do_call+0x12/0x38
[   90.512012]  [<c0ae0000>] ? mtrr_check.part.2+0x32/0x57
[   90.512304] bnx2i [04:00.01]: ISCSI_INIT passed
[  155.484180] INFO: rcu_sched detected stalls on CPUs/tasks: {}
(detected by 7, t=65099 jiffies, g=4371, c=4370, q=172)
[  155.634698] INFO: Stall ended before state dump start
[-- MARK -- Tue Apr 15 09:30:01 2014]
