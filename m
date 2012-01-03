From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: e1000e interface hang on 82574L
Date: Tue, 3 Jan 2012 00:02:06 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B626017762@ORSMSX102.amr.corp.intel.com>
References: <4EFA4024.5000909@bootc.net>
 <FCF3184D-CE4F-471C-B66C-0F671795FD3C@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Chris Boot <bootc@bootc.net>, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7390 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753468Ab2ACACJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 19:02:09 -0500
In-Reply-To: <FCF3184D-CE4F-471C-B66C-0F671795FD3C@bootc.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Chris Boot
>Sent: Saturday, December 31, 2011 1:32 AM
>To: netdev; lkml; e1000-devel@lists.sourceforge.net
>Subject: Re: e1000e interface hang on 82574L
>
>On 27 Dec 2011, at 22:01, Chris Boot wrote:
>
>> Hi folks,
>>
>> Another networking issue I've run into, this time with e1000e (Intel
>Corporation 82574L Gigabit). My new VM cluster appears to drop a NIC -
>the port stops responding within Linux and shows the link as being down
>with ethtool. My ISP says 'Ports running Half Duplex or reduced speed'
>on the port.
>>
>> When the port stops working I see this in dmesg:
>>
>> [35481.659629] ------------[ cut here ]------------
>> [35481.667837] WARNING: at net/sched/sch_generic.c:255
>dev_watchdog+0xe9/0x148()
>> [35481.676370] Hardware name: X9SCL/X9SCM
>> [35481.684793] NETDEV WATCHDOG: eth2 (e1000e): transmit queue 0 timed
>out
>> [35481.684795] Modules linked in: hmac sha256_generic dlm configfs
>ebtable_nat ebtables acpi_cpufreq mperf cpufreq_stats
>cpufreq_conservative cpufreq_userspace cpufreq_powersave microcode
>xt_NOTRACK ip_set_hash_net act_police cls_basic cls_flow cls_fw cls_u32
>sch_tbf sch_prio sch_htb sch_hfsc sch_ingress sch_sfq xt_connlimit
>xt_realm xt_addrtype ip_set_hash_ip iptable_raw xt_comment xt_recent
>ipt_ULOG ipt_REJECT ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN
>ipt_ecn ipt_CLUSTERIP ipt_ah nf_nat_tftp nf_nat_snmp_basic
>nf_conntrack_snmp nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc
>nf_nat_h323 nf_nat_ftp ip6_queue nf_nat_amanda xt_set ip_set
>nf_conntrack_tftp nf_conntrack_sip nf_conntrack_sane
>nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>nf_conntrack_broadcast nf_conntrack_irc nf_conntrack_h323
>nf_conntrack_ftp ts_kmp nf_conntrack_amanda xt_TPROXY xt_NFLOG
>nfnetlink_log nf_tproxy_core xt_time xt_TCPMSS xt_tcpmss xt_sctp
>xt_policy xt_pkttype xt_physdev xt_owner xt_NFQUEUE xt_multiport xt_mark
>xt_mac xt_limit xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP
>xt_dscp xt_dccp xt_connmark xt_CLASSIFY xt_AUDIT ip6t_LOG ip6t_REJECT
>nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack ip6table_raw ipt_LOG
>xt_tcpudp ip6table_mangle xt_state iptable_nat nf_nat nf_conntrack_ipv4
>nf_defrag_ipv4 nf_conntrack iptable_mangle nfnetlink iptable_filter
>ip_tables ip6table_filter ip6_tables x_tables bridge stp bonding
>w83627ehf hwmon_vid coretemp sha1_ssse3 sha1_generic crc32c_intel
>aesni_intel cryptd aes_x86_64 aes_generic ipmi_poweroff ipmi_devintf
>ipmi_si ipmi_msghandler vhost_net macvtap macvlan tun drbd lru_cache cn
>loop kvm_intel kvm snd_pcm snd_timer snd iTCO_wdt soundcore psmouse
>snd_page_alloc i2c_i801 i2c_core cdc_acm iTCO_vendor_support joydev
>evdev serio_raw processor button pcspkr thermal_sys ext4 mbcache jbd2
>crc16 dm_mod raid1 md_mod sd_mod crc_t10dif usb_storage uas usbhid hid
>ahci libahci libata igb ehci_hcd scsi_mod usbcore e1000e dca usb_common
>[last unloaded: scsi_wait_scan]
>> [35481.685740] Pid: 0, comm: swapper/4 Not tainted 3.2.0-rc6+ #4
>> [35481.685744] Call Trace:
>> [35481.685746]  <IRQ>  [<ffffffff810467ed>] ?
>warn_slowpath_common+0x78/0x8c
>> [35481.685849]  [<ffffffff81046899>] ? warn_slowpath_fmt+0x45/0x4a
>> [35481.685875]  [<ffffffff810aeaa0>] ?
>perf_event_task_tick+0x166/0x1ab
>> [35481.686018]  [<ffffffff81294219>] ? netif_tx_lock+0x40/0x72
>> [35481.686090]  [<ffffffff8129437a>] ? dev_watchdog+0xe9/0x148
>> [35481.686136]  [<ffffffff81051e58>] ? run_timer_softirq+0x19a/0x261
>> [35481.686176]  [<ffffffff81294291>] ? netif_tx_unlock+0x46/0x46
>> [35481.686215]  [<ffffffff810659bb>] ? timekeeping_get_ns+0xd/0x2a
>> [35481.686286]  [<ffffffff8104bdd4>] ? __do_softirq+0xb9/0x177
>> [35481.686365]  [<ffffffff81341d6c>] ? call_softirq+0x1c/0x30
>> [35481.686530]  [<ffffffff8100f841>] ? do_softirq+0x3c/0x7b
>> [35481.686580]  [<ffffffff8104c03c>] ? irq_exit+0x3c/0x9a
>> [35481.686742]  [<ffffffff81023e58>] ?
>smp_apic_timer_interrupt+0x74/0x82
>> [35481.686820]  [<ffffffff813405de>] ? apic_timer_interrupt+0x6e/0x80
>> [35481.686826]  <EOI>  [<ffffffff811ddf49>] ? intel_idle+0xea/0x119
>> [35481.686991]  [<ffffffff811ddf28>] ? intel_idle+0xc9/0x119
>> [35481.687051]  [<ffffffff8125dce3>] ? cpuidle_idle_call+0xec/0x179
>> [35481.687089]  [<ffffffff8100d255>] ? cpu_idle+0xa1/0xe8
>> [35481.687143]  [<ffffffff810706ee>] ? arch_local_irq_restore+0x2/0x8
>> [35481.687189]  [<ffffffff8132d191>] ? start_secondary+0x1d5/0x1db
>> [35481.687234] ---[ end trace 01e9907674757948 ]---
>> [35481.687817] e1000e 0000:05:00.0: eth2: Reset adapter
>>
>> To try to regain connectivity I bring down the bond and the interface
>(eth2), then unload e1000e. Upon loading the module again:
>>
>> [36021.888962] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
>> [36021.900258] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
>> [36021.911446] e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -
>> IRQ 20
>> [36021.923204] e1000e 0000:00:19.0: setting latency timer to 64
>> [36021.923372] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
>> [36022.202737] e1000e 0000:00:19.0: eth2: (PCI Express:2.5GT/s:Width
>x1) 00:25:90:56:ac:75
>> [36022.214480] e1000e 0000:00:19.0: eth3: Intel(R) PRO/1000 Network
>Connection
>> [36022.227506] e1000e 0000:00:19.0: eth3: MAC: 10, PHY: 11, PBA No:
>FFFFFF-0FF
>> [36022.239789] e1000e 0000:05:00.0: Disabling ASPM L0s
>> [36022.239805] e1000e 0000:05:00.0: enabling device (0000 -> 0002)
>> [36022.239829] e1000e 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -
>> IRQ 16
>> [36022.239921] e1000e 0000:05:00.0: setting latency timer to 64
>> [36022.240963] e1000e 0000:05:00.0: irq 64 for MSI/MSI-X
>> [36022.240995] e1000e 0000:05:00.0: irq 65 for MSI/MSI-X
>> [36022.241028] e1000e 0000:05:00.0: irq 66 for MSI/MSI-X
>> [36022.241596] e1000e 0000:05:00.0: PCI INT A disabled
>> [36022.241606] e1000e: probe of 0000:05:00.0 failed with error -2
>> [36022.304706] udevd[3634]: renamed network interface eth2 to eth3
>>
>> I then don't get an eth2 interface. Only a reboot brings the interface
>back. This has happened twice so far on this server in the past week,
>both times using v3.2-rc7-3-g4962516.
>>
>> lspci -vnn shows:
>>
>> 05:00.0 Ethernet controller [0200]: Intel Corporation 82574L Gigabit
>Network Connection [8086:10d3]
>>        Subsystem: Super Micro Computer Inc Device [15d9:0000]
>>        Flags: bus master, fast devsel, latency 0, IRQ 16
>>        Memory at fbd00000 (32-bit, non-prefetchable) [size=128K]
>>        I/O ports at e000 [size=32]
>>        Memory at fbd20000 (32-bit, non-prefetchable) [size=16K]
>>        Capabilities: [c8] Power Management version 2
>>        Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
>>        Capabilities: [e0] Express Endpoint, MSI 00
>>        Capabilities: [a0] MSI-X: Enable+ Count=5 Masked-
>>        Capabilities: [100] Advanced Error Reporting
>>        Capabilities: [140] Device Serial Number 00-25-90-ff-ff-56-ac-
>74
>>        Kernel driver in use: e1000e
>
>I've just had this happen on my other (identical) server with a nearly
>identical trace. Is there anything I can do do avoid this at all or at
>least help narrow down the problem?
>
>Cheers,
>Chris
>
>--
>Chris Boot
>bootc@bootc.net
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hello, 

Sorry for the delay in responding.  We have seen some hang issues using MSI-X on 82574 parts.  Can you try reloading the driver the IntMode module parameter.  IntMode=1 (you'll need a setting for each device in the system so two adapters would be IntMode=1,1)  See if that changes the symptom you are seeing with this part.  That setting will make sure the adapter uses MSI interrupts instead of MSI-X.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
