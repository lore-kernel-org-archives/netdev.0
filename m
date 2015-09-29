From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 105221] New: system panics under load on mlx4_en
 interfaces
Date: Tue, 29 Sep 2015 08:44:49 -0700
Message-ID: <20150929084449.562ee8fc@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34745 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934864AbbI2Pol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 11:44:41 -0400
Received: by padhy16 with SMTP id hy16so9584246pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 08:44:40 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id ct2sm26275856pbc.34.2015.09.29.08.44.39
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 08:44:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 29 Sep 2015 07:19:32 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 105221] New: system panics under load on mlx4_en interfaces


https://bugzilla.kernel.org/show_bug.cgi?id=105221

            Bug ID: 105221
           Summary: system panics under load on mlx4_en interfaces
           Product: Networking
           Version: 2.5
    Kernel Version: 4.3.0-rc3-vanilla
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: thomas@drewermann.org
        Regression: No

We are using HP ProLiant DL320e Gen8 with a dual port ConnectX-2 EN network
Mellanox NIC (P/N: MNPH29D_A2-A5) installed. BIOS, iLO, microcode and NIC
firwmwares are up to date. Already tried to change interrupts. All offloading
features are currently disabled:
Features for eth2:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: on
rx-vlan-stag-filter: on [fixed]
l2-fwd-offload: off [fixed]
busy-poll: on [fixed]

When putting load on those NICs we are receiving a kpanic. The issue can be
reproduced at any time. Kernel version doesn't make any difference.

[  176.892495] ------------[ cut here ]------------
[  176.892513] kernel BUG at net/core/skbuff.c:2097!
[  176.892525] invalid opcode: 0000 [#1] SMP
[  176.892538] Modules linked in: cpufreq_stats cpufreq_userspace
cpufreq_powersave iptable_filter cpufreq_conservative xt_CT nf_conntrack
iptable_raw ip_tables x_tables nfsd auth_rpcgss oid_registry nfs_acl nfs lockd
grace fscache sunrpc ip_gre ip_tunnel gre intel_rapl iosf_mbi
x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul
crc32_pclmul ghash_clmulni_intel sha256_ssse3 sha256_generic hmac drbg
ansi_cprng aesni_intel mgag200 aes_x86_64 lrw ttm drm_kms_helper gf128mul
glue_helper drm ablk_helper iTCO_wdt cryptd iTCO_vendor_support joydev evdev
psmouse ie31200_edac serio_raw hpilo i2c_algo_bit edac_core lpc_ich hpwdt
snd_pcm snd_timer snd 8250_fintek soundcore pcspkr mfd_core ipmi_si
ipmi_msghandler shpchp button pcc_cpufreq acpi_cpufreq processor
acpi_power_meter 8021q
[  176.892778]  garp mrp stp llc dummy autofs4 ext4 crc16 mbcache jbd2 dm_mod
mlx4_en vxlan ip6_udp_tunnel udp_tunnel sg sd_mod uas usb_storage scsi_mod
hid_generic usbhid hid crc32c_intel mlx4_core ehci_pci uhci_hcd tg3 ehci_hcd
ptp pps_core libphy usbcore usb_common thermal
[  176.892868] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.3.0-rc3-vanillaice
#1
[  176.892885] Hardware name: HP ProLiant DL320e Gen8, BIOS J05 11/09/2013
[  176.892902] task: ffffffff81814540 ti: ffffffff81800000 task.ti:
ffffffff81800000
[  176.892919] RIP: 0010:[<ffffffff8144d1a6>]  [<ffffffff8144d1a6>]
__skb_checksum+0x2d6/0x2f0
[  176.892942] RSP: 0018:ffff8802474038f8  EFLAGS: 00010286
[  176.892955] RAX: 00000000ffff12f3 RBX: 00000000ffff12f3 RCX:
00000000ffff0ec6
[  176.892972] RDX: ffff88022ce1d980 RSI: 00000000ffff12f3 RDI:
ffff8800afed4400
[  176.892988] RBP: 0000000000000000 R08: ffff880247403978 R09:
00000000ffff12f3
[  176.893005] R10: ffff88022ce1d300 R11: 0000000000000002 R12:
0000000000000000
[  176.893021] R13: 0000000000000000 R14: 00000000ffff12f3 R15:
0000000000000000
[  176.893038] FS:  0000000000000000(0000) GS:ffff880247400000(0000)
knlGS:0000000000000000
[  176.893056] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  176.893070] CR2: 00007f42a19c0000 CR3: 000000000180d000 CR4:
00000000001406f0
[  176.893086] Stack:
[  176.893092]  00000000b0ddb200 ffff880247403978 ffffffffffff12f3
ffffffff81814540
[  176.893113]  ffffffff81814540 ffffffff81814540 0000000000000000
ffff880000000000
[  176.893134]  0000000000000246 ffff8800afed4400 0000000000000000
ffff88022ce1d300
[  176.893155] Call Trace:
[  176.893162]  <IRQ>
[  176.893169]  [<ffffffff8144d1e2>] ? skb_checksum+0x22/0x30
[  176.893185]  [<ffffffff8144a940>] ? skb_push+0x40/0x40
[  176.893198]  [<ffffffff8144a5e0>] ? reqsk_fastopen_remove+0x150/0x150
[  176.893214]  [<ffffffff81535ed4>] ? udp6_ufo_fragment+0xb4/0x2e0
[  176.893230]  [<ffffffff8149ad74>] ? ip_finish_output2+0x134/0x350
[  176.893245]  [<ffffffff815358f2>] ? ipv6_gso_segment+0x112/0x2a0
[  176.893260]  [<ffffffff8144ac1e>] ? __kmalloc_reserve.isra.31+0x2e/0x80
[  176.893276]  [<ffffffff8145fe5e>] ? skb_mac_gso_segment+0x8e/0xe0
[  176.893292]  [<ffffffff814ded67>] ? gre_gso_segment+0x177/0x450
[  176.893307]  [<ffffffff814cf7d9>] ? inet_gso_segment+0x1d9/0x370
[  176.893322]  [<ffffffff81460600>] ? dev_hard_start_xmit+0x210/0x380
[  176.893337]  [<ffffffff8145fe5e>] ? skb_mac_gso_segment+0x8e/0xe0
[  176.893352]  [<ffffffff81460278>] ?
validate_xmit_skb.isra.98.part.99+0x128/0x2a0
[  176.893370]  [<ffffffff814607a6>] ? validate_xmit_skb_list+0x36/0x50
[  176.893953]  [<ffffffff81481da2>] ? sch_direct_xmit+0x102/0x1e0
[  176.894534]  [<ffffffff81481f0e>] ? __qdisc_run+0x8e/0x1b0
[  176.895115]  [<ffffffff81460b4f>] ? __dev_queue_xmit+0x2bf/0x540
[  176.895691]  [<ffffffff8149ae9a>] ? ip_finish_output2+0x25a/0x350
[  176.896264]  [<ffffffff8149d0c8>] ? ip_output+0x68/0xd0
[  176.896834]  [<ffffffff81490e82>] ? nf_hook_slow+0x62/0xb0
[  176.897389]  [<ffffffff81499131>] ? ip_forward+0x391/0x480
[  176.897927]  [<ffffffff81498d10>] ? ip_frag_mem+0x40/0x40
[  176.898446]  [<ffffffff814978c7>] ? ip_rcv+0x277/0x3a0
[  176.898948]  [<ffffffff81496f90>] ? inet_del_offload+0x40/0x40
[  176.899434]  [<ffffffff8145e883>] ? __netif_receive_skb_core+0x843/0x9a0
[  176.899909]  [<ffffffff814dea33>] ? gre_gro_receive+0x1c3/0x380
[  176.900383]  [<ffffffff81535ac2>] ? tcp6_gro_complete+0x42/0x70
[  176.900825]  [<ffffffff8145ea5f>] ? netif_receive_skb_internal+0x1f/0x80
[  176.901302]  [<ffffffff8145f223>] ? dev_gro_receive+0x213/0x340
[  176.901723]  [<ffffffff8145f527>] ? napi_gro_receive+0x27/0xc0
[  176.902140]  [<ffffffffa051eaf0>] ? gro_cell_poll+0x50/0x90 [ip_tunnel]
[  176.902552]  [<ffffffff8145eefa>] ? net_rx_action+0x20a/0x320
[  176.902957]  [<ffffffff810739d7>] ? __do_softirq+0x107/0x270
[  176.903354]  [<ffffffff81073c76>] ? irq_exit+0x86/0x90
[  176.903744]  [<ffffffff8155198f>] ? do_IRQ+0x4f/0xd0
[  176.904132]  [<ffffffff8154f642>] ? common_interrupt+0x82/0x82
[  176.904516]  <EOI>
[  176.904524]  [<ffffffff81429788>] ? cpuidle_enter_state+0xe8/0x220
[  176.905287]  [<ffffffff81429763>] ? cpuidle_enter_state+0xc3/0x220
[  176.905670]  [<ffffffff810ab064>] ? cpu_startup_entry+0x284/0x340
[  176.906048]  [<ffffffff8192ff37>] ? start_kernel+0x472/0x47a
[  176.906422]  [<ffffffff8192f120>] ? early_idt_handler_array+0x120/0x120
[  176.906793]  [<ffffffff8192f600>] ? x86_64_start_kernel+0x145/0x154
[  176.907157] Code: 14 37 39 c2 7d 92 be 20 08 00 00 48 c7 c7 91 35 78 81 89
44 24 38 e8 da 23 c2 ff 8b 44 24 38 e9 74 ff ff ff 31 ed e9 9a fd ff ff <0f> 0b
89 4c 24 10 e9 50 ff ff ff 66 66 66 66 66 66 2e 0f 1f 84
[  176.907990] RIP  [<ffffffff8144d1a6>] __skb_checksum+0x2d6/0x2f0
[  176.908412]  RSP <ffff8802474038f8>

-- 
You are receiving this mail because:
You are the assignee for the bug.
