From: Brian Haley <brian.haley@hp.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Thu, 04 Mar 2010 15:31:23 -0500
Message-ID: <4B90189B.2040801@hp.com>
References: <20091229084929.54912c0c@pluto.restena.lu> <1262077540.12520.4.camel@localhost> <20091229145403.39f82773@pluto.restena.lu> <1262149691.2788.63.camel@localhost> <20100219091034.5fbb0165@pluto.restena.lu> <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com> <20100223131508.4c6cb866@neptune.home> <1267493170.2762.45.camel@dhcp-10-12-137-104.broadcom.com> <20100302081051.3d1b1c53@pluto.restena.lu> <20100302092020.52cfcd0e@pluto.restena.lu> <1267567926.19491.175.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?QnJ1bm8gUHLDqW1vbnQ=?= <bonbons@linux-vserver.org>,
	Benjamin Li <benli@broadcom.com>,
	NetDEV <netdev@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:46611 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756009Ab0CDUcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 15:32:03 -0500
In-Reply-To: <1267567926.19491.175.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

Michael Chan wrote:
> Do we have timers running in this environment?  The timer in the bnx2
> driver, bnx2_timer(), needs to run to provide a heart beat to the
> firmware.  In netpoll mode without timer interrupts, if we are regularly
> calling the NAPI poll function, it should also be able to provide the
> heartbeat.  Without the heartbeat, the firmware will reset the chip and
> result in the NETDEV WATCHDOG.

We have also been seeing watchdog timeouts with bnx2, below is a
stack trace with Benjamin's debug patch applied.  Normally we were
only seeing them under heavy load, but this one was at boot.  We haven't
tried the latest firmware/driver from 2.6.33 yet.  You can contact me
offline if you need more detailed info.

Thanks,

-Brian


[    2.428093] bnx2 0000:04:00.0: firmware: requesting bnx2/bnx2-rv2p-06-5.0.0.j3.fw
[    2.432526] eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz found at mem f6000000, IRQ 41, node addr 00:1c:c4:e1:cc:ea
[    2.439520] bnx2 0000:42:00.0: PCI INT A -> GSI 34 (level, low) -> IRQ 34

<snip>

[  223.805014] ------------[ cut here ]------------
[  223.805023] WARNING: at net/sched/sch_generic.c:261 dev_watchdog+0x12d/0x1d5()
[  223.805026] Hardware name: ProLiant DL385 G2
[  223.805028] NETDEV WATCHDOG: eth0 (bnx2): transmit queue 0 timed out
[  223.805031] Modules linked in: itapi iptable_filter ip_tables x_tables mptctl ipmi_devintf deflate zlib_deflate ctr twofish twofish_common camellia serpent blowfish cast5 des_generic cbc cryptd aes_x86_64 aes_generic xcbc rmd160 sha256_generic sha1_generic crypto_null af_key dm_snapshot dm_mirror dm_region_hash dm_log dm_mod sg bonding sctp crc32c libcrc32c loop psmouse serio_raw amd64_edac_mod edac_core k8temp container i2c_piix4 i2c_core ipmi_si ipmi_msghandler shpchp pci_hotplug hpilo processor evdev ext3 jbd mbcache ses enclosure sd_mod crc_t10dif ide_cd_mod cdrom ata_generic libata ide_pci_generic usbhid hid mptsas bnx2 mptscsih mptbase scsi_transport_sas serverworks ehci_hcd scsi_mod ide_core ohci_hcd uhci_hcd button thermal fan thermal_sys edd [last unloaded: scsi_wait_scan]
[  223.805102] Pid: 0, comm: swapper Not tainted 2.6.32-clim-4-amd64 #1
[  223.805105] Call Trace:
[  223.805108]  <IRQ>  [<ffffffff812697a0>] ? dev_watchdog+0x12d/0x1d5
[  223.805118]  [<ffffffff81049914>] warn_slowpath_common+0x77/0xa4
[  223.805123]  [<ffffffff810499b6>] warn_slowpath_fmt+0x64/0x66
[  223.805128]  [<ffffffff81045df7>] ? default_wake_function+0xd/0xf
[  223.805133]  [<ffffffff81035fa7>] ? __wake_up_common+0x46/0x76
[  223.805138]  [<ffffffff8103b414>] ? __wake_up+0x43/0x50
[  223.805143]  [<ffffffff81253829>] ? netdev_drivername+0x43/0x4b
[  223.805147]  [<ffffffff812697a0>] dev_watchdog+0x12d/0x1d5
[  223.805152]  [<ffffffff8105e84a>] ? delayed_work_timer_fn+0x0/0x3d
[  223.805156]  [<ffffffff8105e7ee>] ? __queue_work+0x35/0x3d
[  223.805159]  [<ffffffff81269673>] ? dev_watchdog+0x0/0x1d5
[  223.805164]  [<ffffffff8105655a>] run_timer_softirq+0x1ff/0x2a1
[  223.805169]  [<ffffffff810205a1>] ? lapic_next_event+0x18/0x1c
[  223.805174]  [<ffffffff8104f9e3>] __do_softirq+0xde/0x19f
[  223.805179]  [<ffffffff8100ccec>] call_softirq+0x1c/0x28
[  223.805183]  [<ffffffff8100e8b1>] do_softirq+0x41/0x81
[  223.805187]  [<ffffffff8104f7bd>] irq_exit+0x36/0x75
[  223.805191]  [<ffffffff81020f33>] smp_apic_timer_interrupt+0x88/0x96
[  223.805195]  [<ffffffff8100c6b3>] apic_timer_interrupt+0x13/0x20
[  223.805198]  <EOI>  [<ffffffff81027740>] ? native_safe_halt+0x6/0x8
[  223.805207]  [<ffffffff81012da3>] ? default_idle+0x55/0x74
[  223.805210]  [<ffffffff810131ce>] ? c1e_idle+0xf4/0xfb
[  223.805215]  [<ffffffff81065529>] ? atomic_notifier_call_chain+0x13/0x15
[  223.805219]  [<ffffffff8100aeec>] ? cpu_idle+0x5b/0x93
[  223.805225]  [<ffffffff81304144>] ? start_secondary+0x1a8/0x1ac
[  223.805228] ---[ end trace b04d103e6c8c23de ]---
[  223.805231] bnx2: eth0 DEBUG: intr_sem[0]
[  223.805236] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  223.805242] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  223.805245] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  228.805016] bnx2: eth0 DEBUG: intr_sem[0]
[  228.805023] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  228.805029] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  228.805033] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  233.805014] bnx2: eth0 DEBUG: intr_sem[0]
[  233.805019] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  233.805024] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  233.805028] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  238.805013] bnx2: eth0 DEBUG: intr_sem[0]
[  238.805019] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  238.805025] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  238.805029] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  243.805015] bnx2: eth0 DEBUG: intr_sem[0]
[  243.805021] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  243.805027] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  243.805031] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  248.805014] bnx2: eth0 DEBUG: intr_sem[0]
[  248.805019] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  248.805025] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  248.805028] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  253.805015] bnx2: eth0 DEBUG: intr_sem[0]
[  253.805021] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  253.805027] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  253.805031] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  258.805016] bnx2: eth0 DEBUG: intr_sem[0]
[  258.805022] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  258.805027] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  258.805031] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  263.805013] bnx2: eth0 DEBUG: intr_sem[0]
[  263.805018] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  263.805023] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  263.805027] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  268.805014] bnx2: eth0 DEBUG: intr_sem[0]
[  268.805019] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  268.805025] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  268.805028] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  273.805015] bnx2: eth0 DEBUG: intr_sem[0]
[  273.805022] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  273.805028] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  273.805032] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  278.805012] bnx2: eth0 DEBUG: intr_sem[0]
[  278.805017] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  278.805023] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  278.805026] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  283.805012] bnx2: eth0 DEBUG: intr_sem[0]
[  283.805016] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  283.805022] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  283.805025] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  288.805015] bnx2: eth0 DEBUG: intr_sem[0]
[  288.805022] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  288.805028] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  288.805031] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  293.805011] bnx2: eth0 DEBUG: intr_sem[0]
[  293.805016] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  293.805022] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  293.805026] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  298.805015] bnx2: eth0 DEBUG: intr_sem[0]
[  298.805021] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  298.805027] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  298.805030] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  303.805013] bnx2: eth0 DEBUG: intr_sem[0]
[  303.805020] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  303.805026] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  303.805030] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  308.805013] bnx2: eth0 DEBUG: intr_sem[0]
[  308.805018] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  308.805023] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  308.805027] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[  313.805011] bnx2: eth0 DEBUG: intr_sem[0]
[  313.805016] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[  313.805022] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[  313.805025] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
