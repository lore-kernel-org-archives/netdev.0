From: =?UTF-8?B?RXJlbiBUw7xya2F5?= <erent@skyatlas.com>
Subject: PROBLEM: Bnx2x Checksum/Length Error Over GRE Tunnel
Date: Tue, 03 Feb 2015 20:05:50 +0200
Message-ID: <54D10DFE.1070604@skyatlas.com>
References: <54D0A345.2030108@skyatlas.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000502040907060804010505"
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfw.csoftintl.com ([209.11.253.18]:36034 "EHLO
	fmvm01.lax10.vpls.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756096AbbBCSVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 13:21:00 -0500
Received: from mta-01.lax7.cloudmail.krypt.com (smtpcloudmail.krypt.com [74.222.174.74])
	by fmvm01.lax10.vpls.net  with ESMTP id t13I5shP023518-t13I5shQ023518
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2015 10:05:54 -0800
Received: from localhost (localhost [127.0.0.1])
	by mta-01.lax7.cloudmail.krypt.com (Postfix) with ESMTP id CAEB13606A3
	for <netdev@vger.kernel.org>; Tue,  3 Feb 2015 10:05:54 -0800 (PST)
Received: from mta-01.lax7.cloudmail.krypt.com ([127.0.0.1])
	by localhost (mta-01.lax7.cloudmail.krypt.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EcZOC13z8kGN for <netdev@vger.kernel.org>;
	Tue,  3 Feb 2015 10:05:54 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
	by mta-01.lax7.cloudmail.krypt.com (Postfix) with ESMTP id AC5653606A6
	for <netdev@vger.kernel.org>; Tue,  3 Feb 2015 10:05:54 -0800 (PST)
Received: from mta-01.lax7.cloudmail.krypt.com ([127.0.0.1])
	by localhost (mta-01.lax7.cloudmail.krypt.com [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id jbAxpvMfr_NI for <netdev@vger.kernel.org>;
	Tue,  3 Feb 2015 10:05:54 -0800 (PST)
Received: from [10.92.0.147] (unknown [78.188.181.18])
	by mta-01.lax7.cloudmail.krypt.com (Postfix) with ESMTPSA id EF69A3606A3
	for <netdev@vger.kernel.org>; Tue,  3 Feb 2015 10:05:53 -0800 (PST)
In-Reply-To: <54D0A345.2030108@skyatlas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000502040907060804010505
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hello,

I am having incorrect checksum and length calculation error when using
GRE tunnel and this leads to unstable/unreliable connections where even
simple nc connection cannot be made correctly due to a lot of TCP
retransmissions. The reported iperf output becomes 23Kbit/s.

When I disable tx checksumming with "ethtool -K eth0 tx off", the
problem seems to be solved but then I lose tcp segmentation offloading
support, without which adds an additional overhead on 10Gbit network
interface. With tx off, I get 4 to 7Gbit/s with parallel 40 connections
using iperf.

In tcpdump output (tcpdump -i em1 proto gre) when tx checksumming is
enabled, I see "checksum error" in every packet + "IP truncated-ip -
63631 bytes missing!" messages, and a lot of TCP
retransmissions. When tx is off, checksums are correct but I get 4-7Gbit
output. With GSO generalization code in [0] it is reported that
9.3Gbit/s is possible over GRE tunnel but I'm nowhere near these results.

Pcap file is attached when tx is on. I tried to contact the original
maintainers (broadcom) but I thought it would help to send it to netdev
mailing list as well.

Thank you for your time.

- Eren

[0] http://thread.gmane.org/gmane.linux.network/332194

Additional Information
======================
em1 is a 10G interface. Jumbo frames are enabled and MTU is set to 9000.
My GRE tunnel has 1500 MTU, and it is tunneled using em1.

Host OS: Ubuntu 14.04
Kernel: 3.18.0 (compiled from ubuntu-vivid repository)
Physical host: HP ProLiant BL460c G6
NIC: Broadcom Corporation NetXtreme II BCM57711E 10-Gigabit PCIe
Ethtool info:

driver: bnx2x
version: 1.710.51-0
firmware-version: bc 6.2.28 phy baa0.105
bus-info: 0000:02:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes


ethtook -k em1:
Features for em1:
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
        tx-tcp-ecn-segmentation: on
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on [fixed]
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: on
tx-ipip-segmentation: on
tx-sit-segmentation: on
tx-udp_tnl-segmentation: on
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: on [fixed]



./ver-linux:
Linux compute1vx 3.18.0-11-generic #12-Ubuntu SMP Wed Jan 28 18:16:44
EET 2015 x86_64 x86_64 x86_64 GNU/Linux

Gnu C                  4.8
Gnu make               3.81
binutils               2.24
util-linux             2.20.1
mount                  support
module-init-tools      15
e2fsprogs              1.42.9
PPP                    2.4.5
Linux C Library        2.19
Dynamic linker (ldd)   2.19
Procps                 3.3.9
Net-tools              1.60
Kbd                    1.15.5
Sh-utils               8.21
wireless-tools         30
Modules Loaded         ip_gre ip_tunnel vhost_net vhost macvtap macvlan
nf_conntrack_ipv6 nf_defrag_ipv6 xt_mac xt_physdev br_netfilter xt_set
iptable_raw ip_set_hash_ip ip_set nfnetlink veth ipt_MASQUERADE
nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4
nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT nf_reject_ipv4
xt_CHECKSUM iptable_mangle xt_tcpudp bridge stp llc ip6table_filter
ip6_tables iptable_filter ip_tables ebtable_nat ebtables x_tables nbd
openvswitch geneve gre ib_iser rdma_cm iw_cm ib_cm ib_sa ib_mad ib_core
ib_addr iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi gpio_ich
dm_multipath scsi_dh radeon intel_powerclamp coretemp kvm_intel kvm
crct10dif_pclmul crc32_pclmul ttm ghash_clmulni_intel drm_kms_helper
aesni_intel aes_x86_64 drm lrw gf128mul glue_helper ablk_helper
i7core_edac ipmi_si edac_core lpc_ich 8250_fintek cryptd hpilo hpwdt
i2c_algo_bit serio_raw ipmi_msghandler acpi_power_meter mac_hid lp
parport mlx4_en vxlan ip6_udp_tunnel udp_tunnel hid_generic bnx2x
psmouse usbhid ptp pps_core hid mdio mlx4_core hpsa libcrc32c


/proc/cpuinfo:
processor       : 23
vendor_id       : GenuineIntel
cpu family      : 6
model           : 44
model name      : Intel(R) Xeon(R) CPU           L5640  @ 2.27GHz
stepping        : 2
microcode       : 0x1a
cpu MHz         : 1600.000
cache size      : 12288 KB
physical id     : 0
siblings        : 12
core id         : 1
cpu cores       : 6
apicid          : 3
initial apicid  : 3
fpu             : yes
fpu_exception   : yes
cpuid level     : 11
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good
nopl xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor
ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid dca sse4_1 sse4_2
popcnt aes lahf_lm ida arat epb dtherm tpr_shadow vnmi flexpriority ept vpid
bugs            :
bogomips        : 4533.56
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management:




/proc/modules:
ip_gre 18295 0 - Live 0xffffffffc05e7000
ip_tunnel 24254 1 ip_gre, Live 0xffffffffc05f3000
vhost_net 18104 1 - Live 0xffffffffc05ed000
vhost 29047 1 vhost_net, Live 0xffffffffc05de000
macvtap 18255 1 vhost_net, Live 0xffffffffc05d8000
macvlan 23656 1 macvtap, Live 0xffffffffc05cd000
nf_conntrack_ipv6 18894 4 - Live 0xffffffffc05c3000
nf_defrag_ipv6 34841 1 nf_conntrack_ipv6, Live 0xffffffffc05b5000
xt_mac 12492 1 - Live 0xffffffffc05b0000
xt_physdev 12587 10 - Live 0xffffffffc05ab000
br_netfilter 17878 1 xt_physdev, Live 0xffffffffc05a5000
xt_set 13314 1 - Live 0xffffffffc0596000
iptable_raw 12678 1 - Live 0xffffffffc0585000
ip_set_hash_ip 31394 1 - Live 0xffffffffc059c000
ip_set 41059 2 xt_set,ip_set_hash_ip, Live 0xffffffffc058a000
nfnetlink 14725 1 ip_set, Live 0xffffffffc0580000
veth 13376 0 - Live 0xffffffffc057b000
ipt_MASQUERADE 12678 3 - Live 0xffffffffc0576000
nf_nat_masquerade_ipv4 13412 1 ipt_MASQUERADE, Live 0xffffffffc0571000
iptable_nat 12875 1 - Live 0xffffffffc0567000
nf_nat_ipv4 14115 1 iptable_nat, Live 0xffffffffc056c000
nf_nat 22050 2 nf_nat_masquerade_ipv4,nf_nat_ipv4, Live 0xffffffffc0560000
nf_conntrack_ipv4 14806 6 - Live 0xffffffffc054f000
nf_defrag_ipv4 12758 1 nf_conntrack_ipv4, Live 0xffffffffc054a000
xt_conntrack 12760 9 - Live 0xffffffffc0557000
nf_conntrack 105074 6
nf_conntrack_ipv6,nf_nat_masquerade_ipv4,nf_nat_ipv4,nf_nat,nf_conntrack_ipv4,xt_conntrack,
Live 0xffffffffc052f000
ipt_REJECT 12541 2 - Live 0xffffffffc052a000
nf_reject_ipv4 13183 1 ipt_REJECT, Live 0xffffffffc0525000
xt_CHECKSUM 12549 1 - Live 0xffffffffc051b000
iptable_mangle 12695 1 - Live 0xffffffffc0516000
xt_tcpudp 12884 11 - Live 0xffffffffc0520000
bridge 108463 1 br_netfilter, Live 0xffffffffc04fa000
stp 12976 1 bridge, Live 0xffffffffc04f5000
llc 14396 2 bridge,stp, Live 0xffffffffc045d000
ip6table_filter 12815 1 - Live 0xffffffffc0430000
ip6_tables 27026 1 ip6table_filter, Live 0xffffffffc04e9000
iptable_filter 12810 1 - Live 0xffffffffc0334000
ip_tables 27240 4 iptable_raw,iptable_nat,iptable_mangle,iptable_filter,
Live 0xffffffffc044d000
ebtable_nat 12807 0 - Live 0xffffffffc024c000
ebtables 35009 1 ebtable_nat, Live 0xffffffffc0426000
x_tables 34059 15
xt_mac,xt_physdev,xt_set,iptable_raw,ipt_MASQUERADE,xt_conntrack,ipt_REJECT,xt_CHECKSUM,iptable_mangle,xt_tcpudp,ip6table_filter,ip6_tables,iptable_filter,ip_tables,ebtables,
Live 0xffffffffc0306000
nbd 17642 0 - Live 0xffffffffc0252000
openvswitch 79201 0 - Live 0xffffffffc04d4000
geneve 13338 1 openvswitch, Live 0xffffffffc0247000


             [20/1876]
gre 13796 2 ip_gre,openvswitch, Live 0xffffffffc0293000
ib_iser 51896 0 - Live 0xffffffffc0418000
rdma_cm 43465 1 ib_iser, Live 0xffffffffc040c000
iw_cm 36940 1 rdma_cm, Live 0xffffffffc035c000
ib_cm 42689 1 rdma_cm, Live 0xffffffffc0350000
ib_sa 33950 2 rdma_cm,ib_cm, Live 0xffffffffc032a000
ib_mad 47486 2 ib_cm,ib_sa, Live 0xffffffffc02df000
ib_core 88311 6 ib_iser,rdma_cm,iw_cm,ib_cm,ib_sa,ib_mad, Live
0xffffffffc0313000
ib_addr 18923 2 rdma_cm,ib_core, Live 0xffffffffc02d9000
iscsi_tcp 18333 0 - Live 0xffffffffc0280000
libiscsi_tcp 25146 1 iscsi_tcp, Live 0xffffffffc02a4000
libiscsi 57233 3 ib_iser,iscsi_tcp,libiscsi_tcp, Live 0xffffffffc02f3000
scsi_transport_iscsi 99909 4 ib_iser,iscsi_tcp,libiscsi, Live
0xffffffffc02bf000
gpio_ich 13586 0 - Live 0xffffffffc036a000
dm_multipath 22843 0 - Live 0xffffffffc02ec000
scsi_dh 14882 1 dm_multipath, Live 0xffffffffc028e000
radeon 1552388 1 - Live 0xffffffffc067b000
intel_powerclamp 18823 0 - Live 0xffffffffc0675000
coretemp 13441 0 - Live 0xffffffffc0173000
kvm_intel 148362 4 - Live 0xffffffffc0a54000
kvm 462696 1 kvm_intel, Live 0xffffffffc0462000
crct10dif_pclmul 14307 0 - Live 0xffffffffc0178000
crc32_pclmul 13133 0 - Live 0xffffffffc0458000
ttm 85166 1 radeon, Live 0xffffffffc0437000
ghash_clmulni_intel 13230 0 - Live 0xffffffffc011a000
drm_kms_helper 98431 1 radeon, Live 0xffffffffc03be000
aesni_intel 169590 0 - Live 0xffffffffc03e1000
aes_x86_64 17131 1 aesni_intel, Live 0xffffffffc03db000
drm 317626 4 radeon,ttm,drm_kms_helper, Live 0xffffffffc036f000
lrw 13286 1 aesni_intel, Live 0xffffffffc02ba000
gf128mul 14951 1 lrw, Live 0xffffffffc033b000
glue_helper 13990 1 aesni_intel, Live 0xffffffffc0289000
ablk_helper 13597 1 aesni_intel, Live 0xffffffffc02b5000
i7core_edac 24139 0 - Live 0xffffffffc029d000
ipmi_si 53386 0 - Live 0xffffffffc0341000
edac_core 51908 2 i7core_edac, Live 0xffffffffc025b000
lpc_ich 21093 0 - Live 0xffffffffc0269000
8250_fintek 12925 0 - Live 0xffffffffc011f000
cryptd 20359 3 ghash_clmulni_intel,aesni_intel,ablk_helper, Live
0xffffffffc02af000
hpilo 17394 0 - Live 0xffffffffc027a000
hpwdt 14257 0 - Live 0xffffffffc0275000
i2c_algo_bit 13413 1 radeon, Live 0xffffffffc0270000
serio_raw 13483 0 - Live 0xffffffffc0298000
ipmi_msghandler 45318 1 ipmi_si, Live 0xffffffffc0147000
acpi_power_meter 18075 0 - Live 0xffffffffc00f0000
mac_hid 13227 0 - Live 0xffffffffc0081000
lp 17759 0 - Live 0xffffffffc0087000
parport 42348 1 lp, Live 0xffffffffc0075000
mlx4_en 90408 0 - Live 0xffffffffc022f000
vxlan 37128 2 openvswitch,mlx4_en, Live 0xffffffffc013c000
ip6_udp_tunnel 12755 2 geneve,vxlan, Live 0xffffffffc00e8000
udp_tunnel 13187 2 geneve,vxlan, Live 0xffffffffc00a5000
hid_generic 12559 0 - Live 0xffffffffc00f9000
bnx2x 722154 0 - Live 0xffffffffc017d000
psmouse 111586 0 - Live 0xffffffffc0156000
usbhid 52657 0 - Live 0xffffffffc012e000
ptp 19395 2 mlx4_en,bnx2x, Live 0xffffffffc0124000
pps_core 19382 1 ptp, Live 0xffffffffc006f000
hid 110426 2 hid_generic,usbhid, Live 0xffffffffc00fe000
mdio 13561 1 bnx2x, Live 0xffffffffc006a000
mlx4_core 245682 1 mlx4_en, Live 0xffffffffc00ab000
hpsa 81092 2 - Live 0xffffffffc0090000
libcrc32c 12644 2 openvswitch,bnx2x, Live 0xffffffffc0065000
-- 
System Administrator
https://skyatlas.com/




--------------000502040907060804010505
Content-Type: application/vnd.tcpdump.pcap;
 name="bnx2x-tx-on-netcat-connection.pcap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="bnx2x-tx-on-netcat-connection.pcap"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAA8KHQVKqODgBiAAAAYgAAANjThWbjWAAmVR+doAgA
RQAAVGGcQAD/LwR0ChQAoQoUAKIAAAgARQACKm0jQABABrlaCh4AAgoeAAGOSCcPSrkeygAA
AACgAnIQFG0AAAIEBbQEAggKAQJz6QAAAAABAwMH8aHQVIGLDgBiAAAAYgAAANjThWbjWAAm
VR+doAgARQAAVGHmQAD/LwQqChQAoQoUAKIAAAgARQABem0kQABABrlZCh4AAgoeAAGOSCcP
SrkeygAAAACgAnIQFG0AAAIEBbQEAggKAQJ04wAAAAABAwMH86HQVBabDgBiAAAAYgAAANjT
hWbjWAAmVR+doAgARQAAVGNHQAD/LwLJChQAoQoUAKIAAAgARQAA5m0lQABABrlYCh4AAgoe
AAGOSCcPSrkeygAAAACgAnIQFG0AAAIEBbQEAggKAQJ22AAAAAABAwMH96HQVGm6DgBiAAAA
YgAAANjThWbjWAAmVR+doAgARQAAVGYJQAD/LwAHChQAoQoUAKIAAAgARQD/vW0mQABABrlX
Ch4AAgoeAAGOSCcPSrkeygAAAACgAnIQFG0AAAIEBbQEAggKAQJ6wgAAAAABAwMH/6HQVDQY
DwBiAAAAYgAAANjThWbjWAAmVR+doAgARQAAVGkDQAD/L/0MChQAoQoUAKIAAAgARQD64W0n
QABABrlWCh4AAgoeAAGOSCcPSrkeygAAAACgAnIQFG0AAAIEBbQEAggKAQKCmAAAAAABAwMH
EKLQVN9SAABiAAAAYgAAANjThWbjWAAmVR+doAgARQAAVHTiQAD/L/EtChQAoQoUAKIAAAgA
RQD3GG0oQABABrlVCh4AAgoeAAGOSCcPSrkeygAAAACgAnIQFG0AAAIEBbQEAggKAQKSQAAA
AAABAwMHMKLQVN5MAQBiAAAAYgAAANjThWbjWAAmVR+doAgARQAAVHobQAD/L+v0ChQAoQoU
AKIAAAgARQDdAW0pQABABrlUCh4AAgoeAAGOSCcPSrkeygAAAACgAnIQFG0AAAIEBbQEAggK
AQKxkAAAAAABAwMH
--------------000502040907060804010505--
