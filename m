From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] net: neighbour: make sure the handler has finished before
 kfree neighbour
Date: Thu, 28 Nov 2013 20:28:52 +0800
Message-ID: <52973704.1030202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Joe Perches" <joe@perches.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:55409 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab3K1M3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 07:29:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have met the oops in Suse11 SP2, the kernel is 2.6.32.59-0.7-default:

[64306.089036] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[64306.089343] IP: [<ffffffff812f8e36>] neigh_timer_handler+0x116/0x3b0
[64306.089535] PGD 0
[64306.089706] Oops: 0000 [#1] SMP
[64306.089935] last sysfs file: /sys/devices/pci0000:00/0000:00:03.0/0000:02:00.0/host0/target0:1:0/0:1:0:0/scsi_generic/sg0/dev
[64306.090142] Die func triggered, code:1
[64306.090147] CPU 1
[64306.090149] Modules linked in: nfsd nfs_common(N) lockd auth_rpcgss smb2(N) smb(N) smb_manager(N) nas_acl(N) nas_proto_vfs(N) snas_ts(N) snas_cafs(PN) snas_ca(N) snas_mds(PN) snas_ds(N) nm(PN) snas_nvcache(PN) snas_dlm(PN) snas_trns(PN) ipmi_devintf(N) ipmi_si(N) ipmi_msghandler(N) af_packet(N) snas_cm_sdd(PN) snas_cm_pma(PN) disk_online_diagnostic(N) snas_monc(N) snas_fc(N) snas_mml(PN) ptlrpc(N) ko2iblnd(N) ksocklnd(N) obdclass(N) lnet(N) lvfs(PN) libcfs(N) snas_base(N) nofs(N) usos(N) zlib_deflate(N) joydev(N) nas_netlink(N) sunrpc cpufreq_conservative(N) cpufreq_userspace(N) cpufreq_powersave(N) acpi_cpufreq(N) t3k_mpt2sas_vdl(N) raidrepair(N) ib_ipoib ib_umad iw_nes crc32c(N) libcrc32c(N) iw_cxgb3 cxgb3 mlx4_ib mlx4_en mlx4_core ib_mthca nvdimm_mapping(N) smbuspci(N) microcode(N) r
 dma_ucm ib_uverbs rdma_cm ib_cm iw_cm ib_sa ib_mad ib_addr ipv6(N) iw_cxgb4(N) ib_core cxgb4(N) nvdimm_mem(N) soft_watchdog(PN) kbox(PN) fuse(N) loop(N) dm_mod(N) iTCO_wdt(N) i2c_i801(N) tp!
m_tis(N)
 tpm(N) rtc_cmos(N) tpm_bios(N) bnx2 ses(N) i2c_core(N) sg(N) iTCO_vendor_support(N) pcspkr(N) rtc_core(N) enclosure(N) rtc_lib(N) wmi(N) container(N) button(N) usbhid(N) hid(N) ehci_hcd(N) usbcore(N) sd_mod crc_t10dif(N) edd(N) ext3(N) mbcache(N) jbd(N) fan(N) processor(N) mpt2sas scsi_transport_sas(N) raid_class(N) scsi_mod thermal(N) thermal_sys(N) hwmon(N) [last unloaded: ipmi_msghandler]
[64306.090258] Supported: Yes, External
[64306.090262] Pid: 58359, comm: socknal_cd04 Tainted: P          N  2.6.32.59-0.7-default #1 T3500 G3
[64306.090266] RIP: 0010:[<ffffffff812f8e36>]  [<ffffffff812f8e36>] neigh_timer_handler+0x116/0x3b0
[64306.090272] RSP: 0018:ffff880c273499d8  EFLAGS: 00010206
[64306.090275] RAX: 0000000000000000 RBX: ffff8801cddf1500 RCX: ffff8801cddf14f2
[64306.090278] RDX: 0000000000000000 RSI: ffff8805e40d3a28 RDI: ffff8801cddf1500
[64306.090281] RBP: ffff8805e40d3a28 R08: ffff8801cddf1530 R09: ffff880c27349b17
[64306.090284] R10: 000000000000000e R11: ffffffff812f8e22 R12: ffff880185c0e840
[64306.090287] R13: 0000000000000000 R14: ffff8805e40d3a60 R15: 0000000003484560
[64306.090291] FS:  00007f081210e700(0000) GS:ffff880036420000(0000) knlGS:0000000000000000
[64306.090295] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[64306.090297] CR2: 0000000000000008 CR3: 0000000001804000 CR4: 00000000000406e0
[64306.090301] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[64306.090304] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[64306.090308] Process socknal_cd04 (pid: 58359, threadinfo ffff880c27348000, task ffff880c25d02300)
[64306.090310] Stack:
[64306.090426]  ffffffff8131f8e0 0000000000000003 ffff8801c189eb40 000000000000000a
[64306.090437] <0> ffffffff00000000 0000000000000002 ffff880c27349a30 ffffffffa304790c
[64306.090444] <0> 0000000000000246 000051010a010000 ffffffff81318357 31312d3300007fff
[64306.090450] <0> ffff880c27349bb8 0248456003484560 ffff8801c189eb40 ffffffff81869300
[64306.090456] <0> ffff880185c0e840 ffff8801cddf1514 ffff8805e40d3a28 00000000000000d0
[64306.090464] Call Trace:

--------------------------- cut here -------------------------------------

I found the NULL place int the neigh_timer_handler, the neigh->ops is NULL,
so the calling of neigh->ops->solicit(neigh, skb) will panic, I found the
neigh has been freed via the kdump, the so I think the neigh was kfreed while
the neigh timer handler is running.

The situation is that there are several server in the local lan:
A: 128.5.10.83
B: 128.5.10.85
C: 128.5.10.xx

I panic the A by manual, and set B's IP to 128.5.10.83, so send broadcast to tell
the lan that B is 128.5.10.83, then the B panic, it is hard to appeared again, so
I only met once.

I think the reason is that:

	CPU0					CPU1
	-----					-----
						<SOFTIRQ>
						neigh_timer_handler();
	neigh_release();
	write_lock(&neigh->lock);
	del_timer(neigh->timer);
	write_unlock(&neigh->lock);
						write_lock(&neigh->lock);
	kfree(neigh);
 						neigh->ops->solicit();

--------------------------------------------------------------------------

So I think the latest kernel still has the problem.

The timer handler must be finished before kfree the neigh in SMP,
but the del_timer could only detach the timer, not sure the timer
is finished, so I use the del_timer_sync() to make sure the handler
has finished before kfree the neighour.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/core/neighbour.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ca15f32..ce7cc83 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -705,8 +705,8 @@ void neigh_destroy(struct neighbour *neigh)
 		return;
 	}
 
-	if (neigh_del_timer(neigh))
-		pr_warn("Impossible event\n");
+	if (neigh->nud_state & NUD_IN_TIMER)
+		del_timer_sync(&neigh->timer);
 
 	write_lock_bh(&neigh->lock);
 	__skb_queue_purge(&neigh->arp_queue);
-- 
1.8.0
