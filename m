From: Honggang Li <honli@redhat.com>
Subject: [PATCH linux-next 1/4] infiniband/ipoib: fix possible NULL pointer dereference in ipoib_get_iflink
Date: Tue, 14 Apr 2015 23:20:14 +0800
Message-ID: <1429024817-21561-2-git-send-email-honli@redhat.com>
References: <1429024817-21561-1-git-send-email-honli@redhat.com>
Cc: Honggang Li <honli@redhat.com>
To: roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	kaber@trash.net, davem@davemloft.net, alex.estrin@intel.com,
	dledford@redhat.com, edumazet@google.com, erezsh@mellanox.com,
	nicolas.dichtel@6wind.com, maheshb@google.com, jbenc@redhat.com,
	ebiederm@xmission.com, elfring@users.sourceforge.net,
	f.fainelli@gmail.com, linux@roeck-us.net, andrew@lunn.ch,
	sfeldma@gmail.com, alexander.h.duyck@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429024817-21561-1-git-send-email-honli@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Starting monitoring for VG vg_rdma01:   3 logical volume(s) in volume
group "vg_rdma01" monitored
[  OK  ]
Starting cgconfig service: Failed to parse /etc/cgconfig.conf or
/etc/cgconfig.d[FAILED]
Loading OpenIB kernel modules:
BUG: unable to handle kernel NULL pointer dereference at 0000000000000120
IP: [<ffffffffa06b9060>] ipoib_get_iflink+0x10/0x20 [ib_ipoib]
PGD 475540067 PUD 473541067 PMD 0
Oops: 0000 [#1] SMP
Modules linked in: ib_ipoib(+) rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm
ib_cm ib_sa vhost_net macvtap macvlan vhost tun ipmi_devintf sg ipmi_si
ipmi_msghandler serio_raw iTCO_wdt iTCO_vendor_support cdc_ether usbnet
mii bnx2 intel_powerclamp coretemp kvm_intel kvm crc32c_intel
ghash_clmulni_intel aesni_intel ablk_helper cryptd lrw gf128mul
glue_helper aes_x86_64 microcode pcspkr i2c_i801 i2c_core lpc_ich
mfd_core acpi_cpufreq ioatdma i7core_edac edac_core shpchp ext4(E)
jbd2(E) mbcache(E) sd_mod(E) megaraid_sas(E) pata_acpi(E) ata_generic(E)
ata_piix(E) iw_cxgb3(E) cxgb3(E) mdio(E) ib_qib(E) dca(E) ib_mad(E)
iw_cxgb4(E) iw_cm(E) ib_core(E) ib_addr(E) ipv6(E) cxgb4(E) dm_mirror(E)
dm_region_hash(E) dm_log(E) dm_mod(E)
CPU: 6 PID: 2405 Comm: modprobe Tainted: G            E
4.0.0-next-20150413 #1
Hardware name: IBM System x3650 M3 -[7945O63]-/00D4062, BIOS
-[D6E157AUS-1.15]- 06/13/2012
task: ffff880476ad6f00 ti: ffff88047579c000 task.ti: ffff88047579c000
RIP: 0010:[<ffffffffa06b9060>]  [<ffffffffa06b9060>]
ipoib_get_iflink+0x10/0x20 [ib_ipoib]
RSP: 0018:ffff88047579f9b8  EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff880476e2a000 RCX: 0000000000000000
RDX: 0000000000000004 RSI: ffff88047579fbb8 RDI: ffff880476e2a000
RBP: ffff88047579f9b8 R08: 0000000000000660 R09: ffff88047404f068
R10: 0000000000000000 R11: 0000000000000000 R12: ffff8804736bec00
R13: ffff88047579fbb4 R14: ffff88047404f000 R15: 0000000000000009
FS:  00007fc047a2e700(0000) GS:ffff88047fc00000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000120 CR3: 000000047541f000 CR4: 00000000000006e0
Stack:
 ffff88047579f9c8 ffffffff814fbfa3 ffff88047579fbe8 ffffffff81515a15
 0000000000000005 ffff880476e2a280 0000000000000005 0000000000000014
 ffff88047579fa48 ffffffff8150a577 0000000000000000 ffff8804ffffffff
Call Trace:
 [<ffffffff814fbfa3>] dev_get_iflink+0x23/0x40
 [<ffffffff81515a15>] rtnl_fill_ifinfo+0x255/0xce0
 [<ffffffff8150a577>] ? __hw_addr_create_ex+0x97/0xc0
 [<ffffffff815d32bb>] ? _raw_spin_unlock_bh+0x1b/0x20
 [<ffffffff8150a8e5>] ? __dev_mc_add+0x75/0x90
 [<ffffffffa00a115c>] ? igmp6_group_added+0x5c/0x130 [ipv6]
 [<ffffffff8119c6cc>] ? __kmalloc_node_track_caller+0x3c/0x50
 [<ffffffff814f0f0b>] ? __kmalloc_reserve+0x3b/0xa0
 [<ffffffff814f12f8>] ? __alloc_skb+0xa8/0x1f0
 [<ffffffff81516783>] rtmsg_ifinfo_build_skb+0x83/0xe0
 [<ffffffff81078fa6>] ? raw_notifier_call_chain+0x16/0x20
 [<ffffffff81516801>] rtmsg_ifinfo+0x21/0x40
 [<ffffffff81504eaf>] register_netdevice+0x38f/0x400
 [<ffffffff81504f3e>] register_netdev+0x1e/0x30
 [<ffffffffa06bc204>] ipoib_add_port.clone.0+0x214/0x390 [ib_ipoib]
 [<ffffffffa06bc447>] ipoib_add_one+0xc7/0x110 [ib_ipoib]
 [<ffffffffa00f9d4d>] ib_register_client+0x7d/0xa0 [ib_core]
 [<ffffffffa06ce000>] ? 0xffffffffa06ce000
 [<ffffffffa06ce0f2>] ipoib_init_module+0xf2/0x13c [ib_ipoib]
 [<ffffffff81000287>] do_one_initcall+0xb7/0x1d0
 [<ffffffff810d8189>] do_init_module+0x69/0x200
 [<ffffffff810da985>] load_module+0x5b5/0x730
 [<ffffffff810d79b0>] ? mod_sysfs_teardown+0x150/0x150
 [<ffffffff81183232>] ? __vmalloc+0x22/0x30
 [<ffffffff810d73c0>] ? module_sect_show+0x30/0x30
 [<ffffffff810dac84>] SyS_init_module+0x94/0xc0
 [<ffffffff815d3997>] system_call_fastpath+0x12/0x6a
Code: 66 66 66 90 b9 1e 00 00 00 48 89 f0 48 8d 77 08 48 89 c7 f3 48 a5
c9 c3 0f 1f 00 55 48 89 e5 66 66 66 66 90 48 8b 87 e8 13 00 00 <8b> 80
20 01 00 00 c9 c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 66
RIP  [<ffffffffa06b9060>] ipoib_get_iflink+0x10/0x20 [ib_ipoib]
 RSP <ffff88047579f9b8>
CR2: 0000000000000120
---[ end trace a8610f6e9640eb85 ]---

Signed-off-by: Honggang Li <honli@redhat.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 657b89b..11ea6e2 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -846,7 +846,10 @@ static int ipoib_get_iflink(const struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	return priv->parent->ifindex;
+	if (priv && priv->parent)
+		return priv->parent->ifindex;
+	else
+		return 0;
 }
 
 static u32 ipoib_addr_hash(struct ipoib_neigh_hash *htbl, u8 *daddr)
-- 
1.8.3.1
