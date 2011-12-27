From: Dave Taht <dave.taht@gmail.com>
Subject: Re: e1000e interface hang on 82574L
Date: Tue, 27 Dec 2011 23:33:07 +0100
Message-ID: <CAA93jw7EKP7zDeHbPUMnqY4iW1dkmgBa_OOoB570tq5G7aKMfQ@mail.gmail.com>
References: <4EFA4024.5000909@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Chris Boot <bootc@bootc.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EFA4024.5000909@bootc.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 27, 2011 at 11:01 PM, Chris Boot <bootc@bootc.net> wrote:
> Hi folks,
>
> Another networking issue I've run into, this time with e1000e (Intel
> Corporation 82574L Gigabit). My new VM cluster appears to drop a NIC =
- the
> port stops responding within Linux and shows the link as being down w=
ith
> ethtool. My ISP says 'Ports running Half Duplex or reduced speed' on =
the
> port.
>
> When the port stops working I see this in dmesg:
>
> [35481.659629] ------------[ cut here ]------------
> [35481.667837] WARNING: at net/sched/sch_generic.c:255
> dev_watchdog+0xe9/0x148()
> [35481.676370] Hardware name: X9SCL/X9SCM
> [35481.684793] NETDEV WATCHDOG: eth2 (e1000e): transmit queue 0 timed=
 out
> [35481.684795] Modules linked in: hmac sha256_generic dlm configfs
> ebtable_nat ebtables acpi_cpufreq mperf cpufreq_stats cpufreq_conserv=
ative
> cpufreq_userspace cpufreq_powersave microcode xt_NOTRACK ip_set_hash_=
net
> act_police cls_basic cls_flow cls_fw cls_u32 sch_tbf sch_prio sch_htb
> sch_hfsc sch_ingress sch_sfq xt_connlimit xt_realm xt_addrtype
> ip_set_hash_ip iptable_raw xt_comment xt_recent ipt_ULOG ipt_REJECT
> ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_CLUSTERIP =
ipt_ah
> nf_nat_tftp nf_nat_snmp_basic nf_conntrack_snmp nf_nat_sip nf_nat_ppt=
p
> nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp ip6_queue nf_nat_a=
manda
> xt_set ip_set nf_conntrack_tftp nf_conntrack_sip nf_conntrack_sane
> nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
> nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
> nf_conntrack_broadcast nf_conntrack_irc nf_conntrack_h323 nf_conntrac=
k_ftp
> ts_kmp nf_conntrack_amanda xt_TPROXY xt_NFLOG nfnetlink_log nf_tproxy=
_core
> xt_time xt_TCPMSS xt_tcpmss xt_sctp xt_policy xt_pkttype xt_physdev x=
t_owner
> xt_NFQUEUE xt_multiport xt_mark xt_mac xt_limit xt_length xt_iprange
> xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp xt_connmark xt_CLASSIF=
Y
> xt_AUDIT ip6t_LOG ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_con=
ntrack
> ip6table_raw ipt_LOG xt_tcpudp ip6table_mangle xt_state iptable_nat n=
f_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack iptable_mangle nfnetlin=
k
> iptable_filter ip_tables ip6table_filter ip6_tables x_tables bridge s=
tp
> bonding w83627ehf hwmon_vid coretemp sha1_ssse3 sha1_generic crc32c_i=
ntel
> aesni_intel cryptd aes_x86_64 aes_generic ipmi_poweroff ipmi_devintf =
ipmi_si
> ipmi_msghandler vhost_net macvtap macvlan tun drbd lru_cache cn loop
> kvm_intel kvm snd_pcm snd_timer snd iTCO_wdt soundcore psmouse
> snd_page_alloc i2c_i801 i2c_core cdc_acm iTCO_vendor_support joydev e=
vdev
> serio_raw processor button pcspkr thermal_sys ext4 mbcache jbd2 crc16=
 dm_mod
> raid1 md_mod sd_mod crc_t10dif usb_storage uas usbhid hid ahci libahc=
i
> libata igb ehci_hcd scsi_mod usbcore e1000e dca usb_common [last unlo=
aded:
> scsi_wait_scan]
> [35481.685740] Pid: 0, comm: swapper/4 Not tainted 3.2.0-rc6+ #4
> [35481.685744] Call Trace:
> [35481.685746] =A0<IRQ> =A0[<ffffffff810467ed>] ? warn_slowpath_commo=
n+0x78/0x8c
> [35481.685849] =A0[<ffffffff81046899>] ? warn_slowpath_fmt+0x45/0x4a
> [35481.685875] =A0[<ffffffff810aeaa0>] ? perf_event_task_tick+0x166/0=
x1ab
> [35481.686018] =A0[<ffffffff81294219>] ? netif_tx_lock+0x40/0x72
> [35481.686090] =A0[<ffffffff8129437a>] ? dev_watchdog+0xe9/0x148
> [35481.686136] =A0[<ffffffff81051e58>] ? run_timer_softirq+0x19a/0x26=
1
> [35481.686176] =A0[<ffffffff81294291>] ? netif_tx_unlock+0x46/0x46
> [35481.686215] =A0[<ffffffff810659bb>] ? timekeeping_get_ns+0xd/0x2a
> [35481.686286] =A0[<ffffffff8104bdd4>] ? __do_softirq+0xb9/0x177
> [35481.686365] =A0[<ffffffff81341d6c>] ? call_softirq+0x1c/0x30
> [35481.686530] =A0[<ffffffff8100f841>] ? do_softirq+0x3c/0x7b
> [35481.686580] =A0[<ffffffff8104c03c>] ? irq_exit+0x3c/0x9a
> [35481.686742] =A0[<ffffffff81023e58>] ? smp_apic_timer_interrupt+0x7=
4/0x82
> [35481.686820] =A0[<ffffffff813405de>] ? apic_timer_interrupt+0x6e/0x=
80
> [35481.686826] =A0<EOI> =A0[<ffffffff811ddf49>] ? intel_idle+0xea/0x1=
19
> [35481.686991] =A0[<ffffffff811ddf28>] ? intel_idle+0xc9/0x119
> [35481.687051] =A0[<ffffffff8125dce3>] ? cpuidle_idle_call+0xec/0x179
> [35481.687089] =A0[<ffffffff8100d255>] ? cpu_idle+0xa1/0xe8
> [35481.687143] =A0[<ffffffff810706ee>] ? arch_local_irq_restore+0x2/0=
x8
> [35481.687189] =A0[<ffffffff8132d191>] ? start_secondary+0x1d5/0x1db
> [35481.687234] ---[ end trace 01e9907674757948 ]---
> [35481.687817] e1000e 0000:05:00.0: eth2: Reset adapter
>
> To try to regain connectivity I bring down the bond and the interface
> (eth2), then unload e1000e. Upon loading the module again:
>
> [36021.888962] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
> [36021.900258] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
> [36021.911446] e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) =
-> IRQ
> 20
> [36021.923204] e1000e 0000:00:19.0: setting latency timer to 64
> [36021.923372] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
> [36022.202737] e1000e 0000:00:19.0: eth2: (PCI Express:2.5GT/s:Width =
x1)
> 00:25:90:56:ac:75
> [36022.214480] e1000e 0000:00:19.0: eth3: Intel(R) PRO/1000 Network
> Connection
> [36022.227506] e1000e 0000:00:19.0: eth3: MAC: 10, PHY: 11, PBA No:
> FFFFFF-0FF
> [36022.239789] e1000e 0000:05:00.0: Disabling ASPM L0s
> [36022.239805] e1000e 0000:05:00.0: enabling device (0000 -> 0002)
> [36022.239829] e1000e 0000:05:00.0: PCI INT A -> GSI 16 (level, low) =
-> IRQ
> 16
> [36022.239921] e1000e 0000:05:00.0: setting latency timer to 64
> [36022.240963] e1000e 0000:05:00.0: irq 64 for MSI/MSI-X
> [36022.240995] e1000e 0000:05:00.0: irq 65 for MSI/MSI-X
> [36022.241028] e1000e 0000:05:00.0: irq 66 for MSI/MSI-X
> [36022.241596] e1000e 0000:05:00.0: PCI INT A disabled
> [36022.241606] e1000e: probe of 0000:05:00.0 failed with error -2
> [36022.304706] udevd[3634]: renamed network interface eth2 to eth3
>
> I then don't get an eth2 interface. Only a reboot brings the interfac=
e back.
> This has happened twice so far on this server in the past week, both =
times
> using v3.2-rc7-3-g4962516.
>
> lspci -vnn shows:
>
> 05:00.0 Ethernet controller [0200]: Intel Corporation 82574L Gigabit =
Network
> Connection [8086:10d3]
> =A0 =A0 =A0 =A0Subsystem: Super Micro Computer Inc Device [15d9:0000]
> =A0 =A0 =A0 =A0Flags: bus master, fast devsel, latency 0, IRQ 16
> =A0 =A0 =A0 =A0Memory at fbd00000 (32-bit, non-prefetchable) [size=3D=
128K]
> =A0 =A0 =A0 =A0I/O ports at e000 [size=3D32]
> =A0 =A0 =A0 =A0Memory at fbd20000 (32-bit, non-prefetchable) [size=3D=
16K]
> =A0 =A0 =A0 =A0Capabilities: [c8] Power Management version 2
> =A0 =A0 =A0 =A0Capabilities: [d0] MSI: Enable- Count=3D1/1 Maskable- =
64bit+
> =A0 =A0 =A0 =A0Capabilities: [e0] Express Endpoint, MSI 00
> =A0 =A0 =A0 =A0Capabilities: [a0] MSI-X: Enable+ Count=3D5 Masked-
> =A0 =A0 =A0 =A0Capabilities: [100] Advanced Error Reporting
> =A0 =A0 =A0 =A0Capabilities: [140] Device Serial Number 00-25-90-ff-f=
f-56-ac-74
> =A0 =A0 =A0 =A0Kernel driver in use: e1000e
>
> Thanks,
> Chris
>
> --
> Chris Boot
> bootc@bootc.net

I too am experiencing problems with  the e1000e. It takes hours to happ=
en,
sometimes days, under a sustained, heavy load (10 iperfs, 1 netperf RR,=
 ping)

while :
do
for i in `seq 1 10`
do
iperf -w254k -t 60 -c MY_SERVER &
done
netperf -H MY_SERVER -t TCP_RR &
wait
sleep2
done

but eventually...
ifconfig will show the e1000e receiving packets, but none will be
transmitted. I kill off the qdisc
(tc del dev eth0 root) and sometimes it comes back (so I was assuming
it was a problem with qfq) - but
this morning I managed to get a full on kernel panic from it and
scribble it down.

This is with net-next as of c5e1fd8ccae09f574d6f978c90c2b968ee29030c -
but I have
been experiencing lockups since I started fiddling with BQL last
month. That said,
I wouldn't consider my environment terribly normal as I'm running with
no tso, no
gso,  tx rings of 64, at 100Mbit, BQL's limit at 4500 bytes, and the QF=
Q qdisc,

and I was willing to write it off
to being too early to jump on net-next until now.

The super duper new fair QFQ based shaping script I've been testing is =
at:

https://github.com/dtaht/deBloat/blob/master/src/staqfq.lua

and my scribbled down morning's panic was:

__schedule_bug
_shedule
atomic_notifier_call_chain
__cond_resched
_cond_resched
__kmalloc
[drm_ks_helper]
[drm_kms_help]
drm_crtc_helper_set_config
drm_fb_helper_restore_fb_mode
drm_fb_helper_force_kernel_mode
drm_fb_helper_panic
notifier_call_chain
atomic_notifier_call_chain
panic
oops_end
no_context
__bad_area_nosemeaphore
_do_page_Fault
? T something
qfq_deactivate_class
qfq_deactivate_class
qfq_reset_qdisc
m@cruithne:~$ more trace.txt
__schedule_bug
_shedule
atomic_notifier_call_chain
__cond_resched
_cond_resched
__kmalloc
[drm_ks_helper]
[drm_kms_help]
drm_crtc_helper_set_config
drm_fb_helper_restore_fb_mode
drm_fb_helper_force_kernel_mode
drm_fb_helper_panic
notifier_call_chain
atomic_notifier_call_chain
panic
oops_end
no_context
__bad_area_nosemeaphore
_do_page_Fault
? T something
qfq_deactivate_class
qfq_deactivate_class
qfq_reset_qdisc
qdisc_reset
dev_deactivate_queue
dev_deativate_many
qdic_graft
tc_get_qdisc
zone_statistics
rtnetlink_rcv_msg
rtnetlink_rcv
netlink_rcu_sb
rtnetlink_rcv
netlink_unicast
netlink_sendmsg
sock_sendmsg
unlock_page
__do_fault
move_addr_to_kernel
verify_iovec
__sys_sendmsg
handle_mm_fault
do_page_fault
sys_sendmsg
system_call_fastpath


--=20
Dave T=E4ht
SKYPE: davetaht
http://www.bufferbloat.net
